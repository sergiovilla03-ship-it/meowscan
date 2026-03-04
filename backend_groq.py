"""
🐱 MEOWSCAN v3.0 - BACKEND CON GROQ VISION IA
════════════════════════════════════════════════════════════════
FastAPI + OpenCV + Groq Vision (llama-3.2-11b-vision-preview)
Análisis ultra preciso: raza, peso, color, orejas, mood, salud
════════════════════════════════════════════════════════════════

INSTALACIÓN:
    pip install fastapi uvicorn opencv-python numpy pillow python-multipart groq

EJECUTAR:
    python backend_groq.py
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
from fastapi.responses import JSONResponse
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

# ── Prompt para Groq Vision ───────────────────────────────────
PROMPT_ES = """Eres un veterinario experto en felinos con 20 años de experiencia.
Analiza esta imagen de un gato y responde ÚNICAMENTE con un objeto JSON válido, sin texto adicional, sin markdown, sin explicaciones.

El JSON debe tener exactamente esta estructura:
{
  "gato_detectado": true o false,
  "raza": {
    "nombre": "nombre de la raza en español",
    "confianza": número del 0 al 100,
    "descripcion": "descripción breve de la raza"
  },
  "peso": {
    "estimado_kg": número decimal,
    "estimado_lb": número decimal,
    "rango_min_kg": número decimal,
    "rango_max_kg": número decimal,
    "confianza": "Alta, Media o Baja"
  },
  "color": {
    "color_principal": "nombre del color en español",
    "colores_secundarios": ["color1", "color2"],
    "patron": "Sólido, Atigrado, Bicolor, Tricolor, Carey,點(spotted), Colorpoint u otro",
    "hex_aproximado": "#xxxxxx"
  },
  "estado_corporal": {
    "bcs": número del 1 al 9,
    "estado": "Bajo peso, Algo delgado, Peso ideal, Sobrepeso u Obesidad",
    "emoji": "emoji apropiado",
    "color_hex": "#52C97A para ideal, #FF9800 para sobrepeso/delgado, #F44336 para obesidad/bajo peso",
    "salud_pct": número del 0 al 100,
    "consejo": "consejo personalizado y empático para el dueño"
  },
  "orejas": {
    "posicion": "Erguidas, Hacia adelante, Hacia atrás, Aplastadas o Relajadas",
    "estado": "nombre descriptivo del estado",
    "significado": "qué significa esta posición de orejas",
    "alerta": true o false
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

Si no hay gato en la imagen, devuelve: {"gato_detectado": false}
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

    # ── Detectar cara con OpenCV ──────────────────────────────
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

    # ── Convertir imagen a base64 para Groq ──────────────────
    def _img_to_b64(self, img_bgr: np.ndarray, max_size: int = 800) -> str:
        h, w = img_bgr.shape[:2]
        if max(h, w) > max_size:
            scale = max_size / max(h, w)
            img_bgr = cv2.resize(img_bgr,
                (int(w * scale), int(h * scale)))

        img_rgb = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2RGB)
        pil_img = Image.fromarray(img_rgb)
        buf     = BytesIO()
        pil_img.save(buf, format="JPEG", quality=85)
        return base64.b64encode(buf.getvalue()).decode("utf-8")

    # ── Analizar con Groq Vision ──────────────────────────────
    def analizar_con_groq(self, img_bgr: np.ndarray) -> Dict[str, Any]:
        img_b64 = self._img_to_b64(img_bgr)

        try:
            response = groq_client.chat.completions.create(
                model="meta-llama/llama-4-maverick-17b-128e-instruct",
                messages=[
                    {
                        "role": "user",
                        "content": [
                            {
                                "type":      "image_url",
                                "image_url": {
                                    "url": f"data:image/jpeg;base64,{img_b64}"
                                },
                            },
                            {
                                "type": "text",
                                "text": PROMPT_ES,
                            },
                        ],
                    }
                ],
                max_tokens=1500,
                temperature=0.1,
            )

            texto = response.choices[0].message.content.strip()

            # Limpiar posible markdown
            texto = texto.replace("```json", "").replace("```", "").strip()

            resultado = json.loads(texto)
            return resultado

        except json.JSONDecodeError as e:
            print(f"⚠️ JSON parse error: {e}")
            return self._resultado_fallback()
        except Exception as e:
            print(f"❌ Groq error: {e}")
            return self._resultado_fallback()

    def _resultado_fallback(self) -> Dict[str, Any]:
        return {
            "gato_detectado": True,
            "raza": {
                "nombre":      "No determinada",
                "confianza":   30,
                "descripcion": "No se pudo determinar la raza"
            },
            "peso": {
                "estimado_kg":  4.5,
                "estimado_lb":  9.9,
                "rango_min_kg": 3.5,
                "rango_max_kg": 5.5,
                "confianza":    "Baja"
            },
            "color": {
                "color_principal":    "No determinado",
                "colores_secundarios": [],
                "patron":             "No determinado",
                "hex_aproximado":     "#888888"
            },
            "estado_corporal": {
                "bcs":       5,
                "estado":    "Peso ideal",
                "emoji":     "✅",
                "color_hex": "#52C97A",
                "salud_pct": 75,
                "consejo":   "No se pudo analizar completamente. Intenta con mejor iluminación."
            },
            "orejas": {
                "posicion":    "No determinada",
                "estado":      "No determinado",
                "significado": "No se pudo analizar",
                "alerta":      False
            },
            "gesto": {
                "nombre":        "No determinado",
                "emocion":       "Desconocido",
                "descripcion":   "No se pudo analizar el estado de ánimo",
                "nivel_estres":  0,
                "cola_posicion": None
            },
            "salud_visual": {
                "ojos":           "No determinado",
                "pelaje":         "No determinado",
                "observaciones":  "Análisis no disponible"
            }
        }

    # ── Anotar imagen con resultados ──────────────────────────
    def anotar_imagen(self, img_bgr: np.ndarray,
                      caras: list, resultado: Dict) -> np.ndarray:
        img = img_bgr.copy()
        raza  = resultado.get("raza", {}).get("nombre", "")
        corp  = resultado.get("estado_corporal", {}).get("estado", "")

        for (x, y, w, h) in caras:
            cv2.rectangle(img, (x, y), (x+w, y+h), (0, 215, 100), 2)
            label = f"{raza} | {corp}"
            cv2.putText(img, label, (x, max(y-8, 20)),
                cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 215, 100), 2)

        return img

    # ── ANÁLISIS COMPLETO ─────────────────────────────────────
    def analizar_frame(self, img_bytes: bytes) -> Dict[str, Any]:
        arr = np.frombuffer(img_bytes, np.uint8)
        img = cv2.imdecode(arr, cv2.IMREAD_COLOR)
        if img is None:
            raise ValueError("No se pudo decodificar la imagen")

        # Detectar cara con OpenCV
        caras = self.detectar_cara(img)

        # Analizar con Groq Vision
        resultado = self.analizar_con_groq(img)

        if not resultado.get("gato_detectado", False):
            return {
                "gato_detectado":   False,
                "timestamp":        time.time(),
                "caras_detectadas": len(caras),
                "mensaje": "No se detectó un gato en la imagen. "
                           "Asegúrate de apuntar bien la cámara."
            }

        # Anotar imagen
        img_anotada = self.anotar_imagen(img, caras, resultado)
        _, buf = cv2.imencode(".jpg", img_anotada,
                              [cv2.IMWRITE_JPEG_QUALITY, 75])
        img_b64 = base64.b64encode(buf.tobytes()).decode()

        # Adaptar al formato que espera la app Flutter
        raza_info  = resultado.get("raza", {})
        peso_info  = resultado.get("peso", {})
        color_info = resultado.get("color", {})
        corp_info  = resultado.get("estado_corporal", {})
        gesto_info = resultado.get("gesto", {})
        orejas     = resultado.get("orejas", {})
        salud_vis  = resultado.get("salud_visual", {})

        return {
            "gato_detectado":   True,
            "timestamp":        time.time(),
            "caras_detectadas": len(caras),
            "imagen_anotada":   img_b64,

            # Raza
            "raza": {
                "raza":       raza_info.get("nombre", "-"),
                "confianza":  raza_info.get("confianza", 0),
                "descripcion":raza_info.get("descripcion", ""),
                "peso_base":  peso_info.get("estimado_kg", 4.5),
            },

            # Peso
            "peso": {
                "peso_kg":       peso_info.get("estimado_kg", 0),
                "peso_lb":       peso_info.get("estimado_lb", 0),
                "rango":         f'{peso_info.get("rango_min_kg",0)}-{peso_info.get("rango_max_kg",0)} kg',
                "area_relativa": 0,
                "confianza":     peso_info.get("confianza", "Media"),
            },

            # Color
            "color": {
                "color_principal":    color_info.get("color_principal", "-"),
                "colores_secundarios":color_info.get("colores_secundarios", []),
                "patron":             color_info.get("patron", "-"),
                "hex":                color_info.get("hex_aproximado", "#888888"),
            },

            # Estado corporal
            "estado_corporal": {
                "bcs":       corp_info.get("bcs", 5),
                "bcs_max":   9,
                "estado":    corp_info.get("estado", "-"),
                "emoji":     corp_info.get("emoji", "🐱"),
                "color_hex": corp_info.get("color_hex", "#52C97A"),
                "salud_pct": corp_info.get("salud_pct", 75),
                "consejo":   corp_info.get("consejo", ""),
            },

            # Gesto / Mood
            "gesto": {
                "nombre":        gesto_info.get("nombre", "-"),
                "emocion":       gesto_info.get("emocion", "-"),
                "descripcion":   gesto_info.get("descripcion", "-"),
                "nivel_estres":  gesto_info.get("nivel_estres", 0),
                "movimiento":    "alto" if gesto_info.get("nivel_estres", 0) > 5 else "bajo",
                "cola_posicion": gesto_info.get("cola_posicion"),
                "confianza":     90,
            },

            # Orejas
            "orejas": {
                "posicion":    orejas.get("posicion", "-"),
                "estado":      orejas.get("estado", "-"),
                "significado": orejas.get("significado", "-"),
                "alerta":      orejas.get("alerta", False),
            },

            # Salud visual
            "salud_visual": {
                "ojos":          salud_vis.get("ojos", "-"),
                "pelaje":        salud_vis.get("pelaje", "-"),
                "observaciones": salud_vis.get("observaciones", "-"),
            },
        }


# ════════════════════════════════════════════════════════════════
#  FASTAPI APP
# ════════════════════════════════════════════════════════════════

app   = FastAPI(title="MeowScan API v3 — Groq Vision", version="3.0")
motor: Optional[MotorGroq] = None
from fastapi.staticfiles import StaticFiles
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
    print("\n🚀 Iniciando MeowScan API v3 con Groq Vision...")
    motor = MotorGroq()
    print("✅ Servidor listo!\n")

@app.get("/perfil")
def perfil():
    return FileResponse("cat_profile.html")
@app.get("/")
def root():
    return {"status": "ok", "app": "MeowScan API", "version": "3.0", "ia": "Groq Vision"}

@app.get("/health")
def health():
    return {
        "status":    "ok",
        "version":   "3.0",
        "ia_engine": "Groq Vision llama-4-scout",
        "groq":      True,
        "tensorflow": False,
    }

@app.post("/analizar")
async def analizar(
    file:      UploadFile = File(...),
    sesion_id: str        = "default",
):
    if motor is None:
        raise HTTPException(status_code=503, detail="Motor no inicializado")

    contenido = await file.read()

    try:
        resultado = motor.analizar_frame(contenido)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

    return JSONResponse(content=resultado)


if __name__ == "__main__":
    print("=" * 55)
    print("  🐱  MEOWSCAN v3 — GROQ VISION IA")
    print("=" * 55)
    uvicorn.run(app, host=HOST, port=PORT, reload=False)
