"""
🐱 MEOWSCAN v3.1 - BACKEND CON GROQ VISION IA
════════════════════════════════════════════════════════════════
FastAPI + OpenCV + Groq Vision
Análisis: raza, peso, color, orejas, mood, salud + vómito
════════════════════════════════════════════════════════════════
"""

import cv2
import numpy as np
import base64
import time
import os
import json
import urllib.request
from io import BytesIO
from typing import List, Dict, Any, Optional

from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse, FileResponse
from PIL import Image
import uvicorn
from groq import Groq

# ── Configuración ─────────────────────────────────────────────
HOST      = "0.0.0.0"
PORT      = 8000
GROQ_KEY  = os.environ.get("GROQ_API_KEY", "")

# ── Cliente Groq ──────────────────────────────────────────────
groq_client = Groq(api_key=GROQ_KEY)

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
PROMPT_ES = """Eres un veterinario experto en animales de compañía con 30 años de experiencia en gatos y perros.
Analiza esta imagen y responde ÚNICAMENTE con un objeto JSON válido, sin texto adicional, sin markdown, sin explicaciones.

Primero determina si hay un gato o un perro en la imagen.

INSTRUCCIONES CRÍTICAS PARA EL PESO Y ESTADO CORPORAL:
- Sé MUY estricto al evaluar el estado corporal. La mayoría de mascotas domésticas tienen sobrepeso.
- Un gato doméstico promedio saludable pesa entre 3.5 y 4.5 kg. Si se ve grande o redondo, probablemente tiene sobrepeso.
- Un gato que pesa más de 5 kg casi siempre tiene sobrepeso u obesidad.
- NO digas "Peso ideal" si el animal se ve robusto, grande o con grasa visible.
- Usa el sistema BCS (Body Condition Score) del 1 al 9 de forma precisa:
  * 1-3: Bajo peso (costillas muy visibles, sin grasa)
  * 4-5: Peso ideal (costillas palpables con poca grasa)
  * 6-7: Sobrepeso (costillas difíciles de palpar, grasa visible)
  * 8-9: Obesidad (costillas no palpables, grasa excesiva, abdomen colgante)
- Si el gato se ve gordo o robusto, asigna BCS 6 o mayor.
- alerta_peso debe ser true si BCS >= 6

INSTRUCCIONES PARA OREJAS:
- Si las orejas están aplastadas, hacia atrás con fuerza o en posición de dolor/miedo, alerta_veterinario debe ser true
- Posiciones de alerta: Aplastadas, Giradas hacia atrás, Pegadas a la cabeza

El JSON debe tener exactamente esta estructura:
{
  "mascota_detectada": true o false,
  "tipo": "gato" o "perro",
  "raza": {
    "nombre": "nombre de la raza en español",
    "confianza": número del 0 al 100,
    "descripcion": "descripción breve de la raza"
  },
  "peso": {
    "estimado_kg": número decimal MUY preciso según tamaño real del animal,
    "estimado_lb": número decimal,
    "rango_min_kg": número decimal,
    "rango_max_kg": número decimal,
    "confianza": "Alta, Media o Baja"
  },
  "color": {
    "color_principal": "nombre del color en español",
    "colores_secundarios": ["color1", "color2"],
    "patron": "Sólido, Atigrado, Bicolor, Tricolor, Carey, Manchado u otro",
    "hex_aproximado": "#xxxxxx"
  },
  "estado_corporal": {
    "bcs": número del 1 al 9 MUY PRECISO,
    "estado": "Bajo peso, Algo delgado, Peso ideal, Sobrepeso u Obesidad",
    "emoji": "emoji apropiado",
    "color_hex": "#52C97A para ideal, #FF9800 para sobrepeso/algo delgado, #F44336 para obesidad/bajo peso",
    "salud_pct": número del 0 al 100,
    "consejo": "consejo personalizado y empático — si tiene sobrepeso u obesidad menciona dieta específica y ejercicio",
    "alerta_peso": true si BCS >= 6 o false si BCS <= 5,
    "mensaje_alerta": "mensaje de alerta si alerta_peso es true, sino null"
  },
  "orejas": {
    "posicion": "Erguidas, Hacia adelante, Hacia atrás, Aplastadas o Relajadas",
    "estado": "nombre descriptivo del estado",
    "significado": "qué significa esta posición de orejas",
    "alerta": true o false,
    "alerta_veterinario": true si la posición indica dolor o miedo intenso, sino false,
    "mensaje_veterinario": "mensaje urgente si alerta_veterinario es true, sino null"
  },
  "cola": {
    "posicion": "Alta, Baja, Horizontal, Entre las patas, Moviéndose o No visible",
    "significado": "qué significa esta posición de cola",
    "visible": true o false
  },
  "gesto": {
    "nombre": "nombre del estado de ánimo con emoji",
    "emocion": "Feliz, Relajado, Curioso, Alerta, Asustado, Enojado, Juguetón o Somnoliento",
    "descripcion": "descripción del comportamiento observado",
    "nivel_estres": número del 0 al 10,
    "cola_posicion": "descripción si es visible, sino null"
  },
  "salud_visual": {
    "ojos": "descripción del estado de los ojos",
    "pelaje": "descripción del estado del pelaje",
    "observaciones": "cualquier observación de salud relevante"
  }
}

Si no hay gato ni perro en la imagen, devuelve: {"mascota_detectada": false}
Responde SOLO el JSON, nada más."""


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

    def _llamar_groq(self, img_b64: str, prompt: str, max_tokens: int = 1500) -> dict:
        response = groq_client.chat.completions.create(
            model="meta-llama/llama-4-maverick-17b-128e-instruct",
            messages=[{
                "role": "user",
                "content": [
                    {"type": "image_url", "image_url": {"url": f"data:image/jpeg;base64,{img_b64}"}},
                    {"type": "text", "text": prompt},
                ],
            }],
            max_tokens=max_tokens,
            temperature=0.1,
        )
        texto = response.choices[0].message.content.strip()
        texto = texto.replace("```json", "").replace("```", "").strip()
        return json.loads(texto)

    # ── Analizar mascota ──────────────────────────────────────
    def analizar_con_groq(self, img_bgr: np.ndarray) -> Dict[str, Any]:
        img_b64 = self._img_to_b64(img_bgr)
        try:
            return self._llamar_groq(img_b64, PROMPT_ES)
        except json.JSONDecodeError as e:
            print(f"⚠️ JSON parse error: {e}")
            return self._resultado_fallback()
        except Exception as e:
            print(f"❌ Groq error: {e}")
            return self._resultado_fallback()

    # ── Analizar vómito ───────────────────────────────────────
    def analizar_vomito_con_groq(self, img_bgr: np.ndarray) -> Dict[str, Any]:
        img_b64 = self._img_to_b64(img_bgr)
        try:
            return self._llamar_groq(img_b64, PROMPT_VOMITO, max_tokens=1200)
        except json.JSONDecodeError as e:
            print(f"⚠️ JSON vomito parse error: {e}")
            return {"vomito_detectado": False}
        except Exception as e:
            print(f"❌ Groq vomito error: {e}")
            return {"vomito_detectado": False}

    def _resultado_fallback(self) -> Dict[str, Any]:
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
    def analizar_frame(self, img_bytes: bytes) -> Dict[str, Any]:
        arr = np.frombuffer(img_bytes, np.uint8)
        img = cv2.imdecode(arr, cv2.IMREAD_COLOR)
        if img is None:
            raise ValueError("No se pudo decodificar la imagen")

        caras     = self.detectar_cara(img)
        resultado = self.analizar_con_groq(img)

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

    # ── ANÁLISIS COMPLETO VÓMITO ──────────────────────────────
    def analizar_frame_vomito(self, img_bytes: bytes) -> Dict[str, Any]:
        arr = np.frombuffer(img_bytes, np.uint8)
        img = cv2.imdecode(arr, cv2.IMREAD_COLOR)
        if img is None:
            raise ValueError("No se pudo decodificar la imagen")

        resultado = self.analizar_vomito_con_groq(img)

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
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.on_event("startup")
async def startup():
    global motor
    print("\n🚀 Iniciando MeowScan API v3.1 con Groq Vision...")
    motor = MotorGroq()
    print("✅ Servidor listo!\n")

@app.get("/perfil")
def perfil():
    return FileResponse("cat_profile.html")

@app.get("/")
def root():
    return {"status": "ok", "app": "MeowScan API", "version": "3.1", "ia": "Groq Vision"}

@app.get("/health")
def health():
    return {"status": "ok", "version": "3.1", "ia_engine": "Groq Vision llama-4-maverick", "groq": True}

@app.post("/analizar")
async def analizar(file: UploadFile = File(...), sesion_id: str = "default"):
    if motor is None:
        raise HTTPException(status_code=503, detail="Motor no inicializado")
    contenido = await file.read()
    try:
        resultado = motor.analizar_frame(contenido)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
    return JSONResponse(content=resultado)

@app.post("/analizar_vomito")
async def analizar_vomito(file: UploadFile = File(...), sesion_id: str = "default"):
    if motor is None:
        raise HTTPException(status_code=503, detail="Motor no inicializado")
    contenido = await file.read()
    try:
        resultado = motor.analizar_frame_vomito(contenido)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
    return JSONResponse(content=resultado)


if __name__ == "__main__":
    print("=" * 55)
    print("  🐱  MEOWSCAN v3.1 — GROQ VISION IA")
    print("=" * 55)
    uvicorn.run(app, host=HOST, port=PORT, reload=False)
