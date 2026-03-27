// ════════════════════════════════════════════════════════════════
// 🐱 MEOWSCAN v3.0 - DISEÑO COLORIDO Y JOVIAL
// ════════════════════════════════════════════════════════════════
// Tema: Claro, colorido, redondeado y playful
// Fuente: Nunito (redondeada y divertida)
// Colores: Coral, Turquesa, Amarillo, Lavanda
// NUEVO: Borrar gatos y escaneos individuales
// ════════════════════════════════════════════════════════════════
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

//  PALETA DE COLORES — Claro, vibrante y jovial
// ════════════════════════════════════════════════════════════════

const Color kBg        = Color(0xFFFFF9F0);   // Crema cálido
const Color kSurface   = Color(0xFFFFFFFF);   // Blanco puro
const Color kCard      = Color(0xFFFFFFFF);   // Blanco
// ── API Security Keys ─────────────────────────────────────────
// Para compilar con claves reales:
//   flutter build apk --release
//     --dart-define=MEOWSCAN_API_KEY=tu_clave
//     --dart-define=RESEND_API_KEY=re_tuclavereal
// En desarrollo usa los defaultValue (nunca subas claves reales al repo)
const String kApiKey = String.fromEnvironment(
  'MEOWSCAN_API_KEY',
  defaultValue: 'ms-x9k2p7q4r8t3w6y1',
);
const String kResendKey = String.fromEnvironment(
  'RESEND_API_KEY',
  defaultValue: '', // vacío en dev: el email simplemente no se envía
);


const Color kCoral     = Color(0xFFFF6B6B);   // Coral vibrante
const Color kCoralLight= Color(0xFFFF8E8E);   // Coral claro
const Color kTurquoise = Color(0xFF4ECDC4);   // Turquesa
const Color kYellow    = Color(0xFFFFE66D);   // Amarillo
const Color kPurple    = Color(0xFFA29BFE);   // Lavanda
const Color kGreen     = Color(0xFF55EFC4);   // Menta
const Color kBlue      = Color(0xFF74B9FF);   // Azul cielo
const Color kText      = Color(0xFF2D3436);   // Gris oscuro
const Color kMuted     = Color(0xFFB2BEC3);   // Gris claro
const Color kBorder    = Color(0xFFEDEDED);   // Borde suave

const String SERVER_URL = "meowscan-api.onrender.com";
const int    SCAN_DURATION  = 60;
const int    FRAME_INTERVAL = 2000;
const String APP_VERSION    = "3.0.0";
const String QR_BASE_URL    = "https://meowscan-api.onrender.com/perfil";

// ════════════════════════════════════════════════════════════════
//  INTERNACIONALIZACIÓN
// ════════════════════════════════════════════════════════════════

class L {
  static String _lang = 'es';
  static void setLang(String lang) => _lang = lang;
  static String get lang => _lang;

  static const _t = {
    'es': {
      'app_name':      'MeowScan',
      'tagline':       '¡Analiza a tu mascota con IA! 🐾',
      'login':         'Entrar',
      'register':      'Crear cuenta',
      'email':         'Correo electrónico',
      'password':      'Contraseña',
      'username':      'Nombre de usuario',
      'cat_name':      'Nombre del gatito',
      'cat_age':       'Edad',
      'years':         'años',
      'months':        'meses',
      'start_scan':    '¡Escanear gatito! 🔍',
      'scanning':      'Escaneando...',
      'results':       '¡Resultados! 🎉',
      'breed':         'Raza',
      'weight':        'Peso estimado',
      'color':         'Color del pelaje',
      'pattern':       'Patrón',
      'body_condition':'Estado corporal',
      'mood':          'Estado de ánimo',
      'ears':          'Análisis de orejas',
      'health_score':  'Índice de salud',
      'download_pdf':  '📄 Descargar Reporte',
      'new_scan':      '🔄 Nuevo escaneo',
      'history':       'Historial',
      'profile':       'Mis mascotas',
      'settings':      'Ajustes',
      'server_ip':     'Servidor',
      'test_conn':     'Probar conexión',
      'connected':     '✅ ¡Conectado!',
      'not_connected': '❌ Sin conexión',
      'language':      'Idioma',
      'logout':        'Cerrar sesión',
      'save':          'Guardar',
      'cancel':        'Cancelar',
      'add_cat':       '+ Agregar mascota',
      'my_cats':       'Mis mascotas',
      'scan_history':  'Historial',
      'no_scans':      'Aún no hay escaneos 😿',
      'no_cats':   'Aún no tienes mascotas 🐾',
      'tip':           '💡 Consejo',
      'welcome':       '¡Hola',
      'select_cat':    'Selecciona tu mascota',
      'seconds':       'seg',
      'frames':        'fotos',
      'delete_cat':    'Borrar gatito',
      'delete_scan':   'Borrar escaneo',
      'delete_confirm':'¿Estás seguro?',
      'delete_cat_msg':'Se borrarán el gatito y todos sus escaneos.',
      'delete_scan_msg':'Se borrará este escaneo.',
      'delete':        'Borrar',
      'cancel_delete': 'Cancelar',
      // Nuevas features
      'vomit_title':       'Analizar Vómito 🔬',
      'vomit_sub':         'Detecta causas por color con IA veterinaria',
      'resp_title':        'Respiración',
      'resp_sub':          'Mide resp/min',
      'spasm_title':       'Espasmos',
      'spasm_sub':         'Detecta temblores',
      'gums_title':        'Encías',
      'gums_sub':          'Detecta anemia y emergencias',
      'meow_title':        'Maullido',
      'meow_sub':          'Analiza emociones',
      // Disclaimer
      'disclaimer_title':  'Aviso importante',
      'disclaimer_body':   '🩺 Este análisis es orientativo y de prevención temprana. SIEMPRE consulta un veterinario certificado para diagnósticos definitivos. Nuestra IA te ayuda a detectar señales de alerta a tiempo.',
      'disclaimer_short':  '⚠️ Diagnóstico orientativo. Siempre consulta un veterinario certificado.',
      'understood':        'Entendido, continuar',
      // Scan screens
      'scan_resp_title':   'Análisis Respiratorio',
      'scan_spasm_title':  'Análisis de Espasmos',
      'scan_gums_title':   'Análisis de Encías',
      'scan_meow_title':   'Análisis de Maullido',
      'point_chest':       'Apunta al pecho',
      'point_back':        'Apunta a la espalda',
      'lift_lip':          'Levanta suavemente el labio y apunta la cámara',
      // Results
      'result':            'Resultado',
      'possible_causes':   'Posibles causas',
      'recommendation':    'Recomendación',
      'vet_clinics':       '🏥 Ver clínicas veterinarias cercanas',
      'back_home':         '🏠 Volver al inicio',
      'method':            'Método',
      'frames_analyzed':   'frames analizados',
      'vet_alert':         '¡Consulta al veterinario!',
      'vet_alert_msg':     'Señales de alerta detectadas. Consulta al veterinario.',
      // Historia médica
      'medical_history':   'Historia Médica',
      'history_building':  'Historia Médica en construcción',
      'history_need':      'El Dr. MeowScan necesita al menos',
      'history_need2':     'escaneos para generar un diagnóstico clínico confiable.',
      'history_missing':   'Faltan',
      'history_missing2':  'escaneos más 🐾',
      'history_scan_tip':  'Cada escaneo aporta datos valiosos sobre la salud de tu mascota. ¡Sigue escaneando regularmente!',
      'next_revision':     'Próxima revisión',
      'next_scan':         'Próximo escaneo en MeowScan',
      'prelim_diag':       'Diagnóstico Preliminar',
      'time_evolution':    'Evolución temporal',
      'first_scan':        'Primer escaneo',
      'last_scan':         'Último escaneo',
      'notable_changes':   'Cambios notables',
      'active_alerts':     'Alertas activas',
      'predictions':       'Predicciones preventivas',
      'recommendations':   'Recomendaciones',
      'vet_visit':         'Visita al veterinario',
      'suggested_studies': 'Estudios sugeridos',
      'observations':      'Observaciones',
      // Maullido
      'recording':         '¡Grabando! Deja que tu gato haga sonidos',
      'tap_record':        'Toca para grabar',
      'record_again':      'Grabar de nuevo 🔄',
      'see_full_analysis': 'Ver análisis completo →',
      'interpretation':    'Interpretación',
      'did_you_know':      '¿Sabías que?',
      'what_to_do':        'Qué hacer ahora',
      'alert_signals':     'Señales de alerta detectadas',
      'analyzing_ia':      'Analizando con IA 🧠',
      // Auth
      'change_password':   'Cambiar contraseña',
      'delete_account':    'Eliminar mi cuenta',
      'new_password':      'Nueva contraseña',
      'confirm_password':  'Confirmar contraseña',
      'save_password':     'Guardar contraseña',
      'forgot_password':   '¿Olvidaste tu contraseña?',
      'continue_google':   'Continuar con Google',
      'recovery_sent':     'Te enviamos un correo de recuperación',
      // Pets
      'add_pet':           'Agregar mascota',
      'pet_name':          'Nombre',
      'select_type':       'Selecciona el tipo',
      'cat':               'Gato',
      'dog':               'Perro',
      'delete_pet':        'Borrar mascota',
      'delete_pet_msg':    'Se borrarán la mascota y todos sus escaneos.',
      'are_you_sure':      '¿Estás seguro?',
      // Settings
      'server':            'Servidor',
      'test_connection':   'Probar conexión',
      'delete_account_confirm': 'Esta acción eliminará tu cuenta y todos tus datos permanentemente.',
      // Scan screen
      'analyzing':         'Analizando...',
      'no_pet_detected':   'No se detectó la mascota',
      'scan_tip_resp':     'Mantén la cámara enfocada en el pecho',
      'scan_tip_spasm':    'Mantén la cámara enfocada en la espalda',
      'scan_tip_gums':     'Asegúrate de ver bien las encías',
      // i18n additions
      'what_analyzes':     '¿Qué analiza MeowScan?',
      'feat_breed':        '🧬 Raza',
      'feat_weight':       '⚖️ Peso',
      'feat_color':        '🎨 Color',
      'feat_body':         '💪 Estado corporal',
      'feat_mood':         '😺 Mood',
      'feat_ears':         '👂 Orejas',
      'scan_title':        '¡Escanear mascota! 🐾',
      'my_pets_label':     'mis mascotas',
      'pet_type_label':    'TIPO DE MASCOTA',
      'stress_level':      'Nivel de estrés',
      'scan_complete':     'Análisis completo con IA',
      'ready':             '¡Listo! 🎉',
      'see_vet_now':       '¡VE AL VETERINARIO!',
      'delete_appt_q':     '¿Eliminar esta cita?',
      'how_to_use_qr':     '💡 ¿Cómo usar este ID?',
      'whatsapp_number':   'Tu número de WhatsApp',
      'whatsapp_hint':     'Ej: 573001234567 (con código de país)',
      'whatsapp_tip':      'Incluye el código del país sin el + (Colombia: 57...)',
      'qr_scan_contact':   'Escanea para contactar',
      'meow_analysis':     'Análisis de Maullido',
      'point_vomit':       'Apunta al vómito',
      'not_applicable':    'No aplica',
      'scan_navbar':       'Escanear',
      'analyzing_video':   'Analizando...',
      'video_few_secs':    'Esto puede tomar unos segundos',
      // Traductor
      'translator_title':  '🗣️ Traductor de Mascotas',
      'translator_sub':    'Tu mascota te está diciendo algo...',
      'translator_btn':    '🎙️ Traducir ahora',
      'translator_record': '¡Grabando! Deja que hable...',
      'translator_analyze':'Traduciendo con IA 🧠',
      'translator_share':  '📲 Compartir en redes',
      'translator_result': 'Tu mascota dice:',
      'translator_prob':   'de probabilidad',
      'translator_again':  '🔄 Traducir de nuevo',
    },
    'en': {
      'app_name':      'MeowScan',
      'tagline':       'Analyze your pet with AI! 🐾',
      'login':         'Log in',
      'register':      'Sign up',
      'email':         'Email',
      'password':      'Password',
      'username':      'Username',
      'cat_name':      'Cat name',
      'cat_age':       'Age',
      'years':         'years',
      'months':        'months',
      'start_scan':    'Scan my kitty! 🔍',
      'scanning':      'Scanning...',
      'results':       'Results! 🎉',
      'breed':         'Breed',
      'weight':        'Estimated weight',
      'color':         'Coat color',
      'pattern':       'Pattern',
      'body_condition':'Body condition',
      'mood':          'Mood',
      'ears':          'Ear analysis',
      'health_score':  'Health score',
      'download_pdf':  '📄 Download Report',
      'new_scan':      '🔄 New scan',
      'history':       'History',
      'profile':       'My pets',
      'settings':      'Settings',
      'server_ip':     'Server',
      'test_conn':     'Test connection',
      'connected':     '✅ Connected!',
      'not_connected': '❌ Not connected',
      'language':      'Language',
      'logout':        'Log out',
      'save':          'Save',
      'cancel':        'Cancel',
      'add_cat':       '+ Add pet',
      'my_cats':       'My pets',
      'scan_history':  'History',
      'no_scans':      'No scans yet 😿',
      'no_cats':       'No pets yet 🐾',
      'tip':           '💡 Tip',
      'welcome':       'Hello',
      'select_cat':    'Select your pet',
      'seconds':       'sec',
      'frames':        'photos',
      'delete_cat':    'Delete cat',
      'delete_scan':   'Delete scan',
      'delete_confirm':'Are you sure?',
      'delete_cat_msg':'This will delete the cat and all its scans.',
      'delete_scan_msg':'This scan will be deleted.',
      'delete':        'Delete',
      'cancel_delete': 'Cancel',
      // New features
      'vomit_title':       'Analyze Vomit 🔬',
      'vomit_sub':         'Detect causes by color with AI',
      'resp_title':        'Breathing',
      'resp_sub':          'Measure breaths/min',
      'spasm_title':       'Spasms',
      'spasm_sub':         'Detect skin tremors',
      'gums_title':        'Gums',
      'gums_sub':          'Detect anemia and emergencies',
      'meow_title':        'Meow',
      'meow_sub':          'Analyze emotions',
      // Disclaimer
      'disclaimer_title':  'Important notice',
      'disclaimer_body':   '🩺 This analysis is for early prevention purposes only. ALWAYS consult a certified veterinarian for definitive diagnoses. Our AI helps you detect warning signs early.',
      'disclaimer_short':  '⚠️ Indicative diagnosis. Always consult a certified veterinarian.',
      'understood':        'Got it, continue',
      // Scan screens
      'scan_resp_title':   'Breathing Analysis',
      'scan_spasm_title':  'Spasm Analysis',
      'scan_gums_title':   'Gum Analysis',
      'scan_meow_title':   'Meow Analysis',
      'point_chest':       'Point at the chest',
      'point_back':        'Point at the back',
      'lift_lip':          'Gently lift the lip and point the camera',
      // Results
      'result':            'Result',
      'possible_causes':   'Possible causes',
      'recommendation':    'Recommendation',
      'vet_clinics':       '🏥 Find nearby vet clinics',
      'back_home':         '🏠 Back to home',
      'method':            'Method',
      'frames_analyzed':   'frames analyzed',
      'vet_alert':         'See a vet now!',
      'vet_alert_msg':     'Warning signals detected. Please consult a veterinarian.',
      // Medical history
      'medical_history':   'Medical History',
      'history_building':  'Medical History in progress',
      'history_need':      'Dr. MeowScan needs at least',
      'history_need2':     'scans to generate a reliable clinical diagnosis.',
      'history_missing':   'Still need',
      'history_missing2':  'more scans 🐾',
      'history_scan_tip':  'Every scan adds valuable health data for your pet. Keep scanning regularly!',
      'next_revision':     'Next check-up',
      'next_scan':         'Next scan in MeowScan',
      'prelim_diag':       'Preliminary Diagnosis',
      'time_evolution':    'Timeline',
      'first_scan':        'First scan',
      'last_scan':         'Latest scan',
      'notable_changes':   'Notable changes',
      'active_alerts':     'Active alerts',
      'predictions':       'Preventive predictions',
      'recommendations':   'Recommendations',
      'vet_visit':         'Vet visit',
      'suggested_studies': 'Suggested tests',
      'observations':      'Observations',
      // Meow
      'recording':         'Recording! Let your cat make sounds',
      'tap_record':        'Tap to record',
      'record_again':      'Record again 🔄',
      'see_full_analysis': 'See full analysis →',
      'interpretation':    'Interpretation',
      'did_you_know':      'Did you know?',
      'what_to_do':        'What to do now',
      'alert_signals':     'Warning signals detected',
      'analyzing_ia':      'Analyzing with AI 🧠',
      // Auth
      'change_password':   'Change password',
      'delete_account':    'Delete my account',
      'new_password':      'New password',
      'confirm_password':  'Confirm password',
      'save_password':     'Save password',
      'forgot_password':   'Forgot your password?',
      'continue_google':   'Continue with Google',
      'recovery_sent':     'We sent you a recovery email',
      // Pets
      'add_pet':           'Add pet',
      'pet_name':          'Name',
      'select_type':       'Select type',
      'cat':               'Cat',
      'dog':               'Dog',
      'delete_pet':        'Delete pet',
      'delete_pet_msg':    'This will delete the pet and all its scans.',
      'are_you_sure':      'Are you sure?',
      // Settings
      'server':            'Server',
      'test_connection':   'Test connection',
      'delete_account_confirm': 'This action will permanently delete your account and all your data.',
      // Scan screen
      'analyzing':         'Analyzing...',
      'no_pet_detected':   'Pet not detected',
      'scan_tip_resp':     'Keep the camera focused on the chest',
      'scan_tip_spasm':    'Keep the camera focused on the back',
      'scan_tip_gums':     'Make sure the gums are clearly visible',
      // i18n additions
      'what_analyzes':     'What does MeowScan analyze?',
      'feat_breed':        '🧬 Breed',
      'feat_weight':       '⚖️ Weight',
      'feat_color':        '🎨 Color',
      'feat_body':         '💪 Body condition',
      'feat_mood':         '😺 Mood',
      'feat_ears':         '👂 Ears',
      'scan_title':        'Scan my pet! 🐾',
      'my_pets_label':     'my pets',
      'pet_type_label':    'PET TYPE',
      'stress_level':      'Stress level',
      'scan_complete':     'Full AI analysis',
      'ready':             'Ready! 🎉',
      'see_vet_now':       'SEE A VET NOW!',
      'delete_appt_q':     'Delete this appointment?',
      'how_to_use_qr':     '💡 How to use this ID?',
      'whatsapp_number':   'Your WhatsApp number',
      'whatsapp_hint':     'E.g.: 573001234567 (with country code)',
      'whatsapp_tip':      'Include country code without + (Colombia: 57...)',
      'qr_scan_contact':   'Scan to contact',
      'meow_analysis':     'Meow Analysis',
      'point_vomit':       'Point at the vomit',
      'not_applicable':    'N/A',
      'scan_navbar':       'Scan',
      'analyzing_video':   'Analyzing...',
      'video_few_secs':    'This may take a few seconds',
      // Translator
      'translator_title':  '🗣️ Pet Translator',
      'translator_sub':    'Your pet is trying to tell you something...',
      'translator_btn':    '🎙️ Translate now',
      'translator_record': 'Recording! Let them speak...',
      'translator_analyze':'Translating with AI 🧠',
      'translator_share':  '📲 Share on social media',
      'translator_result': 'Your pet says:',
      'translator_prob':   'probability',
      'translator_again':  '🔄 Translate again',
    },
  };

  static String get(String key) =>
      _t[_lang]?[key] ?? _t['es']?[key] ?? key;
}

// ════════════════════════════════════════════════════════════════
//  MODELOS
// ════════════════════════════════════════════════════════════════

class CatProfile {
  String id, name, tipo;
  int ageYears, ageMonths;
  String? photoPath;
  CatProfile({required this.id, required this.name,
      required this.ageYears, required this.ageMonths,
      this.photoPath, this.tipo = 'gato'});
  Map<String, dynamic> toJson() => {'id': id, 'name': name,
      'ageYears': ageYears, 'ageMonths': ageMonths,
      'photoPath': photoPath, 'tipo': tipo};
  factory CatProfile.fromJson(Map<String, dynamic> j) => CatProfile(
      id: j['id'], name: j['name'],
      ageYears: j['ageYears'] ?? 0, ageMonths: j['ageMonths'] ?? 0,
      photoPath: j['photoPath'], tipo: j['tipo'] ?? 'gato');
}

// ════════════════════════════════════════════════════════════════
//  MODELOS: CITAS Y MEDICAMENTOS
// ════════════════════════════════════════════════════════════════

class VetAppointment {
  String id, catId, clinicName, reason, notes;
  DateTime date;
  bool completed;
  bool notifyBefore; // notify 1 day before
  VetAppointment({
    required this.id, required this.catId,
    required this.clinicName, required this.reason,
    required this.date, this.notes = '',
    this.completed = false, this.notifyBefore = true,
  });
  Map<String, dynamic> toJson() => {
    'id': id, 'catId': catId, 'clinicName': clinicName,
    'reason': reason, 'date': date.toIso8601String(),
    'notes': notes, 'completed': completed,
    'notifyBefore': notifyBefore,
  };
  factory VetAppointment.fromJson(Map<String, dynamic> j) => VetAppointment(
    id: j['id'], catId: j['catId'], clinicName: j['clinicName'],
    reason: j['reason'], date: DateTime.parse(j['date']),
    notes: j['notes'] ?? '', completed: j['completed'] ?? false,
    notifyBefore: j['notifyBefore'] ?? true,
  );
}

class Medication {
  String id, catId, name, dose, frequency, notes;
  DateTime startDate;
  DateTime? endDate;
  TimeOfDay reminderTime;
  bool active;
  Medication({
    required this.id, required this.catId,
    required this.name, required this.dose,
    required this.frequency, required this.startDate,
    required this.reminderTime,
    this.notes = '', this.endDate, this.active = true,
  });
  Map<String, dynamic> toJson() => {
    'id': id, 'catId': catId, 'name': name, 'dose': dose,
    'frequency': frequency, 'startDate': startDate.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'reminderHour': reminderTime.hour,
    'reminderMinute': reminderTime.minute,
    'notes': notes, 'active': active,
  };
  factory Medication.fromJson(Map<String, dynamic> j) => Medication(
    id: j['id'], catId: j['catId'], name: j['name'],
    dose: j['dose'], frequency: j['frequency'],
    startDate: DateTime.parse(j['startDate']),
    endDate: j['endDate'] != null ? DateTime.parse(j['endDate']) : null,
    reminderTime: TimeOfDay(
      hour: j['reminderHour'] ?? 8,
      minute: j['reminderMinute'] ?? 0),
    notes: j['notes'] ?? '', active: j['active'] ?? true,
  );
}

class ScanRecord {
  String id, catId;
  DateTime date;
  Map<String, dynamic> resultado;
  ScanRecord({required this.id, required this.catId,
      required this.date, required this.resultado});
  Map<String, dynamic> toJson() => {'id': id, 'catId': catId,
      'date': date.toIso8601String(), 'resultado': resultado};
  factory ScanRecord.fromJson(Map<String, dynamic> j) => ScanRecord(
      id: j['id'], catId: j['catId'],
      date: DateTime.parse(j['date']), resultado: j['resultado']);
}

// ════════════════════════════════════════════════════════════════
//  MODELO: VACUNAS
// ════════════════════════════════════════════════════════════════
class VaccineRecord {
  String id, catId, name, veterinarian, notes, lotNumber;
  DateTime applicationDate;
  DateTime? nextDoseDate;
  bool notifyBefore;
  VaccineRecord({
    required this.id, required this.catId, required this.name,
    required this.applicationDate, this.veterinarian = '',
    this.notes = '', this.lotNumber = '',
    this.nextDoseDate, this.notifyBefore = true,
  });
  Map<String, dynamic> toJson() => {
    'id': id, 'catId': catId, 'name': name,
    'applicationDate': applicationDate.toIso8601String(),
    'nextDoseDate': nextDoseDate?.toIso8601String(),
    'veterinarian': veterinarian, 'notes': notes,
    'lotNumber': lotNumber, 'notifyBefore': notifyBefore,
  };
  factory VaccineRecord.fromJson(Map<String, dynamic> j) => VaccineRecord(
    id: j['id'], catId: j['catId'], name: j['name'],
    applicationDate: DateTime.parse(j['applicationDate']),
    nextDoseDate: j['nextDoseDate'] != null ? DateTime.parse(j['nextDoseDate']) : null,
    veterinarian: j['veterinarian'] ?? '', notes: j['notes'] ?? '',
    lotNumber: j['lotNumber'] ?? '', notifyBefore: j['notifyBefore'] ?? true,
  );
  VaccineStatus get status {
    if (nextDoseDate == null) return VaccineStatus.noDate;
    final diff = nextDoseDate!.difference(DateTime.now()).inDays;
    if (diff < 0)   return VaccineStatus.expired;
    if (diff <= 30) return VaccineStatus.soon;
    return VaccineStatus.ok;
  }
  static List<String> commonVaccines(String tipo) => tipo == 'perro'
    ? ['Parvovirus','Moquillo','Hepatitis','Parainfluenza','Rabia','Bordetella','Leptospirosis','Coronavirus']
    : ['Triple Felina (HCP)','Rabia','Leucemia Felina (FeLV)','Panleucopenia','Herpesvirus','Calicivirus','Bordetella Felina'];
}
enum VaccineStatus { ok, soon, expired, noDate }

class UserAccount {
  String email, username, passwordHash;
  List<CatProfile>     cats;
  List<ScanRecord>     scans;
  List<VetAppointment> appointments;
  List<Medication>     medications;
  List<VaccineRecord>  vaccines;
  UserAccount({required this.email, required this.username,
      required this.passwordHash,
      List<CatProfile>? cats, List<ScanRecord>? scans,
      List<VetAppointment>? appointments, List<Medication>? medications,
      List<VaccineRecord>? vaccines})
      : cats         = cats         ?? [],
        scans        = scans        ?? [],
        appointments = appointments ?? [],
        medications  = medications  ?? [],
        vaccines     = vaccines     ?? [];
}
// ════════════════════════════════════════════════════════════════
//  STORAGE
// ════════════════════════════════════════════════════════════════

// ── Secure HTTP helper ────────────────────────────────────────
class SecureHttp {
  static Map<String, String> get jsonHeaders => {
    "Content-Type": "application/json",
    "X-API-Key": kApiKey,
  };

  static String buildUrl(String ip, String endpoint) {
    final isCloud = ip.contains("onrender") || ip.contains("trycloudflare");
    final proto   = isCloud ? "https" : "http";
    final port    = isCloud ? "" : ":8000";
    return "$proto://$ip$port/$endpoint";
  }
}

class StorageService {
  static Future<SharedPreferences> get _p => SharedPreferences.getInstance();

  static Future<void> saveUser(UserAccount u) async {
    final p = await _p;
    await p.setString('user_email',    u.email);
    await p.setString('user_username', u.username);
    await p.setString('user_pass',     u.passwordHash);
    await saveCats(u.cats);
    await saveScans(u.scans);
  }

  static Future<UserAccount?> loadUser() async {
    final p = await _p;
    final email = p.getString('user_email');
    if (email == null) return null;
    return UserAccount(
      email:        email,
      username:     p.getString('user_username') ?? '',
      passwordHash: p.getString('user_pass')     ?? '',
      cats:         await loadCats(),
      scans:        await loadScans(),
      appointments: await loadAppointments(),
      medications:  await loadMedications(),
      vaccines:     await loadVaccines(),
    );
  }

  static Future<void> logout() async {
    final p = await _p;
    await p.remove('user_email');
    await p.remove('user_username');
    await p.remove('user_pass');
  }

  static Future<void> saveCats(List<CatProfile> cats) async {
    final p = await _p;
    await p.setString('cats', jsonEncode(cats.map((c) => c.toJson()).toList()));
  }

  static Future<List<CatProfile>> loadCats() async {
    final p = await _p;
    final data = p.getString('cats');
    if (data == null) return [];
    return (jsonDecode(data) as List).map((j) => CatProfile.fromJson(j)).toList();
  }

  static Future<void> saveScans(List<ScanRecord> scans) async {
    final p = await _p;
    await p.setString('scans', jsonEncode(scans.map((s) => s.toJson()).toList()));
  }

  static Future<List<ScanRecord>> loadScans() async {
    final p = await _p;
    final data = p.getString('scans');
    if (data == null) return [];
    return (jsonDecode(data) as List).map((j) => ScanRecord.fromJson(j)).toList();
  }

  static Future<void> saveAppointments(List<VetAppointment> items) async {
    final p = await _p;
    await p.setString('appointments', jsonEncode(items.map((e) => e.toJson()).toList()));
  }
  static Future<List<VetAppointment>> loadAppointments() async {
    final p = await _p;
    final data = p.getString('appointments');
    if (data == null) return [];
    try { return (jsonDecode(data) as List).map((e) => VetAppointment.fromJson(e)).toList(); }
    catch (_) { return []; }
  }

  static Future<void> saveMedications(List<Medication> items) async {
    final p = await _p;
    await p.setString('medications', jsonEncode(items.map((e) => e.toJson()).toList()));
  }
  static Future<List<Medication>> loadMedications() async {
    final p = await _p;
    final data = p.getString('medications');
    if (data == null) return [];
    try { return (jsonDecode(data) as List).map((e) => Medication.fromJson(e)).toList(); }
    catch (_) { return []; }
  }

  static Future<void> saveVaccines(List<VaccineRecord> items) async {
    final p = await _p;
    await p.setString('vaccines', jsonEncode(items.map((e) => e.toJson()).toList()));
  }
  static Future<List<VaccineRecord>> loadVaccines() async {
    final p = await _p;
    final data = p.getString('vaccines');
    if (data == null) return [];
    try { return (jsonDecode(data) as List).map((e) => VaccineRecord.fromJson(e)).toList(); }
    catch (_) { return []; }
  }

  static Future<String> getServerIp() async {
    final p = await _p;
    return p.getString('server_ip') ?? SERVER_URL;
  }

  static Future<void> setServerIp(String ip) async {
    final p = await _p;
    await p.setString('server_ip', ip);
  }

  static Future<String> getLang() async {
    final p = await _p;
    return p.getString('lang') ?? 'es';
  }

  static Future<void> setLang(String lang) async {
    final p = await _p;
    await p.setString('lang', lang);
    L.setLang(lang);
  }
}

// ════════════════════════════════════════════════════════════════
//  WIDGETS BASE
// ════════════════════════════════════════════════════════════════

TextStyle _nunito(double size, Color color,
    {FontWeight weight = FontWeight.w600}) =>
  GoogleFonts.nunito(fontSize: size, color: color, fontWeight: weight);

Widget kTitle(String t, {double size = 24, Color color = kText}) =>
  Text(t, style: GoogleFonts.nunito(
      fontSize: size, color: color, fontWeight: FontWeight.w800));

Widget kBody(String t, {double size = 14, Color color = kText, TextAlign align = TextAlign.start}) =>
  Text(t, style: _nunito(size, color), textAlign: align);

Widget kLabel(String t) => Text(t.toUpperCase(),
  style: _nunito(11, kMuted, weight: FontWeight.w700));

BoxDecoration kCardDeco({Color? color, Color? border, double radius = 20}) =>
  BoxDecoration(
    color: color ?? kCard,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: border ?? kBorder),
    boxShadow: [BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 10, offset: const Offset(0, 4))],
  );

Widget kGradBtn(String label, VoidCallback onTap,
    {List<Color> colors = const [kCoral, Color(0xFFFF8E53)]}) =>
  AnimatedPressButton(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(
          color: colors.first.withOpacity(0.35),
          blurRadius: 12, offset: const Offset(0, 5))],
      ),
      child: Center(child: Text(label,
        style: _nunito(16, Colors.white, weight: FontWeight.w800))),
    ),
  );

Widget kOutlineBtn(String label, VoidCallback onTap, {Color color = kCoral}) =>
  GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 2),
      ),
      child: Center(child: Text(label,
        style: _nunito(15, color, weight: FontWeight.w700))),
    ),
  );

// ════════════════════════════════════════════════════════════════
//  ANIMATED PRESS BUTTON — efecto tap con escala + brillo
// ════════════════════════════════════════════════════════════════

class AnimatedPressButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double scaleFactor;
  const AnimatedPressButton({
    Key? key,
    required this.child,
    required this.onTap,
    this.scaleFactor = 0.94,
  }) : super(key: key);
  @override
  State<AnimatedPressButton> createState() => _AnimatedPressButtonState();
}

class _AnimatedPressButtonState extends State<AnimatedPressButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _brightness;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scale = Tween<double>(begin: 1.0, end: widget.scaleFactor).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _brightness = Tween<double>(begin: 0.0, end: -0.12).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _ctrl.forward();
  void _onTapUp(TapUpDetails _) {
    _ctrl.reverse();
    widget.onTap();
  }
  void _onTapCancel() => _ctrl.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) => Transform.scale(
          scale: _scale.value,
          child: ColorFiltered(
            colorFilter: ColorFilter.matrix([
              1,0,0,0, _brightness.value * 255,
              0,1,0,0, _brightness.value * 255,
              0,0,1,0, _brightness.value * 255,
              0,0,0,1, 0,
            ]),
            child: child,
          ),
        ),
        child: widget.child,
      ),
    );
  }
}

Widget kTextField(TextEditingController ctrl, String hint,
    {bool obscure = false, IconData? icon, Color accent = kCoral}) =>
  TextField(
    controller: ctrl,
    obscureText: obscure,
    style: _nunito(15, kText),
    decoration: InputDecoration(
      hintText:      hint,
      hintStyle:     _nunito(14, kMuted),
      filled:        true,
      fillColor:     const Color(0xFFF8F8F8),
      prefixIcon:    icon != null
          ? Icon(icon, color: accent, size: 20) : null,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: accent, width: 2)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );

// ════════════════════════════════════════════════════════════════
//  MAIN
// ════════════════════════════════════════════════════════════════


// ════════════════════════════════════════════════════════════════
//  FIRESTORE SERVICE
// ════════════════════════════════════════════════════════════════

class FirestoreService {
  static final _db   = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static String? get uid => _auth.currentUser?.uid;

  // ── Guardar mascotas ──────────────────────────────────────
  static Future<void> saveMascotas(List<CatProfile> mascotas) async {
    if (uid == null) return;
    final batch = _db.batch();
    final col   = _db.collection("usuarios").doc(uid).collection("mascotas");
    for (final m in mascotas) {
      batch.set(col.doc(m.id), m.toJson());
    }
    await batch.commit();
  }

  // ── Cargar mascotas ───────────────────────────────────────
  static Future<List<CatProfile>> loadMascotas() async {
    if (uid == null) return [];
    final snap = await _db
        .collection("usuarios").doc(uid).collection("mascotas").get();
    return snap.docs.map((d) => CatProfile.fromJson(d.data())).toList();
  }

  // ── Guardar escaneos ──────────────────────────────────────
  static Future<void> saveEscaneos(List<ScanRecord> escaneos) async {
    if (uid == null) return;
    final batch = _db.batch();
    final col   = _db.collection("usuarios").doc(uid).collection("escaneos");
    for (final e in escaneos) {
      batch.set(col.doc(e.id), e.toJson());
    }
    await batch.commit();
  }

  // ── Cargar escaneos ───────────────────────────────────────
  static Future<List<ScanRecord>> loadEscaneos() async {
    if (uid == null) return [];
    final snap = await _db
        .collection("usuarios").doc(uid).collection("escaneos").get();
    return snap.docs.map((d) => ScanRecord.fromJson(d.data())).toList();
  }

  // ── Eliminar mascota ──────────────────────────────────────
  static Future<void> deleteMascota(String id) async {
    if (uid == null) return;
    await _db.collection("usuarios").doc(uid)
        .collection("mascotas").doc(id).delete();
  }

  // ── Eliminar escaneo ──────────────────────────────────────
  static Future<void> deleteEscaneo(String id) async {
    if (uid == null) return;
    await _db.collection("usuarios").doc(uid)
        .collection("escaneos").doc(id).delete();
  }

  // ── Eliminar cuenta completa ──────────────────────────────
  static Future<void> deleteAccount() async {
    if (uid == null) return;
    final col1 = await _db.collection("usuarios").doc(uid).collection("mascotas").get();
    final col2 = await _db.collection("usuarios").doc(uid).collection("escaneos").get();
    final batch = _db.batch();
    for (final d in col1.docs) batch.delete(d.reference);
    for (final d in col2.docs) batch.delete(d.reference);
    batch.delete(_db.collection("usuarios").doc(uid));
    await batch.commit();
    await _auth.currentUser?.delete();
  }

  // ── Guardar perfil usuario ────────────────────────────────
  static Future<void> saveUserProfile(UserAccount user) async {
    if (uid == null) return;
    await _db.collection("usuarios").doc(uid).set({
      "email":    user.email,
      "username": user.username,
      "updated":  FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ── Appointments ──────────────────────────────────────────
  static Future<void> saveAppointments(List<VetAppointment> appts) async {
    if (uid == null) return;
    final col = _db.collection("usuarios").doc(uid).collection("citas");
    final batch = _db.batch();
    for (final a in appts) {
      batch.set(col.doc(a.id), a.toJson());
    }
    await batch.commit();
  }

  static Future<void> deleteAppointment(String id) async {
    if (uid == null) return;
    await _db.collection("usuarios").doc(uid).collection("citas").doc(id).delete();
  }

  static Future<List<VetAppointment>> loadAppointments() async {
    if (uid == null) return [];
    final snap = await _db.collection("usuarios").doc(uid).collection("citas").get();
    return snap.docs.map((d) => VetAppointment.fromJson(d.data())).toList();
  }

  // ── Medications ───────────────────────────────────────────
  static Future<void> saveMedications(List<Medication> meds) async {
    if (uid == null) return;
    final col = _db.collection("usuarios").doc(uid).collection("medicamentos");
    final batch = _db.batch();
    for (final m in meds) {
      batch.set(col.doc(m.id), m.toJson());
    }
    await batch.commit();
  }

  static Future<void> deleteMedication(String id) async {
    if (uid == null) return;
    await _db.collection("usuarios").doc(uid).collection("medicamentos").doc(id).delete();
  }

  static Future<List<Medication>> loadMedications() async {
    if (uid == null) return [];
    final snap = await _db.collection("usuarios").doc(uid).collection("medicamentos").get();
    return snap.docs.map((d) => Medication.fromJson(d.data())).toList();
  }
  // ── Vaccines ──────────────────────────────────────────────
  static Future<void> saveVaccines(List<VaccineRecord> vaccines) async {
    if (uid == null) return;
    final col   = _db.collection("usuarios").doc(uid).collection("vacunas");
    final batch = _db.batch();
    for (final v in vaccines) { batch.set(col.doc(v.id), v.toJson()); }
    await batch.commit();
  }
  static Future<void> deleteVaccine(String id) async {
    if (uid == null) return;
    await _db.collection("usuarios").doc(uid).collection("vacunas").doc(id).delete();
  }
  static Future<List<VaccineRecord>> loadVaccines() async {
    if (uid == null) return [];
    final snap = await _db.collection("usuarios").doc(uid).collection("vacunas").get();
    return snap.docs.map((d) => VaccineRecord.fromJson(d.data())).toList();
  }
}

// ════════════════════════════════════════════════════════════════
//  EMAIL BIENVENIDA CON RESEND
// ════════════════════════════════════════════════════════════════

class EmailService {
  // La clave se inyecta en tiempo de compilación con --dart-define=RESEND_API_KEY=...
  // Si está vacía (dev/debug), el email se omite silenciosamente.
  static String get _resendKey => kResendKey;

  static Future<void> enviarBienvenida(String email, String username) async {
    if (_resendKey.isEmpty) {
      print('ℹ️ RESEND_API_KEY no configurada — email de bienvenida omitido');
      return;
    }
    try {
      await http.post(
        Uri.parse("https://api.resend.com/emails"),
        headers: {
          "Authorization": "Bearer $_resendKey",
          "Content-Type": "application/json",
        },
        body: json.encode({
          "from":    "MeowScan <onboarding@resend.dev>",
          "to":      [email],
          "subject": L.lang == 'en' ? "🐾 Welcome to MeowScan!" : "🐾 ¡Bienvenido a MeowScan!",
          "html": """
            <div style="font-family:Arial,sans-serif;max-width:500px;margin:0 auto;background:#fff;border-radius:20px;overflow:hidden;border:1px solid #eee">
              <div style="background:linear-gradient(135deg,#FF6B6B,#A855F7);padding:40px;text-align:center">
                <h1 style="color:white;margin:0;font-size:32px">🐾 MeowScan</h1>
                <p style="color:rgba(255,255,255,0.85);margin:8px 0 0>${L.lang == 'en' ? 'AI Pet Analysis' : 'Análisis de mascotas con IA'}</p>
              </div>
              <div style="padding:32px">
                <h2 style="color:#333">${L.lang == 'en' ? 'Hello' : '¡Hola'} $username! 👋</h2>
                <p style="color:#666;line-height:1.6">${L.lang == 'en' ? 'Welcome to <strong>MeowScan</strong>! You can now start analyzing' : '¡Bienvenido a <strong>MeowScan</strong>! Ya puedes empezar a analizar'} a tus mascotas.</p>
                <div style="background:#f8f9fa;border-radius:12px;padding:20px;margin:20px 0">
                  <p style="margin:0 0 8px;color:#333;font-weight:bold">✨ Con MeowScan puedes:</p>
                  <p style="margin:4px 0;color:#666">🐱 Detectar la raza de tu gato o perro</p>
                  <p style="margin:4px 0;color:#666">${L.lang == 'en' ? '⚖️ Estimate weight & body condition' : '⚖️ Estimar su peso y condición corporal'}</p>
                  <p style="margin:4px 0;color:#666">${L.lang == 'en' ? '😸 Analyze mood & emotions' : '😸 Analizar su estado de ánimo'}</p>
                  <p style="margin:4px 0;color:#666">${L.lang == 'en' ? '🔬 Analyze vomit by color' : '🔬 Analizar el vómito de tu mascota'}</p>
                  <p style="margin:4px 0;color:#666">📱 Crear ID digital para el collar</p>
                </div>
                <p style="color:#999;font-size:12px;text-align:center;margin-top:24px">© 2026 Candle Technology · MeowScan</p>
              </div>
            </div>
          """
        }),
      );
      print("✅ Email enviado a \$email");
    } catch (e) {
      print("⚠️ Email error: \$e");
    }
  }
}

// ════════════════════════════════════════════════════════════════
//  GOOGLE AUTH SERVICE
// ════════════════════════════════════════════════════════════════

class GoogleAuthService {
  static Future<UserAccount?> signIn() async {
    try {
      final googleSignIn = GoogleSignIn();
      final googleUser   = await googleSignIn.signIn();
      if (googleUser == null) return null;
      final googleAuth   = await googleUser.authentication;
      final credential   = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken:     googleAuth.idToken,
      );
      final userCred = await FirebaseAuth.instance.signInWithCredential(credential);
      final fireUser = userCred.user;
      if (fireUser == null) return null;

      final newUser = UserAccount(
        email:        fireUser.email ?? "",
        username:     fireUser.displayName ?? fireUser.email?.split("@").first ?? "Usuario",
        passwordHash: "",
      );

      // Load cloud data
      final mascotas     = await FirestoreService.loadMascotas();
      final escaneos     = await FirestoreService.loadEscaneos();
      final citas        = await FirestoreService.loadAppointments();
      final medicamentos = await FirestoreService.loadMedications();
      newUser.cats         = mascotas;
      newUser.scans        = escaneos;
      newUser.appointments = citas;
      newUser.medications  = medicamentos;

      await StorageService.saveUser(newUser);

      // Send welcome email only for new users
      if (userCred.additionalUserInfo?.isNewUser == true) {
        await EmailService.enviarBienvenida(newUser.email, newUser.username);
      }
      return newUser;
    } catch (e, stack) {
      print("Google sign in error REAL: ${e.runtimeType}: $e");
      print("Stack: $stack");
      return null;
    }
  }

  static Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
  }
}

// ════════════════════════════════════════════════════════════════
//  NOTIFICATION SERVICE
// ════════════════════════════════════════════════════════════════
class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    try {
      tz_data.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('America/Bogota'));
    } catch (_) {}
    try {
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      await _plugin.initialize(const InitializationSettings(android: android));

      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      // Pedir permiso de notificaciones (Android 13+)
      await androidPlugin?.requestNotificationsPermission();

      // Crear canales explícitamente con importancia MAX
      // Esto es crítico en FuntouchOS (Vivo), MIUI (Xiaomi), EMUI (Huawei)
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          'meowscan_meds',
          'Medication Reminders',
          description: 'Daily medication reminders for your pet',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          enableLights: true,
          ledColor: kCoral,
          showBadge: true,
        ));
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          'meowscan_appts',
          'Vet Appointments',
          description: 'Reminders for upcoming vet appointments',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          enableLights: true,
          ledColor: kTurquoise,
          showBadge: true,
        ));
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          'meowscan_now',
          'MeowScan Alerts',
          description: 'Instant alerts from MeowScan',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          showBadge: true,
        ));

      _initialized = true;
    } catch (e) {
      print('⚠️ Notification init error: $e');
    }
  }

  static NotificationDetails _details(String channelId, String channelName) =>
    NotificationDetails(
      android: AndroidNotificationDetails(
        channelId, channelName,
        channelDescription: 'MeowScan reminders — medication & vet appointments',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
        enableLights: true,
        ledColor: kCoral,
        ledOnMs: 1000,
        ledOffMs: 500,
        fullScreenIntent: true,
        // Evita que MIUI/FuntouchOS clasifique la notif como silenciosa
        category: AndroidNotificationCategory.alarm,
        visibility: NotificationVisibility.public,
        icon: '@mipmap/ic_launcher',
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      ),
    );

  // ── Mostrar notificación inmediata (para testing) ──
  static Future<void> showNow(String title, String body) async {
    await init();
    try {
      await _plugin.show(
        DateTime.now().millisecondsSinceEpoch % 100000,
        title, body,
        _details('meowscan_now', 'MeowScan'),
      );
    } catch (e) { print('⚠️ showNow error: $e'); }
  }

  // ── Programar medicamento ──
  static Future<void> scheduleMedication(Medication med) async {
    await init();
    await cancelMedication(med.id);
    if (!med.active) return;
    try {
      final now = tz.TZDateTime.now(tz.local);
      var scheduled = tz.TZDateTime(tz.local,
        now.year, now.month, now.day,
        med.reminderTime.hour, med.reminderTime.minute);
      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
      print('💊 Scheduling notification for: $scheduled');
      await _plugin.zonedSchedule(
        _medId(med.id),
        L.lang == 'en' ? '💊 Medication reminder' : '💊 Recordatorio de medicamento',
        '${med.name} – ${med.dose}',
        scheduled,
        _details('meowscan_meds', 'Medications'),
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      print('💊 Notification scheduled OK');
    } catch (e) { print('⚠️ scheduleMedication error: $e'); }
  }

  static Future<void> cancelMedication(String medId) async {
    try { await _plugin.cancel(_medId(medId)); } catch (_) {}
  }

  // ── Programar cita ──
  static Future<void> scheduleAppointment(VetAppointment appt) async {
    await init();
    await cancelAppointment(appt.id);
    try {
      final now = DateTime.now();
      final dayBefore = appt.date.subtract(const Duration(days: 1));
      if (dayBefore.isAfter(now)) {
        await _plugin.zonedSchedule(
          _apptId(appt.id, 0),
          L.lang == 'en' ? '🏥 Vet appointment tomorrow!' : '🏥 ¡Cita veterinaria mañana!',
          '${appt.clinicName} – ${appt.reason}',
          tz.TZDateTime.from(dayBefore, tz.local),
          _details('meowscan_appts', 'Vet Appointments'),
          androidScheduleMode: AndroidScheduleMode.alarmClock,
          uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
      final twoHoursBefore = appt.date.subtract(const Duration(hours: 2));
      if (twoHoursBefore.isAfter(now)) {
        await _plugin.zonedSchedule(
          _apptId(appt.id, 1),
          L.lang == 'en' ? '🏥 Vet appointment in 2 hours!' : '🏥 ¡Cita veterinaria en 2 horas!',
          '${appt.clinicName} – ${appt.reason}',
          tz.TZDateTime.from(twoHoursBefore, tz.local),
          _details('meowscan_appts', 'Vet Appointments'),
          androidScheduleMode: AndroidScheduleMode.alarmClock,
          uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    } catch (e) { print('⚠️ scheduleAppointment error: $e'); }
  }

  static Future<void> cancelAppointment(String apptId) async {
    try {
      await _plugin.cancel(_apptId(apptId, 0));
      await _plugin.cancel(_apptId(apptId, 1));
    } catch (_) {}
  }

  // ── Reprogramar todo al abrir la app ──
  static Future<void> rescheduleAll(UserAccount user) async {
    await init();
    for (final appt in user.appointments) {
      if (!appt.completed && appt.date.isAfter(DateTime.now())) {
        await scheduleAppointment(appt);
      }
    }
    for (final med in user.medications) {
      if (med.active) await scheduleMedication(med);
    }
    for (final vac in user.vaccines) {
      if (vac.notifyBefore && vac.nextDoseDate != null) {
        await scheduleVaccine(vac);
      }
    }
  }

  // ── Programar vacuna ──
  static Future<void> scheduleVaccine(VaccineRecord vac) async {
    await init();
    await cancelVaccine(vac.id);
    if (vac.nextDoseDate == null || !vac.notifyBefore) return;
    try {
      final now = DateTime.now();
      final sevenDays = vac.nextDoseDate!.subtract(const Duration(days: 7));
      if (sevenDays.isAfter(now)) {
        await _plugin.zonedSchedule(
          _vacId(vac.id, 0),
          L.lang == 'en' ? '💉 Vaccine due in 7 days' : '💉 Vacuna vence en 7 días',
          '${vac.name}',
          tz.TZDateTime.from(sevenDays, tz.local),
          _details('meowscan_appts', 'Vet Appointments'),
          androidScheduleMode: AndroidScheduleMode.alarmClock,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
      final oneDay = vac.nextDoseDate!.subtract(const Duration(days: 1));
      if (oneDay.isAfter(now)) {
        await _plugin.zonedSchedule(
          _vacId(vac.id, 1),
          L.lang == 'en' ? '💉 Vaccine due tomorrow!' : '💉 ¡Vacuna vence mañana!',
          '${vac.name}',
          tz.TZDateTime.from(oneDay, tz.local),
          _details('meowscan_appts', 'Vet Appointments'),
          androidScheduleMode: AndroidScheduleMode.alarmClock,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    } catch (e) { print('⚠️ scheduleVaccine error: \$e'); }
  }

  static Future<void> cancelVaccine(String vacId) async {
    try {
      await _plugin.cancel(_vacId(vacId, 0));
      await _plugin.cancel(_vacId(vacId, 1));
    } catch (_) {}
  }

  static int _apptId(String id, int suffix) =>
    (id.hashCode.abs() % 100000) * 10 + suffix;
  static int _medId(String id) =>
    (id.hashCode.abs() % 100000) * 10 + 5;
  static int _vacId(String id, int suffix) =>
    (id.hashCode.abs() % 90000 + 10000) * 10 + suffix;
}


// ════════════════════════════════════════════════════════════════
//  🥗 NUTRICION SCREEN — Analizador de Alimento
// ════════════════════════════════════════════════════════════════

class NutricionScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  final String serverIp;
  final CatProfile? cat;
  final UserAccount user;
  final VoidCallback onComplete;
  const NutricionScreen({Key? key, required this.cameras,
    required this.serverIp, this.cat,
    required this.user, required this.onComplete}) : super(key: key);
  @override State<NutricionScreen> createState() => _NutricionScreenState();
}

class _NutricionScreenState extends State<NutricionScreen> {
  CameraController? _cam;
  bool _sending = false, _done = false;
  Map<String, dynamic>? _result;
  String? _error;

  @override
  void initState() { super.initState(); _initCam(); }

  Future<void> _initCam() async {
    _cam = CameraController(widget.cameras.first, ResolutionPreset.high,
      enableAudio: false, imageFormatGroup: ImageFormatGroup.jpeg);
    await _cam!.initialize();
    if (mounted) setState(() {});
  }

  @override
  void dispose() { _cam?.dispose(); super.dispose(); }

  Future<void> _capture() async {
    if (_cam == null || !_cam!.value.isInitialized || _sending) return;
    setState(() { _sending = true; _error = null; });
    try {
      final foto  = await _cam!.takePicture();
      final bytes = await foto.readAsBytes();
      final ip    = widget.serverIp;
      final proto = ip.contains('onrender') || ip.contains('trycloudflare') ? 'https' : 'http';
      final port  = ip.contains('onrender') || ip.contains('trycloudflare') ? '' : ':8000';
      final uri   = Uri.parse('$proto://$ip${port}/analizar_nutricion');
      final req   = http.MultipartRequest('POST', uri)
        ..headers['X-API-Key'] = kApiKey
        ..fields['lang'] = L.lang
        ..files.add(http.MultipartFile.fromBytes('file', bytes, filename: 'food.jpg'));
      final s   = await req.send().timeout(const Duration(seconds: 30));
      final res = await http.Response.fromStream(s);
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        // Save to history
        final scan = ScanRecord(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          catId: widget.cat?.id ?? 'general',
          date: DateTime.now(),
          resultado: {...data, 'tipo': 'nutricion'});
        widget.user.scans.add(scan);
        await StorageService.saveScans(widget.user.scans);
        await FirestoreService.saveEscaneos(widget.user.scans);
        setState(() { _result = data; _done = true; _sending = false; });
        widget.onComplete();
      } else {
        setState(() { _error = 'Error ${res.statusCode}'; _sending = false; });
      }
    } catch (e) {
      setState(() { _error = e.toString(); _sending = false; });
    }
  }

  Color _qualityColor(int score) {
    if (score >= 8) return const Color(0xFF00B894);
    if (score >= 6) return const Color(0xFF00CEC9);
    if (score >= 4) return const Color(0xFFFFB347);
    return kCoral;
  }

  String _qualityLabel(int score) {
    if (L.lang == 'en') {
      if (score >= 8) return 'Excellent';
      if (score >= 6) return 'Good';
      if (score >= 4) return 'Regular';
      return 'Poor';
    } else {
      if (score >= 8) return 'Excelente';
      if (score >= 6) return 'Bueno';
      if (score >= 4) return 'Regular';
      return 'Deficiente';
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: kBg,
    body: SafeArea(child: Column(children: [
      // Header
      Padding(
        padding: const EdgeInsets.all(20),
        child: Row(children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(padding: const EdgeInsets.all(10),
              decoration: kCardDeco(radius: 14),
              child: const Icon(Icons.arrow_back_ios_new, color: kPurple, size: 18))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            kTitle(L.lang == 'en' ? '🥗 Food Analyzer' : '🥗 Analizador de Alimento', size: 18),
            kBody(widget.cat?.name ?? (L.lang == 'en' ? 'General analysis' : 'Análisis general'),
              color: kMuted, size: 12),
          ])),
        ])),
      Expanded(child: _done ? _buildResult() : _buildCamera()),
    ])));

  Widget _buildCamera() {
    if (_cam == null || !_cam!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator(color: kPurple));
    }
    if (_sending) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const CircularProgressIndicator(color: const Color(0xFF11998E), strokeWidth: 3),
        const SizedBox(height: 20),
        kTitle(L.lang == 'en' ? '🤖 AI analyzing food...' : '🤖 IA analizando alimento...', size: 16),
        const SizedBox(height: 8),
        kBody(L.lang == 'en' ? 'Reading ingredients & rating quality' : 'Leyendo ingredientes y calificando calidad',
          color: kMuted),
      ]));
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: AspectRatio(
            aspectRatio: _cam!.value.aspectRatio,
            child: CameraPreview(_cam!))),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: kCardDeco(),
          child: Row(children: [
            const Text('🥗', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(child: kBody(
              L.lang == 'en'
                ? 'Point the camera at the pet food bag label or ingredient list'
                : 'Apunta la cámara a la bolsa de alimento o a la lista de ingredientes',
              color: kText)),
          ])),
        const SizedBox(height: 16),
        if (_error != null) ...[
          kBody('❌ $_error', color: kCoral),
          const SizedBox(height: 12),
        ],
        SizedBox(width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.camera_alt_rounded, color: Colors.white),
            label: Text(
              L.lang == 'en' ? 'Scan food bag' : 'Escanear bolsa de alimento',
              style: _nunito(15, Colors.white, weight: FontWeight.w800)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF11998E),
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            onPressed: _capture)),
      ]));
  }

  Widget _buildResult() {
    final r = _result!;
    final score    = (r['calidad_score'] as num? ?? 5).toInt();
    final qColor   = _qualityColor(score);
    final qLabel   = _qualityLabel(score);
    final malos    = (r['ingredientes_malos'] as List? ?? []);
    final alternativas = (r['alternativas'] as List? ?? []);
    final ingredientes = (r['ingredientes_principales'] as List? ?? []);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        // ── Score card ──
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [qColor.withOpacity(0.15), qColor.withOpacity(0.05)],
              begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: qColor.withOpacity(0.3))),
          child: Column(children: [
            const Text('🥗', style: TextStyle(fontSize: 44)),
            const SizedBox(height: 12),
            kTitle(r['marca'] ?? (L.lang == 'en' ? 'Pet food' : 'Alimento'), size: 20),
            const SizedBox(height: 8),
            kBody(r['tipo_alimento'] ?? '', color: kMuted, size: 13),
            const SizedBox(height: 16),
            // Score circle
            Container(
              width: 90, height: 90,
              decoration: BoxDecoration(
                color: qColor.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: qColor, width: 3)),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('$score/10', style: _nunito(22, qColor, weight: FontWeight.w900)),
              ])),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(color: qColor, borderRadius: BorderRadius.circular(20)),
              child: Text(qLabel, style: _nunito(13, Colors.white, weight: FontWeight.w800))),
          ])),
        const SizedBox(height: 16),

        // ── Ingredientes principales ──
        if (ingredientes.isNotEmpty) _nutCard(
          emoji: '📋',
          titulo: L.lang == 'en' ? 'Main ingredients' : 'Ingredientes principales',
          body: ingredientes.map((e) => "• $e").join("\n"),
          color: kPurple),

        // ── Ingredientes malos ──
        if (malos.isNotEmpty) _nutCard(
          emoji: '⚠️',
          titulo: L.lang == 'en' ? 'Concerning ingredients' : 'Ingredientes preocupantes',
          body: malos.map((e) => "🔴 $e").join("\n"),
          color: kCoral),

        // ── Resumen ──
        if (r['resumen'] != null) _nutCard(
          emoji: '💡',
          titulo: L.lang == 'en' ? 'AI Analysis' : 'Análisis IA',
          body: r['resumen'] ?? '',
          color: const Color(0xFF11998E)),

        // ── Alternativas ──
        if (alternativas.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Align(alignment: Alignment.centerLeft,
              child: kTitle(L.lang == 'en' ? '✨ Better alternatives' : '✨ Mejores alternativas', size: 15))),
          ...alternativas.map((alt) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: kCardDeco(),
            child: Row(children: [
              const Text('🏆', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                kTitle(alt['nombre'] ?? '', size: 14),
                const SizedBox(height: 4),
                kBody(alt['razon'] ?? '', color: kMuted, size: 12),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF11998E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12)),
                child: Text('${alt['score'] ?? ''}/10',
                  style: _nunito(12, const Color(0xFF11998E), weight: FontWeight.w800))),
            ]))),
        ],

        const SizedBox(height: 8),
        SizedBox(width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.camera_alt_rounded, color: Color(0xFF11998E)),
            label: Text(
              L.lang == 'en' ? 'Scan another food' : 'Escanear otro alimento',
              style: _nunito(14, const Color(0xFF11998E), weight: FontWeight.w700)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF11998E)),
              padding: const EdgeInsets.all(14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            onPressed: () => setState(() { _done = false; _result = null; }))),
        const SizedBox(height: 20),
      ]));
  }

  Widget _nutCard({required String emoji, required String titulo,
    required String body, required Color color}) =>
    Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: kCardDeco(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            kTitle(titulo, size: 13),
          ]),
          const SizedBox(height: 8),
          kBody(body, color: kText, size: 13),
        ])));
}


// ════════════════════════════════════════════════════════════════
//  🩺 VETBOT TAB — Dr. MeowScan AI Veterinarian
// ════════════════════════════════════════════════════════════════

class _VetMessage {
  final String text;
  final bool isBot;
  final DateTime time;
  _VetMessage({required this.text, required this.isBot, required this.time});
}

class VetBotTab extends StatefulWidget {
  final UserAccount user;
  final List<CameraDescription> cameras;
  const VetBotTab({Key? key, required this.user, required this.cameras}) : super(key: key);
  @override State<VetBotTab> createState() => _VetBotTabState();
}

class _VetBotTabState extends State<VetBotTab> {
  final List<_VetMessage> _messages = [];
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scroll = ScrollController();
  bool _loading = false;
  bool _chatStarted = false;


  // Suggestion chips
  List<String> get _chips => L.lang == 'en' ? [
    '🍽️ Not eating', '😴 Very sleepy', '🤢 Vomiting',
    '💧 Not drinking', '🚨 Emergency', '💊 Medications',
    '🦷 Dental health', '🥗 Best food',
  ] : [
    '🍽️ No come', '😴 Muy dormido', '🤢 Vómitos',
    '💧 No toma agua', '🚨 Emergencia', '💊 Medicamentos',
    '🦷 Salud dental', '🥗 Mejor alimento',
  ];

  // Get context from user's recent scans
  String _buildContext() {
    final cat = widget.user.cats.isNotEmpty ? widget.user.cats.first : null;
    final recentScans = widget.user.scans.take(3).toList();
    String ctx = '';
    if (cat != null) {
      ctx += L.lang == 'en'
        ? "The user has a pet named ${cat.name}, type: ${cat.tipo}, age: ${cat.ageYears}y${cat.ageMonths}m. "
        : "El usuario tiene una mascota llamada ${cat.name}, tipo: ${cat.tipo}, edad: ${cat.ageYears}a${cat.ageMonths}m. ";
    }
    if (recentScans.isNotEmpty) {
      ctx += L.lang == 'en' ? 'Recent scans: ' : 'Escaneos recientes: ';
      for (final s in recentScans) {
        final tipo = s.resultado['tipo'] ?? 'general';
        ctx += '$tipo, ';
      }
    }
    return ctx;
  }

  String get _systemPrompt {
    final ctx = _buildContext();
    final ctxLine = ctx.isNotEmpty ? '\n\nContext: $ctx' : '';
    if (L.lang == 'en') {
      return 'You are Dr. MeowScan, a warm veterinarian with 20+ years of experience specializing in cats and dogs. You work inside the MeowScan app.$ctxLine\n\n'
        'Your personality:\n'
        '- Warm, empathetic and reassuring but honest\n'
        '- Ask clarifying questions when needed (age, symptom duration, etc.)\n'
        '- Always recommend seeing a real vet for serious symptoms\n'
        '- Give practical, actionable advice\n'
        '- Use emojis naturally for a friendly tone\n'
        '- Keep responses concise (max 3-4 sentences per message)\n'
        '- NEVER diagnose definitively - always say could be or might indicate\n'
        '- For emergencies, always say to go to the vet IMMEDIATELY\n\n'
        'Always respond in English.';
    } else {
      return 'Eres el Dr. MeowScan, un veterinario cálido con más de 20 años de experiencia especializado en gatos y perros. Trabajas dentro de la app MeowScan.$ctxLine\n\n'
        'Tu personalidad:\n'
        '- Cálido, empático y tranquilizador pero honesto\n'
        '- Haz preguntas de aclaración cuando sea necesario (edad, duración de síntomas, etc.)\n'
        '- Siempre recomienda ver a un veterinario real para síntomas graves\n'
        '- Da consejos prácticos y accionables\n'
        '- Usa emojis de forma natural para mantener un tono amigable\n'
        '- Respuestas concisas (máx 3-4 oraciones por mensaje)\n'
        '- NUNCA diagnostiques definitivamente - siempre di podria ser o podria indicar\n'
        '- Para emergencias, siempre di que vayan al veterinario INMEDIATAMENTE\n\n'
        'Siempre responde en español.';
    }
  }


  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _loading) return;
    _ctrl.clear();
    setState(() {
      _chatStarted = true;
      _messages.add(_VetMessage(text: text, isBot: false, time: DateTime.now()));
      _loading = true;
    });
    _scrollToBottom();

    try {
      // Build messages history for API
      final apiMessages = <Map<String, dynamic>>[];
      for (final m in _messages) {
        if (!m.isBot) {
          apiMessages.add({'role': 'user', 'content': m.text});
        } else {
          apiMessages.add({'role': 'assistant', 'content': m.text});
        }
      }

      final ip    = await StorageService.getServerIp();
      final proto = ip.contains('onrender') || ip.contains('trycloudflare') ? 'https' : 'http';
      final port  = ip.contains('onrender') || ip.contains('trycloudflare') ? '' : ':8000';
      final res = await http.post(
        Uri.parse('$proto://$ip${port}/vetbot'),
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': kApiKey,
        },
        body: json.encode({
          'messages': apiMessages,
          'system': _systemPrompt,
          'lang': L.lang,
        }),
      ).timeout(const Duration(seconds: 30));

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final reply = data['reply'] as String;
        setState(() {
          _messages.add(_VetMessage(text: reply, isBot: true, time: DateTime.now()));
          _loading = false;
        });
      } else {
        _addError();
      }
    } catch (e) {
      _addError();
    }
    _scrollToBottom();
  }

  void _addError() {
    setState(() {
      _messages.add(_VetMessage(
        text: L.lang == 'en'
          ? '😔 Sorry, I had a connection issue. Please try again.'
          : '😔 Disculpa, tuve un problema de conexión. Intenta de nuevo.',
        isBot: true, time: DateTime.now()));
      _loading = false;
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  void dispose() { _ctrl.dispose(); _scroll.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: kBg,
    body: SafeArea(child: Column(children: [
      // ── Header ──
      Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [kPurple, Color(0xFF4ECDC4)],
            begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
          boxShadow: [BoxShadow(color: kPurple.withOpacity(0.3), blurRadius: 16, offset: const Offset(0,4))],
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
            child: const Center(child: Text('🩺', style: TextStyle(fontSize: 24)))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Dr. MeowScan', style: _nunito(18, Colors.white, weight: FontWeight.w900)),
            Row(children: [
              Container(width: 8, height: 8,
                decoration: const BoxDecoration(color: Color(0xFF55EFC4), shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text(
                L.lang == 'en' ? 'Online • 20+ years experience' : 'En línea • 20+ años de experiencia',
                style: _nunito(11, Colors.white.withOpacity(0.85))),
            ]),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12)),
            child: Text(
              L.lang == 'en' ? 'AI Vet' : 'Vet IA',
              style: _nunito(11, Colors.white, weight: FontWeight.w800))),
        ])),

      // ── Messages or Welcome ──
      Expanded(child: !_chatStarted ? _buildWelcome() : _buildChat()),

      // ── Suggestion chips ──
      if (!_chatStarted) _buildChips(),

      // ── Input ──
      _buildInput(),
    ])));

  Widget _buildWelcome() => SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(children: [
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(20),
        decoration: kCardDeco(),
        child: Column(children: [
          const Text('🩺', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          kTitle(L.lang == "en" ? "Hello! I'm Dr. MeowScan" : "Hola! Soy el Dr. MeowScan",
            size: 18),
          const SizedBox(height: 8),
          kBody(
            L.lang == 'en'
              ? "I'm a veterinarian with 20+ years experience. Ask me anything about your pet's health, food or symptoms."
              : "Soy veterinario con mas de 20 anos de experiencia. Preguntame sobre la salud, alimentacion o sintomas de tu mascota.",
            color: kMuted, size: 13),
        ])),
      const SizedBox(height: 16),
      // Recent scan context
      if (widget.user.scans.isNotEmpty) Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kPurple.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kPurple.withOpacity(0.15))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Text('💡', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            kTitle(L.lang == 'en' ? 'Based on your recent scans' : 'Basado en tus escaneos recientes', size: 13),
          ]),
          const SizedBox(height: 8),
          kBody(
            L.lang == 'en'
              ? "I can see your pet's scan history. Ask me about the results!"
              : "Puedo ver el historial de escaneos. Preguntame sobre los resultados!",
            color: kMuted, size: 12),
        ])),
      const SizedBox(height: 16),
      kTitle(
        L.lang == 'en' ? 'Common questions:' : 'Preguntas frecuentes:',
        size: 14),
      const SizedBox(height: 8),
    ]));

  Widget _buildChat() => ListView.builder(
    controller: _scroll,
    padding: const EdgeInsets.all(16),
    itemCount: _messages.length + (_loading ? 1 : 0),
    itemBuilder: (ctx, i) {
      if (i == _messages.length) return _buildTyping();
      final m = _messages[i];
      return _buildBubble(m);
    });

  Widget _buildBubble(_VetMessage m) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      mainAxisAlignment: m.isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (m.isBot) ...[
          Container(width: 32, height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [kPurple, Color(0xFF4ECDC4)]),
              shape: BoxShape.circle),
            child: const Center(child: Text('🩺', style: TextStyle(fontSize: 16)))),
          const SizedBox(width: 8),
        ],
        Flexible(child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: m.isBot ? Colors.white : kPurple,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(m.isBot ? 4 : 18),
              bottomRight: Radius.circular(m.isBot ? 18 : 4)),
            boxShadow: [BoxShadow(
              color: (m.isBot ? Colors.black : kPurple).withOpacity(0.08),
              blurRadius: 8, offset: const Offset(0,2))]),
          child: Text(m.text,
            style: _nunito(13, m.isBot ? kText : Colors.white)))),
        if (!m.isBot) const SizedBox(width: 8),
      ]));

  Widget _buildTyping() => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(children: [
      Container(width: 32, height: 32,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [kPurple, Color(0xFF4ECDC4)]),
          shape: BoxShape.circle),
        child: const Center(child: Text('🩺', style: TextStyle(fontSize: 16)))),
      const SizedBox(width: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)]),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          _dot(0), const SizedBox(width: 4),
          _dot(200), const SizedBox(width: 4),
          _dot(400),
        ])),
    ]));

  Widget _dot(int delay) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: Duration(milliseconds: 600 + delay),
    builder: (_, v, __) => Container(
      width: 8, height: 8,
      decoration: BoxDecoration(
        color: kPurple.withOpacity(0.3 + v * 0.7),
        shape: BoxShape.circle)));

  Widget _buildChips() => SizedBox(
    height: 44,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _chips.length,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: GestureDetector(
          onTap: () => _sendMessage(_chips[i]),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kPurple.withOpacity(0.2)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)]),
            child: Text(_chips[i], style: _nunito(12, kPurple, weight: FontWeight.w700)))))));

  Widget _buildInput() => Container(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border(top: BorderSide(color: kMuted.withOpacity(0.2)))),
    child: Row(children: [
      Expanded(child: Container(
        decoration: BoxDecoration(
          color: kBg, borderRadius: BorderRadius.circular(24),
          border: Border.all(color: kMuted.withOpacity(0.2))),
        child: TextField(
          controller: _ctrl,
          style: _nunito(13, kText),
          maxLines: null,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: L.lang == 'en' ? 'Ask Dr. MeowScan...' : 'Pregúntale al Dr. MeowScan...',
            hintStyle: _nunito(13, kMuted),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
          onSubmitted: _sendMessage))),
      const SizedBox(width: 8),
      GestureDetector(
        onTap: () => _sendMessage(_ctrl.text),
        child: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [kPurple, Color(0xFF4ECDC4)]),
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: kPurple.withOpacity(0.4), blurRadius: 8, offset: const Offset(0,3))]),
          child: _loading
            ? const Padding(padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Icon(Icons.send_rounded, color: Colors.white, size: 20))),
    ]));
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService.init();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  final lang    = await StorageService.getLang();
  L.setLang(lang);
  final cameras = await availableCameras();
  final user    = await StorageService.loadUser();
  // Reprogramar notificaciones al iniciar (sobrevive reinicios)
  if (user != null) await NotificationService.rescheduleAll(user);
  runApp(MeowScanApp(cameras: cameras, initialUser: user));
}

// ════════════════════════════════════════════════════════════════
//  APP ROOT
// ════════════════════════════════════════════════════════════════

class MeowScanApp extends StatefulWidget {
  final List<CameraDescription> cameras;
  final UserAccount? initialUser;
  const MeowScanApp({Key? key, required this.cameras, this.initialUser})
      : super(key: key);
  static _MeowScanAppState? of(BuildContext ctx) =>
      ctx.findAncestorStateOfType<_MeowScanAppState>();
  @override
  State<MeowScanApp> createState() => _MeowScanAppState();
}

class _MeowScanAppState extends State<MeowScanApp> {
  UserAccount? currentUser;
  @override
  void initState() { super.initState(); currentUser = widget.initialUser; }
  void setLang(String lang) { StorageService.setLang(lang); setState(() {}); }
  void setUser(UserAccount? u) => setState(() => currentUser = u);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title:                    'MeowScanAI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3:            true,
        scaffoldBackgroundColor: kBg,
        colorScheme: ColorScheme.light(primary: kCoral, surface: kSurface),
        textTheme: GoogleFonts.nunitoTextTheme(),
      ),
      home: currentUser == null
          ? AuthScreen(cameras: widget.cameras)
          : MainShell(cameras: widget.cameras, user: currentUser!),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  AUTH SCREEN
// ════════════════════════════════════════════════════════════════

class AuthScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const AuthScreen({Key? key, required this.cameras}) : super(key: key);
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  final _userCtrl  = TextEditingController();
  String _error    = '';
  bool   _loading  = false;

  @override
  void initState() { super.initState(); _tab = TabController(length: 2, vsync: this); _tab.addListener(() { if (mounted) setState(() {}); }); }
  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  void _login() async {
    final e = _emailCtrl.text.trim();
    final p = _passCtrl.text;
    if (e.isEmpty || p.isEmpty) {
      setState(() => _error = L.lang == 'es'
          ? 'Completa todos los campos 😅' : 'Fill all fields 😅');
      return;
    }
    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: e, password: p);
      final fireUser = FirebaseAuth.instance.currentUser;
      final user = UserAccount(
        email:        e,
        username:     fireUser?.displayName ?? e.split('@').first,
        passwordHash: '',
      );
      // Load from Firestore
      user.cats         = await FirestoreService.loadMascotas();
      user.scans        = await FirestoreService.loadEscaneos();
      user.appointments = await FirestoreService.loadAppointments();
      user.medications  = await FirestoreService.loadMedications();
      user.vaccines     = await FirestoreService.loadVaccines();
      await StorageService.saveUser(user);
      if (mounted) {
        MeowScanApp.of(context)?.setUser(user);
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (_) => MainShell(cameras: widget.cameras, user: user)));
      }
    } on FirebaseAuthException catch (ex) {
      String msg = L.lang == 'es' ? 'Correo o contraseña incorrectos 😿' : 'Wrong email or password 😿';
      if (ex.code == 'user-not-found') msg = 'No existe cuenta con ese correo';
      if (ex.code == 'wrong-password') msg = 'Contraseña incorrecta';
      setState(() => _error = msg);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  _register() async {
    if (_emailCtrl.text.isEmpty || _passCtrl.text.isEmpty || _userCtrl.text.isEmpty) {
      setState(() => _error = L.lang == 'es'
          ? 'Completa todos los campos 😅'
          : 'Fill all fields 😅');
      return;
    }
    setState(() => _loading = true);
    try {
      final e = _emailCtrl.text.trim();
      final u = _userCtrl.text.trim();
      final p = _passCtrl.text;
      final cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: e, password: p);
      await cred.user?.updateDisplayName(u);
      final user = UserAccount(email: e, username: u, passwordHash: '');
      await StorageService.saveUser(user);
      await FirestoreService.saveUserProfile(user);
      await EmailService.enviarBienvenida(e, u);
      if (mounted) {
        MeowScanApp.of(context)?.setUser(user);
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (_) => MainShell(cameras: widget.cameras, user: user)));
      }
    } on FirebaseAuthException catch (ex) {
      String msg = 'Error al registrarse';
      if (ex.code == 'email-already-in-use') msg = 'Este correo ya está registrado';
      if (ex.code == 'weak-password')        msg = 'La contraseña debe tener al menos 6 caracteres';
      if (ex.code == 'invalid-email')        msg = 'Correo inválido';
      setState(() => _error = msg);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(children: [
          // ── Parte fija: idioma + logo + título + tabs ──
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 16, 28, 0),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                _langBtn('ES'),
                const SizedBox(width: 8),
                _langBtn('EN'),
              ]),
              const SizedBox(height: 10),
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [kCoral, kPurple],
                    begin: Alignment.topLeft, end: Alignment.bottomRight),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(
                    color: kCoral.withOpacity(0.3),
                    blurRadius: 20, offset: const Offset(0, 8))],
                ),
                child: const Center(child: Text("🐱", style: TextStyle(fontSize: 38))),
              ),
              const SizedBox(height: 10),
              kTitle(L.get('app_name'), size: 30, color: kCoral),
              const SizedBox(height: 4),
              kBody(L.get('tagline'), color: kMuted, size: 13),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: kBorder,
                  borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.all(4),
                child: TabBar(
                  controller: _tab,
                  indicator: BoxDecoration(
                    color: kCoral,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [BoxShadow(
                      color: kCoral.withOpacity(0.3), blurRadius: 8)],
                  ),
                  labelColor:           Colors.white,
                  unselectedLabelColor: kMuted,
                  labelStyle:           _nunito(14, Colors.white, weight: FontWeight.w700),
                  dividerColor:         Colors.transparent,
                  tabs: [Tab(text: L.get('login')), Tab(text: L.get('register'))],
                ),
              ),
              const SizedBox(height: 16),
            ]),
          ),

          // ── Parte scrolleable: formulario ──
          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
              child: Column(children: [
                _tab.index == 0 ? _loginForm() : _registerForm(),
                if (_error.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: kCoral.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: kCoral.withOpacity(0.3)),
                    ),
                    child: kBody(_error, color: kCoral),
                  ),
                ],
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _loginForm() => Column(children: [
    kTextField(_emailCtrl, L.get('email'), icon: Icons.email_rounded),
    const SizedBox(height: 14),
    kTextField(_passCtrl,  L.get('password'), icon: Icons.lock_rounded, obscure: true),
    const SizedBox(height: 8),
    Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: _forgotPassword,
        child: Text(
          L.lang == 'es' ? '¿Olvidaste tu contraseña?' : 'Forgot your password?',
          style: _nunito(13, kPurple, weight: FontWeight.w600),
        ),
      ),
    ),
    const SizedBox(height: 20),
    kGradBtn(L.get('login'), _login),
    const SizedBox(height: 12),
    Row(children: [
      Expanded(child: Container(height: 1, color: kBorder)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(L.lang == 'es' ? 'o' : 'or',
            style: _nunito(13, kMuted))),
      Expanded(child: Container(height: 1, color: kBorder)),
    ]),
    const SizedBox(height: 12),
    _googleSignInBtn(),
  ]);

  Widget _registerForm() => Column(children: [
    kTextField(_userCtrl,  L.get('username'), icon: Icons.person_rounded, accent: kPurple),
    const SizedBox(height: 12),
    kTextField(_emailCtrl, L.get('email'),    icon: Icons.email_rounded,  accent: kPurple),
    const SizedBox(height: 12),
    kTextField(_passCtrl,  L.get('password'), icon: Icons.lock_rounded,   accent: kPurple, obscure: true),
    const SizedBox(height: 20),
    kGradBtn(L.get('register'), _register,
        colors: const [kPurple, Color(0xFF6C5CE7)]),
  ]);

  Widget _googleSignInBtn() => GestureDetector(
    onTap: () async {
      setState(() => _loading = true);
      try {
        final user = await GoogleAuthService.signIn();
        if (user != null && mounted) {
          MeowScanApp.of(context)?.setUser(user);
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (_) => MainShell(cameras: widget.cameras, user: user)));
        } else if (mounted) {
          setState(() => _error = L.lang == 'es'
              ? 'No se pudo iniciar con Google 😿'
              : 'Could not sign in with Google 😿');
        }
      } finally {
        if (mounted) setState(() => _loading = false);
      }
    },
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder, width: 1.5),
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Image.network('https://www.google.com/favicon.ico',
          width: 20, height: 20,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.g_mobiledata_rounded, size: 24, color: Colors.red)),
        const SizedBox(width: 10),
        Text(
          L.lang == 'es' ? 'Continuar con Google' : 'Continue with Google',
          style: _nunito(15, kText, weight: FontWeight.w700)),
      ]),
    ),
  );

  void _forgotPassword() async {
    final e = _emailCtrl.text.trim();
    if (e.isEmpty) {
      setState(() => _error = L.lang == 'es'
          ? 'Escribe tu correo primero 📧'
          : 'Enter your email first 📧');
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: e);
      if (mounted) {
        showDialog(context: context, builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("📧 Correo enviado"),
          content: Text(L.lang == 'es'
              ? 'Te enviamos un enlace a $e para restablecer tu contraseña.'
              : 'We sent a link to $e to reset your password.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK")),
          ],
        ));
      }
    } on FirebaseAuthException catch (ex) {
      setState(() => _error = ex.code == 'user-not-found'
          ? (L.lang == 'es' ? 'No existe cuenta con ese correo' : 'No account with that email')
          : ex.message ?? 'Error');
    }
  }

  Widget _langBtn(String lang) => GestureDetector(
    onTap: () {
      MeowScanApp.of(context)?.setLang(lang.toLowerCase());
      setState(() {});
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color:        L.lang == lang.toLowerCase() ? kCoral : kSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: L.lang == lang.toLowerCase() ? kCoral : kBorder),
      ),
      child: Text(lang, style: _nunito(13,
          L.lang == lang.toLowerCase() ? Colors.white : kMuted,
          weight: FontWeight.w700)),
    ),
  );
}

// ════════════════════════════════════════════════════════════════
//  MAIN SHELL
// ════════════════════════════════════════════════════════════════

class MainShell extends StatefulWidget {
  final List<CameraDescription> cameras;
  final UserAccount user;
  const MainShell({Key? key, required this.cameras, required this.user})
      : super(key: key);
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tab = 0;
  late UserAccount _user;

  @override
  void initState() { super.initState(); _user = widget.user; }

  void _refresh() async {
    final u = await StorageService.loadUser();
    if (u != null) {
      u.appointments = await FirestoreService.loadAppointments();
      u.medications  = await FirestoreService.loadMedications();
      u.vaccines     = await FirestoreService.loadVaccines();
      u.cats         = await FirestoreService.loadMascotas();
      u.scans        = await FirestoreService.loadEscaneos();
      await StorageService.saveUser(u);
      if (mounted) setState(() => _user = u);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeTab(cameras: widget.cameras, user: _user, onRefresh: _refresh),
      HistoryTab(user: _user, cameras: widget.cameras, onRefresh: _refresh),
      VetBotTab(user: _user, cameras: widget.cameras),
      ProfileTab(user: _user, cameras: widget.cameras, onRefresh: _refresh),
      SettingsTab(cameras: widget.cameras),
    ];

    return Scaffold(
      backgroundColor: kBg,
      body: pages[_tab],
      bottomNavigationBar: _navBar(),
    );
  }

  Widget _navBar() {
    // 5 tabs: Scan, History, VetBot, My Pets, Settings
    final items = [
      {'icon': '🏠', 'label': L.get('scan_navbar')  ?? (L.lang=='en'?'Scan':'Escanear')},
      {'icon': '📋', 'label': L.get('history')       ?? (L.lang=='en'?'History':'Historial')},
      {'icon': '🩺', 'label': 'VetBot'},
      {'icon': '🐱', 'label': L.get('my_cats')       ?? (L.lang=='en'?'My Pets':'Mascotas')},
      {'icon': '⚙️', 'label': L.get('settings')      ?? (L.lang=='en'?'Settings':'Config')},
    ];
    return Container(
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 20, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final active = _tab == i;
              return GestureDetector(
                onTap: () => setState(() => _tab = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: active ? kPurple.withOpacity(0.12) : Colors.transparent,
                    borderRadius: BorderRadius.circular(14)),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(items[i]['icon']!,
                      style: TextStyle(
                        fontSize: active ? 22 : 20,
                      )),
                    const SizedBox(height: 2),
                    Text(items[i]['label']!,
                      style: _nunito(
                        9,
                        active ? kPurple : kMuted,
                        weight: active ? FontWeight.w800 : FontWeight.w600)),
                  ])));
            })))));
  }

}

// ════════════════════════════════════════════════════════════════
//  HOME TAB
// ════════════════════════════════════════════════════════════════

class HomeTab extends StatefulWidget {
  final List<CameraDescription> cameras;
  final UserAccount user;
  final VoidCallback onRefresh;
  const HomeTab({Key? key, required this.cameras, required this.user,
    required this.onRefresh}) : super(key: key);
  @override State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  CatProfile? _selected;

  @override
  void initState() {
    super.initState();
    if (widget.user.cats.isNotEmpty) _selected = widget.user.cats.first;
  }

  void _scan() async {
    if (_selected == null) { _addCat(); return; }
    final ok = await Permission.camera.request();
    if (!ok.isGranted) return;
    final ip = await StorageService.getServerIp();
    if (!mounted) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ScanScreen(
        cameras: widget.cameras, serverIp: ip,
        cat: _selected!, user: widget.user,
        onComplete: widget.onRefresh)));
  }

  void _addCat() {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddCatSheet(
        onSave: (cat) {
          widget.user.cats.add(cat);
          StorageService.saveUser(widget.user);
          FirestoreService.saveMascotas(widget.user.cats);
          setState(() => _selected = cat);
          widget.onRefresh();
        }));
  }




  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) =>
    GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 17)));

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _header(),
          const SizedBox(height: 24),
          _scanCard(),
          const SizedBox(height: 16),
          _vomitoCard(),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _miniCard(
              icon: Icons.air_rounded, titulo: L.get('resp_title'),
              subtitulo: L.get('resp_sub'),
              colores: [Color(0xFF00B894), Color(0xFF00CEC9)],
              onTap: () => _openScan('respiracion'))),
            const SizedBox(width: 12),
            Expanded(child: _miniCard(
              icon: Icons.electric_bolt_rounded, titulo: L.get('spasm_title'),
              subtitulo: L.get('spasm_sub'),
              colores: [Color(0xFFE17055), Color(0xFFD63031)],
              onTap: () => _openScan('espasmos'))),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _miniCard(
              icon: Icons.sentiment_very_satisfied_rounded, titulo: L.get('gums_title'),
              subtitulo: L.get('gums_sub'),
              colores: [Color(0xFFFF6B9D), Color(0xFFFF4E8A)],
              onTap: () => _openScan('encias'))),
            const SizedBox(width: 12),
            Expanded(child: _miniCard(
              icon: Icons.record_voice_over_rounded, titulo: L.get('meow_title'),
              subtitulo: L.get('meow_sub'),
              colores: [Color(0xFF6C5CE7), Color(0xFFA855F7)],
              onTap: () => _openMaullido())),
          ]),
          const SizedBox(height: 12),
          // ── Nutrition card ──
          _miniCardWide(
            icon: Icons.set_meal_rounded,
            titulo: L.lang == 'en' ? 'Food Analyzer' : 'Analizador de Alimento',
            subtitulo: L.lang == 'en'
              ? 'Scan your pet food bag — rate quality & get better alternatives'
              : 'Escanea la bolsa de alimento — califica calidad y obtén alternativas',
            colores: [Color(0xFF11998E), Color(0xFF38EF7D)],
            onTap: () => _openNutricion()),
          const SizedBox(height: 12),
          // ── Find a Vet button ──
          _findVetButton(),
          const SizedBox(height: 12),
          // ── Pet Translator card ──
          _miniCardWide(
            icon: Icons.record_voice_over_rounded,
            titulo: L.lang == 'en' ? 'Pet Translator' : 'Traductor de Mascotas',
            subtitulo: L.lang == 'en'
              ? 'What is your pet saying? AI will translate!'
              : '¿Qué dice tu mascota? ¡La IA lo traduce!',
            colores: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
            onTap: () => _openTranslator()),
          const SizedBox(height: 24),
          _catSelector(),
          const SizedBox(height: 24),
          _features(),
        ]),
      ),
    );
  }

  Widget _header() => Row(children: [
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      kBody("${L.get('welcome')}, ${widget.user.username}! 👋",
          color: kMuted, size: 14),
      const SizedBox(height: 4),
      kTitle("¡Escanear mascota! 🐾", size: 22, color: kText),
    ])),
    Container(
      width: 48, height: 48,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [kCoral, kPurple]),
        shape: BoxShape.circle),
      child: Center(child: Text(_selected?.tipo == 'perro' ? "🐶" : "🐱", style: const TextStyle(fontSize: 22))),
    ),
  ]);

  Widget _scanCard() => AnimatedPressButton(
    onTap: _scan,
    scaleFactor: 0.96,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kCoral, Color(0xFFFF8E53)],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(
          color: kCoral.withOpacity(0.35),
          blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: Colors.white24,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.document_scanner_rounded,
              color: Colors.white, size: 42),
        ),
        const SizedBox(height: 14),
        Text(L.get('start_scan'),
          style: _nunito(22, Colors.white, weight: FontWeight.w900)),
        const SizedBox(height: 6),
        Text("$SCAN_DURATION ${L.get('seconds')} · ${L.get('scan_complete')}",
          style: _nunito(13, Colors.white70)),
      ]),
    ),
  );

  Widget _vomitoCard() => AnimatedPressButton(
    onTap: () async {
      if (_selected == null) { _addCat(); return; }
      final ok = await Permission.camera.request();
      if (!ok.isGranted) return;
      final ip = await StorageService.getServerIp();
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => VomitoScanScreen(
          cameras: widget.cameras, serverIp: ip,
          cat: _selected!, user: widget.user,
          onComplete: widget.onRefresh)));
    },
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(
          color: kPurple.withOpacity(0.35),
          blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Row(children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
            color: Colors.white24, shape: BoxShape.circle),
          child: const Icon(Icons.biotech_rounded,
              color: Colors.white, size: 28)),
        const SizedBox(width: 16),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(L.get('vomit_title'),
              style: _nunito(17, Colors.white, weight: FontWeight.w900)),
            Text(L.get('vomit_sub'),
              style: _nunito(12, Colors.white70)),
          ],
        )),
        const Icon(Icons.chevron_right_rounded,
            color: Colors.white70, size: 22),
      ]),
    ),
  );

  Widget _miniCardWide({
    required IconData icon, required String titulo,
    required String subtitulo, required List<Color> colores,
    required VoidCallback onTap}) =>
    AnimatedPressButton(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colores, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: colores[0].withOpacity(0.3), blurRadius: 12, offset: const Offset(0,4))]),
        child: Row(children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: Colors.white24, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 28)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(titulo, style: _nunito(16, Colors.white, weight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(subtitulo, style: _nunito(12, Colors.white.withOpacity(0.85))),
          ])),
          const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 20),
        ])));

  Widget _miniCard({required IconData icon, required String titulo,
      required String subtitulo, required List<Color> colores,
      required VoidCallback onTap}) =>
    AnimatedPressButton(
      onTap: () async {
        if (_selected == null) { _addCat(); return; }
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colores,
              begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(
            color: colores[0].withOpacity(0.35),
            blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: Colors.white24, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 24)),
          const SizedBox(width: 10),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: _nunito(14, Colors.white, weight: FontWeight.w900)),
              Text(subtitulo, style: _nunito(10, Colors.white70)),
            ])),
        ]),
      ),
    );

  void _openNutricion() async {
    final ok = await Permission.camera.request();
    if (!ok.isGranted) return;
    final ip = await StorageService.getServerIp();
    if (!mounted) return;
    Navigator.of(context).push(MaterialPageRoute(builder: (_) =>
      NutricionScreen(
        cameras: widget.cameras, serverIp: ip,
        cat: _selected, user: widget.user,
        onComplete: widget.onRefresh)));
  }

  void _openTranslator() async {
    if (_selected == null) { _addCat(); return; }
    final ok = await Permission.camera.request();
    if (!ok.isGranted) return;
    final ip = await StorageService.getServerIp();
    if (!mounted) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => PetTranslatorScreen(
        cat: _selected!, user: widget.user,
        serverIp: ip, cameras: widget.cameras)));
  }

  // ── Abrir Google Maps con veterinarias cercanas ──
  Future<void> _openVetMap() async {
    // Pedir permiso de ubicación
    final status = await Permission.locationWhenInUse.request();

    // URI geo: abre Google Maps directamente con búsqueda de veterinarias
    // Si tiene permiso usa "near+me", si no igual funciona porque Maps
    // detecta la ubicación por sí solo al abrirse
    final query = L.lang == 'en'
        ? 'veterinary+clinic+near+me'
        : 'veterinaria+cerca+de+mi';

    // Intentar abrir la app de Google Maps nativa primero
    final geoUri = Uri.parse('geo:0,0?q=$query');
    // Fallback: abrir en el navegador
    final webUri = Uri.parse(
        'https://www.google.com/maps/search/$query');

    try {
      if (await canLaunchUrl(geoUri)) {
        await launchUrl(geoUri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: kCoral,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          content: Text(
            L.lang == 'en'
              ? '❌ Could not open Google Maps'
              : '❌ No se pudo abrir Google Maps',
            style: _nunito(13, Colors.white, weight: FontWeight.w700)),
        ));
      }
    }
  }

  Widget _findVetButton() => AnimatedPressButton(
    onTap: _openVetMap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0984E3), Color(0xFF74B9FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(
          color: const Color(0xFF0984E3).withOpacity(0.35),
          blurRadius: 14, offset: const Offset(0, 5))]),
      child: Row(children: [
        // Ícono con fondo blanco semitransparente
        Container(
          width: 46, height: 46,
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(14)),
          child: const Center(
            child: Text('🏥', style: TextStyle(fontSize: 24)))),
        const SizedBox(width: 14),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              L.lang == 'en' ? 'Find a Vet nearby' : 'Buscar veterinario cerca',
              style: _nunito(15, Colors.white, weight: FontWeight.w900)),
            const SizedBox(height: 2),
            Text(
              L.lang == 'en'
                ? 'Open Google Maps with clinics near you'
                : 'Abre Google Maps con clínicas cercanas',
              style: _nunito(11, Colors.white70)),
          ])),
        // Flecha + pin de ubicación
        Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.location_on_rounded,
              color: Colors.white, size: 20),
          const SizedBox(height: 2),
          const Icon(Icons.arrow_forward_ios_rounded,
              color: Colors.white70, size: 13),
        ]),
      ]),
    ),
  );

  void _openScan(String tipo) async {
    final ok = await Permission.camera.request();
    if (!ok.isGranted) return;
    final ip = await StorageService.getServerIp();
    // Show disclaimer first
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          const Text("⚠️ ", style: TextStyle(fontSize: 22)),
          Expanded(child: Text(L.get('disclaimer_title'),
            style: _nunito(16, kText, weight: FontWeight.w800))),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: kYellow.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: kYellow.withOpacity(0.5))),
            child: Text(
              L.get('disclaimer_body'),
              style: _nunito(13, kText),
            )),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
            child: Text("Cancelar", style: _nunito(14, kMuted))),
          TextButton(onPressed: () => Navigator.pop(context, true),
            child: Text(L.get('understood'),
              style: _nunito(14, kPurple, weight: FontWeight.w800))),
        ],
      ));
    if (confirm != true || !mounted) return;
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      if (tipo == 'respiracion') {
        return RespiracionScanScreen(
          cameras: widget.cameras, serverIp: ip,
          cat: _selected!, user: widget.user,
          onComplete: widget.onRefresh);
      } else if (tipo == 'espasmos') {
        return EspasmosScanScreen(
          cameras: widget.cameras, serverIp: ip,
          cat: _selected!, user: widget.user,
          onComplete: widget.onRefresh);
      } else {
        return EnciasScreen(
          cameras: widget.cameras, serverIp: ip,
          cat: _selected!, user: widget.user,
          onComplete: widget.onRefresh);
      }
    }));
  }

  void _openMaullido() async {
    if (_selected == null) { _addCat(); return; }
    final ok = await Permission.microphone.request();
    if (!ok.isGranted) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(L.get('cam_denied') ?? "Permiso de micrófono denegado")));
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          const Text("⚠️ ", style: TextStyle(fontSize: 22)),
          Expanded(child: Text(L.get('disclaimer_title'),
            style: _nunito(16, kText, weight: FontWeight.w800))),
        ]),
        content: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: kYellow.withOpacity(0.15),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kYellow.withOpacity(0.5))),
          child: Text(
            "🩺 Este análisis es orientativo. SIEMPRE consulta un veterinario certificado para diagnósticos definitivos.",
            style: _nunito(13, kText))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
            child: Text("Cancelar", style: _nunito(14, kMuted))),
          TextButton(onPressed: () => Navigator.pop(context, true),
            child: Text("Entendido", style: _nunito(14, kPurple, weight: FontWeight.w800))),
        ]));
    if (confirm != true || !mounted) return;
    final ip = await StorageService.getServerIp();
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => MaullidoScreen(
        cat: _selected!, user: widget.user, serverIp: ip,
        onComplete: widget.onRefresh)));
  }

  Widget _catSelector() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        kLabel(L.get('select_cat')),
        GestureDetector(
          onTap: _addCat,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: kTurquoise.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kTurquoise.withOpacity(0.4)),
            ),
            child: Text(L.get('add_cat'),
              style: _nunito(12, kTurquoise, weight: FontWeight.w700)),
          ),
        ),
      ]),
      const SizedBox(height: 12),
      if (widget.user.cats.isEmpty)
        GestureDetector(
          onTap: _addCat,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: kCardDeco(border: kTurquoise.withOpacity(0.3)),
            child: Center(child: Column(children: [
              const Text("🐾", style: TextStyle(fontSize: 36)),
              const SizedBox(height: 8),
              kBody(L.get('no_cats'), color: kMuted),
            ])),
          ),
        )
      else
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: widget.user.cats.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final cat = widget.user.cats[i];
              final sel = _selected?.id == cat.id;
              return GestureDetector(
                onTap: () => setState(() => _selected = cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 95,
                  decoration: BoxDecoration(
                    color: sel ? kCoral.withOpacity(0.1) : kSurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: sel ? kCoral : kBorder, width: sel ? 2 : 1),
                    boxShadow: sel ? [BoxShadow(
                      color: kCoral.withOpacity(0.2), blurRadius: 10)] : [],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(cat.tipo == 'perro' ? "🐶" : "🐱", style: TextStyle(fontSize: sel ? 32 : 28)),
                      const SizedBox(height: 6),
                      Text(cat.name,
                        style: _nunito(12, sel ? kCoral : kText,
                            weight: FontWeight.w800),
                        overflow: TextOverflow.ellipsis),
                      Text("${cat.ageYears}a",
                        style: _nunito(10, kMuted)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
    ],
  );

  Widget _features() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      kLabel(L.get('what_analyzes')),
      const SizedBox(height: 12),
      Wrap(spacing: 8, runSpacing: 8, children: [
        _chip(L.get('feat_breed'),  kPurple),
        _chip(L.get('feat_weight'), kTurquoise),
        _chip(L.get('feat_color'),  kYellow),
        _chip(L.get('feat_body'),   kCoral),
        _chip(L.get('feat_mood'),   kGreen),
        _chip(L.get('feat_ears'),   kBlue),
      ]),
    ],
  );

  Widget _chip(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Text(label, style: _nunito(13, color, weight: FontWeight.w700)),
  );
}

// ════════════════════════════════════════════════════════════════
//  ADD CAT SHEET
// ════════════════════════════════════════════════════════════════

class AddCatSheet extends StatefulWidget {
  final Function(CatProfile) onSave;
  const AddCatSheet({Key? key, required this.onSave}) : super(key: key);
  @override
  State<AddCatSheet> createState() => _AddCatSheetState();
}

class _AddCatSheetState extends State<AddCatSheet> {
  final _nameCtrl  = TextEditingController();
  int    _ageYears  = 1;
  int    _ageMonths = 0;
  String _tipo      = 'gato';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: kBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(
          width: 40, height: 4,
          decoration: BoxDecoration(
            color: kBorder, borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 20),
        Row(children: [
          Text(_tipo == 'gato' ? "🐱" : "🐶",
              style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 10),
          kTitle(L.get('add_pet'), size: 20, color: kCoral),
        ]),
        const SizedBox(height: 16),
        kLabel(L.get('pet_type_label')),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: GestureDetector(
            onTap: () => setState(() => _tipo = 'gato'),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: _tipo == 'gato'
                    ? kCoral.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _tipo == 'gato' ? kCoral : kBorder, width: 2)),
              child: Column(children: [
                const Text("🐱", style: TextStyle(fontSize: 28)),
                const SizedBox(height: 4),
                Text(L.get('cat'), style: _nunito(13,
                    _tipo == 'gato' ? kCoral : kMuted,
                    weight: FontWeight.w800)),
              ]),
            ),
          )),
          const SizedBox(width: 12),
          Expanded(child: GestureDetector(
            onTap: () => setState(() => _tipo = 'perro'),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: _tipo == 'perro'
                    ? kTurquoise.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _tipo == 'perro' ? kTurquoise : kBorder, width: 2)),
              child: Column(children: [
                const Text("🐶", style: TextStyle(fontSize: 28)),
                const SizedBox(height: 4),
                Text(L.get('dog'), style: _nunito(13,
                    _tipo == 'perro' ? kTurquoise : kMuted,
                    weight: FontWeight.w800)),
              ]),
            ),
          )),
        ]),
        const SizedBox(height: 16),
        kTextField(_nameCtrl,
            _tipo == 'gato' ? "Nombre del gatito" : "Nombre del perrito",
            icon: Icons.pets_rounded,
            accent: _tipo == 'gato' ? kCoral : kTurquoise),
        const SizedBox(height: 16),
        kLabel(L.get('cat_age')),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: _counter(
            "${L.get('years')}: $_ageYears",
            () => setState(() { if (_ageYears > 0) _ageYears--; }),
            () => setState(() => _ageYears++),
            _tipo == 'gato' ? kCoral : kTurquoise)),
          const SizedBox(width: 12),
          Expanded(child: _counter(
            "${L.get('months')}: $_ageMonths",
            () => setState(() { if (_ageMonths > 0) _ageMonths--; }),
            () => setState(() { if (_ageMonths < 11) _ageMonths++; }),
            kPurple)),
        ]),
        const SizedBox(height: 24),
        kGradBtn(L.get('save'), () {
          if (_nameCtrl.text.isEmpty) return;
          widget.onSave(CatProfile(
            id:        DateTime.now().millisecondsSinceEpoch.toString(),
            name:      _nameCtrl.text.trim(),
            ageYears:  _ageYears,
            ageMonths: _ageMonths,
            tipo:      _tipo,
          ));
          Navigator.pop(context);
        }),
      ]),
    );
  }

  Widget _counter(String label, VoidCallback dec, VoidCallback inc, Color color) =>
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        GestureDetector(onTap: dec,
          child: Icon(Icons.remove_circle_rounded, color: color, size: 22)),
        Text(label, style: _nunito(13, color, weight: FontWeight.w700)),
        GestureDetector(onTap: inc,
          child: Icon(Icons.add_circle_rounded, color: color, size: 22)),
      ]),
    );
}

// ════════════════════════════════════════════════════════════════
//  SCAN SCREEN
// ════════════════════════════════════════════════════════════════

class ScanScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  final String serverIp;
  final CatProfile cat;
  final UserAccount user;
  final VoidCallback onComplete;
  const ScanScreen({Key? key, required this.cameras, required this.serverIp,
      required this.cat, required this.user, required this.onComplete})
      : super(key: key);
  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with TickerProviderStateMixin {
  CameraController? _cam;
  Timer?  _scanTimer, _cdTimer;
  int     _secs     = SCAN_DURATION;
  bool    _scanning = false, _sending = false;
  int     _frames   = 0;
  Map<String, dynamic>? _last;
  String  _sesion   = DateTime.now().millisecondsSinceEpoch.toString();
  late AnimationController _ringCtrl;

  // ── Rate limit: evita spam de escaneos al backend ──
  static DateTime? _lastScanFinished;
  static const int _cooldownSeconds = 30;

  bool get _isOnCooldown {
    if (_lastScanFinished == null) return false;
    return DateTime.now().difference(_lastScanFinished!).inSeconds < _cooldownSeconds;
  }

  int get _cooldownRemaining {
    if (_lastScanFinished == null) return 0;
    final elapsed = DateTime.now().difference(_lastScanFinished!).inSeconds;
    return (_cooldownSeconds - elapsed).clamp(0, _cooldownSeconds);
  }

  @override
  void initState() {
    super.initState();
    _ringCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))..repeat();
    _initCam();
  }

  Future<void> _initCam() async {
    _cam = CameraController(widget.cameras.first,
        ResolutionPreset.medium, enableAudio: false);
    await _cam!.initialize();
    if (mounted) setState(() {});
  }

  void _start() {
    // Rate limit: impide iniciar si no han pasado los segundos de cooldown
    if (_isOnCooldown) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: kCoral,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(
          L.lang == 'en'
            ? '⏱ Please wait ${_cooldownRemaining}s before scanning again'
            : '⏱ Espera ${_cooldownRemaining}s antes de escanear de nuevo',
          style: _nunito(13, Colors.white, weight: FontWeight.w700)),
      ));
      return;
    }
    setState(() { _scanning = true; _secs = SCAN_DURATION; _frames = 0; _last = null; });
    _scanTimer = Timer.periodic(Duration(milliseconds: FRAME_INTERVAL), (_) => _capture());
    _cdTimer   = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => _secs--);
      if (_secs <= 0) _finish();
    });
  }

  Future<void> _capture() async {
    if (_cam == null || !_cam!.value.isInitialized || _sending) return;
    setState(() => _sending = true);
    try {
      final foto  = await _cam!.takePicture();
      final bytes = await foto.readAsBytes();
      final ip    = widget.serverIp;
      final proto = ip.contains('onrender') || ip.contains('trycloudflare') ? 'https' : 'http';
      final port  = ip.contains('onrender') || ip.contains('trycloudflare') ? '' : ':8000';
      final uri   = Uri.parse('$proto://$ip$port/analizar?sesion_id=$_sesion');
      final req   = http.MultipartRequest('POST', uri)
        ..headers['X-API-Key'] = kApiKey
        ..fields['lang'] = L.lang
        ..files.add(http.MultipartFile.fromBytes('file', bytes, filename: 'f.jpg'));
      final s   = await req.send().timeout(const Duration(seconds: 10));
      final res = await http.Response.fromStream(s);
      if (res.statusCode == 200 && mounted) {
        final data = _decodeGeneralJson(res.body);
        if (data != null) {
          setState(() {
            _frames++;
            if (data['mascota_detectada'] == true &&
                _shouldKeepGeneralResult(data, _last)) {
              _last = data;
            }
          });
          if (_last != null && _scanning) Future.microtask(() => _finish());
        } else {
          setState(() => _frames++);
        }
      }
    } catch (_) {} finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  int _generalResultScore(Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) return -1;
    if (data['mascota_detectada'] != true) return -100; // ignorar respuestas sin detección
    var score = 0;
    if (data['mascota_detectada'] == true) score += 2;
    if ((data['raza']?['raza'] ?? '').toString().isNotEmpty && data['raza']?['raza'] != '-') score += 3;
    if ((data['peso']?['peso_kg']) != null && data['peso']?['peso_kg'] != 0) score += 2;
    if ((data['color']?['color_principal'] ?? '').toString().isNotEmpty && data['color']?['color_principal'] != '-') score += 2;
    if ((data['estado_corporal']?['estado'] ?? '').toString().isNotEmpty && data['estado_corporal']?['estado'] != '-') score += 2;
    if ((data['gesto']?['nombre'] ?? '').toString().isNotEmpty && data['gesto']?['nombre'] != '-') score += 1;
    if ((data['orejas']?['posicion'] ?? '').toString().isNotEmpty && data['orejas']?['posicion'] != '-') score += 1;
    if ((data['imagen_anotada'] ?? '').toString().isNotEmpty) score += 1;
    return score;
  }

  bool _shouldKeepGeneralResult(Map<String, dynamic> candidate, Map<String, dynamic>? current) {
    final candidateScore = _generalResultScore(candidate);
    final currentScore   = _generalResultScore(current);
    return candidateScore >= currentScore;
  }

  Map<String, dynamic>? _decodeGeneralJson(String body) {
    try { return json.decode(body) as Map<String, dynamic>; }
    catch (_) {}
    final start = body.indexOf('{');
    final end   = body.lastIndexOf('}');
    if (start != -1 && end != -1 && end > start) {
      final slice = body.substring(start, end + 1);
      try { return json.decode(slice) as Map<String, dynamic>; } catch (_) {}
    }
    final cleaned = body
      .replaceAll(RegExp(r",\\s*}"), "}")
      .replaceAll(RegExp(r",\\s*]"), "]");
    try { return json.decode(cleaned) as Map<String, dynamic>; } catch (_) {}
    return null;
  }

  static String _normalizeTipo(String endpoint) {
    if (endpoint.contains('respiracion')) return 'respiracion';
    if (endpoint.contains('espasmo'))     return 'espasmos';
    if (endpoint.contains('encias'))      return 'encias';
    return endpoint;
  }

  void _finish() async {
    _scanTimer?.cancel(); _cdTimer?.cancel();
    // Registrar timestamp para el rate limit
    _lastScanFinished = DateTime.now();
    setState(() => _scanning = false);
    if (_last != null) {
      final raw = Map<String, dynamic>.from(_last!);
      final record = ScanRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        catId: widget.cat.id, date: DateTime.now(),
        resultado: _normalizeGeneral(raw));
      debugPrint("Navigating to ResultScreen with: ${jsonEncode(record.resultado)}");
      widget.user.scans.add(record);
      await StorageService.saveScans(widget.user.scans);
      await FirestoreService.saveEscaneos(widget.user.scans);
      widget.onComplete();
      if (!mounted) return;
      try {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => ResultScreen(
            record: record, cat: widget.cat,
            user: widget.user, serverIp: widget.serverIp,
            cameras: widget.cameras)));
      } catch (e) {
        debugPrint("Navigation error: $e");
      }
    }
  }

  Map<String, dynamic> _normalizeGeneral(Map<String, dynamic> raw) {
    final raza = raw['raza'] as Map? ?? {};
    final peso = raw['peso'] as Map? ?? {};
    final color= raw['color'] as Map? ?? {};
    return {
      ...raw,
      'tipo': 'general',
      'raza': {
        'raza':        raza['raza'] ?? raza['nombre'] ?? '-',
        'confianza':   raza['confianza'] ?? 0,
        'descripcion': raza['descripcion'] ?? '',
      },
      'peso': {
        'peso_kg':   peso['peso_kg'] ?? peso['estimado_kg'] ?? '-',
        'peso_lb':   peso['peso_lb'] ?? peso['estimado_lb'] ?? '-',
        'rango':     '${peso['rango_min_kg'] ?? ''} - ${peso['rango_max_kg'] ?? ''} kg',
        'confianza': peso['confianza'] ?? '-',
      },
      'color': {
        'color_principal': color['color_principal'] ?? '-',
        'patron':          color['patron'] ?? '-',
        'hex':             color['hex'] ?? color['hex_aproximado'] ?? '#888888',
      },
    };
  }

  @override
  void dispose() {
    _scanTimer?.cancel(); _cdTimer?.cancel();
    _cam?.dispose(); _ringCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [
        if (_cam != null && _cam!.value.isInitialized)
          SizedBox.expand(child: CameraPreview(_cam!)),
        SafeArea(child: Column(children: [
          _topBar(),
          _scanBanner(),
          const Spacer(),
          _overlay(),
          const SizedBox(height: 24),
          _controls(),
          const SizedBox(height: 48),
        ])),
      ]),
    );
  }

  Widget _scanBanner() => AnimatedSwitcher(
    duration: const Duration(milliseconds: 400),
    child: _scanning
      ? Container(
          key: const ValueKey('scanning'),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: kCoral.withOpacity(0.85),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: kCoral.withOpacity(0.4), blurRadius: 10, offset: const Offset(0,4))]),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const SizedBox(width: 10, height: 10,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
            const SizedBox(width: 10),
            Text(L.lang == 'en'
              ? '🔍 Scanning · Keep the camera still'
              : '🔍 Escaneando · Mantén la cámara quieta',
              style: _nunito(13, Colors.white, weight: FontWeight.w700)),
          ]))
      : Container(
          key: const ValueKey('tip'),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xCC000000), Color(0xAA1a1a2e)],
              begin: Alignment.centerLeft, end: Alignment.centerRight),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white24)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('💡', style: TextStyle(fontSize: 15)),
            const SizedBox(width: 8),
            Flexible(child: Text(
              L.lang == 'en'
                ? 'Center your pet in the circle and tap Scan'
                : 'Centra a tu mascota en el círculo y toca Escanear',
              style: _nunito(12, Colors.white70),
              textAlign: TextAlign.center)),
          ])));

  Widget _topBar() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    decoration: BoxDecoration(gradient: LinearGradient(
      colors: [Colors.black87, Colors.transparent],
      begin: Alignment.topCenter, end: Alignment.bottomCenter)),
    child: Row(children: [
      GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white24, shape: BoxShape.circle),
          child: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 18))),
      const Spacer(),
      Text("${widget.cat.name} 🐱",
        style: _nunito(16, Colors.white, weight: FontWeight.w800)),
      const Spacer(),
      if (_sending)
        const SizedBox(width: 28, height: 28,
            child: CircularProgressIndicator(color: kCoral, strokeWidth: 2.5))
      else
        const SizedBox(width: 28),
    ]),
  );

  Widget _overlay() {
    final prog = 1 - (_secs / SCAN_DURATION);
    return Stack(alignment: Alignment.center, children: [
      SizedBox(width: 260, height: 260,
        child: CircularProgressIndicator(
          value: _scanning ? prog : 0,
          strokeWidth: 6,
          backgroundColor: Colors.white24,
          valueColor: const AlwaysStoppedAnimation<Color>(kCoral),
          strokeCap: StrokeCap.round,
        )),
      Container(
        width: 234, height: 234,
        decoration: BoxDecoration(
          color: Colors.black45,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24)),
        child: Center(child: _scanning
          ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text("$_secs",
                style: _nunito(56, kCoral, weight: FontWeight.w900)),
              Text(L.get('seconds'), style: _nunito(13, Colors.white70)),
              const SizedBox(height: 6),
              Text("$_frames ${L.get('frames')}",
                style: _nunito(11, Colors.white38)),
              if (_last != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: kCoral.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10)),
                  child: Text(_last!['raza']?['raza'] ?? '',
                    style: _nunito(11, kCoralLight)),
                ),
              ],
            ])
          : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text("🐱", style: TextStyle(fontSize: 56)),
              const SizedBox(height: 8),
              Text(widget.cat.name, style: _nunito(16, Colors.white,
                  weight: FontWeight.w800)),
            ]),
        ),
      ),
    ]);
  }

  Widget _controls() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: _scanning
      ? [
          _btn(Icons.stop_rounded,         Colors.orange, _finish),
          const SizedBox(width: 20),
          _btn(Icons.fast_forward_rounded,  kGreen,       _finish),
        ]
      : [_btn(Icons.play_arrow_rounded, kCoral, _start)],
  );

  Widget _btn(IconData icon, Color color, VoidCallback fn) =>
    GestureDetector(
      onTap: fn,
      child: Container(
        width: 68, height: 68,
        decoration: BoxDecoration(
          color: color, shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 16)]),
        child: Icon(icon, color: Colors.white, size: 30)));
}

// ════════════════════════════════════════════════════════════════
//  RESULT SCREEN
// ════════════════════════════════════════════════════════════════

class ResultScreen extends StatelessWidget {
  final ScanRecord   record;
  final CatProfile   cat;
  final UserAccount  user;
  final String       serverIp;
  final List<CameraDescription> cameras;
  const ResultScreen({Key? key, required this.record, required this.cat,
      required this.user, required this.serverIp, required this.cameras})
      : super(key: key);

  Map<String, dynamic> get r => record.resultado;
  bool get _isEn => L.lang == 'en';
  String _txt(String es, String en) => _isEn ? en : es;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            _topBar(context),
            const SizedBox(height: 16),
            _heroCard(),
            const SizedBox(height: 16),
            _rawJsonCard(),
            const SizedBox(height: 12),
            _infoCard("🧬 ${L.get('breed')}", kPurple, [
              _row(L.get('breed'),    r['raza']?['raza']       ?? '-', kPurple),
              _row(_txt("Confianza IA", "AI confidence"), "${r['raza']?['confianza'] ?? 0}%", kPurple),
              if ((r['raza']?['descripcion'] ?? '').isNotEmpty)
                _desc(r['raza']?['descripcion'] ?? ''),
            ]),
            const SizedBox(height: 12),
            _weightCard(),
            const SizedBox(height: 12),
            _bodyCondCard(),
            const SizedBox(height: 12),
            _infoCard("🎨 ${L.get('color')}", kYellow, [
              Row(children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: _parseHex(r['color']?['hex'] ?? '#888'),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: kBorder)),
                ),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  kBody(r['color']?['color_principal'] ?? '-', color: kText),
                  kBody(r['color']?['hex'] ?? '', color: kMuted, size: 12),
                ]),
              ]),
              const SizedBox(height: 8),
              _row(L.get('pattern'), r['color']?['patron'] ?? '-', kYellow),
            ]),
            const SizedBox(height: 12),
            _earCard(),
            const SizedBox(height: 12),
            _moodCard(),
            const SizedBox(height: 12),
            _colaCard(),
            const SizedBox(height: 12),
            _consejo(),
            const SizedBox(height: 24),
            _actions(context),
            const SizedBox(height: 20),
          ]),
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context) => Row(children: [
    GestureDetector(
      onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: kCardDeco(radius: 14),
        child: const Icon(Icons.home_rounded, color: kCoral, size: 22))),
    const SizedBox(width: 12),
    Expanded(child: kTitle(L.get('results'), size: 22)),
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: kCardDeco(radius: 10),
      child: Text(DateFormat('dd/MM/yy').format(record.date),
        style: _nunito(11, kMuted))),
  ]);

  Widget _heroCard() {
    final imgB64 = r['imagen_anotada'] as String?;
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kBorder),
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Stack(fit: StackFit.expand, children: [
        if (imgB64 != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.memory(base64Decode(imgB64), fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Center(
                child: Text("🐱", style: TextStyle(fontSize: 60))))),
        Positioned(bottom: 12, left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20)),
            child: Text(
              "${cat.tipo == 'perro' ? '🐶' : '🐱'} ${cat.name} · ${cat.ageYears}${L.get('years')} ${cat.ageMonths}${L.get('months')}",
              style: _nunito(13, kCoral, weight: FontWeight.w800)))),
      ]),
    );
  }

  Widget _weightCard() {
    final pesoKg = r['peso']?['peso_kg'] ?? '-';
    final pesoLb = r['peso']?['peso_lb'] ?? '-';
    final rango  = r['peso']?['rango']   ?? '';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: kCardDeco(border: kTurquoise.withOpacity(0.3)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kTurquoise.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12)),
            child: const Text("⚖️", style: TextStyle(fontSize: 20))),
          const SizedBox(width: 10),
          kTitle("${L.get('weight')}", size: 16, color: kText),
        ]),
        const SizedBox(height: 14),
        Row(crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic, children: [
          Text("$pesoKg kg",
            style: _nunito(40, kTurquoise, weight: FontWeight.w900)),
          const SizedBox(width: 10),
          kBody("$pesoLb lb", color: kMuted),
        ]),
        if (rango.isNotEmpty) kBody("${_txt('Rango', 'Range')}: $rango", color: kMuted, size: 12),
        const SizedBox(height: 6),
        _row(_txt("Confianza", "Confidence"), r['peso']?['confianza'] ?? '-', kTurquoise),
      ]),
    );
  }

  Widget _bodyCondCard() {
    final corp   = r['estado_corporal'] as Map? ?? {};
    final hexStr = corp['color_hex'] as String? ?? '#55EFC4';
    Color color;
    try { color = Color(int.parse(hexStr.replaceFirst('#', '0xFF'))); }
    catch (_) { color = kGreen; }
    final bcs   = (corp['bcs']      ?? 5) as int;
    final bcsMax= (corp['bcs_max']  ?? 9) as int;
    final salud = (corp['salud_pct']?? 75) as int;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: kCardDeco(border: color.withOpacity(0.3)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12)),
            child: const Text("💪", style: TextStyle(fontSize: 20))),
          const SizedBox(width: 10),
          kTitle(L.get('body_condition'), size: 16),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color)),
            child: Text("${corp['emoji'] ?? ''} ${corp['estado'] ?? ''}",
              style: _nunito(12, color, weight: FontWeight.w800))),
        ]),
        const SizedBox(height: 16),
        kBody("BCS: $bcs / $bcsMax", color: kMuted, size: 12),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: bcs/bcsMax,
            backgroundColor: kBorder,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 10)),
        const SizedBox(height: 10),
        kBody("${L.get('health_score')}: $salud%", color: kMuted, size: 12),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: salud/100,
            backgroundColor: kBorder,
            valueColor: const AlwaysStoppedAnimation<Color>(kGreen),
            minHeight: 10)),
      ]),
    );
  }

  Widget _earCard() {
    final orejas = r['orejas'] as Map? ?? {};
    final gesto  = r['gesto']  as Map? ?? {};
    final posicion   = orejas['posicion']   ?? '-';
    final estado     = orejas['estado']     ?? '-';
    final significado= orejas['significado']?? '-';
    final alerta     = orejas['alerta']     ?? false;

    return _infoCard("👂 ${L.get('ears')}", kBlue, [
      Row(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: alerta
                ? kCoral.withOpacity(0.1) : kGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: alerta ? kCoral : kGreen)),
          child: Text(posicion,
            style: _nunito(13, alerta ? kCoral : kGreen,
                weight: FontWeight.w700))),
      ]),
      const SizedBox(height: 8),
      _row(_txt("Estado", "State"), estado, kBlue),
      const SizedBox(height: 4),
      kBody(significado, color: kMuted, size: 13),
    ]);
  }

  Widget _moodCard() {
    final gesto = r['gesto'] as Map? ?? {};
    final nombre      = gesto['nombre']       ?? '-';
    final descripcion = gesto['descripcion']  ?? '-';
    final estres      = (gesto['nivel_estres']?? 0) as int;
    final cola        = gesto['cola_posicion'];

    return _infoCard("😺 ${L.get('mood')}", kPurple, [
      Text(nombre, style: _nunito(18, kPurple, weight: FontWeight.w800)),
      const SizedBox(height: 8),
      kBody(descripcion, color: kMuted, size: 13),
      const SizedBox(height: 10),
              kBody("${L.get('stress_level')}: $estres/10", color: kMuted, size: 12),
      const SizedBox(height: 6),
      ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: LinearProgressIndicator(
          value: estres/10,
          backgroundColor: kBorder,
          valueColor: AlwaysStoppedAnimation<Color>(
              estres > 6 ? kCoral : estres > 3 ? kYellow : kGreen),
          minHeight: 8)),
      if (cola != null) ...[
        const SizedBox(height: 8),
        _row(_txt("Cola", "Tail"), cola.toString(), kPurple),
      ],
    ]);
  }

  Widget _colaCard() {
    final cola = record.resultado['cola'] as Map? ?? {};
    final visible  = cola['visible'] ?? false;
    if (!visible || cola.isEmpty) return const SizedBox();
    final posicion   = cola['posicion']   ?? '-';
    final significado= cola['significado']?? '-';
    return Column(children: [
      _infoCard("🐾 ${_txt('Cola', 'Tail')}", kGreen, [
        _row(_txt("Posición", "Position"), posicion, kGreen),
        const SizedBox(height: 6),
        kBody(significado, color: kMuted, size: 13),
      ]),
      const SizedBox(height: 12),
    ]);
  }

  Widget _consejo() {
    final texto = r['estado_corporal']?['consejo'] ?? '';
    if (texto.isEmpty) return const SizedBox();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kYellow.withOpacity(0.2), kCoral.withOpacity(0.1)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kYellow.withOpacity(0.5)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("💡", style: TextStyle(fontSize: 22)),
        const SizedBox(width: 12),
        Expanded(child: kBody(texto, size: 13)),
      ]),
    );
  }

  Widget _actions(BuildContext context) => Column(children: [
    kGradBtn(L.get('download_pdf'), () => _downloadPdf(context)),
    const SizedBox(height: 12),
    kOutlineBtn(L.get('new_scan'), () => Navigator.of(context).pop()),
  ]);

  // ── PDF ──────────────────────────────────────────────────────
  Future<void> _downloadPdf(BuildContext context) async {
    final pdf = pw.Document();
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(_txt('MeowScan — Reporte de Mascota', 'MeowScan — Pet Report'),
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Text((_txt('Mascota: ', 'Pet: ')) + cat.name + ' · ' + cat.ageYears.toString() + (_txt(' años ', 'y ')) + cat.ageMonths.toString() + (_txt(' meses', 'm')),
          ),
          pw.Text((_txt('Fecha: ', 'Date: ')) + DateFormat('dd/MM/yyyy HH:mm').format(record.date)),
          pw.Divider(),
          pw.SizedBox(height: 12),
          _pdfRow(_txt('Raza', 'Breed'), r['raza']?['raza'] ?? '-'),
          _pdfRow(_txt('Confianza IA', 'AI confidence'), '${r['raza']?['confianza'] ?? 0}%'),
          _pdfRow(_txt('Peso', 'Weight'), '${r['peso']?['peso_kg'] ?? '-'} kg / ${r['peso']?['peso_lb'] ?? '-'} lb'),
          _pdfRow(_txt('Estado corporal', 'Body condition'), r['estado_corporal']?['estado'] ?? '-'),
          _pdfRow('BCS',            '${r['estado_corporal']?['bcs'] ?? '-'} / 9'),
          _pdfRow(_txt('Índice salud', 'Health score'), '${r['estado_corporal']?['salud_pct'] ?? '-'}%'),
          _pdfRow(_txt('Color pelaje', 'Coat color'), r['color']?['color_principal'] ?? '-'),
          _pdfRow(_txt('Patrón', 'Pattern'), r['color']?['patron'] ?? '-'),
          _pdfRow(_txt('Orejas', 'Ears'), r['orejas']?['posicion'] ?? '-'),
          _pdfRow(_txt('Estado ánimo', 'Mood'), r['gesto']?['nombre'] ?? '-'),
          _pdfRow(_txt('Nivel estrés', 'Stress level'), '${r['gesto']?['nivel_estres'] ?? 0}/10'),
          pw.SizedBox(height: 16),
          pw.Text(_txt('Consejo:', 'Tip:'), style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text(r['estado_corporal']?['consejo'] ?? ''),
          pw.SizedBox(height: 24),
          pw.Text(_txt('Generado por MeowScan v$APP_VERSION', 'Generated by MeowScan v$APP_VERSION'),
            style: const pw.TextStyle(fontSize: 10)),
        ],
      ),
    ));
    await Printing.layoutPdf(
      onLayout: (_) async => pdf.save(),
      name: 'meowscan_${cat.name}_${DateFormat('yyyyMMdd').format(record.date)}.pdf');
  }

  pw.Widget _pdfRow(String l, String v) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 6),
    child: pw.Row(children: [
      pw.SizedBox(width: 140,
        child: pw.Text(l, style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold, fontSize: 12))),
      pw.Text(v, style: const pw.TextStyle(fontSize: 12)),
    ]));

  // ── Helpers ──────────────────────────────────────────────────
  Widget _infoCard(String titulo, Color accent, List<Widget> children) =>
    Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: kCardDeco(border: accent.withOpacity(0.2)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12)),
            child: Text(titulo.split(' ').first,
              style: const TextStyle(fontSize: 18))),
          const SizedBox(width: 10),
          kTitle(titulo.split(' ').skip(1).join(' '), size: 15),
        ]),
        const SizedBox(height: 12),
        Container(height: 1, color: accent.withOpacity(0.15)),
        const SizedBox(height: 12),
        ...children,
      ]),
    );

  Widget _row(String l, String v, Color accent) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      kBody(l, color: kMuted, size: 13),
      kBody(v, size: 13),
    ]));

  Widget _desc(String text) => Padding(
    padding: const EdgeInsets.only(top: 6),
    child: kBody(text, color: kMuted, size: 12));

  Color _parseHex(String hex) {
    try { return Color(int.parse(hex.replaceFirst('#', '0xFF'))); }
    catch (_) { return Colors.grey; }
  }

  Widget _rawJsonCard() {
    final pretty = const JsonEncoder.withIndent('  ').convert(r);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: kCardDeco(border: kBorder),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        kBody(_txt("Respuesta raw (depuración)", "Raw response (debug)"),
          color: kMuted, size: 12),
        const SizedBox(height: 6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Text(pretty,
            style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
          ),
        ),
      ]),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  HISTORY TAB — con borrar escaneos
// ════════════════════════════════════════════════════════════════

class HistoryTab extends StatefulWidget {
  final UserAccount user;
  final List<CameraDescription> cameras;
  final VoidCallback onRefresh;
  const HistoryTab({Key? key, required this.user,
      required this.cameras, required this.onRefresh}) : super(key: key);
  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {

  void _deleteScan(ScanRecord scan) async {
    // If orphan scan (pet deleted), delete silently without confirmation
    final isOrphan = !widget.user.cats.any((c) => c.id == scan.catId) 
                     && scan.catId != 'general';
    if (isOrphan) {
      widget.user.scans.removeWhere((s) => s.id == scan.id);
      await StorageService.saveScans(widget.user.scans);
      await FirestoreService.saveEscaneos(widget.user.scans);
      widget.onRefresh();
      if (mounted) setState(() {});
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(L.get('delete_confirm'),
          style: _nunito(18, kText, weight: FontWeight.w800)),
        content: Text(L.get('delete_scan_msg'),
          style: _nunito(14, kMuted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(L.get('cancel_delete'),
              style: _nunito(14, kMuted))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: kCoral,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12))),
            child: Text(L.get('delete'),
              style: _nunito(14, Colors.white, weight: FontWeight.w700))),
        ],
      ),
    );
    if (confirm == true) {
      widget.user.scans.removeWhere((s) => s.id == scan.id);
      await StorageService.saveScans(widget.user.scans);
      await FirestoreService.saveEscaneos(widget.user.scans);
      widget.onRefresh();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Only show scans whose pet still exists (or general scans)
    final validCatIds = widget.user.cats.map((c) => c.id).toSet();
    final scans = widget.user.scans
        .where((s) => s.catId == 'general' || validCatIds.contains(s.catId))
        .toList()
        ..sort((a, b) => b.date.compareTo(a.date));

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Header estilo Settings ──
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Row(children: [
              Container(
                width: 50, height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [kCoral, Color(0xFFFF8E53)]),
                  borderRadius: BorderRadius.circular(16)),
                child: const Center(child: Text('📋', style: TextStyle(fontSize: 24)))),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                kTitle(L.get('scan_history'), size: 22),
                kBody('MeowScanAI v$APP_VERSION', color: kMuted, size: 12),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: kCoral.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20)),
                child: Text("${scans.length} ${L.lang == 'en' ? 'scans' : 'escaneos'}",
                  style: _nunito(12, kCoral, weight: FontWeight.w700))),
            ])),
          if (scans.isEmpty)
            Expanded(child: Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("📋", style: TextStyle(fontSize: 56)),
                const SizedBox(height: 16),
                kBody(L.get('no_scans'), color: kMuted, size: 16),
              ])))
          else
            Expanded(child: ListView.separated(
              itemCount: scans.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final s   = scans[i];
                final cat = widget.user.cats.firstWhere(
                  (c) => c.id == s.catId,
                  orElse: () => CatProfile(
                      id: 'general',
                      name: L.lang == 'en' ? 'General' : 'General',
                      ageYears: 0, ageMonths: 0));
                return _scanTile(context, s, cat);
              },
            )),
        ]),
      ),
    );
  }

  // Helper: get scan type info
  Map<String, dynamic> _tipoInfo(String tipo) {
    switch (tipo) {
      case 'vomito':        return {'emoji': '🤮', 'label': L.get('vomit_title') ?? 'Vómito', 'color': 0xFF6C5CE7};
      case 'analizar_respiracion':
      case 'respiracion':   return {'emoji': '🫁', 'label': L.get('scan_resp_title') ?? 'Respiración', 'color': 0xFF00B894};
      case 'analizar_espasmos':
      case 'espasmos':      return {'emoji': '🐾', 'label': L.get('scan_spasm_title') ?? 'Espasmos', 'color': 0xFFE17055};
      case 'analizar_encias':
      case 'encias':        return {'emoji': '🦷', 'label': L.get('scan_gums_title') ?? 'Encías', 'color': 0xFFFF6B9D};
      case 'nutricion':     return {'emoji': '🥗', 'label': L.lang == 'en' ? 'Food Analysis' : 'Análisis Nutricional', 'color': 0xFF11998E};
      case 'maullido':      return {'emoji': '😿', 'label': L.get('scan_meow_title') ?? 'Maullido', 'color': 0xFF6C5CE7};
      default:              return {'emoji': '🔍', 'label': L.get('results') ?? 'Escaneo', 'color': 0xFF4ECDC4};
    }
  }

  Widget _scanTile(BuildContext context, ScanRecord s, CatProfile cat) {
    final tipo    = s.resultado['tipo'] as String? ?? 'general';
    final info    = _tipoInfo(tipo);
    final tColor  = Color(info['color'] as int);
    final tEmoji  = info['emoji'] as String;
    final tLabel  = info['label'] as String;

    // Type-specific subtitle
    String subtitle = '';
    String value    = '';
    if (tipo == 'general') {
      subtitle = s.resultado['raza']?['raza'] ?? '-';
      final peso = s.resultado['peso']?['peso_kg'];
      value = peso != null ? '$peso kg' : '-';
    } else if (tipo == 'vomito') {
      subtitle = s.resultado['color_principal'] ?? '-';
      value = s.resultado['urgencia'] ?? '-';
    } else if (tipo == 'analizar_respiracion' || tipo == 'respiracion') {
      final rpm = s.resultado['respiraciones_por_minuto'];
      subtitle = s.resultado['patron'] ?? '-';
      value = rpm != null ? '$rpm rpm' : '-';
    } else if (tipo == 'analizar_espasmos' || tipo == 'espasmos') {
      subtitle = s.resultado['zona_afectada'] ?? '-';
      value = s.resultado['intensidad'] ?? '-';
    } else if (tipo == 'analizar_encias' || tipo == 'encias') {
      subtitle = s.resultado['color_detectado'] ?? '-';
      value = s.resultado['estado'] ?? '-';
    } else if (tipo == 'maullido') {
      subtitle = s.resultado['tipo_sonido'] ?? '-';
      value = s.resultado['estado_emocional'] ?? '-';
    }

    return Dismissible(
      key: Key(s.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: kCoral.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20)),
        child: const Icon(Icons.delete_rounded, color: kCoral, size: 28)),
      confirmDismiss: (_) async { _deleteScan(s); return false; },
      child: GestureDetector(
        onTap: () {
          if (tipo == 'general') {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => ResultScreen(
                record: s, cat: cat, user: widget.user,
                serverIp: '', cameras: widget.cameras)));
          }
          // Other types just show in history for now
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: kCardDeco(),
          child: Row(children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: tColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16)),
              child: Center(child: Text(tEmoji,
                style: const TextStyle(fontSize: 26)))),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fila 1: nombre + badge tipo
                Row(children: [
                  Flexible(
                    child: Text(cat.name,
                      style: _nunito(14, kText, weight: FontWeight.w800),
                      overflow: TextOverflow.ellipsis)),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: tColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8)),
                    child: Text(tLabel,
                      style: _nunito(9, tColor, weight: FontWeight.w700))),
                ]),
                const SizedBox(height: 4),
                // Fila 2: subtitle izq, value der
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(subtitle,
                        style: _nunito(12, kMuted),
                        overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: 8),
                    Text(value,
                      style: _nunito(12, tColor, weight: FontWeight.w800),
                      overflow: TextOverflow.ellipsis),
                  ]),
                const SizedBox(height: 2),
                // Fecha
                Text(DateFormat('dd/MM/yy').format(s.date),
                  style: _nunito(11, kMuted)),
              ])),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _deleteScan(s),
              child: const Icon(Icons.delete_outline_rounded,
                color: kMuted, size: 20)),
          ]),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  PROFILE TAB — con borrar gatos
// ════════════════════════════════════════════════════════════════

class ProfileTab extends StatefulWidget {
  final UserAccount user;
  final List<CameraDescription> cameras;
  final VoidCallback onRefresh;
  const ProfileTab({Key? key, required this.user,
      required this.cameras, required this.onRefresh}) : super(key: key);
  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {

  void _deleteCat(CatProfile cat) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(L.get('delete_confirm'),
          style: _nunito(18, kText, weight: FontWeight.w800)),
        content: Text(L.get('delete_cat_msg'),
          style: _nunito(14, kMuted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: Text(L.get('cancel_delete'), style: _nunito(14, kMuted))),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: kCoral,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12))),
            child: Text(L.get('delete'),
              style: _nunito(14, Colors.white, weight: FontWeight.w700))),
        ],
      ),
    );
    if (confirm == true) {
      await FirestoreService.deleteMascota(cat.id);
      final scansToDelete = widget.user.scans.where((s) => s.catId == cat.id).toList();
      for (final s in scansToDelete) {
        await FirestoreService.deleteEscaneo(s.id);
      }
      widget.user.cats.removeWhere((c) => c.id == cat.id);
      widget.user.scans.removeWhere((s) => s.catId == cat.id);
      await StorageService.saveCats(widget.user.cats);
      await StorageService.saveScans(widget.user.scans);
      widget.onRefresh();
      if (mounted) setState(() {});
      widget.onRefresh();
    }
  }

  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) =>
    GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 17)));

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Header estilo Settings ──
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(children: [
              Container(
                width: 50, height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [kCoral, kPurple]),
                  borderRadius: BorderRadius.circular(16)),
                child: const Center(child: Text('🐾', style: TextStyle(fontSize: 24)))),
              const SizedBox(width: 14),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                kTitle(L.get('my_cats'), size: 22),
                kBody('MeowScanAI v$APP_VERSION', color: kMuted, size: 12),
              ]),
            ])),
          _userCard(),
          const SizedBox(height: 20),
          kLabel(L.get('my_pets_label')),
          const SizedBox(height: 12),
          if (widget.user.cats.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: kCardDeco(),
              child: Center(child: kBody(L.get('no_cats'), color: kMuted)))
          else
            ...widget.user.cats.map((c) => _catCard(c)),

        ]),
      ),
    );
  }

  Widget _userCard() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [kCoral, kPurple],
        begin: Alignment.topLeft, end: Alignment.bottomRight),
      borderRadius: BorderRadius.circular(24),
      boxShadow: [BoxShadow(
        color: kCoral.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))],
    ),
    child: Row(children: [
      Container(
        width: 60, height: 60,
        decoration: BoxDecoration(
          color: Colors.white24, shape: BoxShape.circle),
        child: const Center(child: Text("😊", style: TextStyle(fontSize: 30)))),
      const SizedBox(width: 16),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(widget.user.username,
          style: _nunito(20, Colors.white, weight: FontWeight.w900)),
        kBody(widget.user.email, color: Colors.white70, size: 13),
        const SizedBox(height: 4),
        Text(() {
          final validIds = widget.user.cats.map((c) => c.id).toSet();
          final realScans = widget.user.scans
              .where((s) => validIds.contains(s.catId) || s.catId == 'general')
              .length;
          final petsLabel = L.lang == 'en'
              ? '${widget.user.cats.length} pets'
              : '${widget.user.cats.length} mascotas';
          final scansLabel = L.lang == 'en'
              ? '$realScans scans'
              : '$realScans escaneos';
          return '$scansLabel · $petsLabel';
        }(),
          style: _nunito(12, Colors.white, weight: FontWeight.w700)),
      ]),
    ]),
  );

  Widget _catCard(CatProfile cat) {
    final scans = widget.user.scans.where((s) => s.catId == cat.id).length;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: kCardDeco(),
      child: Row(children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
            color: kCoral.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16)),
          child: Center(child: Text(cat.tipo == 'perro' ? "🐶" : "🐱", style: const TextStyle(fontSize: 26)))),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(cat.name, style: _nunito(16, kText, weight: FontWeight.w800)),
          kBody("${cat.ageYears} ${L.get('years')} ${cat.ageMonths} ${L.get('months')}",
              color: kMuted, size: 12),
            kBody("$scans ${L.lang == 'en' ? 'scans' : 'escaneos'}", color: kCoral, size: 12),
          const SizedBox(height: 8),
          Row(children: [
            _iconBtn(Icons.history_rounded, kTurquoise, () async {
              final ip = await StorageService.getServerIp();
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => HistoriaMedicaScreen(
                  cat: cat, user: widget.user, serverIp: ip)));
            }),
            const SizedBox(width: 6),
            _iconBtn(Icons.vaccines_rounded, const Color(0xFF00CEC9), () =>
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => VaccineScreen(
                  cat: cat, user: widget.user,
                  onRefresh: widget.onRefresh)))),
            const SizedBox(width: 6),
            _iconBtn(Icons.calendar_month_rounded, const Color(0xFF00B894), () =>
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => VetAppointmentsScreen(cat: cat, user: widget.user,
                  onRefresh: widget.onRefresh)))),
            const SizedBox(width: 6),
            _iconBtn(Icons.medication_rounded, kYellow, () =>
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => MedicationsScreen(cat: cat, user: widget.user,
                  onRefresh: widget.onRefresh)))),
            const SizedBox(width: 6),
            _iconBtn(Icons.qr_code_rounded, kPurple, () =>
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => QrGeneratorScreen(cat: cat, user: widget.user)))),
            const SizedBox(width: 6),
            _iconBtn(Icons.delete_rounded, kCoral, () => _deleteCat(cat)),
          ]),
        ])),
      ]),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  VACCINE SCREEN — Carnet de Vacunas
// ════════════════════════════════════════════════════════════════

class VaccineScreen extends StatefulWidget {
  final CatProfile cat;
  final UserAccount user;
  final VoidCallback onRefresh;
  const VaccineScreen({Key? key, required this.cat,
      required this.user, required this.onRefresh}) : super(key: key);
  @override State<VaccineScreen> createState() => _VaccineScreenState();
}

class _VaccineScreenState extends State<VaccineScreen> {

  List<VaccineRecord> get _catVaccines =>
    widget.user.vaccines.where((v) => v.catId == widget.cat.id).toList()
      ..sort((a, b) => b.applicationDate.compareTo(a.applicationDate));

  Color _statusColor(VaccineStatus s) {
    switch (s) {
      case VaccineStatus.ok:      return const Color(0xFF00B894);
      case VaccineStatus.soon:    return kYellow;
      case VaccineStatus.expired: return kCoral;
      case VaccineStatus.noDate:  return kMuted;
    }
  }

  String _statusLabel(VaccineStatus s) {
    switch (s) {
      case VaccineStatus.ok:      return L.lang == 'en' ? 'Up to date' : 'Al día';
      case VaccineStatus.soon:    return L.lang == 'en' ? 'Due soon' : 'Pronto a vencer';
      case VaccineStatus.expired: return L.lang == 'en' ? 'Expired' : 'Vencida';
      case VaccineStatus.noDate:  return L.lang == 'en' ? 'No date' : 'Sin fecha';
    }
  }

  void _addVaccine() {
    final nameCtrl  = TextEditingController();
    final vetCtrl   = TextEditingController();
    final lotCtrl   = TextEditingController();
    final notesCtrl = TextEditingController();
    DateTime appDate  = DateTime.now();
    DateTime? nextDate;
    bool notify = true;
    final common = VaccineRecord.commonVaccines(widget.cat.tipo);
    String? selectedCommon;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            left: 24, right: 24, top: 24),
          decoration: BoxDecoration(
            color: kSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
          child: SingleChildScrollView(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: kMuted.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              kTitle(L.lang == 'en' ? '💉 Add Vaccine' : '💉 Agregar Vacuna', size: 20),
              const SizedBox(height: 16),
              kLabel(L.lang == 'en' ? 'COMMON VACCINES' : 'VACUNAS COMUNES'),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8,
                children: common.map((v) => GestureDetector(
                  onTap: () { setS(() { selectedCommon = v; nameCtrl.text = v; }); },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: selectedCommon == v ? kTurquoise.withOpacity(0.15) : kBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selectedCommon == v ? kTurquoise : kBorder,
                        width: selectedCommon == v ? 1.5 : 1)),
                    child: Text(v, style: _nunito(12,
                      selectedCommon == v ? kTurquoise : kMuted,
                      weight: FontWeight.w700))),
                )).toList()),
              const SizedBox(height: 14),
              kLabel(L.lang == 'en' ? 'VACCINE NAME' : 'NOMBRE DE LA VACUNA'),
              const SizedBox(height: 8),
              kTextField(nameCtrl,
                L.lang == 'en' ? 'E.g.: Rabies, Triple Feline...' : 'Ej: Rabia, Triple Felina...',
                icon: Icons.vaccines_rounded, accent: kTurquoise),
              const SizedBox(height: 14),
              kLabel(L.lang == 'en' ? 'VETERINARIAN (OPTIONAL)' : 'VETERINARIO (OPCIONAL)'),
              const SizedBox(height: 8),
              kTextField(vetCtrl,
                L.lang == 'en' ? 'Vet name' : 'Nombre del veterinario',
                icon: Icons.person_rounded, accent: kTurquoise),
              const SizedBox(height: 14),
              kLabel(L.lang == 'en' ? 'APPLICATION DATE' : 'FECHA DE APLICACIÓN'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final d = await showDatePicker(
                    context: ctx, initialDate: appDate,
                    firstDate: DateTime(2010), lastDate: DateTime.now(),
                    builder: (_, child) => Theme(
                      data: ThemeData.light().copyWith(
                        colorScheme: const ColorScheme.light(primary: kTurquoise)),
                      child: child!));
                  if (d != null) setS(() => appDate = d);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: kBg, borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: kBorder)),
                  child: Row(children: [
                    const Icon(Icons.calendar_today_rounded, color: kTurquoise, size: 18),
                    const SizedBox(width: 10),
                    Text(DateFormat('dd/MM/yyyy').format(appDate), style: _nunito(14, kText)),
                  ]))),
              const SizedBox(height: 14),
              kLabel(L.lang == 'en' ? 'NEXT DOSE DATE (OPTIONAL)' : 'PRÓXIMA DOSIS (OPCIONAL)'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final d = await showDatePicker(
                    context: ctx,
                    initialDate: nextDate ?? DateTime.now().add(const Duration(days: 365)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 3650)),
                    builder: (_, child) => Theme(
                      data: ThemeData.light().copyWith(
                        colorScheme: const ColorScheme.light(primary: kCoral)),
                      child: child!));
                  if (d != null) setS(() => nextDate = d);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: kBg, borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: nextDate != null ? kCoral.withOpacity(0.4) : kBorder)),
                  child: Row(children: [
                    Icon(Icons.event_rounded,
                      color: nextDate != null ? kCoral : kMuted, size: 18),
                    const SizedBox(width: 10),
                    Text(
                      nextDate != null
                        ? DateFormat('dd/MM/yyyy').format(nextDate!)
                        : (L.lang == 'en' ? 'Tap to set date' : 'Toca para establecer'),
                      style: _nunito(14, nextDate != null ? kText : kMuted)),
                    if (nextDate != null) ...[
                      const Spacer(),
                      GestureDetector(
                        onTap: () => setS(() => nextDate = null),
                        child: const Icon(Icons.close_rounded, color: kMuted, size: 16)),
                    ],
                  ]))),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: kBg, borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kBorder)),
                child: Row(children: [
                  const Icon(Icons.notifications_rounded, color: kTurquoise, size: 18),
                  const SizedBox(width: 10),
                  Expanded(child: Text(
                    L.lang == 'en' ? 'Remind me before next dose' : 'Recordarme antes de la próxima dosis',
                    style: _nunito(13, kText))),
                  Switch(value: notify, onChanged: (v) => setS(() => notify = v),
                    activeColor: kTurquoise),
                ])),
              const SizedBox(height: 24),
              kGradBtn(
                L.lang == 'en' ? '💉 Save Vaccine' : '💉 Guardar Vacuna',
                () async {
                  if (nameCtrl.text.trim().isEmpty) return;
                  final vac = VaccineRecord(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    catId: widget.cat.id,
                    name: nameCtrl.text.trim(),
                    applicationDate: appDate,
                    nextDoseDate: nextDate,
                    veterinarian: vetCtrl.text.trim(),
                    lotNumber: lotCtrl.text.trim(),
                    notes: notesCtrl.text.trim(),
                    notifyBefore: notify,
                  );
                  widget.user.vaccines.add(vac);
                  await StorageService.saveVaccines(widget.user.vaccines);
                  await FirestoreService.saveVaccines(widget.user.vaccines);
                  if (notify && nextDate != null) {
                    await NotificationService.scheduleVaccine(vac);
                  }
                  widget.onRefresh();
                  if (mounted) { Navigator.pop(context); setState(() {}); }
                },
                colors: [kTurquoise, const Color(0xFF00CEC9)]),
            ])))));
  }

  void _deleteVaccine(VaccineRecord vac) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(L.get('delete_confirm'),
          style: _nunito(17, kText, weight: FontWeight.w800)),
        content: Text(
          L.lang == 'en' ? 'This vaccine record will be deleted.' : 'Se eliminará este registro de vacuna.',
          style: _nunito(13, kMuted)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
            child: Text(L.get('cancel_delete'), style: _nunito(13, kMuted))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: kCoral,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text(L.get('delete'),
              style: _nunito(13, Colors.white, weight: FontWeight.w700))),
        ]));
    if (ok == true) {
      await NotificationService.cancelVaccine(vac.id);
      await FirestoreService.deleteVaccine(vac.id);
      widget.user.vaccines.removeWhere((v) => v.id == vac.id);
      await StorageService.saveVaccines(widget.user.vaccines);
      widget.onRefresh();
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final vaccines = _catVaccines;
    final expired  = vaccines.where((v) => v.status == VaccineStatus.expired).length;
    final soon     = vaccines.where((v) => v.status == VaccineStatus.soon).length;
    final ok       = vaccines.where((v) => v.status == VaccineStatus.ok).length;

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Row(children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: kCardDeco(radius: 14),
                child: const Icon(Icons.arrow_back_ios_new, color: kTurquoise, size: 18))),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              kTitle(L.lang == 'en' ? '💉 Vaccine Record' : '💉 Carnet de Vacunas', size: 20),
              kBody(widget.cat.name, color: kMuted, size: 13),
            ])),
            AnimatedPressButton(
              onTap: _addVaccine,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [kTurquoise, Color(0xFF00CEC9)]),
                  borderRadius: BorderRadius.circular(14)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 6),
                  Text(L.lang == 'en' ? 'Add' : 'Agregar',
                    style: _nunito(13, Colors.white, weight: FontWeight.w800)),
                ]))),
          ])),
        if (vaccines.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: Row(children: [
              _statChip('✅', '$ok ${L.lang == 'en' ? 'ok' : 'al día'}', const Color(0xFF00B894)),
              const SizedBox(width: 8),
              _statChip('⚠️', '$soon ${L.lang == 'en' ? 'soon' : 'pronto'}', kYellow),
              const SizedBox(width: 8),
              _statChip('🚨', '$expired ${L.lang == 'en' ? 'expired' : 'vencidas'}', kCoral),
            ])),
        const SizedBox(height: 16),
        Expanded(
          child: vaccines.isEmpty
            ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('💉', style: TextStyle(fontSize: 52)),
                const SizedBox(height: 16),
                kBody(L.lang == 'en' ? 'No vaccines recorded yet' : 'Aún no hay vacunas registradas',
                  color: kMuted, size: 15),
                const SizedBox(height: 8),
                kBody(L.lang == 'en' ? 'Tap + Add to register the first one' : 'Toca + Agregar para registrar la primera',
                  color: kMuted.withOpacity(0.6), size: 13),
              ]))
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                itemCount: vaccines.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _vaccineCard(vaccines[i]))),
      ])));
  }

  Widget _statChip(String emoji, String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.3))),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Text(emoji, style: const TextStyle(fontSize: 13)),
      const SizedBox(width: 5),
      Text(label, style: _nunito(12, color, weight: FontWeight.w700)),
    ]));

  Widget _vaccineCard(VaccineRecord vac) {
    final color    = _statusColor(vac.status);
    final label    = _statusLabel(vac.status);
    final daysLeft = vac.nextDoseDate != null
      ? vac.nextDoseDate!.difference(DateTime.now()).inDays : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kSurface, borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.25)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04),
          blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
            child: const Center(child: Text('💉', style: TextStyle(fontSize: 20)))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(vac.name, style: _nunito(15, kText, weight: FontWeight.w800)),
            if (vac.veterinarian.isNotEmpty)
              kBody('Dr. ${vac.veterinarian}', color: kMuted, size: 12),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.4))),
            child: Text(label, style: _nunito(11, color, weight: FontWeight.w800))),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _deleteVaccine(vac),
            child: const Icon(Icons.delete_outline_rounded, color: kMuted, size: 19)),
        ]),
        const SizedBox(height: 10),
        Container(height: 1, color: kBorder),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: _dateInfo(Icons.check_circle_rounded,
            L.lang == 'en' ? 'Applied' : 'Aplicada',
            DateFormat('dd/MM/yyyy').format(vac.applicationDate),
            const Color(0xFF00B894))),
          if (vac.nextDoseDate != null)
            Expanded(child: _dateInfo(Icons.event_rounded,
              L.lang == 'en' ? 'Next dose' : 'Próxima dosis',
              DateFormat('dd/MM/yyyy').format(vac.nextDoseDate!), color)),
        ]),
        if (daysLeft != null) ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.07), borderRadius: BorderRadius.circular(10)),
            child: Text(
              daysLeft < 0
                ? (L.lang == 'en' ? '🚨 Expired ${daysLeft.abs()} days ago' : '🚨 Vencida hace ${daysLeft.abs()} días')
                : daysLeft == 0
                  ? (L.lang == 'en' ? '🚨 Expires today!' : '🚨 ¡Vence hoy!')
                  : (L.lang == 'en' ? '📅 $daysLeft days remaining' : '📅 $daysLeft días restantes'),
              style: _nunito(12, color, weight: FontWeight.w700))),
        ],
        if (vac.notes.isNotEmpty) ...[
          const SizedBox(height: 6),
          kBody(vac.notes, color: kMuted, size: 11),
        ],
      ]));
  }

  Widget _dateInfo(IconData icon, String label, String value, Color color) =>
    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: color, size: 14),
      const SizedBox(width: 5),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        kBody(label, color: kMuted, size: 10),
        Text(value, style: _nunito(12, kText, weight: FontWeight.w700)),
      ]),
    ]);
}

// ════════════════════════════════════════════════════════════════
//  SETTINGS TAB
// ════════════════════════════════════════════════════════════════

class SettingsTab extends StatefulWidget {
  final List<CameraDescription> cameras;
  const SettingsTab({Key? key, required this.cameras}) : super(key: key);
  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  final _ipCtrl = TextEditingController();
  bool _testing = false;
  String _status = '';

  @override
  void initState() {
    super.initState();
    StorageService.getServerIp().then((ip) => _ipCtrl.text = ip);
  }

  @override
  void dispose() { _ipCtrl.dispose(); super.dispose(); }

  Future<void> _testServer() async {
    setState(() { _testing = true; _status = ''; });
    try {
      final ip    = _ipCtrl.text.trim();
      final proto = ip.contains('onrender') || ip.contains('trycloudflare') ? 'https' : 'http';
      final port  = ip.contains('onrender') || ip.contains('trycloudflare') ? '' : ':8000';
      final r = await http.get(Uri.parse('$proto://$ip$port/health'))
          .timeout(const Duration(seconds: 8));
      await StorageService.setServerIp(ip);
      setState(() => _status = r.statusCode == 200 ? 'ok' : 'error');
    } catch (_) {
      setState(() => _status = 'error');
    } finally {
      setState(() => _testing = false);
    }
  }

  void _changePassword(BuildContext context) {
    final n = TextEditingController();
    final c = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(L.lang == 'es' ? 'Cambiar contrasena' : 'Change password',
        style: _nunito(16, kText, weight: FontWeight.w800)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: n, obscureText: true,
          decoration: InputDecoration(
            labelText: L.lang == 'es' ? 'Nueva contrasena' : 'New password',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
        const SizedBox(height: 12),
        TextField(controller: c, obscureText: true,
          decoration: InputDecoration(
            labelText: L.lang == 'es' ? 'Confirmar' : 'Confirm',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context),
          child: Text(L.lang == 'es' ? 'Cancelar' : 'Cancel')),
        TextButton(
          onPressed: () async {
            if (n.text.length < 6) { ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(L.lang == 'es' ? 'Minimo 6 caracteres' : 'Min 6 characters'))); return; }
            if (n.text != c.text) { ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(L.lang == 'es' ? 'No coinciden' : 'Do not match'))); return; }
            try {
              await FirebaseAuth.instance.currentUser?.updatePassword(n.text);
              if (context.mounted) { Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  backgroundColor: kGreen,
                  content: Text(L.lang == 'es' ? 'Contrasena actualizada' : 'Password updated'))); }
            } on FirebaseAuthException catch (e) {
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                backgroundColor: kCoral,
                content: Text(e.code == 'requires-recent-login'
                  ? (L.lang == 'es' ? 'Cierra sesion y vuelve a ingresar' : 'Sign out and sign in again')
                  : (e.message ?? 'Error'))));
            }
          },
          child: Text(L.lang == 'es' ? 'Guardar' : 'Save',
            style: _nunito(14, kPurple, weight: FontWeight.w800))),
      ]));
  }

  void _deleteAccount(BuildContext context) {
    showDialog(context: context, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(L.lang == 'es' ? 'Eliminar cuenta' : 'Delete account',
        style: _nunito(16, kCoral, weight: FontWeight.w800)),
      content: Text(
        L.lang == 'es'
          ? 'Se eliminaran todos tus datos. Esta accion no se puede deshacer.'
          : 'All your data will be deleted. This action cannot be undone.',
        style: _nunito(13, kText)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context),
          child: Text(L.lang == 'es' ? 'Cancelar' : 'Cancel')),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            await FirestoreService.deleteAccount();
            await StorageService.logout();
            if (context.mounted) Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => AuthScreen(cameras: const [])), (_) => false);
          },
          child: Text(L.lang == 'es' ? 'Eliminar' : 'Delete',
            style: _nunito(14, kCoral, weight: FontWeight.w800))),
      ]));
  }

  void _logout(BuildContext context) async {
    await StorageService.logout();
    await GoogleAuthService.signOut();
    if (context.mounted) Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => AuthScreen(cameras: widget.cameras)), (_) => false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: kBg,
    body: SafeArea(child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Header ──
        Padding(
          padding: const EdgeInsets.only(bottom: 28),
          child: Row(children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [kPurple, kTurquoise]),
                borderRadius: BorderRadius.circular(16)),
              child: const Center(child: Text('⚙️', style: TextStyle(fontSize: 24)))),
            const SizedBox(width: 14),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              kTitle(L.lang == 'es' ? 'Configuracion' : 'Settings', size: 22),
              kBody('MeowScanAI v$APP_VERSION', color: kMuted, size: 12),
            ]),
          ])),

        // ════ IDIOMA ════
        _secLabel(L.lang == 'es' ? '🌐  IDIOMA' : '🌐  LANGUAGE'),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: kCardDeco(),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            kBody('Español / English', color: kText),
            Row(children: [
              _langChip('ES'),
              const SizedBox(width: 8),
              _langChip('EN'),
            ]),
          ])),
        const SizedBox(height: 24),

        // ════ CUENTA ════
        _secLabel(L.lang == 'es' ? '👤  CUENTA' : '👤  ACCOUNT'),
        const SizedBox(height: 10),
        Container(
          decoration: kCardDeco(),
          child: Column(children: [
            _row(Icons.lock_outline_rounded, kPurple,
              L.lang == 'es' ? 'Cambiar contrasena' : 'Change password',
              () => _changePassword(context)),
            _divider(),
            _row(Icons.privacy_tip_outlined, kTurquoise,
              L.lang == 'es' ? 'Politica de privacidad' : 'Privacy policy',
              () async {
                final url = Uri.parse('https://sergiovilla03-ship-it.github.io/meowscan/');
                if (await canLaunchUrl(url)) launchUrl(url, mode: LaunchMode.externalApplication);
              }),
            _divider(),
            _row(Icons.delete_outline_rounded, kCoral,
              L.lang == 'es' ? 'Eliminar cuenta' : 'Delete account',
              () => _deleteAccount(context), danger: true),
          ])),
        const SizedBox(height: 24),

        // ════ INFO APP ════
        _secLabel(L.lang == 'es' ? '🐱  MEOWSCANAI' : '🐱  MEOWSCANAI'),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [kPurple.withOpacity(0.07), kTurquoise.withOpacity(0.04)],
              begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: kPurple.withOpacity(0.12))),
          child: Column(children: [
            Row(children: [
              const Text('🐱', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                kTitle('MeowScanAI', size: 16),
                kBody('Version $APP_VERSION  •  Candle Technology', color: kMuted, size: 11),
              ]),
            ]),
            const SizedBox(height: 14),
            Container(height: 1, color: kMuted.withOpacity(0.12)),
            const SizedBox(height: 12),
            _aiRow('🤖', 'AI', 'Groq llama-4-scout'),
            _aiRow('🎥', 'Video AI', 'Gemini 2.5 Flash'),
          ])),
        const SizedBox(height: 28),

        // ════ CERRAR SESION ════
        GestureDetector(
          onTap: () => _logout(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: kCoral.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kCoral.withOpacity(0.35))),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.logout_rounded, color: kCoral, size: 20),
              const SizedBox(width: 10),
              Text(L.lang == 'es' ? 'Cerrar sesion' : 'Sign out',
                style: _nunito(15, kCoral, weight: FontWeight.w800)),
            ]))),
      ]))));

  // ── helpers ──
  Widget _secLabel(String t) => Padding(
    padding: const EdgeInsets.only(left: 2),
    child: Text(t, style: _nunito(11, kMuted, weight: FontWeight.w800)
      .copyWith(letterSpacing: 1.1)));

  Widget _divider() => Divider(height: 1, indent: 56, color: kMuted.withOpacity(0.15));

  Widget _row(IconData icon, Color color, String label, VoidCallback onTap,
      {bool danger = false}) =>
    GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 19)),
          const SizedBox(width: 14),
          Expanded(child: Text(label,
            style: _nunito(14, danger ? kCoral : kText, weight: FontWeight.w600))),
          Icon(Icons.arrow_forward_ios_rounded,
            size: 13, color: kMuted.withOpacity(0.5)),
        ])));

  Widget _aiRow(String emoji, String label, String value) =>
    Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 15)),
        const SizedBox(width: 10),
        Expanded(child: kBody(label, color: kMuted, size: 12)),
        kBody(value, color: kText, size: 12),
      ]));

  Widget _langChip(String lang) {
    final active = L.lang == lang.toLowerCase();
    return GestureDetector(
      onTap: () { MeowScanApp.of(context)?.setLang(lang.toLowerCase()); setState(() {}); },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
        decoration: BoxDecoration(
          color: active ? kCoral : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? kCoral : kBorder)),
        child: Text(lang,
          style: _nunito(13, active ? Colors.white : kMuted, weight: FontWeight.w800))));
  }

  // ── Card de guía de notificaciones para celulares chinos ──
  Widget _notifGuideCard() {
    // Detectar marca por modelo del dispositivo
    // defaultValue vacío para no crashear si no está disponible
    final brand = 'vivo'; // tu teléfono es Vivo Y22

    final Map<String, Map<String, dynamic>> _brandData = {
      'vivo': {
        'emoji': '📱',
        'color': const Color(0xFF1565C0),
        'name': 'Vivo / iQOO (FuntouchOS)',
        'steps': L.lang == 'en'
          ? [
              'Open Settings → Apps → MeowScanAI',
              'Tap "Battery" → select "No restrictions"',
              'Go back → tap "Notifications" → enable ALL',
              'Settings → Battery → turn OFF "Auto-freeze apps"',
              'Add MeowScanAI to "Whitelisted apps" in Battery section',
            ]
          : [
              'Ajustes → Aplicaciones → MeowScanAI',
              'Toca "Batería" → selecciona "Sin restricciones"',
              'Vuelve → toca "Notificaciones" → actívalas TODAS',
              'Ajustes → Batería → desactiva "Congelar apps automáticamente"',
              'Añade MeowScanAI a "Apps en lista blanca" en Batería',
            ],
      },
      'xiaomi': {
        'emoji': '📱',
        'color': const Color(0xFFFF6900),
        'name': 'Xiaomi / Redmi / POCO (MIUI)',
        'steps': L.lang == 'en'
          ? [
              'Settings → Apps → MeowScanAI → Battery saver → No restrictions',
              'Security app → Permissions → Autostart → Enable MeowScanAI',
              'Settings → Notifications → MeowScanAI → Enable all',
              'Lock the app: swipe recent apps → lock MeowScanAI',
            ]
          : [
              'Ajustes → Aplicaciones → MeowScanAI → Ahorro batería → Sin restricciones',
              'App Seguridad → Permisos → Inicio automático → Activar MeowScanAI',
              'Ajustes → Notificaciones → MeowScanAI → Activar todo',
              'Bloquea la app: recientes → toca el candado sobre MeowScanAI',
            ],
      },
      'huawei': {
        'emoji': '📱',
        'color': const Color(0xFFE53935),
        'name': 'Huawei / Honor (EMUI / HarmonyOS)',
        'steps': L.lang == 'en'
          ? [
              'Phone Manager → App launch → MeowScanAI → Manual manage → Enable all 3',
              'Settings → Battery → App launch → MeowScanAI → disable smart management',
              'Settings → Notifications → MeowScanAI → enable all channels',
            ]
          : [
              'Gestor del teléfono → Inicio de apps → MeowScanAI → Gestión manual → Activa las 3 opciones',
              'Ajustes → Batería → Inicio de apps → MeowScanAI → desactiva gestión inteligente',
              'Ajustes → Notificaciones → MeowScanAI → activa todos los canales',
            ],
      },
      'oppo': {
        'emoji': '📱',
        'color': const Color(0xFF43A047),
        'name': 'OPPO / Realme / OnePlus (ColorOS)',
        'steps': L.lang == 'en'
          ? [
              'Settings → Apps → MeowScanAI → Battery → Don\'t optimize',
              'Phone Manager → Startup manager → enable MeowScanAI',
              'Settings → Notifications → MeowScanAI → enable all',
            ]
          : [
              'Ajustes → Aplicaciones → MeowScanAI → Batería → No optimizar',
              'Gestión del teléfono → Administrador de inicio → activar MeowScanAI',
              'Ajustes → Notificaciones → MeowScanAI → activar todo',
            ],
      },
      'samsung': {
        'emoji': '📱',
        'color': const Color(0xFF1565C0),
        'name': 'Samsung (One UI)',
        'steps': L.lang == 'en'
          ? [
              'Settings → Battery → Background usage limits → Never sleeping apps → add MeowScanAI',
              'Settings → Apps → MeowScanAI → Battery → Unrestricted',
              'Settings → Notifications → MeowScanAI → enable all',
            ]
          : [
              'Ajustes → Batería → Límites de uso en segundo plano → Apps que nunca duermen → añadir MeowScanAI',
              'Ajustes → Aplicaciones → MeowScanAI → Batería → Sin restricciones',
              'Ajustes → Notificaciones → MeowScanAI → activar todo',
            ],
      },
      'generic': {
        'emoji': '📱',
        'color': kPurple,
        'name': L.lang == 'en' ? 'Your phone' : 'Tu teléfono',
        'steps': L.lang == 'en'
          ? [
              'Settings → Apps → MeowScanAI → Battery → No restrictions',
              'Settings → Apps → MeowScanAI → Notifications → Enable all',
              'Settings → Battery → Find MeowScanAI → disable optimization',
            ]
          : [
              'Ajustes → Aplicaciones → MeowScanAI → Batería → Sin restricciones',
              'Ajustes → Aplicaciones → MeowScanAI → Notificaciones → Activar todo',
              'Ajustes → Batería → Busca MeowScanAI → desactiva optimización',
            ],
      },
    };

    final data = _brandData[brand] ?? _brandData['generic']!;
    final Color accentColor = data['color'] as Color;
    final String brandName  = data['name'] as String;
    final List<String> steps = List<String>.from(data['steps'] as List);

    return Container(
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accentColor.withOpacity(0.25)),
        boxShadow: [BoxShadow(
          color: accentColor.withOpacity(0.08),
          blurRadius: 12, offset: const Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Header de la card ──
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [accentColor.withOpacity(0.12), accentColor.withOpacity(0.04)],
              begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18))),
          child: Row(children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12)),
              child: Center(child: Icon(Icons.notifications_active_rounded,
                  color: accentColor, size: 22))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                L.lang == 'en'
                  ? 'Enable notifications'
                  : 'Activar notificaciones',
                style: _nunito(14, kText, weight: FontWeight.w800)),
              Text(brandName,
                style: _nunito(11, accentColor, weight: FontWeight.w700)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8)),
              child: Text(
                L.lang == 'en' ? 'REQUIRED' : 'NECESARIO',
                style: _nunito(9, accentColor, weight: FontWeight.w900)
                    .copyWith(letterSpacing: 0.8))),
          ])),

        // ── Pasos ──
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: steps.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: 22, height: 22,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.12),
                    shape: BoxShape.circle),
                  child: Center(child: Text('${e.key + 1}',
                    style: _nunito(10, accentColor, weight: FontWeight.w900)))),
                const SizedBox(width: 10),
                Expanded(child: Text(e.value,
                  style: _nunito(12, kText))),
              ]))).toList())),

        // ── Botón "Abrir ajustes" ──
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          child: AnimatedPressButton(
            onTap: () async {
              // Lleva directo a los ajustes de la app en el sistema
              final pkg = 'com.candletech.meowscan'; // package name de tu app
              final uri = Uri.parse('package:$pkg');
              try {
                await launchUrl(Uri.parse(
                  'android.settings.APPLICATION_DETAILS_SETTINGS?package=$pkg'),
                  mode: LaunchMode.externalApplication);
              } catch (_) {
                try {
                  await launchUrl(
                    Uri.parse('market://details?id=$pkg'),
                    mode: LaunchMode.externalApplication);
                } catch (_) {}
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accentColor, accentColor.withOpacity(0.75)]),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(
                  color: accentColor.withOpacity(0.3),
                  blurRadius: 8, offset: const Offset(0, 3))]),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.settings_rounded, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(
                  L.lang == 'en'
                    ? 'Open app settings'
                    : 'Abrir ajustes de la app',
                  style: _nunito(13, Colors.white, weight: FontWeight.w800)),
              ])))),

        // ── Nota del disclaimer ──
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          child: Row(children: [
            Icon(Icons.info_outline_rounded, size: 13, color: kMuted),
            const SizedBox(width: 6),
            Expanded(child: Text(
              L.lang == 'en'
                ? 'Without these steps, reminders may not arrive on Chinese-brand phones.'
                : 'Sin estos pasos, los recordatorios pueden no llegar en celulares de marca china.',
              style: _nunito(10, kMuted))),
          ])),
      ]),
    );
  }
}


// ════════════════════════════════════════════════════════════════
//  VOMITO SCAN SCREEN
// ════════════════════════════════════════════════════════════════

class VomitoScanScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  final String      serverIp;
  final CatProfile  cat;
  final UserAccount user;
  final VoidCallback onComplete;
  const VomitoScanScreen({Key? key, required this.cameras,
      required this.serverIp, required this.cat,
      required this.user, required this.onComplete}) : super(key: key);
  @override
  State<VomitoScanScreen> createState() => _VomitoScanScreenState();
}

class _VomitoScanScreenState extends State<VomitoScanScreen>
    with TickerProviderStateMixin {
  CameraController? _cam;
  Timer?  _scanTimer, _cdTimer;
  int     _secs     = 60;
  bool    _scanning = false, _sending = false;
  int     _frames   = 0;
  Map<String, dynamic>? _last;
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))..repeat();
    _initCam();
  }

  Future<void> _initCam() async {
    _cam = CameraController(widget.cameras.first,
        ResolutionPreset.medium, enableAudio: false);
    await _cam!.initialize();
    if (mounted) setState(() {});
  }

  void _start() {
    setState(() { _scanning = true; _secs = 60; _frames = 0; _last = null; });
    _scanTimer = Timer.periodic(const Duration(milliseconds: 2000), (_) => _capture());
    _cdTimer   = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => _secs--);
      if (_secs <= 0) _finish();
    });
  }

  Future<void> _capture() async {
    if (_cam == null || !_cam!.value.isInitialized || _sending) return;
    setState(() => _sending = true);
    try {
      final foto  = await _cam!.takePicture();
      final bytes = await foto.readAsBytes();
      final ip    = widget.serverIp;
      final proto = ip.contains("onrender") || ip.contains("trycloudflare") ? "https" : "http";
      final port  = ip.contains("onrender") || ip.contains("trycloudflare") ? "" : ":8000";
      final uri   = Uri.parse("$proto://$ip${port}/analizar_vomito");
      final req   = http.MultipartRequest("POST", uri)
        ..headers['X-API-Key'] = kApiKey
        ..fields['lang'] = L.lang
        ..files.add(http.MultipartFile.fromBytes("file", bytes, filename: "v.jpg"));
      final s   = await req.send().timeout(const Duration(seconds: 10));
      final res = await http.Response.fromStream(s);
      if (res.statusCode == 200 && mounted) {
        final data = json.decode(res.body);
        if (data["vomito_detectado"] == true)
          setState(() { _last = data; _frames++; });
      }
    } catch (_) {} finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  static String _normalizeTipo(String endpoint) {
    if (endpoint.contains('respiracion')) return 'respiracion';
    if (endpoint.contains('espasmo'))     return 'espasmos';
    if (endpoint.contains('encias'))      return 'encias';
    return endpoint;
  }

  void _finish() async {
    _scanTimer?.cancel(); _cdTimer?.cancel();
    setState(() => _scanning = false);
    if (_last != null) {
      final record = ScanRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        catId: widget.cat.id, date: DateTime.now(),
        resultado: {..._last!, 'tipo': 'vomito'});
      widget.user.scans.add(record);
      await StorageService.saveScans(widget.user.scans);
      await FirestoreService.saveEscaneos(widget.user.scans);
      widget.onComplete();
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => VomitoResultScreen(
          resultado: _last!, cat: widget.cat)));
    }
  }

  @override
  void dispose() {
    _scanTimer?.cancel(); _cdTimer?.cancel();
    _cam?.dispose(); _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [
        if (_cam != null && _cam!.value.isInitialized)
          SizedBox.expand(child: CameraPreview(_cam!)),
        SafeArea(child: Column(children: [
          _topBar(),
          const Spacer(),
          _overlay(),
          const SizedBox(height: 24),
          _controls(),
          const SizedBox(height: 48),
        ])),
      ]),
    );
  }

  Widget _topBar() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    decoration: BoxDecoration(gradient: LinearGradient(
      colors: [Colors.black87, Colors.transparent],
      begin: Alignment.topCenter, end: Alignment.bottomCenter)),
    child: Row(children: [
      GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
              color: Colors.white24, shape: BoxShape.circle),
          child: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 18))),
      const Spacer(),
      Text(L.lang == 'en' ? "🤮 Vomit Analysis" : "🤮 Análisis de Vómito",
        style: _nunito(15, Colors.white, weight: FontWeight.w800)),
      const Spacer(),
      if (_sending)
        const SizedBox(width: 28, height: 28,
            child: CircularProgressIndicator(color: kPurple, strokeWidth: 2.5))
      else
        const SizedBox(width: 28),
    ]),
  );

  Widget _overlay() {
    final prog = 1 - (_secs / 60);
    return Stack(alignment: Alignment.center, children: [
      SizedBox(width: 260, height: 260,
        child: CircularProgressIndicator(
          value: _scanning ? prog : 0,
          strokeWidth: 6,
          backgroundColor: Colors.white24,
          valueColor: const AlwaysStoppedAnimation<Color>(kPurple),
          strokeCap: StrokeCap.round,
        )),
      Container(
        width: 234, height: 234,
        decoration: BoxDecoration(
          color: Colors.black45, shape: BoxShape.circle,
          border: Border.all(color: Colors.white24)),
        child: Center(child: _scanning
          ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text("$_secs",
                style: _nunito(56, kPurple, weight: FontWeight.w900)),
              Text("seg", style: _nunito(13, Colors.white70)),
              const SizedBox(height: 6),
              Text("$_frames capturas",
                style: _nunito(11, Colors.white38)),
              if (_last != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: kPurple.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10)),
                  child: Text(_last!["color_identificado"] ?? "",
                    style: _nunito(11, kPurple))),
              ],
            ])
          : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text("🔬", style: TextStyle(fontSize: 56)),
              const SizedBox(height: 8),
              Text(L.get('point_vomit'),
                style: _nunito(14, Colors.white, weight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text("de ${widget.cat.name}",
                style: _nunito(12, Colors.white60)),
            ]),
        ),
      ),
    ]);
  }

  Widget _controls() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: _scanning
      ? [
          _btn(Icons.stop_rounded,        Colors.orange, _finish),
          const SizedBox(width: 20),
          _btn(Icons.fast_forward_rounded, kGreen,       _finish),
        ]
      : [_btn(Icons.play_arrow_rounded, kPurple, _start)],
  );

  Widget _btn(IconData icon, Color color, VoidCallback fn) =>
    GestureDetector(
      onTap: fn,
      child: Container(
        width: 68, height: 68,
        decoration: BoxDecoration(
          color: color, shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 16)]),
        child: Icon(icon, color: Colors.white, size: 30)));
}

// ════════════════════════════════════════════════════════════════
//  VOMITO RESULT SCREEN
// ════════════════════════════════════════════════════════════════

class VomitoResultScreen extends StatelessWidget {
  final Map<String, dynamic> resultado;
  final CatProfile cat;
  const VomitoResultScreen({Key? key, required this.resultado,
      required this.cat}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final urgencia      = resultado["urgencia"]           ?? "Media";
    final urgenciaColor = resultado["urgencia_color"]     ?? "#FF9800";
    final alerta        = resultado["alerta_veterinario"] ?? false;
    final color         = resultado["color_identificado"] ?? "-";
    final tipo          = resultado["tipo"]               ?? "-";
    final causas        = (resultado["causas_probables"]  as List?) ?? [];
    final enGatos       = resultado["en_gatos"]           ?? "-";
    final enPerros      = resultado["en_perros"]          ?? "-";
    final recomendacion = resultado["recomendacion"]      ?? "-";
    final signos        = resultado["signos_adicionales"] ?? "-";
    final mensajeUrg    = resultado["mensaje_urgencia"]   ?? "-";
    final imgB64        = resultado["imagen_anotada"]     as String?;

    Color urgColor;
    try { urgColor = Color(int.parse(urgenciaColor.replaceFirst("#", "0xFF"))); }
    catch (_) { urgColor = Colors.orange; }

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            // Top bar
            Row(children: [
              GestureDetector(
                onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: kCardDeco(radius: 14),
                  child: const Icon(Icons.home_rounded, color: kPurple, size: 22))),
              const SizedBox(width: 12),
              Expanded(child: kTitle("🔬 ${L.lang == 'en' ? 'Vomit Analysis' : 'Análisis de Vómito'}", size: 20)),
            ]),
            const SizedBox(height: 16),

            // Imagen
            if (imgB64 != null)
              Container(
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: urgColor.withOpacity(0.4), width: 2)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.memory(base64Decode(imgB64),
                    fit: BoxFit.cover, width: double.infinity,
                    errorBuilder: (_, __, ___) =>
                        const Center(child: Text("🔬", style: TextStyle(fontSize: 60)))))),

            const SizedBox(height: 16),

            // Alerta veterinario
            if (alerta == true)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF0000).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red, width: 2)),
                child: Row(children: [
                  const Text("🚨", style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(L.get('see_vet_now'),
                        style: _nunito(15, Colors.red, weight: FontWeight.w900)),
                      Text(mensajeUrg, style: _nunito(12, Colors.red.shade800)),
                    ])),
                ]),
              ),

            // Urgencia card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: kCardDeco(border: urgColor.withOpacity(0.4)),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  kTitle(L.lang == 'en' ? "Urgency level" : "Nivel de urgencia", size: 15),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: urgColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: urgColor)),
                    child: Text(urgencia,
                      style: _nunito(14, urgColor, weight: FontWeight.w900))),
                ]),
                const SizedBox(height: 12),
                _fila(L.lang == 'en' ? "🎨 Identified color" : "🎨 Color identificado", color, urgColor),
                _fila(L.lang == 'en' ? "🔬 Type" : "🔬 Tipo", tipo, urgColor),
              ]),
            ),

            const SizedBox(height: 12),

            // Causas
            _card(L.lang == 'en' ? "⚠️ Probable causes" : "⚠️ Causas probables", kCoral, Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: causas.map<Widget>((c) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("• ", style: _nunito(14, kCoral, weight: FontWeight.w800)),
                  Expanded(child: kBody(c.toString(), size: 13)),
                ]))).toList(),
            )),

            const SizedBox(height: 12),

            // En gatos y perros
            _card(L.lang == 'en' ? "🐱 In cats" : "🐱 En gatos", kTurquoise, kBody(enGatos, size: 13, color: kMuted)),
            const SizedBox(height: 12),
            _card(L.lang == 'en' ? "🐶 In dogs" : "🐶 En perros", kBlue, kBody(enPerros, size: 13, color: kMuted)),
            const SizedBox(height: 12),

            // Recomendación
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [kYellow.withOpacity(0.2), kCoral.withOpacity(0.1)]),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kYellow.withOpacity(0.5))),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text("💡", style: TextStyle(fontSize: 22)),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    kTitle(L.lang == 'en' ? "Recommendation" : "Recomendación", size: 14),
                    const SizedBox(height: 4),
                    kBody(recomendacion, size: 13),
                  ])),
              ]),
            ),

            const SizedBox(height: 12),
            _card(L.lang == 'en' ? "🔍 Additional signs" : "🔍 Signos adicionales", kPurple,
                kBody(signos, size: 13, color: kMuted)),

            const SizedBox(height: 24),
            kOutlineBtn(L.get('back_home'),
              () => Navigator.of(context).popUntil((r) => r.isFirst),
              color: kPurple),
            const SizedBox(height: 20),
          ]),
        ),
      ),
    );
  }

  Widget _fila(String l, String v, Color color) => Padding(
    padding: const EdgeInsets.only(top: 6),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      kBody(l, color: kMuted, size: 13),
      kBody(v, size: 13),
    ]));

  Widget _card(String titulo, Color accent, Widget child) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: kCardDeco(border: accent.withOpacity(0.2)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(titulo, style: _nunito(14, accent, weight: FontWeight.w800)),
      const SizedBox(height: 8),
      child,
    ]));
}


// ════════════════════════════════════════════════════════════════
//  WIDGET REUTILIZABLE: SCAN MEDICO
// ════════════════════════════════════════════════════════════════

class _MedicoScanBase extends StatefulWidget {
  final List<CameraDescription> cameras;
  final String      serverIp, endpoint, titulo, emoji, instruccion;
  final int         duracion;
  final CatProfile  cat;
  final UserAccount user;
  final VoidCallback onComplete;
  const _MedicoScanBase({Key? key, required this.cameras,
      required this.serverIp, required this.endpoint,
      required this.titulo, required this.emoji,
      required this.instruccion, required this.duracion,
      required this.cat, required this.user,
      required this.onComplete}) : super(key: key);
  @override
  State<_MedicoScanBase> createState() => _MedicoScanBaseState();
}

class _MedicoScanBaseState extends State<_MedicoScanBase> {
  CameraController? _cam;
  Timer?  _scanTimer, _cdTimer;
  int     _secs = 0;
  bool    _scanning = false, _sending = false;
  int     _frames = 0;
  Map<String, dynamic>? _last;

  @override
  void initState() {
    super.initState();
    _secs = widget.duracion;
    _initCam();
  }

  Future<void> _initCam() async {
    _cam = CameraController(widget.cameras.first,
        ResolutionPreset.medium, enableAudio: false);
    await _cam!.initialize();
    if (mounted) setState(() {});
  }

  void _start() {
    _startTime = DateTime.now().millisecondsSinceEpoch;
    setState(() { _scanning = true; _secs = widget.duracion; _frames = 0; _last = null; });
    _scanTimer = Timer.periodic(const Duration(milliseconds: 1500), (_) => _capture());
    _cdTimer   = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => _secs--);
      if (_secs <= 0) _finish();
    });
  }

  String get _sessionId => "${widget.cat.id}_${widget.endpoint}_${_startTime}";
  int _startTime = 0;

  Future<void> _capture({bool finalizar = false}) async {
    if (_cam == null || !_cam!.value.isInitialized || _sending) return;
    setState(() => _sending = true);
    try {
      final foto  = await _cam!.takePicture();
      final bytes = await foto.readAsBytes();
      final ip    = widget.serverIp;
      final proto = ip.contains("onrender") || ip.contains("trycloudflare") ? "https" : "http";
      final port  = ip.contains("onrender") || ip.contains("trycloudflare") ? "" : ":8000";
      // Use new session-based endpoints
      final endpointBase = widget.endpoint == "analizar_respiracion"
          ? "respiracion/frame"
          : "espasmos/frame";
      final uri = Uri.parse("$proto://$ip$port/$endpointBase"
          "?session_id=$_sessionId&finalizar=$finalizar");
      final req = http.MultipartRequest("POST", uri)
        ..headers['X-API-Key'] = kApiKey
        ..fields['lang'] = L.lang
        ..files.add(http.MultipartFile.fromBytes("file", bytes, filename: "f.jpg"));
      final s   = await req.send().timeout(const Duration(seconds: 15));
      final res = await http.Response.fromStream(s);
      if (res.statusCode == 200 && mounted) {
        final data = json.decode(res.body);
        // Frame parcial: actualizar preview
        if (!finalizar) {
          final rpm = data["rpm_parcial"];
          final niv = data["nivel"];
          if (rpm != null && niv != null && niv != "Calculando") {
            setState(() {
              _last = {
                "mascota_detectada": true,
                "nivel": niv,
                "respiraciones_por_minuto": rpm,
                "intensidad": data["intensidad"] ?? niv,
              };
              _frames++;
            });
          } else if (data["espasmo_detectado"] != null) {
            setState(() { _last = data; _frames++; });
          }
        } else {
          // Resultado final
          setState(() { _last = data; });
        }
      }
    } catch (_) {} finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  static String _normalizeTipo(String endpoint) {
    if (endpoint.contains('respiracion')) return 'respiracion';
    if (endpoint.contains('espasmo'))     return 'espasmos';
    if (endpoint.contains('encias'))      return 'encias';
    return endpoint;
  }

  void _finish() async {
    _scanTimer?.cancel(); _cdTimer?.cancel();
    setState(() { _scanning = false; _sending = true; });
    await _capture(finalizar: true);
    setState(() => _sending = false);
    if (_last != null && mounted) {
      final record = ScanRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        catId: widget.cat.id, date: DateTime.now(),
        resultado: {..._last!, 'tipo': _normalizeTipo(widget.endpoint)});
      widget.user.scans.add(record);
      await StorageService.saveScans(widget.user.scans);
      await FirestoreService.saveEscaneos(widget.user.scans);
      widget.onComplete();
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => MedicoResultScreen(
          resultado: _last!, titulo: widget.titulo,
          emoji: widget.emoji, cat: widget.cat)));
    }
  }

  @override
  void dispose() {
    _scanTimer?.cancel(); _cdTimer?.cancel();
    _cam?.dispose(); super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [
        if (_cam != null && _cam!.value.isInitialized)
          SizedBox.expand(child: CameraPreview(_cam!)),
        SafeArea(child: Column(children: [
          _topBar(),
          const Spacer(),
          _overlay(),
          const SizedBox(height: 24),
          _controls(),
          const SizedBox(height: 48),
        ])),
      ]),
    );
  }

  Widget _topBar() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    decoration: BoxDecoration(gradient: LinearGradient(
      colors: [Colors.black87, Colors.transparent],
      begin: Alignment.topCenter, end: Alignment.bottomCenter)),
    child: Row(children: [
      GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
          child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18))),
      const Spacer(),
      Text("${widget.emoji} ${widget.titulo}",
        style: _nunito(15, Colors.white, weight: FontWeight.w800)),
      const Spacer(),
      if (_sending)
        const SizedBox(width: 28, height: 28,
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
      else const SizedBox(width: 28),
    ]),
  );

  Widget _overlay() {
    final prog = 1 - (_secs / widget.duracion);
    return Stack(alignment: Alignment.center, children: [
      SizedBox(width: 260, height: 260,
        child: CircularProgressIndicator(
          value: _scanning ? prog : 0, strokeWidth: 6,
          backgroundColor: Colors.white24,
          valueColor: const AlwaysStoppedAnimation<Color>(kTurquoise),
          strokeCap: StrokeCap.round)),
      Container(
        width: 234, height: 234,
        decoration: BoxDecoration(color: Colors.black45, shape: BoxShape.circle,
          border: Border.all(color: Colors.white24)),
        child: Center(child: _scanning
          ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text("$_secs", style: _nunito(56, kTurquoise, weight: FontWeight.w900)),
              Text("seg", style: _nunito(13, Colors.white70)),
              const SizedBox(height: 6),
              Text("$_frames capturas", style: _nunito(11, Colors.white38)),
              if (_last != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: kTurquoise.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10)),
                  child: Text(_last!["nivel"] ?? _last!["intensidad"] ?? "...",
                    style: _nunito(11, kTurquoise))),
              ],
            ])
          : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(widget.emoji, style: const TextStyle(fontSize: 48)),
              const SizedBox(height: 8),
              Text(widget.instruccion,
                style: _nunito(13, Colors.white, weight: FontWeight.w800),
                textAlign: TextAlign.center),
            ]),
      )),
    ]);
  }

  Widget _controls() => Row(mainAxisAlignment: MainAxisAlignment.center,
    children: _scanning
      ? [
          _btn(Icons.stop_rounded, Colors.orange, _finish),
          const SizedBox(width: 20),
          _btn(Icons.fast_forward_rounded, kGreen, _finish),
        ]
      : [_btn(Icons.play_arrow_rounded, kTurquoise, _start)]);

  Widget _btn(IconData icon, Color color, VoidCallback fn) =>
    GestureDetector(onTap: fn,
      child: Container(width: 68, height: 68,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 16)]),
        child: Icon(icon, color: Colors.white, size: 30)));
}

// ════════════════════════════════════════════════════════════════
//  RESPIRACION SCAN
// ════════════════════════════════════════════════════════════════
// ════════════════════════════════════════════════════════════════
//  VIDEO SCAN BASE — Gemini 1.5 Flash
// ════════════════════════════════════════════════════════════════
class _VideoScanBase extends StatefulWidget {
  final List<CameraDescription> cameras;
  final String      serverIp, endpoint, titulo, emoji, instruccion;
  final int         duracion; // seconds
  final CatProfile  cat;
  final UserAccount user;
  final VoidCallback onComplete;
  const _VideoScanBase({Key? key,
      required this.cameras, required this.serverIp,
      required this.endpoint, required this.titulo,
      required this.emoji, required this.instruccion,
      required this.duracion, required this.cat,
      required this.user, required this.onComplete}) : super(key: key);
  @override State<_VideoScanBase> createState() => _VideoScanBaseState();
}

class _VideoScanBaseState extends State<_VideoScanBase> {
  CameraController? _cam;
  bool  _recording = false, _analyzing = false, _done = false;
  int   _secs = 0;
  Timer? _timer;
  Map<String, dynamic>? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    _secs = widget.duracion;
    _initCam();
  }

  Future<void> _initCam() async {
    _cam = CameraController(
      widget.cameras.first, ResolutionPreset.medium,
      enableAudio: false, imageFormatGroup: ImageFormatGroup.jpeg);
    await _cam!.initialize();
    if (mounted) setState(() {});
  }

  Future<void> _startRecording() async {
    if (_cam == null || !_cam!.value.isInitialized) return;
    await _cam!.startVideoRecording();
    setState(() { _recording = true; _secs = widget.duracion; });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => _secs--);
      if (_secs <= 0) _stopAndAnalyze();
    });
  }

  Future<void> _stopAndAnalyze() async {
    _timer?.cancel();
    if (!_recording) return;
    setState(() { _recording = false; _analyzing = true; });
    try {
      final videoFile = await _cam!.stopVideoRecording();
      final bytes     = await videoFile.readAsBytes();
      final ip        = widget.serverIp;
      final proto     = ip.contains("onrender") || ip.contains("trycloudflare") ? "https" : "http";
      final port      = ip.contains("onrender") || ip.contains("trycloudflare") ? "" : ":8000";
      final uri       = Uri.parse("$proto://$ip$port/${widget.endpoint}");
      final req       = http.MultipartRequest("POST", uri)
        ..headers['X-API-Key'] = kApiKey
        ..fields['lang'] = L.lang
        ..files.add(http.MultipartFile.fromBytes("file", bytes, filename: "video.mp4"));
      final s   = await req.send().timeout(const Duration(seconds: 60));
      final res = await http.Response.fromStream(s);
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        // Normalizar tipo segun endpoint
        String tipoNorm = widget.endpoint;
        if (tipoNorm.contains('respiracion')) tipoNorm = 'respiracion';
        else if (tipoNorm.contains('espasmo')) tipoNorm = 'espasmos';
        else if (tipoNorm.contains('encias'))  tipoNorm = 'encias';
        // Save to history CON tipo
        final scan = ScanRecord(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          catId: widget.cat.id,
          date: DateTime.now(),
          resultado: {...data, 'tipo': tipoNorm});
        widget.user.scans.add(scan);
        await StorageService.saveScans(widget.user.scans);
        await FirestoreService.saveEscaneos(widget.user.scans);
        setState(() { _result = data; _done = true; _analyzing = false; });
        widget.onComplete();
      } else {
        setState(() { _error = "Error ${res.statusCode}"; _analyzing = false; });
      }
    } catch (e) {
      setState(() { _error = e.toString(); _analyzing = false; });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cam?.dispose();
    super.dispose();
  }

  // ── Urgency color ──
  Color _urgencyColor(String? u) {
    switch (u) {
      case 'emergencia':      return kCoral;
      case 'veterinario_pronto': return kYellow;
      case 'observar':        return const Color(0xFF00B894);
      default:                return kGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(child: Column(children: [
        // ── Header ──
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(padding: const EdgeInsets.all(10),
                decoration: kCardDeco(radius: 14),
                child: const Icon(Icons.arrow_back_ios_new, color: kPurple, size: 18))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              kTitle("${widget.emoji} ${widget.titulo}", size: 18),
              kBody(widget.cat.name, color: kMuted, size: 12),
            ])),
          ])),

        Expanded(child: _done ? _buildResult() : _buildCamera()),
      ])),
    );
  }

  Widget _buildCamera() {
    if (_cam == null || !_cam!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator(color: kPurple));
    }
    if (_analyzing) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const CircularProgressIndicator(color: kPurple, strokeWidth: 3),
        const SizedBox(height: 20),
        kTitle(L.get('analyzing_video'), size: 16),
        const SizedBox(height: 8),
        kBody(L.get('video_few_secs'),
          color: kMuted),
      ]));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(children: [
        // Camera preview
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: AspectRatio(
            aspectRatio: _cam!.value.aspectRatio,
            child: CameraPreview(_cam!))),
        const SizedBox(height: 16),
        // Instruction
        Container(
          padding: const EdgeInsets.all(14),
          decoration: kCardDeco(),
          child: Row(children: [
            Text(widget.emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(child: kBody(widget.instruccion, color: kText)),
          ])),
        const SizedBox(height: 16),
        // Recording timer
        if (_recording) ...[
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(width: 10, height: 10,
              decoration: const BoxDecoration(color: kCoral, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            kTitle(L.lang == 'en' ? "Recording: ${_secs}s remaining" : "Grabando: ${_secs}s restantes",
              size: 14),
          ]),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 1 - (_secs / widget.duracion),
              minHeight: 8,
              backgroundColor: kMuted.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(kCoral))),
          const SizedBox(height: 16),
          // Stop button
          SizedBox(width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.stop_rounded, color: Colors.white),
              label: Text(L.lang == 'en' ? "Stop & Analyze" : "Detener y Analizar",
                style: _nunito(15, Colors.white, weight: FontWeight.w800)),
              style: ElevatedButton.styleFrom(
                backgroundColor: kCoral,
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              onPressed: _stopAndAnalyze)),
        ] else ...[
          // Start button
          SizedBox(width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.videocam_rounded, color: Colors.white),
              label: Text(
                L.lang == 'en'
                  ? "Record ${widget.duracion}s video"
                  : "Grabar video de ${widget.duracion}s",
                style: _nunito(15, Colors.white, weight: FontWeight.w800)),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPurple,
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              onPressed: _startRecording)),
        ],
        if (_error != null) ...[
          const SizedBox(height: 12),
          kBody("❌ $_error", color: kCoral),
        ],
      ]));
  }

  Widget _buildResult() {
    final r = _result!;
    final urgencia = r['urgencia'] as String? ?? 'normal';
    final urgColor = _urgencyColor(urgencia);
    final isResp   = widget.endpoint.contains('respiracion');
    final isEncias = widget.endpoint.contains('encias');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        // Urgency badge
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: urgColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: urgColor.withOpacity(0.3))),
          child: Column(children: [
            Text(widget.emoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 8),
            kTitle(r['conclusion'] ?? '', size: 15),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: urgColor, borderRadius: BorderRadius.circular(20)),
              child: Text(
                urgencia.toUpperCase().replaceAll('_', ' '),
                style: _nunito(11, Colors.white, weight: FontWeight.w800))),
          ])),
        const SizedBox(height: 16),

        // Details
        if (isResp) ...[
          _resultCard("🫁", L.lang == 'en' ? "Breathing rate" : "Frecuencia respiratoria",
            "${r['respiraciones_por_minuto'] ?? '--'} rpm - ${r['frecuencia_respiratoria'] ?? ''}"),
          _resultCard("📊", L.lang == 'en' ? "Pattern" : "Patrón", r['patron'] ?? ''),
        ] else if (isEncias) ...[
          _resultCard("🦷", L.lang == 'en' ? "Gum color" : "Color de encías",
            r['color_encias'] ?? '-'),
          _resultCard("💧", L.lang == 'en' ? "Hydration" : "Hidratación",
            r['hidratacion'] ?? '-'),
          _resultCard("🔍", L.lang == 'en' ? "Capillary refill" : "Relleno capilar",
            r['relleno_capilar'] ?? '-'),
        ] else ...[
          _resultCard("🔍", L.lang == 'en' ? "Spasms detected" : "Espasmos detectados",
            ((r['espasmos_detectados'] == true ? (L.lang == 'en' ? "Yes" : "Sí") : "No") + " - " + (r['tipo'] ?? '') + " - " + (r['intensidad'] ?? ''))),
          _resultCard("📍", L.lang == 'en' ? "Affected area" : "Zona afectada",
            r['zona_afectada'] ?? ''),
        ],

        // Alarm signs / possible causes
        if ((r['signos_alarma'] as List?)?.isNotEmpty == true ||
            (r['posibles_causas'] as List?)?.isNotEmpty == true) ...[
          _resultCard(
            "⚠️",
            isResp
              ? (L.lang == 'en' ? "Warning signs" : "Signos de alarma")
              : (L.lang == 'en' ? "Possible causes" : "Posibles causas"),
            (isResp
              ? (r['signos_alarma'] as List? ?? [])
              : (r['posibles_causas'] as List? ?? []))
              .map((e) => "• $e").join("\n")),
        ],

        _resultCard("💡", L.lang == 'en' ? "Recommendation" : "Recomendación",
          r['recomendacion'] ?? ''),

        const SizedBox(height: 8),
        // Redo button
        SizedBox(width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.videocam_rounded, color: kPurple),
            label: Text(L.lang == 'en' ? "Record again" : "Grabar de nuevo",
              style: _nunito(14, kPurple, weight: FontWeight.w700)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: kPurple),
              padding: const EdgeInsets.all(14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            onPressed: () => setState(() { _done = false; _result = null; _secs = widget.duracion; }))),
        const SizedBox(height: 20),
      ]));
  }

  Widget _resultCard(String emoji, String title, String body) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: kCardDeco(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          kTitle(title, size: 13),
        ]),
        const SizedBox(height: 6),
        kBody(body, color: kText, size: 13),
      ])));
}

// ════════════════════════════════════════════════════════════════
//  RESPIRACION SCAN — Video con Gemini
// ════════════════════════════════════════════════════════════════
class RespiracionScanScreen extends StatelessWidget {
  final List<CameraDescription> cameras;
  final String serverIp; final CatProfile cat;
  final UserAccount user; final VoidCallback onComplete;
  const RespiracionScanScreen({Key? key, required this.cameras,
      required this.serverIp, required this.cat,
      required this.user, required this.onComplete}) : super(key: key);
  @override
  Widget build(BuildContext context) => _VideoScanBase(
    cameras: cameras, serverIp: serverIp,
    endpoint: "analizar_video_respiracion",
    titulo: L.get('scan_resp_title'), emoji: "🫁",
    instruccion: L.lang == 'en'
      ? "Point the camera at ${cat.name}\'s chest area so breathing is visible"
      : "Apunta la cámara al pecho de ${cat.name} para que se vea la respiración",
    duracion: 30, cat: cat, user: user, onComplete: onComplete);
}

// ════════════════════════════════════════════════════════════════
//  ESPASMOS SCAN
// ════════════════════════════════════════════════════════════════

// ════════════════════════════════════════════════════════════════
//  ESPASMOS SCAN — Video con Gemini
// ════════════════════════════════════════════════════════════════
class EspasmosScanScreen extends StatelessWidget {
  final List<CameraDescription> cameras;
  final String serverIp; final CatProfile cat;
  final UserAccount user; final VoidCallback onComplete;
  const EspasmosScanScreen({Key? key, required this.cameras,
      required this.serverIp, required this.cat,
      required this.user, required this.onComplete}) : super(key: key);
  @override
  Widget build(BuildContext context) => _VideoScanBase(
    cameras: cameras, serverIp: serverIp,
    endpoint: "analizar_video_espasmos",
    titulo: L.get('scan_spasm_title'), emoji: "🐾",
    instruccion: L.lang == 'en'
      ? "Record ${cat.name} so any spasms or tremors are visible"
      : "Graba a ${cat.name} para que se vean los espasmos o temblores",
    duracion: 30, cat: cat, user: user, onComplete: onComplete);
}

// ════════════════════════════════════════════════════════════════
//  RESULTADO MEDICO GENERICO
// ════════════════════════════════════════════════════════════════
class MedicoResultScreen extends StatelessWidget {
  final Map<String, dynamic> resultado;
  final String titulo, emoji;
  final CatProfile cat;
  const MedicoResultScreen({Key? key, required this.resultado,
      required this.titulo, required this.emoji,
      required this.cat}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final nivel      = resultado["nivel"] ?? resultado["intensidad"] ?? "Normal";
    final color      = resultado["nivel_color"] ?? resultado["intensidad_color"] ?? "#52C97A";
    final alerta     = resultado["alerta_veterinario"] ?? false;
    final imgB64     = resultado["imagen_anotada"] as String?;
    final causas     = (resultado["posibles_causas"] as List?) ?? [];
    final recom      = resultado["recomendacion"] ?? "-";
    final msgUrg     = resultado["mensaje_urgencia"];
    final obs        = resultado["observaciones"] ?? resultado["patron"] ?? "-";

    Color accentColor;
    try { accentColor = Color(int.parse(color.replaceFirst("#","0xFF"))); }
    catch (_) { accentColor = kGreen; }

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            // Top bar
            Row(children: [
              GestureDetector(
                onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
                child: Container(padding: const EdgeInsets.all(10),
                  decoration: kCardDeco(radius: 14),
                  child: const Icon(Icons.home_rounded, color: kPurple, size: 22))),
              const SizedBox(width: 12),
              Expanded(child: kTitle("$emoji $titulo", size: 18)),
            ]),
            const SizedBox(height: 16),

            // Imagen
            if (imgB64 != null)
              Container(height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: accentColor.withOpacity(0.4), width: 2)),
                child: ClipRRect(borderRadius: BorderRadius.circular(18),
                  child: Image.memory(base64Decode(imgB64),
                    fit: BoxFit.cover, width: double.infinity,
                    errorBuilder: (_, __, ___) =>
                      Center(child: Text(emoji, style: const TextStyle(fontSize: 60)))))),

            const SizedBox(height: 16),

            // Disclaimer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: kYellow.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: kYellow.withOpacity(0.4))),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text("⚠️", style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(child: Text(
                  L.get('disclaimer_short'),
                  style: _nunito(11, kMuted))),
              ]),
            ),

            // Alerta veterinario
            if (alerta == true && msgUrg != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red, width: 2)),
                child: Row(children: [
                  const Text("🚨", style: TextStyle(fontSize: 26)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(L.get('vet_alert'),
                        style: _nunito(14, Colors.red, weight: FontWeight.w900)),
                      Text(msgUrg, style: _nunito(12, Colors.red.shade800)),
                    ])),
                ]),
              ),

            // Resultado principal
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: kCardDeco(border: accentColor.withOpacity(0.3)),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  kTitle(L.get('result'), size: 15),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: accentColor)),
                    child: Text(nivel,
                      style: _nunito(14, accentColor, weight: FontWeight.w900))),
                ]),
                if (resultado["respiraciones_por_minuto"] != null) ...[
                  const SizedBox(height: 12),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text("${resultado["respiraciones_por_minuto"]}",
                      style: _nunito(48, accentColor, weight: FontWeight.w900)),
                    const SizedBox(width: 8),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      kBody("resp/min", size: 14),
                      kBody(resultado["patron"] ?? "", color: kMuted, size: 12),
                    ]),
                  ]),
                ],
                if (resultado["zona_afectada"] != null) ...[
                  const SizedBox(height: 8),
                  _fila(L.lang == 'en' ? "📍 Area" : "📍 Zona", resultado["zona_afectada"]!, accentColor),
                ],
                const SizedBox(height: 8),
                _fila("🔍 ${L.get('observations')}", obs, accentColor),
                if (resultado["metodo"] != null) ...[
                  const SizedBox(height: 6),
                  _fila("⚙️ ${L.get('method')}", resultado["metodo"]!, accentColor),
                ],
                if (resultado["total_frames"] != null) ...[
                  const SizedBox(height: 6),
                  _fila(L.lang == 'en' ? "📸 Frames" : "📸 Fotogramas", "${resultado["total_frames"]} ${L.get('frames_analyzed')}", accentColor),
                ],
              ]),
            ),

            if (causas.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: kCardDeco(border: kCoral.withOpacity(0.2)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("⚠️ ${L.get('possible_causes')}",
                    style: _nunito(14, kCoral, weight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  ...causas.map((causa) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text("• ", style: _nunito(14, kCoral, weight: FontWeight.w800)),
                      Expanded(child: kBody(causa.toString(), size: 13)),
                    ]))),
                ]),
              ),
            ],

            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [kYellow.withOpacity(0.15), kCoral.withOpacity(0.08)]),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kYellow.withOpacity(0.4))),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text("💡", style: TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    kTitle(L.get('recommendation'), size: 13),
                    const SizedBox(height: 4),
                    kBody(recom, size: 13),
                  ])),
              ]),
            ),

            const SizedBox(height: 16),

            // Botón clínicas cercanas
            GestureDetector(
              onTap: () async {
                final mapsApp = Uri.parse("geo:0,0?q=veterinario+cerca");
            final mapsBrowser = Uri.parse("https://www.google.com/maps/search/veterinario+cerca+de+mi+ubicacion");
            if (await canLaunchUrl(mapsApp)) {
              await launchUrl(mapsApp, mode: LaunchMode.externalApplication);
            } else if (await canLaunchUrl(mapsBrowser)) {
              await launchUrl(mapsBrowser, mode: LaunchMode.externalApplication);
            }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kCoral.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kCoral.withOpacity(0.3))),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.local_hospital_rounded, color: kCoral, size: 22),
                  const SizedBox(width: 10),
                  Text(L.get('vet_clinics'),
                    style: _nunito(14, kCoral, weight: FontWeight.w700)),
                ]),
              ),
            ),

            const SizedBox(height: 12),
            kOutlineBtn(L.get('back_home'),
              () => Navigator.of(context).popUntil((r) => r.isFirst),
              color: kPurple),
            const SizedBox(height: 20),
          ]),
        ),
      ),
    );
  }

  Widget _fila(String l, String v, Color color) => Padding(
    padding: const EdgeInsets.only(top: 6),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        kBody(l, color: kMuted, size: 12),
        const SizedBox(width: 8),
        Expanded(child: kBody(v, size: 12, align: TextAlign.right)),
      ]));
}

// ════════════════════════════════════════════════════════════════
//  HISTORIA MEDICA SCREEN
// ════════════════════════════════════════════════════════════════
class HistoriaMedicaScreen extends StatefulWidget {
  final CatProfile cat;
  final UserAccount user;
  final String serverIp;
  const HistoriaMedicaScreen({Key? key, required this.cat,
      required this.user, required this.serverIp}) : super(key: key);
  @override
  State<HistoriaMedicaScreen> createState() => _HistoriaMedicaScreenState();
}

class _HistoriaMedicaScreenState extends State<HistoriaMedicaScreen> {
  bool _loading = true;
  Map<String, dynamic>? _historia;
  String? _error;

  @override
  void initState() { super.initState(); _cargar(); }

  Future<void> _cargar() async {
    setState(() { _loading = true; _error = null; });
    try {
      // Siempre recargar desde Firestore para tener datos frescos
      final todosLosScans = await FirestoreService.loadEscaneos();
      widget.user.scans
        ..clear()
        ..addAll(todosLosScans);

      final scansGato = widget.user.scans
          .where((s) => s.catId == widget.cat.id)
          .toList();

      // Debug: print all scan tipos
      debugPrint('MEOW_DEBUG total=' + scansGato.length.toString());
      for (final s in scansGato) {
        final t = (s.resultado['tipo'] ?? 'null').toString();
        debugPrint('MEOW_SCAN tipo=' + t + ' catId=' + s.catId);
      }

      // Solo 5 tipos especializados, 2 de cada uno
      final tipos = ['vomito', 'encias', 'maullido', 'respiracion', 'espasmos'];
      final Map<String, int> conteo = {};
      for (final t in tipos) {
        conteo[t] = scansGato.where((s) {
          final tipo = (s.resultado['tipo'] ?? '').toString().toLowerCase();
          return tipo == t || tipo.contains(t);
        }).length;
      }
      debugPrint('MEOW_CONTEO ' + conteo.toString());
      final faltanTipos = tipos.where((t) => (conteo[t] ?? 0) < 2).toList();
      if (faltanTipos.isNotEmpty) {
        final partes = conteo.entries.map((e) => e.key + ':' + e.value.toString()).join(',');
        setState(() { _loading = false;
          _error = 'historia_insuficiente:' + partes; });
        return;
      }

      // Send ALL scan types with dates for complete clinical picture
      final escaneos = scansGato.map((s) => {
        'tipo': s.resultado['tipo'] ?? 'general',
        'fecha': s.date.toIso8601String(),
        'datos': s.resultado,
      }).toList();
      final ip    = widget.serverIp;
      final proto = ip.contains("onrender") || ip.contains("trycloudflare") ? "https" : "http";
      final port  = ip.contains("onrender") || ip.contains("trycloudflare") ? "" : ":8000";
      final uri   = Uri.parse("$proto://$ip${port}/historia_medica");
      final res   = await http.post(uri,
        headers: {"Content-Type": "application/json", "X-API-Key": kApiKey},
        body: json.encode({"historial": escaneos}));
      if (res.statusCode == 200) {
        setState(() { _historia = json.decode(res.body); _loading = false; });
      } else {
        setState(() { _loading = false; _error = L.lang == 'en' ? "Could not generate medical history" : "Error al generar historia médica"; });
      }
    } catch (e) {
      setState(() { _loading = false; _error = L.lang == 'en' ? "Connection error: $e" : "Error de conexión: $e"; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(padding: const EdgeInsets.all(10),
                  decoration: kCardDeco(radius: 14),
                  child: const Icon(Icons.arrow_back_ios_new, color: kPurple, size: 18))),
              const SizedBox(width: 12),
              Expanded(child: kTitle("📋 ${L.get('medical_history')}", size: 20)),
              GestureDetector(
                onTap: _cargar,
                child: Container(padding: const EdgeInsets.all(10),
                  decoration: kCardDeco(radius: 14),
                  child: const Icon(Icons.refresh_rounded, color: kTurquoise, size: 20))),
            ]),
          ),
          Expanded(child: _loading
            ? Center(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: kPurple),
                  const SizedBox(height: 16),
                  Text(L.get('analyzing_ia')),
                ]))
            : _error != null
              ? _buildErrorOrInsuficiente(_error!)
              : _buildHistoria()),
        ]),
      ),
    );
  }

  Widget _buildErrorOrInsuficiente(String error) {
    if (error.startsWith('historia_insuficiente:')) {
      // Parse conteo: "general:1,vomito:0,encias:2,maullido:1,respiracion:0,espasmos:2"
      final payload = error.substring('historia_insuficiente:'.length);
      final Map<String, int> conteo = {};
      for (final part in payload.split(',')) {
        final kv = part.split(':');
        if (kv.length == 2) conteo[kv[0]] = int.tryParse(kv[1]) ?? 0;
      }
      final tipos = ['vomito', 'encias', 'maullido', 'respiracion', 'espasmos'];
      final emojis = {'general':'🔍','vomito':'🤮','encias':'👅','maullido':'😿','respiracion':'🫁','espasmos':'🐾'};
      final nombres_es = {'general':'General','vomito':'Vómito','encias':'Encías','maullido':'Maullido','respiracion':'Respiración','espasmos':'Espasmos'};
      final nombres_en = {'general':'General','vomito':'Vomit','encias':'Gums','maullido':'Meow','respiracion':'Breathing','espasmos':'Spasms'};
      final actual  = conteo.values.fold(0, (a, b) => a + b);
      final total   = 10; // 2 x 5 types
      final pct     = (actual / total).clamp(0.0, 1.0);
      final completados = tipos.where((t) => (conteo[t] ?? 0) >= 2).length; // out of 5

      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
        child: Column(children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [kPurple.withOpacity(0.08), kCoral.withOpacity(0.05)],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(28)),
            child: Column(children: [
              Stack(alignment: Alignment.center, children: [
                Container(width: 120, height: 120,
                  decoration: BoxDecoration(shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [kPurple.withOpacity(0.15), kCoral.withOpacity(0.10)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight))),
                Container(width: 96, height: 96,
                  decoration: BoxDecoration(shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [kPurple, Color(0xFFA855F7)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight),
                    boxShadow: [BoxShadow(color: kPurple.withOpacity(0.4),
                      blurRadius: 20, offset: const Offset(0, 8))]),
                  child: const Center(child: Text("🩺", style: TextStyle(fontSize: 46)))),
              ]),
              const SizedBox(height: 20),
              Text(L.lang == 'en' ? "Medical History" : "Historia Médica",
                style: _nunito(22, kPurple, weight: FontWeight.w900)),
              const SizedBox(height: 6),
              Text(
                L.lang == 'en'
                  ? "Dr. MeowScan needs 2 scans of each type"
                  : "El Dr. MeowScan necesita 2 escaneos de cada tipo",
                style: _nunito(13, kMuted), textAlign: TextAlign.center),
            ])),

          const SizedBox(height: 24),

          // Overall progress
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: kCardDeco(border: kPurple.withOpacity(0.2)),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(L.lang == 'en' ? "Overall progress" : "Progreso general",
                  style: _nunito(14, kText, weight: FontWeight.w700)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [kPurple, Color(0xFFA855F7)]),
                    borderRadius: BorderRadius.circular(20)),
                  child: Text("$completados / 5 ${L.lang == 'en' ? 'types' : 'tipos'}",
                    style: _nunito(13, Colors.white, weight: FontWeight.w900))),
              ]),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: LinearProgressIndicator(
                  value: completados / 5,
                  minHeight: 14,
                  backgroundColor: kPurple.withOpacity(0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(kPurple))),
            ])),

          const SizedBox(height: 16),

          // Per-type progress grid
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: kCardDeco(border: kTurquoise.withOpacity(0.2)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(L.lang == 'en' ? "📊 Progress by scan type" : "📊 Progreso por tipo de escaneo",
                style: _nunito(14, kTurquoise, weight: FontWeight.w800)),
              const SizedBox(height: 16),
              ...tipos.map((t) {
                final cnt = conteo[t] ?? 0;
                final done = cnt >= 2;
                final emoji = emojis[t]!;
                final nombre = L.lang == 'en' ? nombres_en[t]! : nombres_es[t]!;
                final color = done ? kGreen : (cnt == 1 ? kYellow : kCoral);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(children: [
                    Text(emoji, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text(nombre, style: _nunito(13, kText, weight: FontWeight.w700)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: color.withOpacity(0.4))),
                          child: Text(
                            done ? (L.lang == 'en' ? "✓ Done" : "✓ Listo") : "$cnt / 2",
                            style: _nunito(11, color, weight: FontWeight.w800))),
                      ]),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: (cnt / 2).clamp(0.0, 1.0),
                          minHeight: 8,
                          backgroundColor: color.withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(color))),
                    ])),
                  ]));
              }).toList(),
            ])),

          const SizedBox(height: 20),
        ]));
    }
    // Generic error
    return Center(child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text("⚠️", style: TextStyle(fontSize: 56)),
        const SizedBox(height: 16),
        Text(L.lang == 'en' ? "Could not load medical history" : "Error al cargar historia médica",
          textAlign: TextAlign.center, style: _nunito(15, kMuted)),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: _cargar,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [kPurple, Color(0xFFA855F7)]),
              borderRadius: BorderRadius.circular(16)),
            child: Text(L.lang == 'en' ? "Try again" : "Reintentar",
              style: _nunito(14, Colors.white, weight: FontWeight.w800)))),
      ])));
  }

  Widget _scanTypeBadge(String emoji, String label, Color color) =>
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.35))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 4),
        Text(label, style: _nunito(11, color, weight: FontWeight.w700)),
      ]));

  Widget _buildHistoria() {
    final h         = _historia!;
    final score     = h["score_salud"] ?? 0;
    final tendencia = h["tendencia"] ?? "Estable";
    final tColor    = h["tendencia_color"] ?? "#52C97A";
    final resumen   = h["resumen"] ?? "";
    final alertas   = (h["alertas_activas"] as List?) ?? [];
    final prediccs  = (h["predicciones"] as List?) ?? [];
    final recomends = (h["recomendaciones"] as List?) ?? [];
    final proxima   = h["proxima_revision"] ?? "";

    Color tColorObj;
    try { tColorObj = Color(int.parse(tColor.replaceFirst("#","0xFF"))); }
    catch (_) { tColorObj = kGreen; }

    Color scoreColor = score >= 80 ? kGreen : score >= 60 ? Colors.orange : kCoral;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: Column(children: [
        // Disclaimer
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: kYellow.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kYellow.withOpacity(0.4))),
          child: Text(
            L.get('disclaimer_short'),
            style: _nunito(11, kMuted), textAlign: TextAlign.center)),

        // Score
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: kCardDeco(border: scoreColor.withOpacity(0.3)),
          child: Column(children: [
            kTitle("🐾 ${widget.cat.name}", size: 18),
            const SizedBox(height: 16),
            Stack(alignment: Alignment.center, children: [
              SizedBox(width: 120, height: 120,
                child: CircularProgressIndicator(
                  value: score / 100, strokeWidth: 10,
                  backgroundColor: kBorder,
                  valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                  strokeCap: StrokeCap.round)),
              Column(children: [
                Text("$score", style: _nunito(36, scoreColor, weight: FontWeight.w900)),
                Text("/ 100", style: _nunito(12, kMuted)),
              ]),
            ]),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: tColorObj.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: tColorObj)),
              child: Text(tendencia,
                style: _nunito(13, tColorObj, weight: FontWeight.w800))),
            const SizedBox(height: 12),
            kBody(resumen, color: kMuted, size: 13, align: TextAlign.center),
          ]),
        ),

        if (alertas.isNotEmpty) ...[
          const SizedBox(height: 16),
          _seccion("🚨 ${L.get('active_alerts')}", kCoral, Column(
            children: alertas.map<Widget>((a) {
              final urgColor = a["urgencia"] == "Alta" ? kCoral
                  : a["urgencia"] == "Media" ? Colors.orange : kGreen;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: urgColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: urgColor.withOpacity(0.3))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(a["tipo"] ?? "",
                      style: _nunito(13, urgColor, weight: FontWeight.w800))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: urgColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10)),
                      child: Text(a["urgencia"] ?? "",
                        style: _nunito(10, urgColor, weight: FontWeight.w700))),
                  ]),
                  const SizedBox(height: 4),
                  kBody(a["descripcion"] ?? "", size: 12, color: kMuted),
                  const SizedBox(height: 4),
                  kBody("💡 ${a["recomendacion"] ?? ""}", size: 12),
                ]),
              );
            }).toList())),
        ],

        if (prediccs.isNotEmpty) ...[
          const SizedBox(height: 16),
          _seccion("🔮 ${L.get('predictions')}", kPurple, Column(
            children: prediccs.map<Widget>((p) {
              final probColor = p["probabilidad"] == "Alta" ? kCoral
                  : p["probabilidad"] == "Media" ? Colors.orange : kGreen;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kPurple.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kPurple.withOpacity(0.2))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(p["condicion"] ?? "",
                      style: _nunito(13, kPurple, weight: FontWeight.w800))),
                    Text(p["probabilidad"] ?? "",
                      style: _nunito(11, probColor, weight: FontWeight.w700)),
                  ]),
                  const SizedBox(height: 4),
                  kBody("📅 ${p["plazo"] ?? ""}", size: 12, color: kMuted),
                  kBody("🛡️ ${p["prevencion"] ?? ""}", size: 12),
                ]),
              );
            }).toList())),
        ],

        if (recomends.isNotEmpty) ...[
          const SizedBox(height: 16),
          _seccion("💡 ${L.get('recommendations')}", kTurquoise, Column(
            children: recomends.asMap().entries.map<Widget>((e) =>
              Padding(padding: const EdgeInsets.only(bottom: 6),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("${e.key + 1}. ",
                    style: _nunito(13, kTurquoise, weight: FontWeight.w800)),
                  Expanded(child: kBody(e.value.toString(), size: 13)),
                ]))).toList())),
        ],

        if (proxima.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity, padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kGreen.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kGreen.withOpacity(0.3))),
            child: Row(children: [
              const Text("📅", style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  kTitle(L.get('next_revision'), size: 13),
                  const SizedBox(height: 2),
                  kBody(proxima, size: 13),
                ])),
            ])),
        ],

        const SizedBox(height: 16),
        GestureDetector(
          onTap: () async {
            // Try Google Maps app first, fallback to browser
            final mapsApp = Uri.parse(
                "geo:0,0?q=veterinario+cerca");
            final mapsBrowser = Uri.parse(
                "https://www.google.com/maps/search/veterinario+cerca+de+mi+ubicacion");
            if (await canLaunchUrl(mapsApp)) {
              await launchUrl(mapsApp, mode: LaunchMode.externalApplication);
            } else if (await canLaunchUrl(mapsBrowser)) {
              await launchUrl(mapsBrowser, mode: LaunchMode.externalApplication);
            }
          },
          child: Container(
            width: double.infinity, padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kCoral.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kCoral.withOpacity(0.3))),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.local_hospital_rounded, color: kCoral, size: 22),
              const SizedBox(width: 10),
              Text(L.get('vet_clinics'),
                style: _nunito(14, kCoral, weight: FontWeight.w700)),
            ])),
        ),
      ]),
    );
  }

  Widget _seccion(String titulo, Color color, Widget child) => Container(
    width: double.infinity, padding: const EdgeInsets.all(16),
    decoration: kCardDeco(border: color.withOpacity(0.2)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(titulo, style: _nunito(15, color, weight: FontWeight.w800)),
      const SizedBox(height: 12),
      child,
    ]));
}

// ════════════════════════════════════════════════════════════════
//  ENCÍAS SCREEN
// ════════════════════════════════════════════════════════════════
class EnciasScreen extends StatelessWidget {
  final List<CameraDescription> cameras;
  final String serverIp; final CatProfile cat;
  final UserAccount user; final VoidCallback onComplete;
  const EnciasScreen({Key? key, required this.cameras,
      required this.serverIp, required this.cat,
      required this.user, required this.onComplete}) : super(key: key);
  @override
  Widget build(BuildContext context) => _VideoScanBase(
    cameras: cameras, serverIp: serverIp,
    endpoint: "analizar_video_encias",
    titulo: L.get('scan_gums_title'), emoji: "🦷",
    instruccion: L.lang == 'en'
      ? "Gently lift ${cat.name}\'s lip to show the gums clearly. Hold steady for 30 seconds."
      : "Levanta suavemente el labio de ${cat.name} para mostrar las encías. Mantén firme 30 segundos.",
    duracion: 30, cat: cat, user: user, onComplete: onComplete);
}

// ════════════════════════════════════════════════════════════════
//  MAULLIDO SCREEN
// ════════════════════════════════════════════════════════════════
class MaullidoScreen extends StatefulWidget {
  final CatProfile cat; final UserAccount user;
  final String serverIp; final VoidCallback onComplete;
  const MaullidoScreen({Key? key, required this.cat,
      required this.user, required this.serverIp,
      required this.onComplete}) : super(key: key);
  @override
  State<MaullidoScreen> createState() => _MaullidoScreenState();
}

class _MaullidoScreenState extends State<MaullidoScreen> {
  final AudioRecorder _recorder = AudioRecorder();
  bool   _recording  = false;
  bool   _analyzing  = false;
  int    _secs       = 0;
  int    _maxSecs    = 15;
  Timer? _timer;
  String? _recordPath;
  double _peakDb     = 0;
  double _currentDb  = 0;
  List<double> _dbHistory = [];
  Map<String, dynamic>? _resultado;
  String _instruccion = "";

  @override
  void initState() {
    super.initState();
    _instruccion = L.get('tap_record');
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    final dir  = await getTemporaryDirectory();
    final path = '${dir.path}/maullido_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: path);
    setState(() { _recording = true; _secs = 0; _dbHistory = []; _instruccion = "${L.get('recording')}"; });
    _recordPath = path;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) async {
      final amp = await _recorder.getAmplitude();
      final db  = amp.current.isFinite ? amp.current : -60.0;
      setState(() {
        _secs++;
        _currentDb = db;
        if (db > _peakDb) _peakDb = db;
        _dbHistory.add(db);
      });
      if (_secs >= _maxSecs) _stopAndAnalyze();
    });
  }

  Future<void> _stopAndAnalyze() async {
    _timer?.cancel();
    setState(() { _recording = false; _analyzing = true; _instruccion = "Analizando con IA 🧠"; });
    await _recorder.stop();
    // Build audio description from db history
    final avgDb    = _dbHistory.isNotEmpty
        ? _dbHistory.reduce((a, b) => a + b) / _dbHistory.length : -60.0;
    final loudSecs = _dbHistory.where((d) => d > -30).length;
    final silSecs  = _dbHistory.where((d) => d < -50).length;
    String desc;
    if (loudSecs == 0 && silSecs > _maxSecs * 0.8) {
      desc = "Grabación mayormente en silencio. La mascota no emitió sonidos audibles.";
    } else {
      final isEn = L.lang == 'en';
      desc = (isEn ? "Recording of $_secs seconds. " : "Grabación de $_secs segundos. ")
          + (isEn ? "Average volume: ${avgDb.toStringAsFixed(1)} dB. " : "Volumen promedio: ${avgDb.toStringAsFixed(1)} dB. ")
          + (isEn ? "Peak: ${_peakDb.toStringAsFixed(1)} dB. " : "Pico máximo: ${_peakDb.toStringAsFixed(1)} dB. ")
          + (isEn ? "Active sound seconds: $loudSecs of $_secs. " : "Segundos con sonido activo: $loudSecs de $_secs. ")
          + (loudSecs > 5 ? (isEn ? "The pet made frequent and intense sounds." : "La mascota emitió sonidos frecuentes e intensos.") : "")
          + (loudSecs >= 2 && loudSecs <= 5 ? (isEn ? "The pet made occasional sounds." : "La mascota emitió algunos sonidos ocasionales.") : "")
          + (silSecs > _maxSecs * 0.7 ? (isEn ? "The pet remained mostly silent." : "La mascota permaneció principalmente en silencio.") : "");
    }
    try {
      final ip    = widget.serverIp;
      final proto = ip.contains("onrender") || ip.contains("trycloudflare") ? "https" : "http";
      final port  = ip.contains("onrender") || ip.contains("trycloudflare") ? "" : ":8000";
      final uri   = Uri.parse("$proto://$ip${port}/analizar_maullido");
      final res   = await http.post(uri,
        headers: {"Content-Type": "application/json", "X-API-Key": kApiKey},
        body: json.encode({
          "lang":          L.lang,
          "descripcion":   desc,
          "duracion_seg":  _secs.toDouble(),
          "intensidad_db": avgDb,
        })).timeout(const Duration(seconds: 20));
      if (res.statusCode == 200 && mounted) {
        final data = json.decode(res.body);
        // Save to scan history
        final record = ScanRecord(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          catId: widget.cat.id, date: DateTime.now(),
          resultado: {...data, 'tipo': 'maullido'});
        widget.user.scans.add(record);
        await StorageService.saveScans(widget.user.scans);
        await FirestoreService.saveEscaneos(widget.user.scans);
        widget.onComplete();
        setState(() { _resultado = data; _analyzing = false; });
      } else {
        setState(() { _analyzing = false; });
      }
    } catch (e) {
      if (mounted) setState(() { _analyzing = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(child: Column(children: [
        // Top bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: const BoxDecoration(gradient: LinearGradient(
            colors: [Colors.black87, Colors.transparent],
            begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          child: Row(children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18))),
            const Spacer(),
            Text("😿 ${L.get('scan_meow_title')}",
              style: _nunito(15, Colors.white, weight: FontWeight.w800)),
            const Spacer(),
            const SizedBox(width: 34),
          ])),
        const Spacer(),
        // Main circle
        Stack(alignment: Alignment.center, children: [
          // Sound wave rings
          if (_recording) ...[
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              width: 280 + (_currentDb.abs() < 60 ? (60 - _currentDb.abs()) * 2 : 0),
              height: 280 + (_currentDb.abs() < 60 ? (60 - _currentDb.abs()) * 2 : 0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF6C5CE7).withOpacity(0.3), width: 2))),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 250 + (_currentDb.abs() < 60 ? (60 - _currentDb.abs()) * 1.5 : 0),
              height: 250 + (_currentDb.abs() < 60 ? (60 - _currentDb.abs()) * 1.5 : 0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF6C5CE7).withOpacity(0.5), width: 2))),
          ],
          Container(
            width: 220, height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF6C5CE7), Color(0xFFA855F7)],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
              boxShadow: [BoxShadow(
                color: const Color(0xFF6C5CE7).withOpacity(0.5),
                blurRadius: 30)]),
            child: _resultado != null
              ? _resultadoCirculo()
              : _analyzing
                ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                    SizedBox(height: 12),
                    Text("Analizando...", style: TextStyle(color: Colors.white, fontSize: 14))])
                : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(_recording ? "🎙️" : "😿",
                      style: const TextStyle(fontSize: 60)),
                    const SizedBox(height: 8),
                    Text(_recording ? "$_secs / $_maxSecs seg" : L.get('tap_record'),
                      style: _nunito(16, Colors.white, weight: FontWeight.w900)),
                    if (_recording) ...[
                      const SizedBox(height: 4),
                      Text("${_currentDb.toStringAsFixed(0)} dB",
                        style: _nunito(12, Colors.white70)),
                    ] else
                      Text(L.get('tap_record'),
                        style: _nunito(12, Colors.white70)),
                  ])),
        ]),
        const SizedBox(height: 32),
        // Controls
        if (_resultado == null)
          GestureDetector(
            onTap: _recording ? _stopAndAnalyze
                : (_analyzing ? null : _startRecording),
            child: Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _recording ? Colors.red : const Color(0xFF6C5CE7),
                boxShadow: [BoxShadow(
                  color: (_recording ? Colors.red : const Color(0xFF6C5CE7)).withOpacity(0.5),
                  blurRadius: 20)]),
              child: Icon(
                _recording ? Icons.stop_rounded : Icons.mic_rounded,
                color: Colors.white, size: 32)))
        else ...[
          // Ver resultado completo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(children: [
              GestureDetector(
                onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(
                  builder: (_) => MaullidoResultScreen(
                    resultado: _resultado!, cat: widget.cat))),
                child: Container(
                  width: double.infinity, padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C5CE7), Color(0xFFA855F7)]),
                    borderRadius: BorderRadius.circular(16)),
                  child: Text(L.get('see_full_analysis'),
                    style: _nunito(15, Colors.white, weight: FontWeight.w800),
                    textAlign: TextAlign.center))),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => setState(() { _resultado = null; _secs = 0; _peakDb = 0; }),
                child: Text(L.get('record_again'),
                  style: _nunito(14, Colors.white70))),
            ])),
        ],
        const Spacer(),
      ])),
    );
  }

  Widget _resultadoCirculo() {
    final estado = _resultado!["estado_emocional"] ?? "Analizando";
    final colorStr = _resultado!["estado_color"] ?? "#6C5CE7";
    Color col;
    try { col = Color(int.parse(colorStr.replaceFirst("#","0xFF"))); }
    catch (_) { col = const Color(0xFF6C5CE7); }
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(_resultado!["tipo_sonido"] == "Ronroneo" ? "😻"
          : _resultado!["tipo_sonido"] == "Chillido" ? "😱"
          : _resultado!["tipo_sonido"] == "Gruñido"  ? "😾"
          : "😿", style: const TextStyle(fontSize: 40)),
      const SizedBox(height: 6),
      Text(estado, style: _nunito(14, Colors.white, weight: FontWeight.w900),
        textAlign: TextAlign.center),
      const SizedBox(height: 4),
      Text(_resultado!["tipo_sonido"] ?? "",
        style: _nunito(11, Colors.white70)),
    ]);
  }
}

// ════════════════════════════════════════════════════════════════
//  MAULLIDO RESULT SCREEN
// ════════════════════════════════════════════════════════════════
class MaullidoResultScreen extends StatelessWidget {
  final Map<String, dynamic> resultado;
  final CatProfile cat;
  const MaullidoResultScreen({Key? key,
      required this.resultado, required this.cat}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final estado     = resultado["estado_emocional"] ?? "Desconocido";
    final colorStr   = resultado["estado_color"] ?? "#6C5CE7";
    final tipo       = resultado["tipo_sonido"] ?? "-";
    final intensidad = resultado["intensidad"] ?? "-";
    final interp     = resultado["interpretacion"] ?? "-";
    final causas     = (resultado["posibles_causas"] as List?) ?? [];
    final recom      = resultado["recomendacion"] ?? "-";
    final curiosidad = resultado["curiosidad_felina"] ?? "";
    final alerta     = resultado["alerta_veterinario"] ?? false;
    final urgencia   = resultado["nivel_urgencia"] ?? "Normal";

    Color accentColor;
    try { accentColor = Color(int.parse(colorStr.replaceFirst("#","0xFF"))); }
    catch (_) { accentColor = const Color(0xFF6C5CE7); }

    String emoji = tipo == "Ronroneo" ? "😻"
        : tipo == "Chillido" ? "😱"
        : tipo == "Gruñido"  ? "😾"
        : tipo == "Trino"    ? "😸"
        : tipo == "Silencio" ? "🤫" : "😿";

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Row(children: [
            GestureDetector(
              onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
              child: Container(padding: const EdgeInsets.all(10),
                decoration: kCardDeco(radius: 14),
                child: const Icon(Icons.home_rounded, color: kPurple, size: 22))),
            const SizedBox(width: 12),
              Expanded(child: kTitle("$emoji ${L.get('meow_analysis')}", size: 18)),
          ]),
          const SizedBox(height: 16),

          // Disclaimer
          Container(
            width: double.infinity, padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: kYellow.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: kYellow.withOpacity(0.4))),
            child: Text(L.get('disclaimer_short'),
              style: _nunito(11, kMuted), textAlign: TextAlign.center)),

          // Alerta si urgente
          if (alerta == true)
            Container(
              width: double.infinity, padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red, width: 2)),
              child: Row(children: [
                const Text("🚨", style: TextStyle(fontSize: 24)),
                const SizedBox(width: 10),
                Expanded(child: Text(L.get('vet_alert_msg'),
                  style: _nunito(13, Colors.red, weight: FontWeight.w800))),
              ])),

          // Estado emocional principal
          Container(
            width: double.infinity, padding: const EdgeInsets.all(20),
            decoration: kCardDeco(border: accentColor.withOpacity(0.3)),
            child: Column(children: [
              Text(emoji, style: const TextStyle(fontSize: 52)),
              const SizedBox(height: 12),
              Text(estado,
                style: _nunito(22, accentColor, weight: FontWeight.w900)),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                _chip(tipo, accentColor),
                const SizedBox(width: 8),
                _chip(intensidad, kMuted),
                const SizedBox(width: 8),
                _chip(urgencia, urgencia == "Normal" ? kGreen : kCoral),
              ]),
            ])),

          const SizedBox(height: 12),

          // Interpretación
          Container(
            width: double.infinity, padding: const EdgeInsets.all(16),
            decoration: kCardDeco(border: kPurple.withOpacity(0.2)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("🧠 ${L.get('interpretation')}",
                style: _nunito(14, kPurple, weight: FontWeight.w800)),
              const SizedBox(height: 8),
              kBody(interp, size: 13),
            ])),

          if (causas.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity, padding: const EdgeInsets.all(16),
              decoration: kCardDeco(border: kCoral.withOpacity(0.2)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("⚠️ ${L.get('possible_causes')}",
                  style: _nunito(14, kCoral, weight: FontWeight.w800)),
                const SizedBox(height: 8),
                ...causas.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(children: [
                    const Text("• ", style: TextStyle(color: kCoral, fontWeight: FontWeight.bold)),
                    Expanded(child: kBody(e.toString(), size: 13)),
                  ]))),
              ])),
          ],

          const SizedBox(height: 12),

          // Recomendación
          Container(
            width: double.infinity, padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                kYellow.withOpacity(0.15), kCoral.withOpacity(0.08)]),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kYellow.withOpacity(0.4))),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("💡", style: TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  kTitle(L.get('what_to_do'), size: 13),
                  const SizedBox(height: 4),
                  kBody(recom, size: 13),
                ])),
            ])),

          if (curiosidad.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity, padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kTurquoise.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kTurquoise.withOpacity(0.3))),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text("🐱", style: TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    kTitle(L.get('did_you_know'), size: 13),
                    const SizedBox(height: 4),
                    kBody(curiosidad, size: 13),
                  ])),
              ])),
          ],

          const SizedBox(height: 16),

          // Botón clínicas
          GestureDetector(
            onTap: () async {
              final mapsApp = Uri.parse("geo:0,0?q=veterinario+cerca");
              final mapsBrowser = Uri.parse("https://www.google.com/maps/search/veterinario+cerca+de+mi+ubicacion");
              if (await canLaunchUrl(mapsApp)) {
                await launchUrl(mapsApp, mode: LaunchMode.externalApplication);
              } else if (await canLaunchUrl(mapsBrowser)) {
                await launchUrl(mapsBrowser, mode: LaunchMode.externalApplication);
              }
            },
            child: Container(
              width: double.infinity, padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kCoral.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kCoral.withOpacity(0.3))),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.local_hospital_rounded, color: kCoral, size: 22),
                const SizedBox(width: 10),
                Text(L.get('vet_clinics'),
                  style: _nunito(14, kCoral, weight: FontWeight.w700)),
              ]))),

          const SizedBox(height: 12),
          kOutlineBtn(L.get('back_home'),
            () => Navigator.of(context).popUntil((r) => r.isFirst),
            color: kPurple),
          const SizedBox(height: 20),
        ]),
      )),
    );
  }

  Widget _chip(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withOpacity(0.5))),
    child: Text(text, style: _nunito(11, color, weight: FontWeight.w700)));
}

// ════════════════════════════════════════════════════════════════
//  🗣️ PET TRANSLATOR SCREEN — "¿Qué dice tu mascota?"
// ════════════════════════════════════════════════════════════════

class PetTranslatorScreen extends StatefulWidget {
  final CatProfile              cat;
  final UserAccount             user;
  final String                  serverIp;
  final List<CameraDescription> cameras;
  const PetTranslatorScreen({Key? key, required this.cat,
      required this.user, required this.serverIp,
      required this.cameras}) : super(key: key);
  @override State<PetTranslatorScreen> createState() => _PetTranslatorScreenState();
}

class _PetTranslatorScreenState extends State<PetTranslatorScreen>
    with TickerProviderStateMixin {

  // ── Cámara ──
  CameraController? _cam;
  bool _camReady   = false;

  // ── Grabación ──
  bool   _recording  = false;
  bool   _analyzing  = false;
  bool   _uploading  = false;
  int    _secs       = 0;
  final  _maxSecs    = 15;
  Timer? _timer;
  String? _videoPath;

  // ── Resultado ──
  Map<String, dynamic>? _resultado;
  String? _videoResultPath;   // video procesado que regresa del backend

  // ── Animación ──
  late AnimationController _pulseCtrl;
  late AnimationController _subtitleCtrl;
  late Animation<double>   _subtitleAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl    = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 900))..repeat(reverse: true);
    _subtitleCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 600));
    _subtitleAnim = CurvedAnimation(parent: _subtitleCtrl, curve: Curves.elasticOut);
    _initCamera();
  }

  Future<void> _initCamera() async {
    if (widget.cameras.isEmpty) return;
    _cam = CameraController(
      widget.cameras.first,
      ResolutionPreset.high,
      enableAudio: true,
    );
    await _cam!.initialize();
    if (mounted) setState(() => _camReady = true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cam?.dispose();
    _pulseCtrl.dispose();
    _subtitleCtrl.dispose();
    super.dispose();
  }

  // ── Iniciar grabación de video ──
  Future<void> _startRecording() async {
    final okCam = await Permission.camera.request();
    final okMic = await Permission.microphone.request();
    if (!okCam.isGranted || !okMic.isGranted) return;
    if (_cam == null || !_camReady) return;

    await _cam!.startVideoRecording();
    setState(() { _recording = true; _secs = 0; _resultado = null; _videoResultPath = null; });

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => _secs++);
      if (_secs >= _maxSecs) _stopAndTranslate();
    });
  }

  // Subtítulos: el backend los quema. En el cliente compartimos el video original.
  Future<String?> _quemarSubtitulosLocal(
      String videoPath, String frase, int prob) async {
    // ffmpeg_kit removido por compatibilidad — el backend quema los subtítulos
    // Si el backend no los quemó, se comparte el video original con el texto como descripción
    return null;
  }


  // ── Detener y enviar al backend ──
  Future<void> _stopAndTranslate() async {
    _timer?.cancel();
    if (!_recording) return;

    final xfile = await _cam!.stopVideoRecording();
    _videoPath  = xfile.path;
    setState(() { _recording = false; _analyzing = true; });

    try {
      final ip    = widget.serverIp;
      final proto = ip.contains("onrender") || ip.contains("trycloudflare") ? "https" : "http";
      final port  = ip.contains("onrender") || ip.contains("trycloudflare") ? "" : ":8000";
      final uri   = Uri.parse("$proto://$ip${port}/traducir_video");

      setState(() { _uploading = true; });

      final req = http.MultipartRequest('POST', uri)
        ..headers['X-API-Key'] = kApiKey
        ..fields['lang']       = L.lang
        ..fields['tipo']       = widget.cat.tipo == 'perro' ? 'dog' : 'cat'
        ..fields['nombre']     = widget.cat.name
        ..files.add(await http.MultipartFile.fromPath('video', _videoPath!,
            contentType: MediaType('video', 'mp4')));

      final streamed = await req.send().timeout(const Duration(seconds: 90));
      final res      = await http.Response.fromStream(streamed);

      setState(() { _uploading = false; _analyzing = false; });

      if (res.statusCode == 200) {
        final ct = res.headers['content-type'] ?? '';
        if (ct.contains('video')) {
          // Backend devolvió video con subtítulos ya quemados
          final dir  = await getTemporaryDirectory();
          final path = '${dir.path}/traduccion_${DateTime.now().millisecondsSinceEpoch}.mp4';
          await File(path).writeAsBytes(res.bodyBytes);
          setState(() { _videoResultPath = path; _resultado = _fallbackResult(); });
        } else {
          // Backend devolvió solo JSON → quemar subtítulos en el celular
          final data  = json.decode(res.body);
          final frase = data["frase"] ?? "";
          final prob  = (data["probabilidad"] ?? 85) as int;
          setState(() { _resultado = data; });

          // Subtítulos: el backend los quema si tiene ffmpeg instalado
          if (_videoPath != null && frase.isNotEmpty) {
            setState(() { _analyzing = true; });
            final subPath = await _quemarSubtitulosLocal(_videoPath!, frase, prob);
            setState(() {
              _videoResultPath = subPath;
              _analyzing = false;
            });
          }
        }
      } else {
        // Backend falló → usar fallback y quemar subtítulos localmente
        final data  = _fallbackResult();
        final frase = data["frase"] ?? "";
        final prob  = (data["probabilidad"] ?? 85) as int;
        setState(() { _resultado = data; });
        if (_videoPath != null && frase.isNotEmpty) {
          setState(() { _analyzing = true; });
          final subPath = await _quemarSubtitulosLocal(_videoPath!, frase, prob);
          setState(() { _videoResultPath = subPath; _analyzing = false; });
        }
      }
    } catch (_) {
      // Error de red → fallback + subtítulos locales
      final data  = _fallbackResult();
      final frase = data["frase"] ?? "";
      final prob  = (data["probabilidad"] ?? 85) as int;
      setState(() {
        _uploading = false;
        _analyzing = false;
        _resultado = data;
      });
      if (_videoPath != null && frase.isNotEmpty) {
        setState(() { _analyzing = true; });
        final subPath = await _quemarSubtitulosLocal(_videoPath!, frase, prob);
        setState(() { _videoResultPath = subPath; _analyzing = false; });
      }
    }
    _subtitleCtrl.forward();
  }

  // ── Fallback con frases graciosas ──
  Map<String, dynamic> _fallbackResult() {
    final esDog  = widget.cat.tipo == 'perro';
    final nombre = widget.cat.name;
    final frases = esDog ? [
      {"frase": L.lang == 'en' ? "I need to go outside RIGHT NOW!" : "¡Necesito salir AHORA MISMO!", "prob": 87, "emoji": "🐕"},
      {"frase": L.lang == 'en' ? "Is that food? GIVE ME THE FOOD." : "¿Es comida? DAME LA COMIDA.", "prob": 92, "emoji": "🦮"},
      {"frase": L.lang == 'en' ? "You are my favorite human." : "Eres mi humano favorito.", "prob": 78, "emoji": "🐶"},
      {"frase": L.lang == 'en' ? "The mailman is VERY suspicious." : "El cartero es MUY sospechoso.", "prob": 95, "emoji": "🐕‍🦺"},
    ] : [
      {"frase": L.lang == 'en' ? "Feed me. Feed me NOW." : "Dame comida. AHORA.", "prob": 94, "emoji": "😾"},
      {"frase": L.lang == 'en' ? "I knocked it off because I wanted to." : "Lo tiré porque quise. Y lo volvería a hacer.", "prob": 89, "emoji": "😼"},
      {"frase": L.lang == 'en' ? "I love you... but only when it suits me." : "Te quiero... pero solo cuando me conviene.", "prob": 76, "emoji": "😸"},
      {"frase": L.lang == 'en' ? "This house is mine. You just pay rent." : "Esta casa es mía. Tú solo pagas el arriendo.", "prob": 91, "emoji": "🐱"},
    ];
    frases.shuffle();
    final chosen = frases.first;
    return {
      "frase":        chosen["frase"],
      "probabilidad": chosen["prob"],
      "emoji":        chosen["emoji"],
      "contexto":     L.lang == 'en'
        ? "Based on $nombre's sound and personality"
        : "Basado en el sonido y personalidad de $nombre",
      "mood":       L.lang == 'en' ? "Expressive" : "Expresivo",
      "mood_color": "#A29BFE",
    };
  }

  // ── Compartir en todas las redes ──
  Future<void> _share() async {
    if (_resultado == null) return;
    final frase  = _resultado!["frase"] ?? "";
    final prob   = _resultado!["probabilidad"] ?? 0;
    final nombre = widget.cat.name;
    final isEn   = L.lang == 'en';

    final line1 = isEn ? '🐾 $nombre says ($prob% probability):' : '🐾 $nombre dice ($prob% de probabilidad):';
    final line2 = '"$frase"';
    final line3 = isEn ? 'Translated with MeowScanAI' : 'Traducido con MeowScanAI';
    final line4 = isEn ? '#PetTranslator #MeowScan #AIpets' : '#TraductorDeMascotas #MeowScan #IA';
    final text  = '$line1\n$line2\n\n$line3\n$line4';

    if (_videoResultPath != null) {
      // Compartir el video procesado con subtítulos quemados
      await Share.shareXFiles(
        [XFile(_videoResultPath!)],
        text: text,
        subject: 'MeowScanAI — $nombre',
      );
    } else if (_videoPath != null) {
      // Compartir el video original con el texto de traducción
      await Share.shareXFiles(
        [XFile(_videoPath!)],
        text: text,
        subject: 'MeowScanAI — $nombre',
      );
    } else {
      // Solo texto
      await Share.share(text, subject: 'MeowScanAI — $nombre');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDog = widget.cat.tipo == 'perro';

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(child: Stack(children: [

        // ── VISTA DE CÁMARA (siempre de fondo) ──
        if (_camReady && _cam != null && _resultado == null)
          Positioned.fill(child: CameraPreview(_cam!)),

        // ── OVERLAY oscuro cuando no está grabando ──
        if (!_recording && _resultado == null && _camReady)
          Positioned.fill(child: Container(color: Colors.black45)),

        // ── RESULTADO sobre fondo negro ──
        if (_resultado != null)
          Positioned.fill(child: _resultView()),

        // ── UI SUPERIOR siempre visible ──
        Positioned(
          top: 0, left: 0, right: 0,
          child: _topBar()),

        // ── SUBTÍTULOS ANIMADOS sobre la cámara durante grabación ──
        if (_recording)
          Positioned(
            bottom: 120, left: 20, right: 20,
            child: _recordingSubtitle()),

        // ── CONTROLES INFERIORES ──
        if (_resultado == null)
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _controls(isDog)),

      ])));
  }

  Widget _topBar() => Container(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.black87, Colors.transparent],
        begin: Alignment.topCenter, end: Alignment.bottomCenter)),
    child: Row(children: [
      GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white12, borderRadius: BorderRadius.circular(14)),
          child: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 18))),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(L.get('translator_title'),
          style: _nunito(17, Colors.white, weight: FontWeight.w900)),
        Text(widget.cat.name, style: _nunito(12, Colors.white54)),
      ])),
      // Timer cuando graba
      if (_recording)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: kCoral, borderRadius: BorderRadius.circular(20)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.fiber_manual_record, color: Colors.white, size: 10),
            const SizedBox(width: 5),
            Text('$_secs / $_maxSecs s',
              style: _nunito(12, Colors.white, weight: FontWeight.w800)),
          ])),
    ]));

  Widget _recordingSubtitle() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.black54,
      borderRadius: BorderRadius.circular(16)),
    child: Text(
      L.lang == 'en'
        ? 'Recording... let ${widget.cat.name} speak!'
        : 'Grabando... ¡deja que hable ${widget.cat.name}!',
      style: _nunito(14, Colors.white, weight: FontWeight.w700),
      textAlign: TextAlign.center));

  Widget _controls(bool isDog) => Container(
    padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.transparent, Colors.black87],
        begin: Alignment.topCenter, end: Alignment.bottomCenter)),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      // Estado / tip
      if (!_recording && !_analyzing)
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(14)),
            child: Text(
              L.lang == 'en'
                ? isDog
                  ? '💡 Get ${widget.cat.name} to bark, whine or growl'
                  : '💡 Get ${widget.cat.name} to meow, purr or chirp'
                : isDog
                  ? '💡 Haz que ${widget.cat.name} ladre, lloriquee o gruña'
                  : '💡 Haz que ${widget.cat.name} maúlle, ronronee o chille',
              style: _nunito(12, Colors.white60),
              textAlign: TextAlign.center))),

      if (_analyzing || _uploading)
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(children: [
            const CircularProgressIndicator(color: kPurple, strokeWidth: 2.5),
            const SizedBox(height: 12),
            Text(
              _uploading
                ? (L.lang == 'en' ? 'Uploading video...' : 'Subiendo video...')
                : (L.lang == 'en' ? 'AI is translating...' : 'La IA está traduciendo...'),
              style: _nunito(13, Colors.white70)),
          ])),

      // Botón grabar
      if (!_analyzing && !_uploading)
        AnimatedPressButton(
          onTap: _recording ? _stopAndTranslate : _startRecording,
          child: Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: _recording
                  ? [kCoral, const Color(0xFFFF8E53)]
                  : [kPurple, const Color(0xFF6C5CE7)]),
              boxShadow: [BoxShadow(
                color: (_recording ? kCoral : kPurple).withOpacity(0.5),
                blurRadius: 20, spreadRadius: 2)]),
            child: Center(child: Icon(
              _recording ? Icons.stop_rounded : Icons.videocam_rounded,
              color: Colors.white, size: 36)))),
    ]));

  Widget _resultView() {
    final frase   = _resultado!["frase"] ?? "";
    final prob    = _resultado!["probabilidad"] ?? 0;
    final emoji   = _resultado!["emoji"] ?? (widget.cat.tipo == 'perro' ? "🐕" : "🐱");
    final contexto= _resultado!["contexto"] ?? "";
    final mood    = _resultado!["mood"] ?? "";
    final moodClr = _resultado!["mood_color"] ?? "#A29BFE";
    Color mColor;
    try { mColor = Color(int.parse(moodClr.replaceFirst("#","0xFF"))); }
    catch (_) { mColor = kPurple; }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 100, 24, 40),
      child: Column(children: [

        // ── Card viral con marca de agua ──
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A0A2E), Color(0xFF0D0D1A)],
              begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: kPurple.withOpacity(0.35), width: 1.5)),
          child: Column(children: [
            // Marca de agua superior
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: kPurple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10)),
                child: Text('MeowScanAI 🐾',
                  style: _nunito(10, kPurple, weight: FontWeight.w700))),
            ]),
            const SizedBox(height: 12),

            // Emoji
            Text(emoji.toString(), style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 16),

            // Frase
            ScaleTransition(
              scale: _subtitleAnim,
              child: Text(
                '"$frase"',
                style: _nunito(20, Colors.white, weight: FontWeight.w800),
                textAlign: TextAlign.center)),
            const SizedBox(height: 20),

            // Barra probabilidad
            Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(L.get('translator_prob'),
                  style: _nunito(12, Colors.white54)),
                Text('$prob%',
                  style: _nunito(16, kPurple, weight: FontWeight.w900)),
              ]),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: (prob as num).toDouble() / 100,
                  minHeight: 8,
                  backgroundColor: Colors.white12,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    prob > 80 ? kGreen : prob > 60 ? kYellow : kCoral))),
            ]),

            if (mood.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: mColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: mColor.withOpacity(0.4))),
                child: Text(mood,
                  style: _nunito(12, mColor, weight: FontWeight.w800))),
            ],

            if (contexto.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(contexto,
                style: _nunito(11, Colors.white38),
                textAlign: TextAlign.center),
            ],
          ])),

        const SizedBox(height: 16),

        // ── Badge "video incluido" si viene del backend ──
        if (_videoResultPath != null)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: kTurquoise.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kTurquoise.withOpacity(0.3))),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.check_circle_rounded, color: kTurquoise, size: 16),
              const SizedBox(width: 8),
              Text(
                L.lang == 'en'
                  ? 'Video with subtitles ready!'
                  : '¡Video con subtítulos listo!',
                style: _nunito(13, kTurquoise, weight: FontWeight.w700)),
            ])),

        // ── Botón compartir (toda las redes) ──
        AnimatedPressButton(
          onTap: _share,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)]),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(
                color: kPurple.withOpacity(0.4),
                blurRadius: 12, offset: const Offset(0, 4))]),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.share_rounded, color: Colors.white, size: 22),
              const SizedBox(width: 10),
              Text(
                _videoResultPath != null || _videoPath != null
                  ? (L.lang == 'en' ? '📲 Share video on all platforms' : '📲 Compartir video en todas las redes')
                  : (L.lang == 'en' ? '📲 Share on all platforms' : '📲 Compartir en todas las redes'),
                style: _nunito(15, Colors.white, weight: FontWeight.w800)),
            ]))),

        const SizedBox(height: 12),

        // ── Grabar de nuevo ──
        kOutlineBtn(
          L.get('translator_again'),
          () {
            _subtitleCtrl.reset();
            setState(() {
              _resultado       = null;
              _videoPath       = null;
              _videoResultPath = null;
              _secs            = 0;
            });
          },
          color: kPurple),

        const SizedBox(height: 12),

        kOutlineBtn(
          L.lang == 'en' ? '🏠 Back to home' : '🏠 Volver al inicio',
          () => Navigator.of(context).popUntil((r) => r.isFirst),
          color: kMuted),

        const SizedBox(height: 24),
      ]));
  }
}

// ════════════════════════════════════════════════════════════════
//  VET APPOINTMENTS SCREEN
// ════════════════════════════════════════════════════════════════
class VetAppointmentsScreen extends StatefulWidget {
  final CatProfile cat;
  final UserAccount user;
  final VoidCallback onRefresh;
  const VetAppointmentsScreen({Key? key, required this.cat,
      required this.user, required this.onRefresh}) : super(key: key);
  @override State<VetAppointmentsScreen> createState() => _VetAppointmentsScreenState();
}

class _VetAppointmentsScreenState extends State<VetAppointmentsScreen> {
  late List<VetAppointment> _appts;

  @override
  void initState() {
    super.initState();
    _loadAppts();
  }

  void _loadAppts() {
    _appts = widget.user.appointments
        .where((a) => a.catId == widget.cat.id)
        .toList()..sort((a, b) => a.date.compareTo(b.date));
  }

  Future<void> _save() async {
    await StorageService.saveAppointments(widget.user.appointments);
    await FirestoreService.saveAppointments(widget.user.appointments);
    if (mounted) setState(() => _loadAppts());
    widget.onRefresh();
  }

  Future<void> _showAddSheet([VetAppointment? existing]) async {
    final clinicCtrl  = TextEditingController(text: existing?.clinicName ?? '');
    final reasonCtrl  = TextEditingController(text: existing?.reason ?? '');
    final notesCtrl   = TextEditingController(text: existing?.notes ?? '');
    DateTime selDate  = existing?.date ?? DateTime.now().add(const Duration(days: 7));

    await showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Container(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
          decoration: const BoxDecoration(
            color: kBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 40, height: 4,
              decoration: BoxDecoration(color: kMuted.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            kTitle(existing == null
              ? (L.lang == 'en' ? "New Appointment" : "Nueva Cita")
              : (L.lang == 'en' ? "Edit Appointment" : "Editar Cita"), size: 18),
            const SizedBox(height: 16),
            kTextField(clinicCtrl,
              L.lang == 'en' ? "Clinic or vet name" : "Nombre de la clínica o vet",
              icon: Icons.local_hospital_rounded),
            const SizedBox(height: 10),
            kTextField(reasonCtrl,
              L.lang == 'en' ? "Reason (checkup, vaccine...)" : "Motivo (control, vacuna...)",
              icon: Icons.medical_services_rounded),
            const SizedBox(height: 10),
            kTextField(notesCtrl,
              L.lang == 'en' ? "Notes (optional)" : "Notas (opcional)",
              icon: Icons.notes_rounded),
            const SizedBox(height: 10),
            // Date picker
            GestureDetector(
              onTap: () async {
                final d = await showDatePicker(
                  context: ctx,
                  initialDate: selDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 2)));
                if (d != null) {
                  final t = await showTimePicker(
                    context: ctx, initialTime: TimeOfDay.fromDateTime(selDate));
                  setS(() => selDate = DateTime(
                    d.year, d.month, d.day,
                    t?.hour ?? selDate.hour,
                    t?.minute ?? selDate.minute));
                }
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: kCardDeco(border: kPurple.withOpacity(0.2)),
                child: Row(children: [
                  const Icon(Icons.calendar_month_rounded, color: Color(0xFF00B894), size: 20),
                  const SizedBox(width: 10),
                  Text(DateFormat('EEE dd MMM yyyy – HH:mm').format(selDate),
                    style: _nunito(14, kText, weight: FontWeight.w700)),
                  const Spacer(),
                  const Icon(Icons.edit_rounded, color: kMuted, size: 16),
                ]))),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00B894),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.all(16)),
                onPressed: () async {
                  if (clinicCtrl.text.isEmpty || reasonCtrl.text.isEmpty) return;
                  if (existing != null) {
                    widget.user.appointments.removeWhere((a) => a.id == existing.id);
                  }
                  final appt = VetAppointment(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    catId: widget.cat.id,
                    clinicName: clinicCtrl.text.trim(),
                    reason: reasonCtrl.text.trim(),
                    date: selDate,
                    notes: notesCtrl.text.trim());
                  widget.user.appointments.add(appt);
                  await _save();
                  await NotificationService.scheduleAppointment(appt);
                  Navigator.pop(ctx);
                },
                child: Text(L.lang == 'en' ? "Save appointment" : "Guardar cita",
                  style: _nunito(15, Colors.white, weight: FontWeight.w800)))),
          ]))));
  }

  @override
  Widget build(BuildContext context) {
    final upcoming = _appts.where((a) => !a.completed && a.date.isAfter(DateTime.now())).toList();
    final past     = _appts.where((a) => a.completed || a.date.isBefore(DateTime.now())).toList();

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(child: Column(children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(padding: const EdgeInsets.all(10),
                decoration: kCardDeco(radius: 14),
                child: const Icon(Icons.arrow_back_ios_new, color: kPurple, size: 18))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              kTitle("🏥 ${L.lang == 'en' ? 'Vet Appointments' : 'Citas Veterinarias'}", size: 18),
              kBody(widget.cat.name, color: kMuted, size: 12),
            ])),
            GestureDetector(
              onTap: () => _showAddSheet(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00B894),
                  borderRadius: BorderRadius.circular(14)),
                child: Text(L.lang == 'en' ? "+ New" : "+ Nueva",
                  style: _nunito(13, Colors.white, weight: FontWeight.w800)))),
          ])),
        Expanded(child: _appts.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text("🏥", style: TextStyle(fontSize: 56)),
              const SizedBox(height: 16),
              kTitle(L.lang == 'en' ? "No appointments yet" : "Sin citas aún", size: 16),
              const SizedBox(height: 8),
              kBody(L.lang == 'en'
                ? "Tap + New to add a vet appointment"
                : "Toca + Nueva para agregar una cita", color: kMuted),
            ]))
          : ListView(padding: const EdgeInsets.symmetric(horizontal: 20), children: [
              if (upcoming.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 10),
                  child: kTitle(L.lang == 'en' ? "Upcoming" : "Próximas", size: 14)),
                ...upcoming.map((a) => _apptCard(a, upcoming: true)),
              ],
              if (past.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 10),
                  child: kTitle(L.lang == 'en' ? "Past / Done" : "Pasadas / Completadas", size: 14)),
                ...past.map((a) => _apptCard(a, upcoming: false)),
              ],
              const SizedBox(height: 20),
            ])),
      ])),
    );
  }

  Widget _apptCard(VetAppointment a, {required bool upcoming}) {
    final isToday = DateFormat('yyyyMMdd').format(a.date) ==
                    DateFormat('yyyyMMdd').format(DateTime.now());
    final isTomorrow = DateFormat('yyyyMMdd').format(a.date) ==
                       DateFormat('yyyyMMdd').format(DateTime.now().add(const Duration(days: 1)));
    final accentColor = a.completed ? kMuted
        : isToday ? kCoral
        : isTomorrow ? kYellow
        : const Color(0xFF00B894);
    final badge = a.completed
        ? (L.lang == 'en' ? "✅ Done" : "✅ Completada")
        : isToday ? (L.lang == 'en' ? "🔴 Today!" : "🔴 ¡Hoy!")
        : isTomorrow ? (L.lang == 'en' ? "🟡 Tomorrow" : "🟡 Mañana")
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: kCardDeco(border: accentColor.withOpacity(0.3)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14)),
            child: Center(child: Icon(Icons.local_hospital_rounded,
              color: accentColor, size: 22))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(a.clinicName,
                style: _nunito(14, kText, weight: FontWeight.w800))),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10)),
                  child: Text(badge, style: _nunito(10, accentColor, weight: FontWeight.w700))),
            ]),
            const SizedBox(height: 2),
            kBody(a.reason, color: kMuted, size: 12),
            const SizedBox(height: 4),
            Row(children: [
              Icon(Icons.access_time_rounded, size: 12, color: accentColor),
              const SizedBox(width: 4),
              Text(DateFormat('EEE dd MMM – HH:mm').format(a.date),
                style: _nunito(11, accentColor, weight: FontWeight.w700)),
            ]),
            if (a.notes.isNotEmpty) ...[
              const SizedBox(height: 4),
              kBody(a.notes, color: kMuted, size: 11),
            ],
          ])),
          Column(children: [
            GestureDetector(
              onTap: () => _showAddSheet(a),
              child: const Icon(Icons.edit_rounded, color: kMuted, size: 18)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                a.completed = !a.completed;
                await _save();
              },
              child: Icon(
                a.completed ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                color: a.completed ? kGreen : kMuted, size: 22)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (dialogCtx) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: Text(L.get('delete_confirm'), style: _nunito(16, kText, weight: FontWeight.w800)),
                    content: Text(L.get('delete_appt_q'), style: _nunito(14, kMuted)),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(dialogCtx).pop(false),
                        child: Text(L.get('cancel_delete'), style: _nunito(14, kMuted))),
                      ElevatedButton(onPressed: () => Navigator.of(dialogCtx).pop(true),
                        style: ElevatedButton.styleFrom(backgroundColor: kCoral,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: Text(L.get('delete'), style: _nunito(14, Colors.white, weight: FontWeight.w700))),
                    ]));
                if (confirm == true) {
                  widget.user.appointments.removeWhere((x) => x.id == a.id);
                  await FirestoreService.deleteAppointment(a.id);
                  await StorageService.saveAppointments(widget.user.appointments);
                  await NotificationService.cancelAppointment(a.id);
                  if (mounted) setState(() => _loadAppts());
                  widget.onRefresh();
                }
              },
              child: const Icon(Icons.delete_outline_rounded, color: kCoral, size: 18)),
          ]),
        ])));
  }
}

// ════════════════════════════════════════════════════════════════
//  MEDICATIONS SCREEN
// ════════════════════════════════════════════════════════════════
class MedicationsScreen extends StatefulWidget {
  final CatProfile cat;
  final UserAccount user;
  final VoidCallback onRefresh;
  const MedicationsScreen({Key? key, required this.cat,
      required this.user, required this.onRefresh}) : super(key: key);
  @override State<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen> {
  late List<Medication> _meds;

  @override
  void initState() {
    super.initState();
    _loadMeds();
  }

  void _loadMeds() {
    _meds = widget.user.medications
        .where((m) => m.catId == widget.cat.id)
        .toList()..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<void> _save() async {
    await StorageService.saveMedications(widget.user.medications);
    await FirestoreService.saveMedications(widget.user.medications);
    if (mounted) setState(() => _loadMeds());
    widget.onRefresh();
  }

  Future<void> _showAddSheet([Medication? existing]) async {
    final nameCtrl  = TextEditingController(text: existing?.name ?? '');
    final doseCtrl  = TextEditingController(text: existing?.dose ?? '');
    final notesCtrl = TextEditingController(text: existing?.notes ?? '');
    String freq     = existing?.frequency ?? (L.lang == 'en' ? 'Once daily' : 'Una vez al día');
    TimeOfDay remTime = existing?.reminderTime ?? const TimeOfDay(hour: 8, minute: 0);

    final freqOptions = L.lang == 'en'
      ? ['Once daily', 'Twice daily', 'Every 8 hours', 'Every 12 hours', 'Weekly', 'As needed']
      : ['Una vez al día', 'Dos veces al día', 'Cada 8 horas', 'Cada 12 horas', 'Semanal', 'Según necesidad'];

    await showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Container(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
          decoration: const BoxDecoration(
            color: kBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
          child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 40, height: 4,
              decoration: BoxDecoration(color: kMuted.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            kTitle(existing == null
              ? (L.lang == 'en' ? "New Medication" : "Nuevo Medicamento")
              : (L.lang == 'en' ? "Edit Medication" : "Editar Medicamento"), size: 18),
            const SizedBox(height: 16),
            kTextField(nameCtrl,
              L.lang == 'en' ? "Medication name" : "Nombre del medicamento",
              icon: Icons.medication_rounded),
            const SizedBox(height: 10),
            kTextField(doseCtrl,
              L.lang == 'en' ? "Dose (e.g. 5mg, 1 pill)" : "Dosis (ej: 5mg, 1 pastilla)",
              icon: Icons.colorize_rounded),
            const SizedBox(height: 10),
            // Frequency picker
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: kCardDeco(border: kYellow.withOpacity(0.3)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: freqOptions.contains(freq) ? freq : freqOptions.first,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: kYellow),
                  items: freqOptions.map((f) => DropdownMenuItem(
                    value: f,
                    child: Text(f, style: _nunito(13, kText)))).toList(),
                  onChanged: (v) { if (v != null) setS(() => freq = v); }))),
            const SizedBox(height: 10),
            // Reminder time
            GestureDetector(
              onTap: () async {
                final t = await showTimePicker(context: ctx, initialTime: remTime);
                if (t != null) setS(() => remTime = t);
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: kCardDeco(border: kYellow.withOpacity(0.2)),
                child: Row(children: [
                  const Icon(Icons.alarm_rounded, color: kYellow, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    L.lang == 'en' ? "Reminder at " : "Recordatorio a las ",
                    style: _nunito(13, kMuted)),
                  Text(remTime.format(ctx),
                    style: _nunito(14, kText, weight: FontWeight.w800)),
                  const Spacer(),
                  const Icon(Icons.edit_rounded, color: kMuted, size: 16),
                ]))),
            const SizedBox(height: 10),
            kTextField(notesCtrl,
              L.lang == 'en' ? "Notes (optional)" : "Notas (opcional)",
              icon: Icons.notes_rounded),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kYellow,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.all(16)),
                onPressed: () async {
                  if (nameCtrl.text.isEmpty || doseCtrl.text.isEmpty) return;
                  if (existing != null) {
                    widget.user.medications.removeWhere((m) => m.id == existing.id);
                  }
                  final med = Medication(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    catId: widget.cat.id,
                    name: nameCtrl.text.trim(),
                    dose: doseCtrl.text.trim(),
                    frequency: freq,
                    startDate: DateTime.now(),
                    reminderTime: remTime,
                    notes: notesCtrl.text.trim());
                  widget.user.medications.add(med);
                  await _save();
                  await NotificationService.scheduleMedication(med);
                  Navigator.pop(ctx);
                },
                child: Text(L.lang == 'en' ? "Save medication" : "Guardar medicamento",
                  style: _nunito(15, Colors.white, weight: FontWeight.w800)))),
            const SizedBox(height: 8),
          ])))));
  }

  @override
  Widget build(BuildContext context) {
    final meds       = _meds;
    final activeMeds = meds.where((m) => m.active).toList();
    final inactiveMeds = meds.where((m) => !m.active).toList();

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(child: Column(children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(padding: const EdgeInsets.all(10),
                decoration: kCardDeco(radius: 14),
                child: const Icon(Icons.arrow_back_ios_new, color: kPurple, size: 18))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              kTitle("💊 ${L.lang == 'en' ? 'Medications' : 'Medicamentos'}", size: 18),
              kBody(widget.cat.name, color: kMuted, size: 12),
            ])),
            GestureDetector(
              onTap: () => _showAddSheet(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: kYellow,
                  borderRadius: BorderRadius.circular(14)),
                child: Text(L.lang == 'en' ? "+ Add" : "+ Agregar",
                  style: _nunito(13, Colors.white, weight: FontWeight.w800)))),
          ])),
        Expanded(child: meds.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text("💊", style: TextStyle(fontSize: 56)),
              const SizedBox(height: 16),
              kTitle(L.lang == 'en' ? "No medications yet" : "Sin medicamentos aún", size: 16),
              const SizedBox(height: 8),
              kBody(L.lang == 'en'
                ? "Tap + Add to register a medication"
                : "Toca + Agregar para registrar un medicamento", color: kMuted),
            ]))
          : ListView(padding: const EdgeInsets.symmetric(horizontal: 20), children: [
              if (activeMeds.isNotEmpty) ...[
                Padding(padding: const EdgeInsets.only(top: 4, bottom: 10),
                  child: kTitle(L.lang == 'en' ? "Active" : "Activos", size: 14)),
                ...activeMeds.map((m) => _medCard(m)),
              ],
              if (inactiveMeds.isNotEmpty) ...[
                Padding(padding: const EdgeInsets.only(top: 16, bottom: 10),
                  child: kTitle(L.lang == 'en' ? "Inactive" : "Inactivos", size: 14)),
                ...inactiveMeds.map((m) => _medCard(m)),
              ],
              const SizedBox(height: 20),
            ])),
      ])),
    );
  }

  Widget _medCard(Medication m) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: kCardDeco(border: (m.active ? kYellow : kMuted).withOpacity(0.25)),
      child: Row(children: [
        Container(
          width: 46, height: 46,
          decoration: BoxDecoration(
            color: (m.active ? kYellow : kMuted).withOpacity(0.1),
            borderRadius: BorderRadius.circular(14)),
          child: Center(child: Icon(Icons.medication_rounded,
            color: m.active ? kYellow : kMuted, size: 22))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(m.name, style: _nunito(14, kText, weight: FontWeight.w800)),
          kBody(m.dose, color: kMuted, size: 12),
          const SizedBox(height: 4),
          Row(children: [
            Icon(Icons.repeat_rounded, size: 12, color: kYellow),
            const SizedBox(width: 4),
            Text(m.frequency, style: _nunito(11, kYellow, weight: FontWeight.w700)),
            const SizedBox(width: 10),
            Icon(Icons.alarm_rounded, size: 12, color: kPurple),
            const SizedBox(width: 4),
            Text(m.reminderTime.format(context),
              style: _nunito(11, kPurple, weight: FontWeight.w700)),
          ]),
          if (m.notes.isNotEmpty) ...[
            const SizedBox(height: 2),
            kBody(m.notes, color: kMuted, size: 11),
          ],
        ])),
        Column(children: [
          GestureDetector(
            onTap: () => _showAddSheet(m),
            child: const Icon(Icons.edit_rounded, color: kMuted, size: 18)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              m.active = !m.active;
              if (m.active) {
                await NotificationService.scheduleMedication(m);
              } else {
                await NotificationService.cancelMedication(m.id);
              }
              await _save();
            },
            child: Icon(
              m.active ? Icons.pause_circle_rounded : Icons.play_circle_rounded,
              color: m.active ? kYellow : kGreen, size: 22)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (dialogCtx) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: Text(L.get('delete_confirm'), style: _nunito(16, kText, weight: FontWeight.w800)),
                  content: Text(L.lang == 'en' ? 'Delete this medication?' : '¿Eliminar este medicamento?', style: _nunito(14, kMuted)),
                  actions: [
                    TextButton(onPressed: () => Navigator.of(dialogCtx).pop(false),
                      child: Text(L.get('cancel_delete'), style: _nunito(14, kMuted))),
                    ElevatedButton(onPressed: () => Navigator.of(dialogCtx).pop(true),
                      style: ElevatedButton.styleFrom(backgroundColor: kCoral,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: Text(L.get('delete'), style: _nunito(14, Colors.white, weight: FontWeight.w700))),
                  ]));
              if (confirm == true) {
                widget.user.medications.removeWhere((x) => x.id == m.id);
                await FirestoreService.deleteMedication(m.id);
                await StorageService.saveMedications(widget.user.medications);
                await NotificationService.cancelMedication(m.id);
                if (mounted) setState(() => _loadMeds());
                widget.onRefresh();
              }

            },
            child: const Icon(Icons.delete_outline_rounded, color: kCoral, size: 18)),
        ]),
      ])));
}

// ════════════════════════════════════════════════════════════════
//  QR GENERATOR SCREEN
// ════════════════════════════════════════════════════════════════
class QrGeneratorScreen extends StatefulWidget {
  final CatProfile cat;
  final UserAccount user;
  const QrGeneratorScreen({Key? key, required this.cat, required this.user})
      : super(key: key);
  @override
  State<QrGeneratorScreen> createState() => _QrGeneratorScreenState();
}

class _QrGeneratorScreenState extends State<QrGeneratorScreen> {
  final _waCtrl    = TextEditingController();
  final _qrKey     = GlobalKey();
  bool  _generated = false;
  String _qrUrl    = '';

  @override
  void initState() {
    super.initState();
    // Pre-cargar datos del gato
    _waCtrl.text = '';
  }

  @override
  void dispose() { _waCtrl.dispose(); super.dispose(); }

  // Construye la URL del QR con todos los parámetros
  String _buildUrl() {
    final nombre = Uri.encodeComponent(widget.cat.name);
    final dueno  = Uri.encodeComponent(widget.user.username);
    final raza   = Uri.encodeComponent(
        widget.user.scans
            .where((s) => s.catId == widget.cat.id)
            .lastOrNull
            ?.resultado['raza']?['raza'] ?? 'Desconocida');
    final edad   = Uri.encodeComponent(
        '${widget.cat.ageYears} años ${widget.cat.ageMonths} meses');
    final wa     = Uri.encodeComponent(_waCtrl.text.replaceAll(' ', ''));
    return '$QR_BASE_URL?nombre=$nombre&dueno=$dueno&raza=$raza&edad=$edad&wa=$wa';
  }

  void _generate() {
    if (_waCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Ingresa tu número de WhatsApp',
            style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w700)),
        backgroundColor: kCoral,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    setState(() {
      _qrUrl      = _buildUrl();
      _generated  = true;
    });
  }

  // Captura el widget QR como imagen
  Future<Uint8List> _captureQr() async {
    final boundary = _qrKey.currentContext!.findRenderObject()
        as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 4.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  // Generar y descargar PDF
  Future<void> _downloadPdf() async {
    final qrBytes = await _captureQr();

    // Obtener raza del último escaneo
    final ultimoScan = widget.user.scans
        .where((s) => s.catId == widget.cat.id)
        .lastOrNull;
    final raza = ultimoScan?.resultado['raza']?['raza'] ?? 'Desconocida';
    final peso = ultimoScan?.resultado['peso']?['peso_kg'] ?? '-';

    final pdf = pw.Document();
    final qrImage = pw.MemoryImage(qrBytes);

    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (pw.Context ctx) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            // Header
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#FF6B6B'),
                borderRadius: pw.BorderRadius.circular(16),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text('🐱 MeowScan — ID Digital Felino',
                    style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white)),
                ],
              ),
            ),
            pw.SizedBox(height: 30),

            // Tarjeta del gato
            pw.Container(
              padding: const pw.EdgeInsets.all(24),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColor.fromHex('#EDEDED'), width: 2),
                borderRadius: pw.BorderRadius.circular(20),
              ),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // QR Code
                  pw.Column(children: [
                    pw.Container(
                      width: 160, height: 160,
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(
                            color: PdfColor.fromHex('#FF6B6B'), width: 2),
                        borderRadius: pw.BorderRadius.circular(16),
                      ),
                      child: pw.ClipRRect(
                        horizontalRadius: 14, verticalRadius: 14,
                        child: pw.Image(qrImage, fit: pw.BoxFit.contain)),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text('Escanea para contactar',
                      style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColor.fromHex('#B2BEC3'))),
                  ]),

                  pw.SizedBox(width: 24),

                  // Datos del gato
                  pw.Expanded(child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(widget.cat.name,
                        style: pw.TextStyle(
                            fontSize: 28, fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex('#2D3436'))),
                      pw.SizedBox(height: 6),
                      pw.Text((L.lang == 'en' ? 'Owner: ' : 'Dueño: ') + widget.user.username,
                        style: pw.TextStyle(
                            fontSize: 14,
                            color: PdfColor.fromHex('#A29BFE'),
                            fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 16),
                      _pdfChip('🧬 Raza', raza,   '#A29BFE'),
                      pw.SizedBox(height: 8),
                      _pdfChip('🎂 Edad',
                          '${widget.cat.ageYears} años ${widget.cat.ageMonths} meses',
                          '#FF6B6B'),
                      pw.SizedBox(height: 8),
                      _pdfChip('⚖️ Peso', '$peso kg', '#4ECDC4'),
                      pw.SizedBox(height: 8),
                      _pdfChip('📱 WhatsApp', _waCtrl.text, '#25D366'),
                    ],
                  )),
                ],
              ),
            ),

            pw.SizedBox(height: 24),

            // Instrucciones
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#FFF9F0'),
                borderRadius: pw.BorderRadius.circular(12),
                border: pw.Border.all(color: PdfColor.fromHex('#FFE66D')),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('💡 ¿Cómo usar este ID?',
                    style: pw.TextStyle(
                        fontSize: 13, fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#2D3436'))),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    '1. Imprime esta tarjeta y recorta el código QR\n'
                    '2. Ponlo en el collar de ${widget.cat.name}\n'
                    '3. Si alguien encuentra al gato, escanea el QR\n'
                    '4. Verá los datos del gato y podrá contactarte por WhatsApp',
                    style: const pw.TextStyle(
                        fontSize: 12, color: PdfColors.black)),
                ],
              ),
            ),

            pw.SizedBox(height: 20),
            pw.Text(
              'Generado con MeowScan v$APP_VERSION · ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
              style: pw.TextStyle(fontSize: 10, color: PdfColor.fromHex('#B2BEC3'))),
          ],
        );
      },
    ));

    await Printing.layoutPdf(
      onLayout: (_) async => pdf.save(),
      name: 'meowscan_qr_${widget.cat.name.toLowerCase().replaceAll(' ', '_')}.pdf',
    );
  }

  pw.Widget _pdfChip(String label, String value, String hexColor) =>
    pw.Row(children: [
      pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: pw.BoxDecoration(
          color: PdfColor.fromHex(hexColor).shade(0.15),
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Text('$label: $value',
          style: pw.TextStyle(
              fontSize: 11,
              color: PdfColor.fromHex(hexColor),
              fontWeight: pw.FontWeight.bold)),
      ),
    ]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar
              Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: kCardDeco(radius: 14),
                    child: const Icon(Icons.arrow_back_ios_new,
                        color: kCoral, size: 18))),
                const SizedBox(width: 14),
                kTitle("ID Digital 🐾", size: 22),
              ]),
              const SizedBox(height: 24),

              // Info del gato (solo lectura)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [kCoral, kPurple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(
                    color: kCoral.withOpacity(0.3),
                    blurRadius: 16, offset: const Offset(0, 6))],
                ),
                child: Row(children: [
                  Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white24, shape: BoxShape.circle),
                    child: const Center(
                        child: Text("🐱", style: TextStyle(fontSize: 30)))),
                  const SizedBox(width: 16),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(widget.cat.name,
                      style: GoogleFonts.nunito(
                          fontSize: 22, color: Colors.white,
                          fontWeight: FontWeight.w900)),
                    Text("Dueño: ${widget.user.username}",
                      style: GoogleFonts.nunito(
                          fontSize: 13, color: Colors.white70,
                          fontWeight: FontWeight.w600)),
                    Text(
                      "${widget.cat.ageYears} años ${widget.cat.ageMonths} meses",
                      style: GoogleFonts.nunito(
                          fontSize: 12, color: Colors.white60)),
                  ]),
                ]),
              ),

              const SizedBox(height: 24),

              // Campo WhatsApp
              kLabel(L.get('whatsapp_number').toUpperCase()),
              const SizedBox(height: 10),
              kTextField(
                _waCtrl,
                L.get('whatsapp_hint'),
                icon: Icons.phone_rounded,
                accent: const Color(0xFF25D366),
              ),
              const SizedBox(height: 6),
              kBody(
                "Incluye el código del país sin el + (Colombia: 57...)",
                color: kMuted, size: 12),

              const SizedBox(height: 20),

              // Botón generar
              kGradBtn("🔳 Generar código QR", _generate),

              // QR generado
              if (_generated) ...[
                const SizedBox(height: 28),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: kCardDeco(
                    border: kCoral.withOpacity(0.2)),
                  child: Column(children: [
                    kTitle(L.get('ready'), size: 20, color: kCoral),
                    const SizedBox(height: 6),
                    kBody(
                      "Escanea este QR para ver el perfil de ${widget.cat.name}",
                      color: kMuted, size: 13),
                    const SizedBox(height: 20),

                    // QR Code
                    RepaintBoundary(
                      key: _qrKey,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: kCoral.withOpacity(0.3), width: 2),
                          boxShadow: [BoxShadow(
                            color: kCoral.withOpacity(0.1),
                            blurRadius: 16)],
                        ),
                        child: QrImageView(
                          data:            _qrUrl,
                          version:         QrVersions.auto,
                          size:            200,
                          backgroundColor: Colors.white,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color:    kCoral),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color:           Color(0xFF2D3436)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Chips de info
                    Wrap(spacing: 8, runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                      _infoChip("🐱 ${widget.cat.name}", kCoral),
                      _infoChip("👤 ${widget.user.username}", kPurple),
                      _infoChip("📱 ${_waCtrl.text}", const Color(0xFF25D366)),
                    ]),

                    const SizedBox(height: 20),

                    // Botón descargar PDF
                    GestureDetector(
                      onTap: _downloadPdf,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF6B6B), Color(0xFFA29BFE)]),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(
                            color: kCoral.withOpacity(0.3),
                            blurRadius: 12, offset: const Offset(0, 5))],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("📄", style: TextStyle(fontSize: 20)),
                            const SizedBox(width: 10),
                            Text("Descargar PDF con QR",
                              style: GoogleFonts.nunito(
                                fontSize: 16, color: Colors.white,
                                fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                    kBody(
                      "💡 Imprime el PDF y ponlo en el collar de ${widget.cat.name}",
                      color: kMuted, size: 12),
                  ]),
                ),
              ],

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoChip(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.3))),
    child: Text(label,
      style: GoogleFonts.nunito(
          fontSize: 12, color: color, fontWeight: FontWeight.w700)),
  );
}
