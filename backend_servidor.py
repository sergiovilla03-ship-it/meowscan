"""
🐱 MEOWSCAN - BACKEND DE ANÁLISIS FELINO
════════════════════════════════════════════════════════════════
FastAPI + OpenCV + TensorFlow/MobileNetV2
Analiza: raza, peso estimado, color, estado corporal, gestos/mood
════════════════════════════════════════════════════════════════

INSTALACIÓN:
    pip install fastapi uvicorn opencv-python tensorflow numpy pillow python-multipart

EJECUTAR:
    python backend_servidor.py

IP de tu PC:
    Windows → ipconfig
    Mac/Linux → ifconfig
El celular debe estar en la MISMA red WiFi.
"""

import cv2
import numpy as np
import base64
import time
import os
import math
import urllib.request
from io import BytesIO
from typing import Optional, List, Dict, Any

from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from PIL import Image
import uvicorn

# ── TensorFlow ────────────────────────────────────────────────
try:
    import tensorflow as tf
    from tensorflow.keras.applications import MobileNetV2
    from tensorflow.keras.applications.mobilenet_v2 import preprocess_input, decode_predictions
    from tensorflow.keras.preprocessing.image import img_to_array
    TF_DISPONIBLE = True
    print("✅ TensorFlow:", tf.__version__)
except ImportError:
    TF_DISPONIBLE = False
    print("⚠️  TensorFlow no disponible - solo análisis visual básico")

HOST             = "0.0.0.0"
PORT             = 8000
CONFIANZA_MINIMA = 0.25

# ── Cascades ─────────────────────────────────────────────────
CASCADES_URL = {
    "haarcascade_frontalcatface.xml":
        "https://raw.githubusercontent.com/opencv/opencv/master/data/haarcascades/haarcascade_frontalcatface.xml",
    "haarcascade_frontalcatface_extended.xml":
        "https://raw.githubusercontent.com/opencv/opencv/master/data/haarcascades/haarcascade_frontalcatface_extended.xml",
}

# ── Razas conocidas (ImageNet → nombre amigable) ──────────────
RAZAS_MAP = {
    "tabby":        {"nombre": "Tabby / Común",      "peso_base": 4.5},
    "tiger_cat":    {"nombre": "Tiger Cat",           "peso_base": 4.8},
    "Persian_cat":  {"nombre": "Persa",               "peso_base": 5.5},
    "Siamese_cat":  {"nombre": "Siamés",              "peso_base": 4.0},
    "Egyptian_cat": {"nombre": "Egipcio / Abisinio",  "peso_base": 3.8},
    "lynx":         {"nombre": "Lince / Maine Coon",  "peso_base": 7.0},
    "cougar":       {"nombre": "Savannah / Exótico",  "peso_base": 6.5},
}

CLASES_GATO = set(RAZAS_MAP.keys()) | {"leopard", "snow_leopard", "lion", "tiger", "jaguar"}

# ── Análisis de gestos/mood ───────────────────────────────────
GESTOS = [
    {"nombre": "Relajado 😌",      "descripcion": "Ojos semicerrados, postura tranquila. Tu gato está en paz."},
    {"nombre": "Curioso 👀",        "descripcion": "Orejas hacia adelante, ojos bien abiertos. Explorando el entorno."},
    {"nombre": "Alerta 😤",         "descripcion": "Postura tensa, orejas erguidas. Detectó algo interesante."},
    {"nombre": "Juguetón 🎾",       "descripcion": "Movimientos activos, cola en alto. ¡Hora de jugar!"},
    {"nombre": "Somnoliento 😴",    "descripcion": "Ojos muy cerrados, sin moverse. Listo para una siesta."},
    {"nombre": "Hambriento 🍽️",    "descripcion": "Maullando frecuentemente, acercándose. Hora de comer."},
    {"nombre": "Cómodo y feliz 😺", "descripcion": "Ronroneando, amasando. Muy contento contigo."},
]


# ════════════════════════════════════════════════════════════════
#  MOTOR DE ANÁLISIS
# ════════════════════════════════════════════════════════════════

class MotorAnalisis:

    def __init__(self):
        self.cascade_normal = None
        self.cascade_ext    = None
        self.modelo_tf      = None
        self.frames_buffer: List[np.ndarray] = []
        self._init_cascades()
        self._init_tensorflow()

    # ── Cascades ─────────────────────────────────────────────
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

    # ── TensorFlow ───────────────────────────────────────────
    def _init_tensorflow(self):
        if not TF_DISPONIBLE:
            return
        print("🔄 Cargando MobileNetV2...")
        try:
            self.modelo_tf = MobileNetV2(weights="imagenet")
            print("✅ MobileNetV2 listo")
        except Exception as e:
            print(f"⚠️  {e}")

    # ── Detectar cara de gato ─────────────────────────────────
    def detectar_cara(self, gris: np.ndarray) -> List[tuple]:
        params = dict(scaleFactor=1.1, minNeighbors=4, minSize=(50, 50))
        result = []
        for cascade in [self.cascade_normal, self.cascade_ext]:
            if cascade and not cascade.empty():
                det = cascade.detectMultiScale(gris, **params)
                if len(det) > 0:
                    result.extend(det.tolist())
        return result

    # ── Clasificar raza con TF ────────────────────────────────
    def clasificar_raza(self, img_bgr: np.ndarray) -> Dict[str, Any]:
        if self.modelo_tf is None:
            return {"raza": "No determinada", "confianza": 0.0, "peso_base": 4.5}

        img = cv2.resize(img_bgr, (224, 224))
        img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        arr = img_to_array(img)
        arr = np.expand_dims(arr, axis=0)
        arr = preprocess_input(arr)

        preds = self.modelo_tf.predict(arr, verbose=0)
        top5  = decode_predictions(preds, top=5)[0]

        for _, clase, conf in top5:
            if clase in CLASES_GATO and conf >= CONFIANZA_MINIMA:
                info = RAZAS_MAP.get(clase, {"nombre": clase.replace("_"," ").title(), "peso_base": 4.5})
                return {
                    "raza":       info["nombre"],
                    "confianza":  round(float(conf) * 100, 1),
                    "peso_base":  info["peso_base"],
                    "clase_raw":  clase,
                }

        return {"raza": "Mixto / No determinada", "confianza": 30.0, "peso_base": 4.5}

    # ── Analizar color del pelaje ─────────────────────────────
    def analizar_color(self, img_bgr: np.ndarray) -> Dict[str, Any]:
        img_rgb  = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2RGB)
        pixels   = img_rgb.reshape(-1, 3).astype(np.float32)

        # K-means con 4 colores dominantes
        criteria = (cv2.TERM_CRITERIA_EPS + cv2.TERM_CRITERIA_MAX_ITER, 20, 1.0)
        _, labels, centers = cv2.kmeans(pixels, 4, None, criteria, 5, cv2.KMEANS_RANDOM_CENTERS)
        centers = centers.astype(int)

        # Color más frecuente
        counts    = np.bincount(labels.flatten())
        principal = centers[np.argmax(counts)]
        r, g, b   = int(principal[0]), int(principal[1]), int(principal[2])

        # Mapear a nombre de color
        nombre = self._nombre_color(r, g, b)

        # Detectar patrones
        std = np.std(pixels, axis=0).mean()
        patron = "Atigrado" if std > 55 else ("Bicolor" if std > 30 else "Sólido")

        return {
            "color_principal": nombre,
            "patron":          patron,
            "hex":             f"#{r:02x}{g:02x}{b:02x}",
            "rgb":             [r, g, b],
        }

    def _nombre_color(self, r, g, b) -> str:
        h, s, v = self._rgb_to_hsv(r, g, b)
        if v < 40:                    return "Negro"
        if v > 200 and s < 30:        return "Blanco"
        if v > 120 and s < 40:        return "Gris"
        if 20 < h < 40 and s > 80:    return "Naranja / Rojizo"
        if 10 < h < 25:               return "Marrón / Canela"
        if h < 10 or h > 350:         return "Rojizo"
        if 40 < h < 70:               return "Dorado / Crema"
        if 70 < h < 160:              return "Verde oliva"
        return "Mixto"

    def _rgb_to_hsv(self, r, g, b):
        r_, g_, b_ = r/255, g/255, b/255
        mx = max(r_, g_, b_)
        mn = min(r_, g_, b_)
        df = mx - mn
        if mx == mn:     h = 0
        elif mx == r_:   h = (60 * ((g_-b_)/df) + 360) % 360
        elif mx == g_:   h = (60 * ((b_-r_)/df) + 120) % 360
        else:            h = (60 * ((r_-g_)/df) + 240) % 360
        s = 0 if mx == 0 else (df/mx)*255
        v = mx*255
        return h, s, v

    # ── Estimar tamaño y peso ─────────────────────────────────
    def estimar_peso(self, img_bgr: np.ndarray, peso_base: float) -> Dict[str, Any]:
        """
        Estimación basada en:
        - Área del contorno del gato relativa al frame
        - Proporción corporal
        - Peso base de la raza
        """
        H, W = img_bgr.shape[:2]
        area_frame = H * W

        gris   = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2GRAY)
        blur   = cv2.GaussianBlur(gris, (15, 15), 0)
        _, bin = cv2.threshold(blur, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)

        contornos, _ = cv2.findContours(bin, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

        if not contornos:
            return {"peso_kg": peso_base, "peso_lb": round(peso_base * 2.205, 1),
                    "area_relativa": 0, "confianza": "Baja"}

        mayor = max(contornos, key=cv2.contourArea)
        area  = cv2.contourArea(mayor)
        ratio = area / area_frame  # 0.0 – 1.0

        # Factor de ajuste por tamaño en frame
        # Gato típico ocupa 20-60% del frame en una foto cercana
        if ratio < 0.05:    factor = 0.70   # muy pequeño/lejos
        elif ratio < 0.15:  factor = 0.85
        elif ratio < 0.30:  factor = 1.00
        elif ratio < 0.50:  factor = 1.15
        else:               factor = 1.30   # muy grande/cerca

        # Detectar "redondez" = posible sobrepeso
        x_, y_, w_, h_ = cv2.boundingRect(mayor)
        redondez = area / (w_ * h_) if w_ * h_ > 0 else 0.5

        if redondez > 0.75:  factor *= 1.10  # forma más redonda = más peso
        elif redondez < 0.50: factor *= 0.90

        peso_estimado = round(peso_base * factor, 2)

        return {
            "peso_kg":       peso_estimado,
            "peso_lb":       round(peso_estimado * 2.205, 1),
            "area_relativa": round(ratio * 100, 1),
            "redondez":      round(redondez, 2),
            "confianza":     "Alta" if 0.15 < ratio < 0.60 else "Media",
        }

    # ── Estado corporal (BCS - Body Condition Score) ──────────
    def estado_corporal(self, peso_kg: float, raza_info: Dict) -> Dict[str, Any]:
        peso_base = raza_info.get("peso_base", 4.5)
        ratio     = peso_kg / peso_base

        if ratio < 0.80:
            estado   = "Bajo peso"
            emoji    = "⚠️"
            color    = "#FF9800"
            bcs      = 2
            consejo  = "Tu gato está por debajo del peso ideal. Consulta al veterinario sobre su dieta."
            salud    = 60
        elif ratio < 0.92:
            estado   = "Algo delgado"
            emoji    = "🔶"
            color    = "#FFC107"
            bcs      = 3
            consejo  = "Ligeramente por debajo del rango ideal. Incrementa un poco las porciones."
            salud    = 75
        elif ratio <= 1.10:
            estado   = "Peso ideal ✓"
            emoji    = "✅"
            color    = "#4CAF50"
            bcs      = 5
            consejo  = "¡Excelente! Tu gato mantiene un peso saludable."
            salud    = 95
        elif ratio <= 1.25:
            estado   = "Sobrepeso"
            emoji    = "🔶"
            color    = "#FF9800"
            bcs      = 7
            consejo  = "Tu gato tiene algo de sobrepeso. Reduce snacks y aumenta el juego."
            salud    = 70
        else:
            estado   = "Obesidad"
            emoji    = "🚨"
            color    = "#F44336"
            bcs      = 9
            consejo  = "Tu gato está obeso. Recomendamos visitar al veterinario para un plan de dieta."
            salud    = 45

        return {
            "estado":    estado,
            "emoji":     emoji,
            "color_hex": color,
            "bcs":       bcs,
            "bcs_max":   9,
            "consejo":   consejo,
            "salud_pct": salud,
        }

    # ── Detectar gesto / mood ─────────────────────────────────
    def detectar_gesto(self, frames: List[np.ndarray]) -> Dict[str, Any]:
        """
        Análisis de movimiento entre frames + brillo de ojos.
        """
        if len(frames) < 2:
            gesto = GESTOS[0]
            return {**gesto, "movimiento": "bajo", "confianza": 50}

        # Calcular movimiento promedio entre frames
        diffs = []
        for i in range(1, min(len(frames), 8)):
            g1 = cv2.cvtColor(frames[i-1], cv2.COLOR_BGR2GRAY)
            g2 = cv2.cvtColor(frames[i],   cv2.COLOR_BGR2GRAY)
            diff = cv2.absdiff(g1, g2)
            diffs.append(diff.mean())

        mov_promedio = np.mean(diffs)

        # Detectar ojos brillantes (reflexión tapetum)
        ultimo   = frames[-1]
        gris_ult = cv2.cvtColor(ultimo, cv2.COLOR_BGR2GRAY)
        _, bright = cv2.threshold(gris_ult, 220, 255, cv2.THRESH_BINARY)
        ojos_brillantes = bright.sum() / (gris_ult.size * 255)

        # Lógica de mood
        if mov_promedio > 15:
            gesto_idx = 3  # Juguetón
            nivel_mov = "alto"
        elif mov_promedio > 8:
            gesto_idx = 2  # Alerta
            nivel_mov = "medio"
        elif ojos_brillantes > 0.03:
            gesto_idx = 1  # Curioso
            nivel_mov = "bajo"
        elif mov_promedio < 2:
            gesto_idx = 4  # Somnoliento
            nivel_mov = "mínimo"
        else:
            gesto_idx = 0  # Relajado
            nivel_mov = "bajo"

        gesto = GESTOS[gesto_idx]
        return {
            **gesto,
            "movimiento":    nivel_mov,
            "mov_score":     round(float(mov_promedio), 2),
            "confianza":     80,
        }

    # ── ANÁLISIS COMPLETO (un frame) ──────────────────────────
    def analizar_frame(self, img_bytes: bytes, frames_previos: List[np.ndarray]) -> Dict[str, Any]:
        # Decodificar imagen
        arr = np.frombuffer(img_bytes, np.uint8)
        img = cv2.imdecode(arr, cv2.IMREAD_COLOR)
        if img is None:
            raise ValueError("No se pudo decodificar la imagen")

        gris = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
        gris = cv2.equalizeHist(gris)

        # Detectar cara de gato
        caras = self.detectar_cara(gris)
        gato_detectado = len(caras) > 0

        # Región de análisis: cara o frame completo
        if caras:
            x, y, w, h = caras[0]
            pad = 40
            H_, W_ = img.shape[:2]
            roi = img[max(0,y-pad):min(H_,y+h+pad), max(0,x-pad):min(W_,x+w+pad)]
        else:
            roi = img

        # Análisis
        raza_info  = self.clasificar_raza(roi)
        color_info = self.analizar_color(roi)
        peso_info  = self.estimar_peso(img, raza_info["peso_base"])
        corp_info  = self.estado_corporal(peso_info["peso_kg"], raza_info)
        gesto_info = self.detectar_gesto(frames_previos + [img])

        # Imagen anotada en base64
        img_anotada = self._anotar_imagen(img.copy(), caras, raza_info, corp_info)
        _, buf = cv2.imencode(".jpg", img_anotada, [cv2.IMWRITE_JPEG_QUALITY, 75])
        img_b64 = base64.b64encode(buf.tobytes()).decode()

        return {
            "gato_detectado":  gato_detectado,
            "timestamp":       time.time(),
            "raza":            raza_info,
            "color":           color_info,
            "peso":            peso_info,
            "estado_corporal": corp_info,
            "gesto":           gesto_info,
            "imagen_anotada":  img_b64,
            "caras_detectadas": len(caras),
        }

    def _anotar_imagen(self, img, caras, raza_info, corp_info):
        for (x, y, w, h) in caras:
            color = (0, 255, 100)
            cv2.rectangle(img, (x, y), (x+w, y+h), color, 2)
            texto = f"{raza_info['raza']} | {corp_info['estado']}"
            cv2.putText(img, texto, (x, y-8),
                        cv2.FONT_HERSHEY_SIMPLEX, 0.55, color, 2)
        return img


# ════════════════════════════════════════════════════════════════
#  FASTAPI APP
# ════════════════════════════════════════════════════════════════

app    = FastAPI(title="MeowScan API", version="1.0")
motor  = None  # se inicializa en startup

# Almacenar frames de la sesión activa
sesiones: Dict[str, List[np.ndarray]] = {}

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.on_event("startup")
async def startup():
    global motor
    print("\n🚀 Iniciando MeowScan API...")
    motor = MotorAnalisis()
    print("✅ Servidor listo!\n")

@app.get("/")
def root():
    return {"status": "ok", "app": "MeowScan API", "version": "1.0"}

@app.get("/health")
def health():
    return {
        "status":         "ok",
        "tensorflow":     TF_DISPONIBLE,
        "cascade_normal": motor.cascade_normal is not None if motor else False,
        "cascade_ext":    motor.cascade_ext    is not None if motor else False,
    }

@app.post("/analizar")
async def analizar(
    file:      UploadFile = File(...),
    sesion_id: str        = "default",
):
    """
    Recibe un frame JPEG desde Flutter y retorna análisis completo.
    """
    if motor is None:
        raise HTTPException(status_code=503, detail="Motor no inicializado")

    contenido = await file.read()

    # Recuperar frames previos de la sesión
    frames_prev = sesiones.get(sesion_id, [])

    try:
        resultado = motor.analizar_frame(contenido, frames_prev)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

    # Guardar frame actual en buffer (máx 10)
    arr = np.frombuffer(contenido, np.uint8)
    img = cv2.imdecode(arr, cv2.IMREAD_COLOR)
    if img is not None:
        frames_prev.append(img)
        sesiones[sesion_id] = frames_prev[-10:]

    return JSONResponse(content=resultado)

@app.delete("/sesion/{sesion_id}")
def limpiar_sesion(sesion_id: str):
    sesiones.pop(sesion_id, None)
    return {"ok": True}


if __name__ == "__main__":
    print("=" * 55)
    print("  🐱  MEOWSCAN - SERVIDOR DE ANÁLISIS FELINO")
    print("=" * 55)
    uvicorn.run(app, host=HOST, port=PORT, reload=False)
