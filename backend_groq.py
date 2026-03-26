"""
🐱 MEOWSCAN v4.0 - BACKEND CON GEMINI 2.5 FLASH
════════════════════════════════════════════════════════════════
FastAPI + OpenCV + Gemini 2.5 Flash
Análisis: raza, peso, color, orejas, mood, salud + vómito
════════════════════════════════════════════════════════════════
"""

import cv2
import numpy as np
import base64
import time
import os
import json
import tempfile
import uuid
import random
import asyncio
import subprocess
import urllib.request
from io import BytesIO
from pathlib import Path
from typing import List, Dict, Any, Optional
from groq import Groq
import google.generativeai as genai  # solo para video

from fastapi import FastAPI, File, UploadFile, HTTPException, Request, Depends, Form
from fastapi.security import APIKeyHeader
from pydantic import BaseModel
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse, FileResponse
from PIL import Image
from collections import defaultdict
import uvicorn
import time

# ── Configuración ─────────────────────────────────────────────
HOST      = "0.0.0.0"
PORT      = 8000
GROQ_API_KEY   = os.environ.get("GROQ_API_KEY", "")
groq_client    = Groq(api_key=GROQ_API_KEY)
GEMINI_API_KEY = os.environ.get("GEMINI_API_KEY", "")
genai.configure(api_key=GEMINI_API_KEY)

# ── Seguridad ─────────────────────────────────────────────────
# API Key que la app envía en cada request
MEOWSCAN_API_KEY = os.environ.get("MEOWSCAN_API_KEY", "meowscan-secret-2024")
MAX_IMAGE_BYTES = 10 * 1024 * 1024
MAX_VIDEO_BYTES = 30 * 1024 * 1024
MAX_JSON_BODY_BYTES = 256 * 1024
PUBLIC_PATHS = {"/", "/health", "/perfil"}

# Rate limiting: max requests por IP por ventana de tiempo
_rate_store: dict = defaultdict(list)
RATE_LIMIT_REQUESTS = 60   # max 60 requests
RATE_LIMIT_WINDOW   = 60   # por minuto

api_key_header = APIKeyHeader(name="X-API-Key", auto_error=False)

def verify_api_key(key: str = Depends(api_key_header)):
    """Verifica que el request viene de la app MeowScan."""
    if key != MEOWSCAN_API_KEY:
        raise HTTPException(
            status_code=401,
            detail="Unauthorized - Invalid API Key")
    return key

def check_rate_limit(request: Request):
    """Max 60 requests/min por IP."""
    ip  = request.client.host if request.client else "unknown"
    now = time.time()
    # Clean old entries
    _rate_store[ip] = [t for t in _rate_store[ip] if now - t < RATE_LIMIT_WINDOW]
    if len(_rate_store[ip]) >= RATE_LIMIT_REQUESTS:
        raise HTTPException(
            status_code=429,
            detail="Too many requests. Please slow down.")
    _rate_store[ip].append(now)

def _is_public_path(path: str) -> bool:
    return path in PUBLIC_PATHS

async def _read_upload_bytes(file: UploadFile, max_bytes: int, label: str) -> bytes:
    """Lee archivos con límite duro de tamaño para evitar abuso de memoria."""
    contenido = await file.read(max_bytes + 1)
    if len(contenido) > max_bytes:
        raise HTTPException(
            status_code=413,
            detail=f"{label} too large. Limit is {max_bytes // (1024 * 1024)} MB."
        )
    if not contenido:
        raise HTTPException(status_code=400, detail=f"{label} is empty.")
    return contenido

def _client_error(detail: str = "Invalid request.") -> HTTPException:
    return HTTPException(status_code=400, detail=detail)

def _server_error() -> HTTPException:
    return HTTPException(status_code=500, detail="Internal server error.")

def _parse_content_length(value: Optional[str]) -> Optional[int]:
    if value is None:
        return None
    try:
        return int(value)
    except (TypeError, ValueError):
        raise HTTPException(status_code=400, detail="Invalid Content-Length header.")

# ── Cascades Haar ─────────────────────────────────────────────
CASCADES_URL = {
    "haarcascade_frontalcatface.xml":
        "https://raw.githubusercontent.com/opencv/opencv/master/data/haarcascades/haarcascade_frontalcatface.xml",
    "haarcascade_frontalcatface_extended.xml":
        "https://raw.githubusercontent.com/opencv/opencv/master/data/haarcascades/haarcascade_frontalcatface_extended.xml",
}

# ════════════════════════════════════════════════════════════════
#  PROMPT MASCOTA — con énfasis en peso real y alertas
# ════════════════════════════════════════════════════════════════
PROMPT_ES = """Eres un veterinario experto. Analiza esta imagen de mascota y responde SOLO con JSON válido, sin texto extra ni markdown.

Formato exacto requerido:
{"mascota_detectada":true,"tipo":"gato","raza":{"nombre":"nombre raza","confianza":85,"descripcion":"desc breve"},"peso":{"estimado_kg":4.2,"estimado_lb":9.3,"rango_min_kg":3.5,"rango_max_kg":5.0,"confianza":"Media"},"color":{"color_principal":"naranja","colores_secundarios":["blanco"],"patron":"Atigrado","hex_aproximado":"#FF8C42"},"estado_corporal":{"bcs":5,"estado":"Peso ideal","emoji":"🐱","color_hex":"#52C97A","salud_pct":80,"consejo":"consejo nutricional","alerta_peso":false,"mensaje_alerta":null},"orejas":{"posicion":"Erguidas","estado":"Alerta","significado":"descripcion","alerta":false,"alerta_veterinario":false,"mensaje_veterinario":null},"cola":{"posicion":"Alta","significado":"descripcion","visible":true},"gesto":{"nombre":"Curioso","emocion":"Curioso","descripcion":"descripcion","nivel_estres":2,"cola_posicion":null},"salud_visual":{"ojos":"descripcion ojos","pelaje":"descripcion pelaje","observaciones":"observaciones"}}

Si no hay mascota: {"mascota_detectada":false}"""


# ════════════════════════════════════════════════════════════════
#  PROMPT VÓMITO — veterinario experto
# ════════════════════════════════════════════════════════════════
PROMPT_VOMITO = """Actúa como un veterinario con 30 años de experiencia en medicina de pequeños animales, experto en diagnóstico clínico de gatos y perros. Tu tarea es analizar la imagen del vómito que te muestro y determinar la posible causa según el color y características observadas.

Analiza la imagen y responde ÚNICAMENTE con un objeto JSON válido, sin texto adicional, sin markdown, sin explicaciones.

Para el análisis considera estos colores y sus significados:
- Amarillo/Verde: bilis, estómago vacío, problemas hepáticos
- Marrón: sangre digerida, obstrucción intestinal, coprofagia
- Rojo/Sangre fresca: úlceras, trauma esofágico, emergencia
- Negro: sangre muy digerida, emergencia grave
- Espumoso/Blanco: estómago vacío, náuseas, problemas respiratorios
- Transparente/Agua: reflujo, estómago vacío, ingestión de agua
- Con comida sin digerir: comer muy rápido, intolerancia alimentaria
- Con parásitos visibles: infestación parasitaria, emergencia

El JSON debe tener exactamente esta estructura:
{
  "vomito_detectado": true o false,
  "color_identificado": "color principal del vómito",
  "tipo": "descripción del tipo de vómito",
  "urgencia": "Baja, Media, Alta o Emergencia",
  "urgencia_color": "#52C97A para baja, #FF9800 para media, #F44336 para alta, #8B0000 para emergencia",
  "alerta_veterinario": true si urgencia es Alta o Emergencia, sino false,
  "causas_probables": [
    "causa 1",
    "causa 2",
    "causa 3"
  ],
  "en_gatos": "explicación específica para gatos",
  "en_perros": "explicación específica para perros",
  "recomendacion": "recomendación práctica e inmediata para el dueño",
  "signos_adicionales": "signos adicionales que ayudan a determinar gravedad",
  "mensaje_urgencia": "mensaje claro y directo sobre qué hacer ahora mismo"
}

Si la imagen no muestra vómito de mascota, devuelve: {"vomito_detectado": false}
Responde SOLO el JSON, nada más."""



# ════════════════════════════════════════════════════════════════
#  PROMPT RESPIRACIÓN
# ════════════════════════════════════════════════════════════════
PROMPT_RESPIRACION = """Eres un veterinario experto con 30 años de experiencia en medicina felina y canina.
Analiza esta imagen/frame de video del pecho o cuerpo de la mascota y evalúa su respiración.

PARÁMETROS NORMALES:
- Gatos: 20-30 respiraciones por minuto en reposo
- Perros: 15-30 respiraciones por minuto en reposo
- Más de 40: taquipnea (requiere atención)
- Más de 60: emergencia respiratoria

Responde ÚNICAMENTE con JSON válido, sin texto adicional:
{
  "mascota_detectada": true o false,
  "respiraciones_por_minuto": número estimado,
  "patron": "Regular, Irregular, Superficial, Profunda o No determinado",
  "nivel": "Normal, Elevada, Alta o Emergencia",
  "nivel_color": "#52C97A para normal, #FF9800 para elevada, #F44336 para alta, #8B0000 para emergencia",
  "alerta_veterinario": true o false,
  "observaciones": "descripción del patrón respiratorio observado",
  "posibles_causas": ["causa1", "causa2"] si hay anomalía sino [],
  "recomendacion": "recomendación práctica para el dueño",
  "mensaje_urgencia": "mensaje si alerta_veterinario es true, sino null"
}

Si no se ve la mascota claramente: {"mascota_detectada": false}
Responde SOLO el JSON."""

# ════════════════════════════════════════════════════════════════
#  PROMPT ESPASMOS
# ════════════════════════════════════════════════════════════════
PROMPT_ESPASMOS = """Eres un veterinario neurólogo felino con 30 años de experiencia, experto en el Síndrome de Hiperesthesia Felina y trastornos neuromusculares en gatos y perros.

Analiza este frame de video y detecta si hay movimientos anormales en la piel o músculos de la espalda de la mascota.

SIGNOS A DETECTAR:
- Ondulación o temblor de la piel del lomo (rolling skin)
- Espasmos musculares en la espalda
- Movimientos involuntarios de la cola
- Postura anormal de la espalda
- Tensión muscular visible

Responde ÚNICAMENTE con JSON válido, sin texto adicional:
{
  "mascota_detectada": true o false,
  "espasmo_detectado": true o false,
  "intensidad": "Leve, Moderada, Severa o No detectado",
  "intensidad_color": "#52C97A para leve, #FF9800 para moderada, #F44336 para severa",
  "zona_afectada": "descripción de dónde se detecta el movimiento",
  "patron": "descripción del patrón del movimiento",
  "posibles_causas": [
    "Síndrome de Hiperesthesia Felina",
    "Estrés o ansiedad",
    "Irritación por pulgas",
    "Trastorno neurológico",
    "Alergia cutánea"
  ],
  "alerta_veterinario": true si intensidad es Moderada o Severa,
  "recomendacion": "recomendación práctica e inmediata",
  "mensaje_urgencia": "mensaje si alerta_veterinario es true, sino null"
}

Si no se ve la espalda de la mascota claramente: {"mascota_detectada": false}
Responde SOLO el JSON."""

# ════════════════════════════════════════════════════════════════
#  PROMPT HISTORIA MÉDICA E IA PREDICTIVA
# ════════════════════════════════════════════════════════════════
PROMPT_HISTORIA = """Eres el Dr. MeowScan, un veterinario clínico con 30 años de experiencia especializado en medicina felina y canina, diagnóstico preventivo y bienestar animal.

Tu misión es analizar TODOS los datos del historial médico de esta mascota y generar un diagnóstico clínico completo, profesional y útil para el dueño.

INSTRUCCIONES CRÍTICAS:
- Analiza CADA escaneo del historial individualmente y en conjunto
- Busca PATRONES y TENDENCIAS a lo largo del tiempo
- Identifica CAMBIOS entre escaneos (mejora, empeoramiento, estabilidad)
- Cruza datos: color de ojos + pelaje + comportamiento + signos vitales
- Actúa como el veterinario más experimentado del mundo
- Sé específico, no genérico — menciona hallazgos concretos del historial
- Si hay señales de alarma, dilo claramente con urgencia
- Siempre recomienda visita al veterinario con nivel de urgencia específico

DATOS QUE RECIBIRÁS POR ESCANEO:
- Fecha del escaneo
- Condición de ojos (color, opacidad, secreciones)
- Condición del pelaje (brillo, textura, pérdida)
- Signos vitales si disponibles (respiración, espasmos)
- Alertas detectadas
- Observaciones generales de la IA

DISCLAIMER: Este análisis es orientativo y de prevención temprana. Siempre consulta un veterinario certificado para diagnósticos definitivos.

Responde ÚNICAMENTE con JSON válido, sin texto adicional:
{
  "score_salud": número del 0 al 100 basado en todos los datos,
  "tendencia": "Mejorando, Estable, Deteriorando o Datos insuficientes",
  "tendencia_color": "#52C97A para mejorando/estable, #FF9800 para deteriorando",
  "resumen_clinico": "párrafo de 3-4 oraciones describiendo el estado clínico real basado en los datos encontrados. Menciona hallazgos específicos.",
  "diagnostico_preliminar": "diagnóstico clínico basado en los patrones encontrados, mencionando las condiciones más probables",
  "alertas_activas": [
    {
      "tipo": "nombre clínico del problema",
      "descripcion": "descripción médica específica basada en los datos",
      "urgencia": "Baja, Media o Alta",
      "evidencia": "qué escaneos o datos respaldan esta alerta",
      "recomendacion": "acción específica a tomar"
    }
  ],
  "predicciones": [
    {
      "condicion": "nombre de la condición",
      "probabilidad": "Baja, Media o Alta",
      "plazo": "plazo estimado en meses",
      "señales_detectadas": "qué señales del historial sugieren esto",
      "prevencion": "protocolo preventivo específico"
    }
  ],
  "evolucion_temporal": {
    "primer_escaneo": "descripción del estado inicial",
    "ultimo_escaneo": "descripción del estado más reciente",
    "cambios_notables": "cambios significativos observados entre escaneos"
  },
  "habitos_detectados": {
    "ojos": "estado y tendencia ocular",
    "pelaje": "estado y tendencia del pelaje",
    "actividad": "nivel de actividad observado",
    "salud_general": "evaluación clínica general"
  },
  "recomendaciones": [
    "recomendación clínica específica 1",
    "recomendación clínica específica 2",
    "recomendación clínica específica 3"
  ],
  "visita_veterinario": {
    "urgencia": "Inmediata, Esta semana, Este mes o Revisión rutinaria",
    "urgencia_color": "#F44336 para inmediata, #FF9800 para esta semana, #52C97A para rutinaria",
    "motivo": "razón clínica específica para la visita",
    "estudios_sugeridos": ["examen 1", "examen 2"]
  },
  "proxima_revision": "fecha recomendada para próximo escaneo en MeowScan"
}

Responde SOLO el JSON."""

# ══════════════════════════════════════════════════════════════
# 🌐 ENGLISH PROMPTS
# ══════════════════════════════════════════════════════════════

PROMPT_EN = """You are an expert veterinarian. Analyze this pet image and respond ONLY with valid JSON, no extra text or markdown.

Required exact format:
{"mascota_detectada":true,"tipo":"cat","raza":{"nombre":"breed name","confianza":85,"descripcion":"brief desc"},"peso":{"estimado_kg":4.2,"estimado_lb":9.3,"rango_min_kg":3.5,"rango_max_kg":5.0,"confianza":"Medium"},"color":{"color_principal":"orange","colores_secundarios":["white"],"patron":"Tabby","hex_aproximado":"#FF8C42"},"estado_corporal":{"bcs":5,"estado":"Ideal weight","emoji":"🐱","color_hex":"#52C97A","salud_pct":80,"consejo":"nutritional advice","alerta_peso":false,"mensaje_alerta":null},"orejas":{"posicion":"Upright","estado":"Alert","significado":"description","alerta":false,"alerta_veterinario":false,"mensaje_veterinario":null},"cola":{"posicion":"High","significado":"description","visible":true},"gesto":{"nombre":"Curious","emocion":"Curious","descripcion":"description","nivel_estres":2,"cola_posicion":null},"salud_visual":{"ojos":"eye description","pelaje":"coat description","observaciones":"observations"}}

If no pet visible: {"mascota_detectada":false}"""

PROMPT_VOMITO_EN = """Act as a veterinarian with 30 years of experience in small animal medicine.
Analyze the vomit image and respond ONLY with valid JSON:
{
  "vomito_detectado": true/false,
  "color_principal": "yellow|white|red|brown|green|transparent|other",
  "tipo": "bile|food|mucus|blood|unknown",
  "posibles_causas": ["list of possible causes"],
  "nivel_urgencia": "normal|observe|vet_soon|emergency",
  "recomendacion": "recommendation for the owner",
  "mensaje": "clear message about what was found"
}"""

PROMPT_RESPIRACION_EN = """You are an expert veterinarian analyzing a pet breathing pattern.
Respond ONLY with valid JSON:
{
  "mascota_detectada": true/false,
  "frecuencia_respiratoria": "normal|elevated|low|very_elevated",
  "rpm_parcial": estimated breaths per minute,
  "nivel": "Normal|Elevated|Low|Critical",
  "patron": "description of breathing pattern",
  "signos_alarma": ["list of concerning signs"],
  "conclusion": "general assessment",
  "urgencia": "normal|observe|vet_soon|emergency"
}"""

PROMPT_ESPASMOS_EN = """You are a veterinary neurologist analyzing a pet for spasms or abnormal movements.
Respond ONLY with valid JSON:
{
  "mascota_detectada": true/false,
  "espasmos_detectados": true/false,
  "tipo": "none|mild_tremor|muscle_spasm|convulsion|involuntary_movement",
  "zona_afectada": "description of affected body part",
  "intensidad": "mild|moderate|severe|not_applicable",
  "posibles_causas": ["list of possible causes"],
  "conclusion": "general assessment",
  "urgencia": "normal|observe|vet_soon|emergency"
}"""

PROMPT_ENCIAS_EN = """You are Dr. MeowScan, a clinical veterinarian analyzing a pet's gums.
Respond ONLY with valid JSON:
{
  "mascota_detectada": true/false,
  "color_encias": "pink|pale|white|yellow|blue_purple|red|brown",
  "estado_hidratacion": "normal|mild_dehydration|moderate_dehydration|severe_dehydration",
  "tiempo_llenado_capilar": "normal|slow|very_slow",
  "hallazgos": ["list of findings"],
  "posibles_causas": ["list of possible causes"],
  "nivel_urgencia": "normal|observe|vet_soon|emergency",
  "recomendacion": "recommendation",
  "mensaje": "message to the owner"
}"""

PROMPT_MAULLIDO_EN = """You are Dr. MeowScan, a feline ethologist analyzing a cat meow recording.
CRITICAL: Respond ONLY with a single valid JSON object. No extra text, no markdown, no explanations before or after. Start your response with { and end with }.
{
  "tipo_maullido": "greeting|hunger|pain|stress|attention|territorial|other",
  "estado_emocional": "calm|happy|stressed|anxious|in_pain|playful",
  "intensidad": "soft|moderate|intense|very_intense",
  "posibles_causas": ["list of possible causes"],
  "recomendacion": "recommendation for the owner",
  "urgencia": "normal|observe|vet_soon|emergency",
  "mensaje": "friendly interpretation message",
  "alerta_veterinario": false,
  "nivel_urgencia": "Normal",
  "curiosidad_felina": "interesting fact about cat sounds"
}"""

PROMPT_HISTORIA_EN = """You are Dr. MeowScan, a clinical veterinarian with 30 years of experience.
Analyze the medical history of the pet and respond ONLY with valid JSON with this structure:
{
  "resumen_ejecutivo": "brief clinical summary",
  "estado_general": "excellent|good|fair|poor",
  "tendencia_salud": "improving|stable|declining|variable",
  "sistemas_evaluados": {
    "respiratorio": "assessment",
    "digestivo": "assessment",
    "neurologico": "assessment",
    "oral": "assessment",
    "conductual": "assessment",
    "general": "assessment"
  },
  "hallazgos_principales": ["list of main findings"],
  "patrones_identificados": ["list of identified patterns"],
  "factores_riesgo": ["list of risk factors"],
  "recomendaciones": ["list of recommendations"],
  "proximos_pasos": ["list of next steps"],
  "frecuencia_consulta_sugerida": "monthly|every_3_months|every_6_months|annual",
  "mensaje_dueno": "personalized message to the owner"
}"""

PROMPT_VIDEO_RESPIRACION_EN = """
You are an expert veterinarian analyzing a video of a pet's breathing.
Analyze the video and respond ONLY with valid JSON with this exact structure.
CRITICAL: every string value must be in English only. Do not use Spanish anywhere in the JSON.
{
  "frecuencia_respiratoria": "normal|elevated|low|very_elevated",
  "respiraciones_por_minuto": estimated number,
  "patron": "description of the breathing pattern observed",
  "signos_alarma": ["list of concerning signs observed"],
  "conclusion": "general breathing assessment",
  "recomendacion": "what the owner should do",
  "urgencia": "normal|observe|vet_soon|emergency"
}
Be precise and clear. If you cannot determine something, indicate it in the corresponding field.
"""

PROMPT_VIDEO_ESPASMOS_EN = """
You are an expert veterinarian analyzing a video of a pet looking for spasms, tremors or abnormal movements.
Analyze the video and respond ONLY with valid JSON with this exact structure:
{
  "espasmos_detectados": true/false,
  "tipo": "none|mild_tremor|muscle_spasm|convulsion|involuntary_movement",
  "frecuencia": "description of how often it occurs",
  "zona_afectada": "description of which body part",
  "intensidad": "mild|moderate|severe|not_applicable",
  "posibles_causas": ["list of possible causes"],
  "conclusion": "general assessment",
  "recomendacion": "what the owner should do",
  "urgencia": "normal|observe|vet_soon|emergency"
}
Be precise. If no spasms are detected, state it clearly.
"""


# ════════════════════════════════════════════════════════════════
#  PROMPT ENCÍAS
# ════════════════════════════════════════════════════════════════
PROMPT_ENCIAS = """Eres el Dr. MeowScan, veterinario clínico con 30 años de experiencia especializado en medicina felina y canina.

Analiza esta imagen de la boca/encías de la mascota y evalúa su color y estado.

ESCALA DE COLORES DE ENCÍAS:
- Rosa brillante: NORMAL — buena perfusión y oxigenación
- Rosa pálido: ALERTA — posible anemia, shock temprano
- Blanco/muy pálido: EMERGENCIA — anemia severa, shock
- Azul/morado (cianosis): EMERGENCIA CRÍTICA — falta de oxígeno, llamar al vet YA
- Amarillo (ictericia): URGENTE — problemas hepáticos o biliares
- Rojo intenso: ALERTA — infección, fiebre alta, toxicidad
- Marrón/chocolate: EMERGENCIA — envenenamiento por paracetamol u otras toxinas

TAMBIÉN EVALÚA:
- Tiempo de llenado capilar (TLC): encía blanca vuelve a rosa en <2 seg = normal
- Humedad: encías secas = deshidratación
- Presencia de sarro o inflamación gingival
- Úlceras o lesiones visibles

Responde ÚNICAMENTE con JSON válido:
{
  "mascota_detectada": true o false,
  "encias_visibles": true o false,
  "color_detectado": "Rosa normal, Rosa pálido, Blanco, Azul/Morado, Amarillo, Rojo intenso o Marrón",
  "color_hex": "#color representativo del tono detectado",
  "estado": "Normal, Alerta, Urgente o Emergencia crítica",
  "estado_color": "#52C97A normal, #FF9800 alerta, #F44336 urgente, #8B0000 emergencia",
  "humedad": "Húmedas, Ligeramente secas o Secas",
  "sarro": true o false,
  "inflamacion": true o false,
  "alerta_veterinario": true si no es Normal,
  "diagnostico": "descripción clínica de lo observado",
  "posibles_condiciones": ["condición 1", "condición 2"],
  "recomendacion": "acción inmediata recomendada",
  "urgencia_minutos": "tiempo máximo para ver al vet: null si normal, número si urgente"
}
Si no se ven las encías claramente: {"mascota_detectada": false}
Responde SOLO el JSON."""

# ════════════════════════════════════════════════════════════════
#  PROMPT MAULLIDO
# ════════════════════════════════════════════════════════════════
PROMPT_MAULLIDO = """Eres el Dr. MeowScan, veterinario etólogo felino con 30 años de experiencia especializado en comunicación y comportamiento de gatos.

Se te proporcionará una descripción de sonidos felinos captados. Analiza el patrón de comunicación y determina el estado emocional y físico de la mascota.

CRÍTICO: Responde ÚNICAMENTE con un objeto JSON válido. Sin texto adicional, sin markdown, sin explicaciones antes o después. Empieza con { y termina con }.

{
  "sonido_detectado": true,
  "tipo_sonido": "Maullido, Ronroneo, Trino, Chillido, Gruñido, Silencio o Mixto",
  "intensidad": "Suave, Moderado o Intenso",
  "frecuencia": "Ocasional, Frecuente o Muy frecuente",
  "estado_emocional": "Feliz, Hambriento, Estresado, Asustado, Dolorido, Territorial, En celo o Desorientado",
  "estado_color": "#52C97A",
  "nivel_urgencia": "Normal",
  "alerta_veterinario": false,
  "interpretacion": "explicación de lo que el gato está comunicando",
  "posibles_causas": ["causa 1", "causa 2"],
  "recomendacion": "qué hacer ahora mismo",
  "curiosidad_felina": "dato interesante sobre este tipo de comunicación"
}
Si no se detecta sonido: {"sonido_detectado": false}"""

# ════════════════════════════════════════════════════════════════
#  MOTOR DE ANÁLISIS
# ════════════════════════════════════════════════════════════════

class MotorGroq:

    def __init__(self):
        self.cascade_normal = None
        self.cascade_ext    = None
        self._init_cascades()
        print("✅ Motor Groq Vision inicializado")

    def _init_cascades(self):
        cv_data = cv2.data.haarcascades
        for key in CASCADES_URL:
            ruta = os.path.join(cv_data, key)
            if not os.path.exists(ruta):
                print(f"📥 Descargando {key}...")
                try:
                    urllib.request.urlretrieve(CASCADES_URL[key], key)
                    ruta = key
                except Exception as e:
                    print(f"❌ {e}")
                    continue
            clf = cv2.CascadeClassifier(ruta)
            if not clf.empty():
                if "extended" in key:
                    self.cascade_ext = clf
                else:
                    self.cascade_normal = clf
                print(f"✅ Cascade: {key}")

    def detectar_cara(self, img_bgr: np.ndarray) -> List[tuple]:
        gris   = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2GRAY)
        gris   = cv2.equalizeHist(gris)
        params = dict(scaleFactor=1.1, minNeighbors=4, minSize=(40, 40))
        result = []
        for cascade in [self.cascade_normal, self.cascade_ext]:
            if cascade and not cascade.empty():
                det = cascade.detectMultiScale(gris, **params)
                if len(det) > 0:
                    result.extend(det.tolist())
        return result

    def _img_to_b64(self, img_bgr: np.ndarray, max_size: int = 800) -> str:
        h, w = img_bgr.shape[:2]
        if max(h, w) > max_size:
            scale = max_size / max(h, w)
            img_bgr = cv2.resize(img_bgr, (int(w * scale), int(h * scale)))
        img_rgb = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2RGB)
        pil_img = Image.fromarray(img_rgb)
        buf     = BytesIO()
        pil_img.save(buf, format="JPEG", quality=85)
        return base64.b64encode(buf.getvalue()).decode("utf-8")

    def _extraer_json(self, texto: str) -> dict:
        """Extrae JSON robusto de respuesta de Gemini."""
        import re
        def _completar_json_truncado(fragmento: str) -> str:
            """Intenta cerrar strings, objetos y arrays si la respuesta quedó truncada."""
            if not fragmento:
                return fragmento

            stack = []
            en_string = False
            escape = False

            for ch in fragmento:
                if escape:
                    escape = False
                    continue
                if ch == "\\" and en_string:
                    escape = True
                    continue
                if ch == '"':
                    en_string = not en_string
                    continue
                if en_string:
                    continue
                if ch == "{":
                    stack.append("}")
                elif ch == "[":
                    stack.append("]")
                elif ch in "}]":
                    if stack and stack[-1] == ch:
                        stack.pop()

            texto_completado = fragmento.rstrip()
            if texto_completado.endswith(":"):
                texto_completado += ' null'
            elif texto_completado.endswith(","):
                texto_completado = texto_completado[:-1].rstrip()

            if en_string:
                texto_completado += '"'

            while stack:
                if texto_completado.rstrip().endswith(":"):
                    texto_completado += ' null'
                elif texto_completado.rstrip().endswith(","):
                    texto_completado = texto_completado.rstrip()[:-1].rstrip()
                texto_completado += stack.pop()

            return texto_completado

        def _podar_fragmentos_incompletos(fragmento: str) -> str:
            """Elimina claves o valores cortados que quedaron inválidos al final."""
            if not fragmento:
                return fragmento

            texto_podado = fragmento.rstrip()
            while texto_podado:
                original = texto_podado
                texto_podado = re.sub(r',?\s*"[^"]*"?\s*}$', "}", texto_podado)
                texto_podado = re.sub(r',?\s*"[^"]*"?\s*]$', "]", texto_podado)
                texto_podado = re.sub(r',?\s*"[^"]*"?\s*:\s*$', "", texto_podado)
                texto_podado = re.sub(r',?\s*"[^"]*"?\s*:\s*[^,\}\]]*$', "", texto_podado)
                texto_podado = re.sub(r',\s*$', "", texto_podado)
                if texto_podado == original:
                    break

            return texto_podado

        texto = texto.strip()
        # Strip markdown fences
        if "```json" in texto:
            texto = texto.split("```json")[1].split("```")[0].strip()
        elif "```" in texto:
            partes = texto.split("```")
            for p in partes:
                p = p.strip()
                if p.startswith("{"):
                    texto = p
                    break
        # Extract from first { to last }
        start = texto.find("{")
        end   = texto.rfind("}")
        if start != -1 and end != -1 and end > start:
            texto = texto[start:end+1]
        # Fix Python literals
        texto = texto.replace(": True",  ": true")
        texto = texto.replace(": False", ": false")
        texto = texto.replace(": None",  ": null")
        # Remove trailing commas
        texto = re.sub(r",[ \t\n\r]*}", "}", texto)
        texto = re.sub(r",[ \t\n\r]*]", "]", texto)
        texto = _podar_fragmentos_incompletos(texto)
        texto = _completar_json_truncado(texto)
        # First try: direct parse
        try:
            return json.loads(texto)
        except Exception as e:
            print(f"❌ JSON parse failed: {e}\nTexto: {texto[:300]}")

        # Second try: remove non-JSON lines inside the block
        # This handles cases where Gemini inserts stray words like "Menu" mid-JSON
        lineas_limpias = []
        for linea in texto.split("\n"):
            stripped = linea.strip()
            # Keep lines that look like valid JSON content
            if (stripped == "" or
                stripped.startswith('"') or
                stripped.startswith("{") or
                stripped.startswith("}") or
                stripped.startswith("[") or
                stripped.startswith("]") or
                stripped.startswith("//") or
                re.match(r'^[\{\}\[\],]', stripped) or
                re.match(r'^"[^"]+"\s*:', stripped) or
                re.match(r'^(true|false|null|\d)', stripped)):
                lineas_limpias.append(linea)
            else:
                print(f"⚠️ Línea descartada del JSON: {repr(stripped)}")
        texto_limpio = "\n".join(lineas_limpias)
        # Remove trailing commas again after cleanup
        texto_limpio = re.sub(r",[ \t\n\r]*}", "}", texto_limpio)
        texto_limpio = re.sub(r",[ \t\n\r]*]", "]", texto_limpio)
        texto_limpio = _podar_fragmentos_incompletos(texto_limpio)
        texto_limpio = _completar_json_truncado(texto_limpio)
        try:
            return json.loads(texto_limpio)
        except Exception as e2:
            print(f"❌ JSON parse failed after cleanup: {e2}\nTexto limpio: {texto_limpio[:300]}")

        # Third try: use regex to extract each key-value pair
        resultado = {}
        patron_kv = re.findall(r'"([^"]+)"\s*:\s*("(?:[^"\\]|\\.)*"|\[.*?\]|true|false|null|-?\d+\.?\d*)', texto, re.DOTALL)
        for k, v in patron_kv:
            try:
                resultado[k] = json.loads(v)
            except:
                resultado[k] = v.strip('"')
        if resultado:
            print(f"⚠️ JSON recuperado parcialmente con regex: {list(resultado.keys())}")
            return resultado

        raise ValueError(f"No se pudo parsear JSON: {texto[:200]}")

    def _normalizar_resultado_maullido(self, resultado: Dict[str, Any], lang: str = "es") -> Dict[str, Any]:
        """Completa campos faltantes del análisis de maullido con valores seguros."""
        defaults_es = {
            "sonido_detectado": True,
            "tipo_sonido": "Maullido",
            "intensidad": "Moderado",
            "frecuencia": "Ocasional",
            "estado_emocional": "Expresivo",
            "estado_color": "#A29BFE",
            "nivel_urgencia": "Normal",
            "alerta_veterinario": False,
            "interpretacion": "Tu gato se está comunicando contigo. El análisis llegó incompleto y fue corregido automáticamente.",
            "posibles_causas": ["Busca atención", "Hambre", "Saludo"],
            "recomendacion": "Observa el comportamiento y lenguaje corporal de tu gato para confirmar el contexto.",
            "curiosidad_felina": "Los gatos suelen maullar más con humanos que con otros gatos.",
        }
        defaults_en = {
            "sonido_detectado": True,
            "tipo_sonido": "Meow",
            "intensidad": "Moderate",
            "frecuencia": "Occasional",
            "estado_emocional": "Expressive",
            "estado_color": "#A29BFE",
            "nivel_urgencia": "Normal",
            "alerta_veterinario": False,
            "interpretacion": "Your cat is communicating with you. The analysis came back incomplete and was auto-corrected.",
            "posibles_causas": ["Seeking attention", "Hunger", "Greeting"],
            "recomendacion": "Observe your cat's behavior and body language to confirm the context.",
            "curiosidad_felina": "Cats usually meow more to humans than to other cats.",
        }

        defaults = defaults_en if lang == "en" else defaults_es
        normalizado = defaults.copy()
        if isinstance(resultado, dict):
            for clave, valor in resultado.items():
                if valor not in (None, "", []):
                    normalizado[clave] = valor
        return normalizado

    def _llamar_gemini(self, img_b64: str, prompt: str, max_tokens: int = 2000) -> dict:
        """Llama a Groq Vision (llama-4-scout) con la imagen."""
        response = groq_client.chat.completions.create(
            model="meta-llama/llama-4-scout-17b-16e-instruct",
            messages=[{
                "role": "user",
                "content": [
                    {"type": "image_url", "image_url": {"url": f"data:image/jpeg;base64,{img_b64}"}},
                    {"type": "text", "text": prompt}
                ]
            }],
            max_tokens=max_tokens,
            temperature=0.1,
        )
        texto = response.choices[0].message.content.strip()
        print(f"📝 Groq raw response (first 300): {texto[:300]}")
        return self._extraer_json(texto)

    def analizar_con_groq(self, img_bgr: np.ndarray, lang: str = "es") -> Dict[str, Any]:
        img_b64 = self._img_to_b64(img_bgr)
        try:
            prompt_base = PROMPT_EN if lang == "en" else PROMPT_ES
            idioma_line = "Respond ONLY in English." if lang == "en" else "Responde SOLO en español."
            prompt = f"{prompt_base}\\n{idioma_line}"
            return self._llamar_gemini(img_b64, prompt)
        except json.JSONDecodeError as e:
            print(f"⚠️ JSON parse error: {e}")
            return self._resultado_fallback(lang=lang)
        except Exception as e:
            print(f"❌ Groq error: {e}")
            return self._resultado_fallback(lang=lang)

    # ── Analizar vómito ───────────────────────────────────────
    def analizar_vomito_con_groq(self, img_bgr: np.ndarray, lang: str = "es") -> Dict[str, Any]:
        img_b64 = self._img_to_b64(img_bgr)
        try:
            prompt = PROMPT_VOMITO_EN if lang == "en" else PROMPT_VOMITO
            return self._llamar_gemini(img_b64, prompt, max_tokens=1200)
        except json.JSONDecodeError as e:
            print(f"⚠️ JSON vomito parse error: {e}")
            return {"vomito_detectado": False}
        except Exception as e:
            print(f"❌ Groq vomito error: {e}")
            return {"vomito_detectado": False}

    def _resultado_fallback(self, lang: str = "es") -> Dict[str, Any]:
        if lang == "en":
            return {
                "mascota_detectada": True,
                "raza": {"nombre": "Undetermined", "confianza": 0, "descripcion": ""},
                "peso": {"estimado_kg": 4.0, "estimado_lb": 8.8, "rango_min_kg": 3.0, "rango_max_kg": 5.0, "confianza": "Low"},
                "color": {"color_principal": "Undetermined", "colores_secundarios": [], "patron": "-", "hex_aproximado": "#888888"},
                "estado_corporal": {
                    "bcs": 5, "estado": "Undetermined", "emoji": "🐱",
                    "color_hex": "#52C97A", "salud_pct": 75,
                    "consejo": "The scan could not be completed. Try again with better lighting.",
                    "alerta_peso": False, "mensaje_alerta": None
                },
                "orejas": {
                    "posicion": "Undetermined", "estado": "Undetermined",
                    "significado": "Could not analyze", "alerta": False,
                    "alerta_veterinario": False, "mensaje_veterinario": None
                },
                "gesto": {"nombre": "Undetermined", "emocion": "Unknown", "descripcion": "Could not analyze", "nivel_estres": 0, "cola_posicion": None},
                "salud_visual": {"ojos": "Undetermined", "pelaje": "Undetermined", "observaciones": "Analysis unavailable"}
            }
        return {
            "mascota_detectada": True,
            "raza": {"nombre": "No determinada", "confianza": 0, "descripcion": ""},
            "peso": {"estimado_kg": 4.0, "estimado_lb": 8.8, "rango_min_kg": 3.0, "rango_max_kg": 5.0, "confianza": "Baja"},
            "color": {"color_principal": "No determinado", "colores_secundarios": [], "patron": "-", "hex_aproximado": "#888888"},
            "estado_corporal": {
                "bcs": 5, "estado": "No determinado", "emoji": "🐱",
                "color_hex": "#52C97A", "salud_pct": 75,
                "consejo": "No se pudo analizar completamente. Intenta con mejor iluminación.",
                "alerta_peso": False, "mensaje_alerta": None
            },
            "orejas": {
                "posicion": "No determinada", "estado": "No determinado",
                "significado": "No se pudo analizar", "alerta": False,
                "alerta_veterinario": False, "mensaje_veterinario": None
            },
            "gesto": {"nombre": "No determinado", "emocion": "Desconocido", "descripcion": "No se pudo analizar", "nivel_estres": 0, "cola_posicion": None},
            "salud_visual": {"ojos": "No determinado", "pelaje": "No determinado", "observaciones": "Análisis no disponible"}
        }

    def anotar_imagen(self, img_bgr: np.ndarray, caras: list, resultado: Dict) -> np.ndarray:
        img   = img_bgr.copy()
        raza  = resultado.get("raza", {}).get("nombre", "")
        corp  = resultado.get("estado_corporal", {}).get("estado", "")
        for (x, y, w, h) in caras:
            cv2.rectangle(img, (x, y), (x+w, y+h), (0, 215, 100), 2)
            label = f"{raza} | {corp}"
            cv2.putText(img, label, (x, max(y-8, 20)), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 215, 100), 2)
        return img

    # ── ANÁLISIS COMPLETO MASCOTA ─────────────────────────────
    def analizar_frame(self, img_bytes: bytes, lang: str = "es") -> Dict[str, Any]:
        arr = np.frombuffer(img_bytes, np.uint8)
        img = cv2.imdecode(arr, cv2.IMREAD_COLOR)
        if img is None:
            raise ValueError("No se pudo decodificar la imagen")

        caras     = self.detectar_cara(img)
        resultado = self.analizar_con_groq(img, lang=lang)

        if not resultado.get("mascota_detectada", False):
            return {
                "mascota_detectada": False,
                "gato_detectado":    False,
                "timestamp":         time.time(),
                "caras_detectadas":  len(caras),
                "mensaje": "No se detectó un gato ni un perro. Asegúrate de apuntar bien la cámara."
            }

        img_anotada = self.anotar_imagen(img, caras, resultado)
        _, buf = cv2.imencode(".jpg", img_anotada, [cv2.IMWRITE_JPEG_QUALITY, 75])
        img_b64 = base64.b64encode(buf.tobytes()).decode()

        raza_info  = resultado.get("raza", {})
        peso_info  = resultado.get("peso", {})
        color_info = resultado.get("color", {})
        corp_info  = resultado.get("estado_corporal", {})
        gesto_info = resultado.get("gesto", {})
        orejas     = resultado.get("orejas", {})
        salud_vis  = resultado.get("salud_visual", {})

        return {
            "gato_detectado":    True,
            "mascota_detectada": True,
            "tipo":              resultado.get("tipo", "gato"),
            "timestamp":         time.time(),
            "caras_detectadas":  len(caras),
            "imagen_anotada":    img_b64,

            "raza": {
                "raza":        raza_info.get("nombre", "-"),
                "confianza":   raza_info.get("confianza", 0),
                "descripcion": raza_info.get("descripcion", ""),
                "peso_base":   peso_info.get("estimado_kg", 4.5),
            },
            "peso": {
                "peso_kg":       peso_info.get("estimado_kg", 0),
                "peso_lb":       peso_info.get("estimado_lb", 0),
                "rango":         f'{peso_info.get("rango_min_kg",0)}-{peso_info.get("rango_max_kg",0)} kg',
                "area_relativa": 0,
                "confianza":     peso_info.get("confianza", "Media"),
            },
            "color": {
                "color_principal":     color_info.get("color_principal", "-"),
                "colores_secundarios": color_info.get("colores_secundarios", []),
                "patron":              color_info.get("patron", "-"),
                "hex":                 color_info.get("hex_aproximado", "#888888"),
            },
            "estado_corporal": {
                "bcs":            corp_info.get("bcs", 5),
                "bcs_max":        9,
                "estado":         corp_info.get("estado", "-"),
                "emoji":          corp_info.get("emoji", "🐱"),
                "color_hex":      corp_info.get("color_hex", "#52C97A"),
                "salud_pct":      corp_info.get("salud_pct", 75),
                "consejo":        corp_info.get("consejo", ""),
                "alerta_peso":    corp_info.get("alerta_peso", False),
                "mensaje_alerta": corp_info.get("mensaje_alerta", None),
            },
            "gesto": {
                "nombre":        gesto_info.get("nombre", "-"),
                "emocion":       gesto_info.get("emocion", "-"),
                "descripcion":   gesto_info.get("descripcion", "-"),
                "nivel_estres":  gesto_info.get("nivel_estres", 0),
                "movimiento":    "alto" if gesto_info.get("nivel_estres", 0) > 5 else "bajo",
                "cola_posicion": gesto_info.get("cola_posicion"),
                "confianza":     90,
            },
            "orejas": {
                "posicion":           orejas.get("posicion", "-"),
                "estado":             orejas.get("estado", "-"),
                "significado":        orejas.get("significado", "-"),
                "alerta":             orejas.get("alerta", False),
                "alerta_veterinario": orejas.get("alerta_veterinario", False),
                "mensaje_veterinario":orejas.get("mensaje_veterinario", None),
            },
            "cola": {
                "posicion":   resultado.get("cola", {}).get("posicion", "No visible"),
                "significado":resultado.get("cola", {}).get("significado", "-"),
                "visible":    resultado.get("cola", {}).get("visible", False),
            },
            "salud_visual": {
                "ojos":          salud_vis.get("ojos", "-"),
                "pelaje":        salud_vis.get("pelaje", "-"),
                "observaciones": salud_vis.get("observaciones", "-"),
            },
        }

    # ── Analizar encías ──────────────────────────────────────
    def analizar_encias_con_groq(self, img_bgr, lang: str = "es") -> Dict[str, Any]:
        img_b64 = self._img_to_b64(img_bgr)
        try:
            prompt = PROMPT_ENCIAS_EN if lang == "en" else PROMPT_ENCIAS
            return self._llamar_gemini(img_b64, prompt, max_tokens=900)
        except Exception as e:
            print(f"❌ Encias error: {e}")
            return {"mascota_detectada": False}

    def analizar_frame_encias(self, img_bytes: bytes, lang: str = "es") -> Dict[str, Any]:
        arr = np.frombuffer(img_bytes, np.uint8)
        img = cv2.imdecode(arr, cv2.IMREAD_COLOR)
        if img is None:
            raise ValueError("No se pudo decodificar la imagen")
        resultado = self.analizar_encias_con_groq(img, lang=lang)
        if not resultado.get("mascota_detectada", False) or            not resultado.get("encias_visibles", False):
            return {"mascota_detectada": False, "timestamp": time.time(),
                    "mensaje": "No se ven las encías. Levanta suavemente el labio de tu mascota y toma la foto."}
        # Annotate image
        estado = resultado.get("estado", "Normal")
        color_map = {"Normal": (82,201,122), "Alerta": (0,152,255),
                     "Urgente": (0,100,244), "Emergencia crítica": (0,0,180)}
        color_cv = color_map.get(estado, (82,201,122))
        img_an   = img.copy()
        cv2.putText(img_an, f"Encias: {estado}",
            (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.8, color_cv, 2)
        cv2.putText(img_an, resultado.get("color_detectado", ""),
            (10, 60), cv2.FONT_HERSHEY_SIMPLEX, 0.6, color_cv, 2)
        _, buf   = cv2.imencode(".jpg", img_an, [cv2.IMWRITE_JPEG_QUALITY, 80])
        img_b64  = base64.b64encode(buf.tobytes()).decode()
        return {
            "mascota_detectada":    True,
            "timestamp":            time.time(),
            "imagen_anotada":       img_b64,
            "color_detectado":      resultado.get("color_detectado", "-"),
            "color_hex":            resultado.get("color_hex", "#FFB6C1"),
            "estado":               estado,
            "estado_color":         resultado.get("estado_color", "#52C97A"),
            "humedad":              resultado.get("humedad", "-"),
            "sarro":                resultado.get("sarro", False),
            "inflamacion":          resultado.get("inflamacion", False),
            "alerta_veterinario":   resultado.get("alerta_veterinario", False),
            "diagnostico":          resultado.get("diagnostico", "-"),
            "posibles_condiciones": resultado.get("posibles_condiciones", []),
            "recomendacion":        resultado.get("recomendacion", "-"),
            "urgencia_minutos":     resultado.get("urgencia_minutos", None),
            "nivel":                estado,
            "nivel_color":          resultado.get("estado_color", "#52C97A"),
            "observaciones":        resultado.get("diagnostico", "-"),
            "posibles_causas":      resultado.get("posibles_condiciones", []),
        }

    # ── Analizar maullido ────────────────────────────────────
    def analizar_audio_maullido(self, descripcion: str, lang: str = "es") -> Dict[str, Any]:
        """Analiza descripción de sonidos felinos con IA."""
        try:
            _pm = PROMPT_MAULLIDO_EN if lang == "en" else PROMPT_MAULLIDO
            prompt_completo = f"{_pm}\n\nSonidos capturados:\n{descripcion}"
            model = genai.GenerativeModel(
                "gemini-2.5-flash",
                generation_config=genai.GenerationConfig(max_output_tokens=2000, temperature=0.2)
            )
            response = model.generate_content(prompt_completo)
            texto = response.text.strip()
            return self._normalizar_resultado_maullido(self._extraer_json(texto), lang=lang)
        except Exception as e:
            print(f"❌ Maullido error: {e}")
            # Fallback result so the app always gets a valid response
            if lang == "en":
                return {
                    "sonido_detectado": True,
                    "tipo_sonido": "Meow",
                    "intensidad": "Moderate",
                    "frecuencia": "Occasional",
                    "estado_emocional": "Expressive",
                    "estado_color": "#A29BFE",
                    "nivel_urgencia": "Normal",
                    "alerta_veterinario": False,
                    "interpretacion": "Your cat is communicating with you. Analysis could not be completed fully.",
                    "posibles_causas": ["Seeking attention", "Hunger", "Greeting"],
                    "recomendacion": "Observe your cat's behavior and body language for more context.",
                    "curiosidad_felina": "Cats only meow to communicate with humans, not with other cats.",
                    "error": str(e)
                }
            else:
                return {
                    "sonido_detectado": True,
                    "tipo_sonido": "Maullido",
                    "intensidad": "Moderado",
                    "frecuencia": "Ocasional",
                    "estado_emocional": "Expresivo",
                    "estado_color": "#A29BFE",
                    "nivel_urgencia": "Normal",
                    "alerta_veterinario": False,
                    "interpretacion": "Tu gato se está comunicando contigo. El análisis no pudo completarse.",
                    "posibles_causas": ["Busca atención", "Hambre", "Saludo"],
                    "recomendacion": "Observa el comportamiento y lenguaje corporal de tu gato.",
                    "curiosidad_felina": "Los gatos solo maúllan para comunicarse con humanos, no con otros gatos.",
                    "error": str(e)
                }

    # ── Analizar respiración ─────────────────────────────────
    def analizar_respiracion_con_groq(self, img_bgr: np.ndarray, lang: str = "es") -> Dict[str, Any]:
        img_b64 = self._img_to_b64(img_bgr)
        try:
            prompt = PROMPT_RESPIRACION_EN if lang == "en" else PROMPT_RESPIRACION
            return self._llamar_gemini(img_b64, prompt, max_tokens=800)
        except Exception as e:
            print(f"❌ Respiracion error: {e}")
            return {"mascota_detectada": False}

    # ── Analizar espasmos ─────────────────────────────────────
    def analizar_espasmos_con_groq(self, img_bgr: np.ndarray, lang: str = "es") -> Dict[str, Any]:
        img_b64 = self._img_to_b64(img_bgr)
        try:
            prompt = PROMPT_ESPASMOS_EN if lang == "en" else PROMPT_ESPASMOS
            return self._llamar_gemini(img_b64, prompt, max_tokens=800)
        except Exception as e:
            print(f"❌ Espasmos error: {e}")
            return {"mascota_detectada": False}

    # ── Historia médica predictiva ────────────────────────────
    def analizar_historia_medica(self, historial: list, lang: str = "es") -> Dict[str, Any]:
        if not historial:
            return {"error": "sin_historial"}
        
        # Build detailed history summary for the AI
        resumen_detallado = []
        for i, scan in enumerate(historial):
            datos = scan.get("datos", scan)
            tipo = datos.get("tipo", scan.get("tipo", "general"))
            fecha = scan.get("fecha", f"Escaneo {i+1}")[:10]  # Solo fecha, no hora
            
            # Extract key fields per scan type to avoid token overflow
            resumen = {"n": i+1, "fecha": fecha, "tipo": tipo}
            if tipo == "general":
                resumen["raza"] = datos.get("raza", {}).get("raza", "-") if isinstance(datos.get("raza"), dict) else datos.get("raza", "-")
                resumen["peso_kg"] = datos.get("peso", {}).get("peso_kg", "-") if isinstance(datos.get("peso"), dict) else "-"
                resumen["condicion"] = datos.get("condicion_corporal", "-")
                resumen["anomalias"] = datos.get("anomalias_detectadas", [])
            elif tipo == "vomito":
                resumen["color"] = datos.get("color_principal", "-")
                resumen["urgencia"] = datos.get("urgencia", "-")
                resumen["posibles_causas"] = datos.get("posibles_causas", [])
            elif tipo in ("analizar_respiracion", "respiracion"):
                resumen["rpm"] = datos.get("respiraciones_por_minuto", "-")
                resumen["patron"] = datos.get("patron", "-")
                resumen["urgencia"] = datos.get("urgencia", "-")
                resumen["signos_alarma"] = datos.get("signos_alarma", [])
            elif tipo in ("analizar_espasmos", "espasmos"):
                resumen["zona"] = datos.get("zona_afectada", "-")
                resumen["intensidad"] = datos.get("intensidad", "-")
                resumen["tipo_espasmo"] = datos.get("tipo", "-")
                resumen["urgencia"] = datos.get("urgencia", "-")
            elif tipo in ("analizar_encias", "encias"):
                resumen["color"] = datos.get("color_detectado", "-")
                resumen["estado"] = datos.get("estado", "-")
                resumen["urgencia"] = datos.get("urgencia", "-")
            elif tipo == "maullido":
                resumen["tipo_sonido"] = datos.get("tipo_sonido", "-")
                resumen["estado_emocional"] = datos.get("estado_emocional", "-")
                resumen["urgencia"] = datos.get("urgencia", "-")
            
            resumen["conclusion"] = str(datos.get("conclusion", ""))[:200]
            resumen_detallado.append(resumen)
        
        resumen_json = json.dumps(resumen_detallado, ensure_ascii=False, indent=2)
        total = len(historial)
        
        _ph = PROMPT_HISTORIA_EN if lang == "en" else PROMPT_HISTORIA
        prompt_con_datos = f"""{_ph}

HISTORIAL COMPLETO ({total} escaneos de TODOS los tipos - general, vomito, respiracion, espasmos, encias, maullido):
{resumen_json}

Analiza TODOS los escaneos, detecta patrones y tendencias entre los diferentes tipos, y genera un diagnóstico clínico profesional integral."""

        try:
            model = genai.GenerativeModel(
                "gemini-2.5-flash",
                generation_config=genai.GenerationConfig(max_output_tokens=2000, temperature=0.1)
            )
            response = model.generate_content(prompt_con_datos)
            texto = response.text.strip()
            return self._extraer_json(texto)
        except Exception as e:
            print(f"❌ Historia error: {e}")
            return {"error": str(e)}

    # ── ANÁLISIS COMPLETO RESPIRACIÓN ────────────────────────
    def analizar_frame_respiracion(self, img_bytes: bytes, lang: str = "es") -> Dict[str, Any]:
        arr = np.frombuffer(img_bytes, np.uint8)
        img = cv2.imdecode(arr, cv2.IMREAD_COLOR)
        if img is None:
            raise ValueError("No se pudo decodificar la imagen")
        resultado = self.analizar_respiracion_con_groq(img, lang=lang)
        if lang == "en":
            resultado = self._normalizar_respiracion_ingles(resultado)
        if not resultado.get("mascota_detectada", False):
            return {"mascota_detectada": False, "timestamp": time.time(),
                    "mensaje": "No se detectó la mascota. Apunta al pecho del animal."}
        nivel = resultado.get("nivel", "Normal")
        color_map = {"Normal": (82,201,122), "Elevada": (0,152,255),
                     "Alta": (0,100,244), "Emergencia": (0,0,139)}
        color_cv = color_map.get(nivel, (82,201,122))
        img_an = img.copy()
        rpm = resultado.get("respiraciones_por_minuto", 0)
        cv2.putText(img_an, f"{rpm} resp/min - {nivel}",
                    (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.8, color_cv, 2)
        _, buf = cv2.imencode(".jpg", img_an, [cv2.IMWRITE_JPEG_QUALITY, 75])
        img_b64 = base64.b64encode(buf.tobytes()).decode()
        return {
            "mascota_detectada":       True,
            "timestamp":               time.time(),
            "imagen_anotada":          img_b64,
            "respiraciones_por_minuto":resultado.get("respiraciones_por_minuto", 0),
            "patron":                  resultado.get("patron", "-"),
            "nivel":                   nivel,
            "nivel_color":             resultado.get("nivel_color", "#52C97A"),
            "alerta_veterinario":      resultado.get("alerta_veterinario", False),
            "observaciones":           resultado.get("observaciones", "-"),
            "posibles_causas":         resultado.get("posibles_causas", []),
            "recomendacion":           resultado.get("recomendacion", "-"),
            "mensaje_urgencia":        resultado.get("mensaje_urgencia", None),
        }

    def _normalizar_respiracion_ingles(self, resultado: Dict[str, Any]) -> Dict[str, Any]:
        """Corrige valores comunes si el modelo mezcla español en respuestas de respiración."""
        if not isinstance(resultado, dict):
            return resultado

        mapa = {
            "Elevada": "Elevated",
            "Alta": "High",
            "Emergencia": "Emergency",
            "Regular": "Regular",
            "Irregular": "Irregular",
            "Superficial": "Shallow",
            "Profunda": "Deep",
            "No determinado": "Undetermined",
            "No determinada": "Undetermined",
            "Indeterminada": "Undetermined",
            "observar": "observe",
            "veterinario_pronto": "vet_soon",
            "emergencia": "emergency",
        }

        for clave in ("nivel", "patron", "urgencia", "frecuencia_respiratoria"):
            valor = resultado.get(clave)
            if isinstance(valor, str) and valor in mapa:
                resultado[clave] = mapa[valor]

        return resultado

    # ── ANÁLISIS COMPLETO ESPASMOS ───────────────────────────
    def analizar_frame_espasmos(self, img_bytes: bytes, lang: str = "es") -> Dict[str, Any]:
        arr = np.frombuffer(img_bytes, np.uint8)
        img = cv2.imdecode(arr, cv2.IMREAD_COLOR)
        if img is None:
            raise ValueError("No se pudo decodificar la imagen")
        resultado = self.analizar_espasmos_con_groq(img, lang=lang)
        if not resultado.get("mascota_detectada", False):
            return {"mascota_detectada": False, "timestamp": time.time(),
                    "mensaje": "No se detectó la mascota. Apunta a la espalda del animal."}
        intensidad = resultado.get("intensidad", "No detectado")
        color_map  = {"No detectado": (82,201,122), "Leve": (82,201,122),
                      "Moderada": (0,152,255), "Severa": (0,0,200)}
        color_cv   = color_map.get(intensidad, (82,201,122))
        img_an     = img.copy()
        cv2.putText(img_an, f"Espasmo: {intensidad}",
                    (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.8, color_cv, 2)
        _, buf   = cv2.imencode(".jpg", img_an, [cv2.IMWRITE_JPEG_QUALITY, 75])
        img_b64  = base64.b64encode(buf.tobytes()).decode()
        return {
            "mascota_detectada":  True,
            "timestamp":          time.time(),
            "imagen_anotada":     img_b64,
            "espasmo_detectado":  resultado.get("espasmo_detectado", False),
            "intensidad":         intensidad,
            "intensidad_color":   resultado.get("intensidad_color", "#52C97A"),
            "zona_afectada":      resultado.get("zona_afectada", "-"),
            "patron":             resultado.get("patron", "-"),
            "posibles_causas":    resultado.get("posibles_causas", []),
            "alerta_veterinario": resultado.get("alerta_veterinario", False),
            "recomendacion":      resultado.get("recomendacion", "-"),
            "mensaje_urgencia":   resultado.get("mensaje_urgencia", None),
        }

    # ── ANÁLISIS COMPLETO VÓMITO ──────────────────────────────
    def analizar_frame_vomito(self, img_bytes: bytes, lang: str = "es") -> Dict[str, Any]:
        arr = np.frombuffer(img_bytes, np.uint8)
        img = cv2.imdecode(arr, cv2.IMREAD_COLOR)
        if img is None:
            raise ValueError("No se pudo decodificar la imagen")

        resultado = self.analizar_vomito_con_groq(img, lang=lang)

        if not resultado.get("vomito_detectado", False):
            return {
                "vomito_detectado": False,
                "timestamp":        time.time(),
                "mensaje": "No se detectó vómito en la imagen. Asegúrate de apuntar bien la cámara."
            }

        # Imagen anotada con color de urgencia
        urgencia    = resultado.get("urgencia", "Media")
        color_map   = {"Baja": (82, 201, 122), "Media": (0, 152, 255), "Alta": (0, 100, 244), "Emergencia": (0, 0, 139)}
        color_cv    = color_map.get(urgencia, (0, 152, 255))
        img_anotada = img.copy()
        cv2.putText(img_anotada, f"Urgencia: {urgencia}", (10, 30),
                    cv2.FONT_HERSHEY_SIMPLEX, 1.0, color_cv, 2)
        _, buf   = cv2.imencode(".jpg", img_anotada, [cv2.IMWRITE_JPEG_QUALITY, 75])
        img_b64  = base64.b64encode(buf.tobytes()).decode()

        return {
            "vomito_detectado":   True,
            "timestamp":          time.time(),
            "imagen_anotada":     img_b64,
            "color_identificado": resultado.get("color_identificado", "-"),
            "tipo":               resultado.get("tipo", "-"),
            "urgencia":           resultado.get("urgencia", "Media"),
            "urgencia_color":     resultado.get("urgencia_color", "#FF9800"),
            "alerta_veterinario": resultado.get("alerta_veterinario", False),
            "causas_probables":   resultado.get("causas_probables", []),
            "en_gatos":           resultado.get("en_gatos", "-"),
            "en_perros":          resultado.get("en_perros", "-"),
            "recomendacion":      resultado.get("recomendacion", "-"),
            "signos_adicionales": resultado.get("signos_adicionales", "-"),
            "mensaje_urgencia":   resultado.get("mensaje_urgencia", "-"),
        }


# ════════════════════════════════════════════════════════════════
#  FASTAPI APP
# ════════════════════════════════════════════════════════════════

app   = FastAPI(title="MeowScan API v3.1 — Groq Vision", version="3.1")
motor: Optional[MotorGroq] = None

from fastapi.responses import FileResponse

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],          # Mobile apps don't have a fixed origin
    allow_methods=["POST", "GET"],
    allow_headers=["Content-Type", "X-API-Key"],
)

@app.middleware("http")
async def security_middleware(request: Request, call_next):
    """Block suspicious requests and add security headers."""
    # Block common attack paths
    path = request.url.path.lower()
    blocked = [".php", ".asp", ".env", "wp-admin", "phpmyadmin",
               "xmlrpc", ".git", "eval(", "<script"]
    if any(b in path for b in blocked):
        return JSONResponse(status_code=404, content={"detail": "Not found"})
    if request.method != "OPTIONS" and not _is_public_path(path):
        try:
            verify_api_key(request.headers.get("X-API-Key"))
            check_rate_limit(request)
            content_length = _parse_content_length(request.headers.get("content-length"))
            if content_length and content_length > MAX_VIDEO_BYTES + 1024:
                return JSONResponse(status_code=413, content={"detail": "Request too large."})
        except HTTPException as exc:
            return JSONResponse(status_code=exc.status_code, content={"detail": exc.detail})
    response = await call_next(request)
    # Security headers
    response.headers["X-Content-Type-Options"]  = "nosniff"
    response.headers["X-Frame-Options"]         = "DENY"
    response.headers["X-XSS-Protection"]        = "1; mode=block"
    response.headers["Referrer-Policy"]          = "no-referrer"
    return response


@app.get("/")
@app.get("/health")
async def health():
    """Health check - no auth required (for UptimeRobot)."""
    return {"status": "ok", "service": "MeowScan API", "version": "4.1"}

@app.on_event("startup")
async def startup():
    global motor
    print("\n🚀 Iniciando MeowScan API v3.1 con Groq Vision...")
    motor = MotorGroq()
    print("✅ Servidor listo!\n")
try:
    modelos = [m.name for m in genai.list_models() if "generateContent" in m.supported_generation_methods]
    print(f"🤖 Modelos Gemini disponibles: {modelos}")
except Exception as e:
    print(f"⚠️ Modelos no listados: {e}")

@app.get("/perfil")
def perfil():
    return FileResponse("cat_profile.html")

@app.get("/")
def root():
    return {"status": "ok", "app": "MeowScan API", "version": "3.1", "ia": "Groq Vision"}

@app.get("/health")
def health():
    return {"status": "ok", "version": "3.1", "ia_engine": "Gemini 2.5 Flash", "groq": True}

@app.post("/analizar")
async def analizar(file: UploadFile = File(...), sesion_id: str = "default", lang: str = Form("es")):
    if motor is None:
        raise HTTPException(status_code=503, detail="Motor no inicializado")
    try:
        contenido = await _read_upload_bytes(file, MAX_IMAGE_BYTES, "Image")
        resultado = motor.analizar_frame(contenido, lang=lang)
    except HTTPException:
        raise
    except Exception as e:
        print(f"❌ analizar error: {e}")
        raise _client_error()
    return JSONResponse(content=resultado)

@app.post("/analizar_vomito")
async def analizar_vomito(file: UploadFile = File(...), sesion_id: str = "default", lang: str = Form("es")):
    if motor is None:
        raise HTTPException(status_code=503, detail="Motor no inicializado")
    try:
        contenido = await _read_upload_bytes(file, MAX_IMAGE_BYTES, "Image")
        resultado = motor.analizar_frame_vomito(contenido, lang=lang)
    except HTTPException:
        raise
    except Exception as e:
        print(f"❌ analizar_vomito error: {e}")
        raise _client_error()
    return JSONResponse(content=resultado)


@app.post("/analizar_respiracion")
async def analizar_respiracion(file: UploadFile = File(...), lang: str = Form("es")):
    if motor is None:
        raise HTTPException(status_code=503, detail="Motor no inicializado")
    try:
        contenido = await _read_upload_bytes(file, MAX_IMAGE_BYTES, "Image")
        resultado = motor.analizar_frame_respiracion(contenido, lang=lang)
    except HTTPException:
        raise
    except Exception as e:
        print(f"❌ analizar_respiracion error: {e}")
        raise _client_error()
    return JSONResponse(content=resultado)

@app.post("/analizar_espasmos")
async def analizar_espasmos(file: UploadFile = File(...), lang: str = Form("es")):
    if motor is None:
        raise HTTPException(status_code=503, detail="Motor no inicializado")
    try:
        contenido = await _read_upload_bytes(file, MAX_IMAGE_BYTES, "Image")
        resultado = motor.analizar_frame_espasmos(contenido, lang=lang)
    except HTTPException:
        raise
    except Exception as e:
        print(f"❌ analizar_espasmos error: {e}")
        raise _client_error()
    return JSONResponse(content=resultado)

class HistoriaRequest(BaseModel):
    historial: list
    lang: str = "es"

@app.post("/analizar_encias")
async def analizar_encias(file: UploadFile = File(...), lang: str = Form("es")):
    if motor is None:
        raise HTTPException(status_code=503, detail="Motor no inicializado")
    try:
        contenido = await _read_upload_bytes(file, MAX_IMAGE_BYTES, "Image")
        resultado = motor.analizar_frame_encias(contenido, lang=lang)
    except HTTPException:
        raise
    except Exception as e:
        print(f"❌ analizar_encias error: {e}")
        raise _client_error()
    return JSONResponse(content=resultado)


class MaullidoRequest(BaseModel):
    descripcion: str
    duracion_seg: float = 10.0
    intensidad_db: float = 0.0
    lang: str = "es"

@app.post("/analizar_maullido")
async def analizar_maullido(req: MaullidoRequest):
    if motor is None:
        raise HTTPException(status_code=503, detail="Motor no inicializado")
    try:
        # Enrich description with technical data
        desc_enriquecida = f"""
Duración grabación: {req.duracion_seg} segundos
Nivel de volumen promedio: {req.intensidad_db:.1f} dB
Descripción del sonido detectado: {req.descripcion}
"""
        resultado = motor.analizar_audio_maullido(desc_enriquecida, lang=req.lang)
        resultado["duracion_seg"]   = req.duracion_seg
        resultado["intensidad_db"]  = req.intensidad_db
        resultado["timestamp"]      = time.time()
    except Exception as e:
        print(f"❌ analizar_maullido error: {e}")
        raise _client_error()
    return JSONResponse(content=resultado)


@app.post("/historia_medica")
async def historia_medica(req: HistoriaRequest):
    if motor is None:
        raise HTTPException(status_code=503, detail="Motor no inicializado")
    try:
        resultado = motor.analizar_historia_medica(req.historial, lang=req.lang)
    except Exception as e:
        print(f"❌ historia_medica error: {e}")
        raise _client_error()
    return JSONResponse(content=resultado)


# ══════════════════════════════════════════════════════════════
# 🎥 GEMINI VIDEO ENDPOINTS — Respiración y Espasmos
# ══════════════════════════════════════════════════════════════

PROMPT_VIDEO_RESPIRACION = """
Eres un veterinario experto analizando un video de la respiración de una mascota (gato o perro).
Analiza el video y responde SOLO con JSON válido con esta estructura exacta:
{
  "frecuencia_respiratoria": "normal|elevada|baja|muy_elevada",
  "respiraciones_por_minuto": número estimado,
  "patron": "descripción del patrón respiratorio observado",
  "signos_alarma": ["lista de signos preocupantes observados"],
  "conclusion": "evaluación general de la respiración",
  "recomendacion": "qué debe hacer el dueño",
  "urgencia": "normal|observar|veterinario_pronto|emergencia"
}
Sé preciso y claro. Si no puedes determinar algo, indícalo en el campo correspondiente.
"""

PROMPT_VIDEO_ESPASMOS = """
Eres un veterinario experto analizando un video de una mascota (gato o perro) buscando espasmos, temblores o movimientos anormales.
Analiza el video y responde SOLO con JSON válido con esta estructura exacta:
{
  "espasmos_detectados": true|false,
  "tipo": "ninguno|temblor_leve|espasmo_muscular|convulsion|movimiento_involuntario",
  "frecuencia": "descripción de cuántas veces ocurre",
  "zona_afectada": "descripción de qué parte del cuerpo",
  "intensidad": "leve|moderada|severa|N/A",
  "posibles_causas": ["lista de posibles causas"],
  "conclusion": "evaluación general",
  "recomendacion": "qué debe hacer el dueño",
  "urgencia": "normal|observar|veterinario_pronto|emergencia"
}
Sé preciso. Si no detectas espasmos, indícalo claramente.
"""

@app.post("/analizar_video_respiracion")
async def analizar_video_respiracion(file: UploadFile = File(...), lang: str = Form("es")):
    """Analiza video de respiración con Gemini 1.5 Flash"""
    if not GEMINI_API_KEY:
        raise HTTPException(status_code=503, detail="Gemini API key no configurada")
    tmp_path = None
    try:
        contenido = await _read_upload_bytes(file, MAX_VIDEO_BYTES, "Video")
        print(f"📹 Video recibido: {len(contenido)} bytes")

        with tempfile.NamedTemporaryFile(delete=False, suffix=".mp4") as tmp:
            tmp.write(contenido)
            tmp_path = tmp.name
        print(f"📁 Guardado en: {tmp_path}")

        import time as _time
        print("⬆️ Subiendo a Gemini Files API...")
        video_file = genai.upload_file(tmp_path, mime_type="video/mp4")
        print(f"✅ Subido: {video_file.name} estado={video_file.state.name}")

        while video_file.state.name == "PROCESSING":
            _time.sleep(2)
            video_file = genai.get_file(video_file.name)
            print(f"⏳ Procesando... estado={video_file.state.name}")

        if video_file.state.name == "FAILED":
            raise ValueError("Gemini no pudo procesar el video")

        print("🤖 Analizando con Gemini...")
        model    = genai.GenerativeModel("gemini-2.5-flash")
        _pvr = PROMPT_VIDEO_RESPIRACION_EN if lang == "en" else PROMPT_VIDEO_RESPIRACION
        response = model.generate_content([video_file, _pvr])
        print(f"✅ Respuesta recibida: {response.text[:100]}")

        try: genai.delete_file(video_file.name)
        except: pass
        try: os.unlink(tmp_path)
        except: pass

        text = response.text.strip()
        if "```" in text:
            text = text.split("```")[1]
            if text.startswith("json"): text = text[4:]
        resultado = json.loads(text.strip())
        if lang == "en":
            resultado = motor._normalizar_respiracion_ingles(resultado) if motor else resultado
        return JSONResponse(content=resultado)

    except json.JSONDecodeError as e:
        print(f"❌ JSON parse error: {e}")
        return JSONResponse(content={
            "frecuencia_respiratoria": "indeterminada",
            "respiraciones_por_minuto": 0,
            "patron": "No se pudo parsear la respuesta",
            "signos_alarma": [],
            "conclusion": "Análisis incompleto",
            "recomendacion": "Intenta de nuevo",
            "urgencia": "observar"
        })
    except Exception as e:
        print(f"❌ ERROR analizar_video_respiracion: {type(e).__name__}: {e}")
        if tmp_path:
            try: os.unlink(tmp_path)
            except: pass
        raise _server_error()


@app.post("/analizar_video_espasmos")
async def analizar_video_espasmos(file: UploadFile = File(...), lang: str = Form("es")):
    """Analiza video de espasmos con Gemini 1.5 Flash"""
    if not GEMINI_API_KEY:
        raise HTTPException(status_code=503, detail="Gemini API key no configurada")
    tmp_path = None
    try:
        contenido = await _read_upload_bytes(file, MAX_VIDEO_BYTES, "Video")
        print(f"📹 Video espasmos recibido: {len(contenido)} bytes")

        with tempfile.NamedTemporaryFile(delete=False, suffix=".mp4") as tmp:
            tmp.write(contenido)
            tmp_path = tmp.name

        import time as _time
        video_file = genai.upload_file(tmp_path, mime_type="video/mp4")
        print(f"✅ Subido: {video_file.name}")

        while video_file.state.name == "PROCESSING":
            _time.sleep(2)
            video_file = genai.get_file(video_file.name)

        if video_file.state.name == "FAILED":
            raise ValueError("Gemini no pudo procesar el video")

        model    = genai.GenerativeModel("gemini-2.5-flash")
        _pve = PROMPT_VIDEO_ESPASMOS_EN if lang == "en" else PROMPT_VIDEO_ESPASMOS
        response = model.generate_content([video_file, _pve])
        print(f"✅ Espasmos respuesta: {response.text[:100]}")

        try: genai.delete_file(video_file.name)
        except: pass
        try: os.unlink(tmp_path)
        except: pass

        text = response.text.strip()
        if "```" in text:
            text = text.split("```")[1]
            if text.startswith("json"): text = text[4:]
        resultado = json.loads(text.strip())
        return JSONResponse(content=resultado)

    except json.JSONDecodeError as e:
        print(f"❌ JSON parse error espasmos: {e}")
        return JSONResponse(content={
            "espasmos_detectados": False,
            "tipo": "indeterminado",
            "frecuencia": "no determinada",
            "zona_afectada": "no determinada",
            "intensidad": "N/A",
            "posibles_causas": [],
            "conclusion": "Análisis incompleto",
            "recomendacion": "Intenta de nuevo",
            "urgencia": "observar"
        })
    except Exception as e:
        print(f"❌ ERROR analizar_video_espasmos: {type(e).__name__}: {e}")
        if tmp_path:
            try: os.unlink(tmp_path)
            except: pass
        raise _server_error()

@app.post("/analizar_video_encias")
async def analizar_video_encias(file: UploadFile = File(...), lang: str = Form("es")):
    """Analiza video de encías con Gemini 2.5 Flash"""
    if not GEMINI_API_KEY:
        raise HTTPException(status_code=503, detail="Gemini API key no configurada")

    contenido = await _read_upload_bytes(file, MAX_VIDEO_BYTES, "Video")
    with tempfile.NamedTemporaryFile(delete=False, suffix=".mp4") as tmp:
        tmp.write(contenido)
        tmp_path = tmp.name

    try:
        video_file = genai.upload_file(tmp_path, mime_type="video/mp4")
        timeout = 30
        while video_file.state.name == "PROCESSING" and timeout > 0:
            time.sleep(2)
            video_file = genai.get_file(video_file.name)
            timeout -= 2

        if lang == "en":
            prompt_encias = """You are a veterinary expert. Analyze this video of a cat or dog's gums carefully.
Respond ONLY with valid JSON, no extra text.
{"gum_analysis": true, "color_encias": "Pink/Pale/White/Yellow/Blue/Red - description", "hidratacion": "Adequate/Dehydrated/Severely dehydrated - based on moisture", "relleno_capilar": "Normal <2s/Slow 2-4s/Very slow >4s", "estado_general": "Normal/Alert/Emergency", "signos_alarma": ["list of concerning signs if any"], "urgencia": "normal/observar/veterinario_pronto/emergencia", "recomendacion": "specific recommendation", "conclusion": "brief overall conclusion"}
If gums are not visible: {"gum_analysis": false, "conclusion": "Gums not visible in video. Please lift the pet's lip gently."}"""
        else:
            prompt_encias = """Eres un veterinario experto. Analiza este video de las encías del gato o perro cuidadosamente.
Responde SOLO con JSON válido, sin texto extra.
{"gum_analysis": true, "color_encias": "Rosado/Pálido/Blanco/Amarillo/Azul/Rojo - descripción", "hidratacion": "Adecuada/Deshidratado/Gravemente deshidratado - según humedad", "relleno_capilar": "Normal <2s/Lento 2-4s/Muy lento >4s", "estado_general": "Normal/Alerta/Emergencia", "signos_alarma": ["lista de signos preocupantes si hay"], "urgencia": "normal/observar/veterinario_pronto/emergencia", "recomendacion": "recomendación específica", "conclusion": "conclusión general breve"}
Si no se ven las encías: {"gum_analysis": false, "conclusion": "No se visualizan las encías. Levanta suavemente el labio de tu mascota."}"""

        model = genai.GenerativeModel("gemini-2.5-flash")
        response = model.generate_content([video_file, prompt_encias])
        texto = response.text.strip()
        print(f"📝 Encias Gemini response: {texto[:300]}")

        # Parse JSON
        if "```json" in texto:
            texto = texto.split("```json")[1].split("```")[0].strip()
        elif "```" in texto:
            texto = texto.split("```")[1].strip()
        start = texto.find("{")
        end   = texto.rfind("}")
        if start != -1 and end != -1:
            texto = texto[start:end+1]
        resultado = json.loads(texto)

        try: genai.delete_file(video_file.name)
        except: pass

        return JSONResponse(content={
            **resultado,
            "tipo": "encias",
            "timestamp": time.time(),
            "urgencia":  resultado.get("urgencia", "normal"),
            "conclusion": resultado.get("conclusion", ""),
        })

    except Exception as e:
        print(f"❌ analizar_video_encias error: {e}")
        try: genai.delete_file(video_file.name)
        except: pass
        return JSONResponse(content={
            "gum_analysis": False,
            "tipo": "encias",
            "urgencia": "normal",
            "color_encias": "-",
            "hidratacion": "-",
            "relleno_capilar": "-",
            "conclusion": "Error al analizar. Intenta de nuevo.",
            "recomendacion": "Intenta grabar de nuevo con mejor iluminación.",
            "signos_alarma": [],
            "timestamp": time.time(),
        })
    finally:
        try: os.unlink(tmp_path)
        except: pass


@app.post("/analizar_nutricion")
async def analizar_nutricion(file: UploadFile = File(...), lang: str = Form("es")):
    """Analiza bolsa de alimento para mascotas con Groq Vision"""
    try:
        contenido = await _read_upload_bytes(file, MAX_IMAGE_BYTES, "Image")
        img_b64   = base64.b64encode(contenido).decode()

        if lang == "en":
            prompt = """You are an expert veterinary nutritionist. Analyze this pet food bag image.
Identify the brand, product name, and evaluate the ingredient quality.
Respond ONLY with valid JSON, no extra text:
{
  "alimento_detectado": true,
  "marca": "brand name",
  "tipo_alimento": "dry food for adult cats / puppy food / etc",
  "calidad_score": 7,
  "ingredientes_principales": ["Chicken", "Rice", "Corn", "..."],
  "ingredientes_malos": ["Corn syrup (empty calories)", "Artificial colors", "..."],
  "resumen": "Brief honest analysis of this food quality and what it means for the pet",
  "alternativas": [
    {"nombre": "Royal Canin Adult", "razon": "Higher protein, no fillers", "score": 8},
    {"nombre": "Orijen Cat & Kitten", "razon": "Biologically appropriate, grain free", "score": 9}
  ]
}
If no pet food is visible: {"alimento_detectado": false, "mensaje": "No pet food visible. Please point at the bag label or ingredient list."}
Rate from 1-10: 1-3=very poor (harmful fillers), 4-5=poor, 6-7=acceptable, 8-9=good, 10=premium."""
        else:
            prompt = """Eres un nutricionista veterinario experto. Analiza esta imagen de bolsa de alimento para mascotas.
Identifica la marca, producto y evalúa la calidad de los ingredientes.
Responde SOLO con JSON válido, sin texto extra:
{
  "alimento_detectado": true,
  "marca": "nombre de la marca",
  "tipo_alimento": "alimento seco para gatos adultos / cachorro / etc",
  "calidad_score": 7,
  "ingredientes_principales": ["Pollo", "Arroz", "Maíz", "..."],
  "ingredientes_malos": ["Maíz como primer ingrediente (relleno)", "Colorantes artificiales", "..."],
  "resumen": "Análisis honesto y breve de la calidad de este alimento y qué significa para la mascota",
  "alternativas": [
    {"nombre": "Royal Canin Adult", "razon": "Mayor proteína, sin rellenos", "score": 8},
    {"nombre": "Hills Science Diet", "razon": "Fórmula veterinaria balanceada", "score": 8}
  ]
}
Si no se ve alimento para mascotas: {"alimento_detectado": false, "mensaje": "No se detecta bolsa de alimento. Apunta a la etiqueta o lista de ingredientes."}
Califica del 1 al 10: 1-3=muy malo (rellenos dañinos), 4-5=malo, 6-7=aceptable, 8-9=bueno, 10=premium."""

        response = groq_client.chat.completions.create(
            model="meta-llama/llama-4-scout-17b-16e-instruct",
            messages=[{
                "role": "user",
                "content": [
                    {"type": "image_url", "image_url": {"url": f"data:image/jpeg;base64,{img_b64}"}},
                    {"type": "text", "text": prompt}
                ]
            }],
            max_tokens=1500,
            temperature=0.3,
        )
        texto = response.choices[0].message.content.strip()
        print(f"📝 Nutricion Groq response: {texto[:300]}")

        # Parse JSON
        if "```json" in texto:
            texto = texto.split("```json")[1].split("```")[0].strip()
        elif "```" in texto:
            texto = texto.split("```")[1].strip()
        start = texto.find("{")
        end   = texto.rfind("}")
        if start != -1 and end != -1:
            texto = texto[start:end+1]

        resultado = json.loads(texto)
        return JSONResponse(content={
            **resultado,
            "tipo": "nutricion",
            "timestamp": time.time(),
        })

    except HTTPException:
        raise
    except Exception as e:
        print(f"❌ analizar_nutricion error: {e}")
        return JSONResponse(content={
            "alimento_detectado": False,
            "tipo": "nutricion",
            "marca": "-",
            "tipo_alimento": "-",
            "calidad_score": 0,
            "ingredientes_principales": [],
            "ingredientes_malos": [],
            "resumen": "Error al analizar. Intenta de nuevo con mejor iluminación." if lang == "es" else "Analysis error. Try again with better lighting.",
            "alternativas": [],
            "timestamp": time.time(),
        })


@app.post("/vetbot")
async def vetbot(request: Request):
    """VetBot — Dr. MeowScan con Groq llama-4-scout"""
    try:
        content_length = _parse_content_length(request.headers.get("content-length"))
        if content_length and content_length > MAX_JSON_BODY_BYTES:
            raise _client_error("Request too large.")
        body = await request.json()
        messages  = body.get("messages", [])
        system    = body.get("system", "")
        lang      = body.get("lang", "es")

        # Build Groq messages
        groq_messages = []
        for m in messages:
            role    = m.get("role", "user")
            content = m.get("content", "")
            if role in ("user", "assistant") and content:
                groq_messages.append({"role": role, "content": content})

        # Need at least one message
        if not groq_messages:
            return JSONResponse(content={"reply": "Hola, ¿en qué puedo ayudarte?" if lang == "es" else "Hello, how can I help you?"})

        response = groq_client.chat.completions.create(
            model="meta-llama/llama-4-scout-17b-16e-instruct",
            messages=[
                {"role": "system", "content": system},
                *groq_messages,
            ],
            max_tokens=400,
            temperature=0.7,
        )

        reply = response.choices[0].message.content.strip()
        print(f"🩺 VetBot reply: {reply[:100]}")
        return JSONResponse(content={"reply": reply})

    except HTTPException:
        raise
    except Exception as e:
        print(f"❌ VetBot error: {e}")
        lang = "es"
        try:
            body = await request.json()
            lang = body.get("lang", "es")
        except: pass
        return JSONResponse(content={
            "reply": "Disculpa, tuve un problema. Intenta de nuevo." if lang == "es" else "Sorry, I had an issue. Please try again."
        })


@app.get("/modelos_gemini")
async def listar_modelos():
    """Lista los modelos Gemini disponibles"""
    try:
        modelos = [m.name for m in genai.list_models()]
        return JSONResponse(content={"modelos": modelos})
    except Exception as e:
        print(f"❌ listar_modelos error: {e}")
        raise _server_error()


# ════════════════════════════════════════════════════════════════
#  TRADUCTOR DE MASCOTAS — Video con subtítulos y marca de agua
# ════════════════════════════════════════════════════════════════

# Frases de fallback si Whisper no detecta sonido claro
_FRASES_FALLBACK = {
    "cat": {
        "es": [
            ("Dame comida. AHORA. Te dije que me dieras comida.", 94),
            ("Lo tiré porque quise. Y lo volvería a hacer.", 89),
            ("Esta casa es mía. Tú solo pagas el arriendo.", 91),
            ("Te quiero... pero solo cuando me conviene.", 76),
            ("¿Por qué me miras? Deja de mirarme.", 83),
        ],
        "en": [
            ("Feed me. Feed me NOW. I said feed me.", 94),
            ("I knocked it off because I wanted to.", 89),
            ("This house is mine. You just pay rent.", 91),
            ("I love you... but only when it suits me.", 76),
            ("Why are you looking at me? Stop looking at me.", 83),
        ],
    },
    "dog": {
        "es": [
            ("¡Necesito salir AHORA MISMO!", 87),
            ("¿Es comida? DAME LA COMIDA.", 92),
            ("Eres mi humano favorito, te quiero.", 78),
            ("El cartero es MUY sospechoso. Lo vi.", 95),
            ("¿Vamos a pasear? ¡VAMOS A PASEAR!", 98),
        ],
        "en": [
            ("I need to go outside RIGHT NOW!", 87),
            ("Is that food? GIVE ME THE FOOD.", 92),
            ("You are my favorite human, I love you.", 78),
            ("The mailman is VERY suspicious. I saw him.", 95),
            ("Are we going for a walk? WE ARE GOING FOR A WALK!", 98),
        ],
    },
}


def _ffmpeg_disponible() -> bool:
    """Verifica si ffmpeg está instalado en el sistema."""
    try:
        subprocess.run(["ffmpeg", "-version"],
                       capture_output=True, timeout=5)
        return True
    except Exception:
        return False


def _quemar_subtitulos(input_path: str, output_path: str,
                       frase: str, marca: str) -> bool:
    """
    Usa ffmpeg para quemar subtítulos y marca de agua en el video.
    Devuelve True si tuvo éxito, False si falló.
    """
    # Escapar comillas simples para ffmpeg
    frase_esc = frase.replace("'", "\\'").replace(":", "\\:")
    marca_esc = marca.replace("'", "\\'").replace(":", "\\:")

    # Filtro: subtítulo grande abajo + marca de agua pequeña arriba
    vf = (
        f"drawtext=text='{frase_esc}':"
        f"fontsize=26:fontcolor=white:"
        f"x=(w-text_w)/2:y=h-80:"
        f"box=1:boxcolor=black@0.65:boxborderw=8,"
        f"drawtext=text='{marca_esc}':"
        f"fontsize=13:fontcolor=white@0.75:"
        f"x=10:y=10:"
        f"box=1:boxcolor=black@0.45:boxborderw=4"
    )

    cmd = [
        "ffmpeg", "-y",
        "-i", input_path,
        "-vf", vf,
        "-c:v", "libx264",
        "-c:a", "aac",
        "-crf", "23",
        "-preset", "fast",
        output_path
    ]

    try:
        result = subprocess.run(cmd, capture_output=True,
                                timeout=120, text=True)
        return result.returncode == 0
    except Exception as e:
        print(f"❌ ffmpeg error: {e}")
        return False


def _extraer_audio(video_path: str, audio_path: str) -> bool:
    """Extrae el audio del video en formato wav para Whisper."""
    cmd = [
        "ffmpeg", "-y",
        "-i", video_path,
        "-vn",
        "-ac", "1",
        "-ar", "16000",
        "-f", "wav",
        audio_path
    ]
    try:
        result = subprocess.run(cmd, capture_output=True,
                                timeout=30, text=True)
        return result.returncode == 0
    except Exception:
        return False


def _generar_traduccion_con_ia(nombre: str, tipo: str,
                                lang: str, audio_path: str) -> tuple[str, int]:
    """
    Usa Whisper (Groq) para transcribir el audio y
    LLaMA para generar la frase graciosa traducida.
    """
    sonido = ""
    try:
        with open(audio_path, "rb") as f:
            transcripcion = groq_client.audio.transcriptions.create(
                file=(Path(audio_path).name, f),
                model="whisper-large-v3-turbo",
                language="es" if lang == "es" else "en",
            )
        sonido = transcripcion.text.strip()
        print(f"🎙️ Whisper transcripción: '{sonido}'")
    except Exception as e:
        print(f"⚠️ Whisper error: {e}")

    # Fallback si no hubo sonido
    pool = _FRASES_FALLBACK.get(tipo, _FRASES_FALLBACK["cat"]).get(
        lang, _FRASES_FALLBACK["cat"]["es"])

    if not sonido or len(sonido) < 3:
        return random.choice(pool)

    # LLaMA genera la traducción graciosa
    tipo_animal = "cat" if tipo == "cat" else "dog"
    tipo_es     = "gato" if tipo == "cat" else "perro"
    idioma      = "Spanish" if lang == "es" else "English"

    prompt = (
        f"You are a funny pet language translator.\n"
        f"The {tipo_animal}'s name is {nombre}.\n"
        f"Sound detected: '{sonido}'\n\n"
        f"Generate ONE short funny sentence (max 10 words) in {idioma} "
        f"representing what {nombre} is 'saying'. "
        f"Be humorous and relatable for pet owners. "
        f"Reply ONLY with the sentence, no quotes, no explanation."
    )

    try:
        resp = groq_client.chat.completions.create(
            model="llama-3.3-70b-versatile",
            messages=[{"role": "user", "content": prompt}],
            max_tokens=50,
            temperature=0.92,
        )
        frase = resp.choices[0].message.content.strip().strip('"').strip("'")
        prob  = random.randint(74, 96)
        print(f"🗣️ Traducción generada: '{frase}' ({prob}%)")
        return frase, prob
    except Exception as e:
        print(f"⚠️ LLaMA error: {e}")
        return random.choice(pool)


@app.post("/traducir_video")
async def traducir_video(
    video:  UploadFile = File(...),
    lang:   str        = Form("es"),
    tipo:   str        = Form("cat"),
    nombre: str        = Form("Mascota"),
):
    """
    Recibe video del gato/perro, genera traducción con IA
    y quema subtítulos + marca de agua con ffmpeg.
    Si ffmpeg no está disponible, devuelve solo JSON con la traducción.
    """
    job_id    = uuid.uuid4().hex
    tmp_dir   = Path(tempfile.gettempdir()) / "meowscan"
    tmp_dir.mkdir(exist_ok=True)

    in_path   = tmp_dir / f"{job_id}_in.mp4"
    aud_path  = tmp_dir / f"{job_id}.wav"
    out_path  = tmp_dir / f"{job_id}_out.mp4"

    frase = ""
    prob  = 85

    try:
        # ── 1. Guardar video recibido ──────────────────────────
        contenido = await _read_upload_bytes(video, MAX_VIDEO_BYTES, "Video")
        in_path.write_bytes(contenido)
        print(f"📹 Video recibido: {len(contenido) / 1024:.1f} KB — {nombre} ({tipo})")

        # ── 2. Extraer audio y generar traducción ──────────────
        audio_ok = _extraer_audio(str(in_path), str(aud_path))
        if audio_ok and aud_path.exists():
            frase, prob = await asyncio.to_thread(
                _generar_traduccion_con_ia, nombre, tipo, lang, str(aud_path))
        else:
            pool  = _FRASES_FALLBACK.get(tipo, _FRASES_FALLBACK["cat"]).get(
                lang, _FRASES_FALLBACK["cat"]["es"])
            frase, prob = random.choice(pool)

        # ── 3. Marca de agua ───────────────────────────────────
        prob_label = "probabilidad" if lang == "es" else "probability"
        marca = f"MeowScanAI  |  {prob}% {prob_label}"

        # ── 4. Quemar subtítulos con ffmpeg ────────────────────
        if _ffmpeg_disponible():
            exito = await asyncio.to_thread(
                _quemar_subtitulos,
                str(in_path), str(out_path), frase, marca)

            if exito and out_path.exists():
                print(f"✅ Video procesado listo: {out_path.name}")
                # Limpiar inputs
                for p in [in_path, aud_path]:
                    try: p.unlink()
                    except: pass
                # Devolver video con subtítulos quemados
                return FileResponse(
                    str(out_path),
                    media_type="video/mp4",
                    filename=f"meowscan_{nombre}_{job_id[:6]}.mp4",
                )
            else:
                print("⚠️ ffmpeg falló — devolviendo JSON")
        else:
            print("⚠️ ffmpeg no instalado — devolviendo JSON")

        # ── 5. Fallback: devolver solo JSON ────────────────────
        #    Flutter compartirá el video original + texto
        emoji = "🐱" if tipo == "cat" else "🐶"
        return JSONResponse(content={
            "frase":        frase,
            "probabilidad": prob,
            "emoji":        emoji,
            "contexto":     (f"Basado en los sonidos de {nombre}"
                             if lang == "es"
                             else f"Based on {nombre}'s sounds"),
            "mood":         "Expresivo" if lang == "es" else "Expressive",
            "mood_color":   "#A29BFE",
        })

    except Exception as e:
        print(f"❌ traducir_video error: {e}")
        pool  = _FRASES_FALLBACK.get(tipo, _FRASES_FALLBACK["cat"]).get(
            lang, _FRASES_FALLBACK["cat"]["es"])
        frase, prob = random.choice(pool)
        return JSONResponse(content={
            "frase":        frase,
            "probabilidad": prob,
            "emoji":        "🐱" if tipo == "cat" else "🐶",
            "contexto":     f"Basado en {nombre}" if lang == "es" else f"Based on {nombre}",
            "mood":         "Expresivo" if lang == "es" else "Expressive",
            "mood_color":   "#A29BFE",
        })
    finally:
        for p in [in_path, aud_path]:
            try: p.unlink()
            except: pass

if __name__ == "__main__":
    print("=" * 55)
    print("  🐱  MEOWSCAN v3.1 — GROQ VISION IA")
    print("=" * 55)
    uvicorn.run(app, host=HOST, port=PORT, reload=False)
