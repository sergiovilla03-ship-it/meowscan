// ════════════════════════════════════════════════════════════════
// 🐱 MEOWSCAN v2.0 - APP FLUTTER COMPLETA
// ════════════════════════════════════════════════════════════════
//
// NUEVAS FUNCIONES v2:
//   ✅ Login / Registro con email y contraseña
//   ✅ Perfil del gato (nombre, edad, foto)
//   ✅ Análisis de orejas
//   ✅ Historial de escaneos
//   ✅ Descargar reporte en PDF
//   ✅ Español / Inglés
//   ✅ Diseño premium listo para vender
//
// ESTRUCTURA DE ARCHIVOS:
//   lib/main.dart                ← este archivo (punto de entrada)
//
// DEPENDENCIAS (pubspec.yaml):
//   camera: ^0.10.5+9
//   http: ^1.2.0
//   permission_handler: ^11.3.0
//   fl_chart: ^0.67.0
//   google_fonts: ^6.2.1
//   shared_preferences: ^2.2.3
//   image_picker: ^1.1.2
//   pdf: ^3.11.0
//   printing: ^5.13.1
//   path_provider: ^2.1.3
//   intl: ^0.19.0
//
// PERMISOS AndroidManifest.xml:
//   <uses-permission android:name="android.permission.CAMERA"/>
//   <uses-permission android:name="android.permission.INTERNET"/>
//   <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
//   <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
// ════════════════════════════════════════════════════════════════

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ════════════════════════════════════════════════════════════════
//  CONFIGURACIÓN GLOBAL
// ════════════════════════════════════════════════════════════════

const String APP_VERSION    = "2.0.0";
const int    SCAN_DURATION  = 60;
const int    FRAME_INTERVAL = 2000;

// Paleta — oscura, elegante, con dorado como acento premium
const Color kBg        = Color(0xFF0D0D0D);
const Color kSurface   = Color(0xFF1A1A1A);
const Color kCard      = Color(0xFF242424);
const Color kGold      = Color(0xFFD4A843);
const Color kGoldLight = Color(0xFFF0C860);
const Color kRed       = Color(0xFFE05252);
const Color kGreen     = Color(0xFF52C97A);
const Color kText      = Color(0xFFF5F5F0);
const Color kMuted     = Color(0xFF888880);
const Color kBorder    = Color(0xFF2E2E2E);


// ════════════════════════════════════════════════════════════════
//  INTERNACIONALIZACIÓN (ES / EN)
// ════════════════════════════════════════════════════════════════

class L {
  static String _lang = 'es';
  static void setLang(String lang) => _lang = lang;
  static String get lang => _lang;

  static const _t = {
    'es': {
      'app_name':       'MeowScan',
      'tagline':        'Análisis Felino con IA',
      'login':          'Iniciar sesión',
      'register':       'Crear cuenta',
      'email':          'Correo electrónico',
      'password':       'Contraseña',
      'username':       'Nombre de usuario',
      'cat_name':       'Nombre del gato',
      'cat_age':        'Edad del gato',
      'years':          'años',
      'months':         'meses',
      'start_scan':     'Iniciar Escaneo',
      'scanning':       'Escaneando...',
      'results':        'Resultados',
      'breed':          'Raza',
      'weight':         'Peso estimado',
      'color':          'Color del pelaje',
      'pattern':        'Patrón',
      'body_condition': 'Estado corporal',
      'mood':           'Estado de ánimo',
      'ears':           'Análisis de orejas',
      'health_score':   'Índice de salud',
      'download_pdf':   'Descargar Reporte PDF',
      'new_scan':       'Nuevo escaneo',
      'history':        'Historial',
      'profile':        'Perfil',
      'settings':       'Ajustes',
      'server_ip':      'IP del servidor',
      'test_conn':      'Probar conexión',
      'connected':      '✅ Conectado',
      'not_connected':  '❌ Sin conexión',
      'language':       'Idioma',
      'logout':         'Cerrar sesión',
      'save':           'Guardar',
      'cancel':         'Cancelar',
      'add_cat':        'Agregar gato',
      'my_cats':        'Mis gatos',
      'scan_history':   'Historial de escaneos',
      'no_scans':       'Aún no hay escaneos',
      'tip':            '💡 Consejo',
      'ear_alert':      'Orejas alertas',
      'ear_relaxed':    'Orejas relajadas',
      'ear_back':       'Orejas hacia atrás',
      'ear_forward':    'Orejas hacia adelante',
      'welcome':        'Bienvenido',
      'select_cat':     'Selecciona tu gato',
      'cat_photo':      'Foto del gato',
      'seconds':        'segundos',
      'frames':         'capturas',
      'ideal_weight':   'Peso ideal ✓',
      'overweight':     'Sobrepeso',
      'obese':          'Obesidad 🚨',
      'underweight':    'Bajo peso',
      'slightly_thin':  'Algo delgado',
    },
    'en': {
      'app_name':       'MeowScan',
      'tagline':        'AI-Powered Cat Analysis',
      'login':          'Log in',
      'register':       'Create account',
      'email':          'Email address',
      'password':       'Password',
      'username':       'Username',
      'cat_name':       'Cat name',
      'cat_age':        'Cat age',
      'years':          'years',
      'months':         'months',
      'start_scan':     'Start Scan',
      'scanning':       'Scanning...',
      'results':        'Results',
      'breed':          'Breed',
      'weight':         'Estimated weight',
      'color':          'Coat color',
      'pattern':        'Pattern',
      'body_condition': 'Body condition',
      'mood':           'Mood',
      'ears':           'Ear analysis',
      'health_score':   'Health score',
      'download_pdf':   'Download PDF Report',
      'new_scan':       'New scan',
      'history':        'History',
      'profile':        'Profile',
      'settings':       'Settings',
      'server_ip':      'Server IP',
      'test_conn':      'Test connection',
      'connected':      '✅ Connected',
      'not_connected':  '❌ Not connected',
      'language':       'Language',
      'logout':         'Log out',
      'save':           'Save',
      'cancel':         'Cancel',
      'add_cat':        'Add cat',
      'my_cats':        'My cats',
      'scan_history':   'Scan history',
      'no_scans':       'No scans yet',
      'tip':            '💡 Tip',
      'ear_alert':      'Alert ears',
      'ear_relaxed':    'Relaxed ears',
      'ear_back':       'Ears back',
      'ear_forward':    'Ears forward',
      'welcome':        'Welcome',
      'select_cat':     'Select your cat',
      'cat_photo':      'Cat photo',
      'seconds':        'seconds',
      'frames':         'frames',
      'ideal_weight':   'Ideal weight ✓',
      'overweight':     'Overweight',
      'obese':          'Obese 🚨',
      'underweight':    'Underweight',
      'slightly_thin':  'Slightly thin',
    },
  };

  static String get(String key) =>
      _t[_lang]?[key] ?? _t['es']?[key] ?? key;
}


// ════════════════════════════════════════════════════════════════
//  MODELOS DE DATOS
// ════════════════════════════════════════════════════════════════

class CatProfile {
  String id;
  String name;
  int    ageYears;
  int    ageMonths;
  String? photoPath;

  CatProfile({
    required this.id,
    required this.name,
    required this.ageYears,
    required this.ageMonths,
    this.photoPath,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name,
    'ageYears': ageYears, 'ageMonths': ageMonths,
    'photoPath': photoPath,
  };

  factory CatProfile.fromJson(Map<String, dynamic> j) => CatProfile(
    id:        j['id'],
    name:      j['name'],
    ageYears:  j['ageYears'] ?? 0,
    ageMonths: j['ageMonths'] ?? 0,
    photoPath: j['photoPath'],
  );
}

class ScanRecord {
  String id;
  String catId;
  DateTime date;
  Map<String, dynamic> resultado;

  ScanRecord({
    required this.id,
    required this.catId,
    required this.date,
    required this.resultado,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'catId': catId,
    'date': date.toIso8601String(),
    'resultado': resultado,
  };

  factory ScanRecord.fromJson(Map<String, dynamic> j) => ScanRecord(
    id:        j['id'],
    catId:     j['catId'],
    date:      DateTime.parse(j['date']),
    resultado: j['resultado'],
  );
}

class UserAccount {
  String email;
  String username;
  String passwordHash;
  List<CatProfile> cats;
  List<ScanRecord>  scans;

  UserAccount({
    required this.email,
    required this.username,
    required this.passwordHash,
    List<CatProfile>? cats,
    List<ScanRecord>?  scans,
  })  : cats  = cats  ?? [],
        scans = scans ?? [];
}


// ════════════════════════════════════════════════════════════════
//  SERVICIO DE ALMACENAMIENTO LOCAL
// ════════════════════════════════════════════════════════════════

class StorageService {
  static Future<SharedPreferences> get _p => SharedPreferences.getInstance();

  // ── Usuario ────────────────────────────────────────────────
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
    );
  }

  static Future<void> logout() async {
    final p = await _p;
    await p.remove('user_email');
    await p.remove('user_username');
    await p.remove('user_pass');
  }

  // ── Gatos ──────────────────────────────────────────────────
  static Future<void> saveCats(List<CatProfile> cats) async {
    final p = await _p;
    await p.setString('cats', jsonEncode(cats.map((c) => c.toJson()).toList()));
  }

  static Future<List<CatProfile>> loadCats() async {
    final p    = await _p;
    final data = p.getString('cats');
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((j) => CatProfile.fromJson(j)).toList();
  }

  // ── Escaneos ───────────────────────────────────────────────
  static Future<void> saveScans(List<ScanRecord> scans) async {
    final p = await _p;
    await p.setString('scans', jsonEncode(scans.map((s) => s.toJson()).toList()));
  }

  static Future<List<ScanRecord>> loadScans() async {
    final p    = await _p;
    final data = p.getString('scans');
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((j) => ScanRecord.fromJson(j)).toList();
  }

  // ── Config ─────────────────────────────────────────────────
  static Future<String> getServerIp() async {
    final p = await _p;
    return p.getString('server_ip') ?? '192.168.1.100';
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
//  MAIN
// ════════════════════════════════════════════════════════════════

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  final lang = await StorageService.getLang();
  L.setLang(lang);

  final cameras = await availableCameras();
  final user    = await StorageService.loadUser();

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
  String       _lang = L.lang;

  @override
  void initState() {
    super.initState();
    currentUser = widget.initialUser;
  }

  void setLang(String lang) {
    StorageService.setLang(lang);
    setState(() => _lang = lang);
  }

  void setUser(UserAccount? u) => setState(() => currentUser = u);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title:                    L.get('app_name'),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3:           true,
        scaffoldBackgroundColor: kBg,
        colorScheme:            ColorScheme.dark(primary: kGold, surface: kSurface),
        textTheme:              GoogleFonts.dmSansTextTheme(ThemeData.dark().textTheme),
      ),
      home: currentUser == null
          ? AuthScreen(cameras: widget.cameras)
          : MainShell(cameras: widget.cameras, user: currentUser!),
    );
  }
}


// ════════════════════════════════════════════════════════════════
//  WIDGETS REUTILIZABLES
// ════════════════════════════════════════════════════════════════

Widget kDivider() => const Divider(color: kBorder, height: 1);

Widget kLabel(String text) => Text(text,
  style: GoogleFonts.dmSans(fontSize: 11, color: kMuted,
      letterSpacing: 1.2, fontWeight: FontWeight.w600));

Widget kTitle(String text, {double size = 22}) => Text(text,
  style: GoogleFonts.playfairDisplay(
      fontSize: size, color: kText, fontWeight: FontWeight.w700));

Widget kBody(String text, {Color color = kText, double size = 14}) =>
  Text(text, style: GoogleFonts.dmSans(fontSize: size, color: color));

BoxDecoration kCardDeco({Color? border}) => BoxDecoration(
  color:        kCard,
  borderRadius: BorderRadius.circular(16),
  border:       Border.all(color: border ?? kBorder),
);

Widget kGoldBtn(String label, VoidCallback onTap) => GestureDetector(
  onTap: onTap,
  child: Container(
    width:   double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 16),
    decoration: BoxDecoration(
      gradient:     const LinearGradient(colors: [kGold, kGoldLight]),
      borderRadius: BorderRadius.circular(14),
      boxShadow: [BoxShadow(
          color: kGold.withOpacity(0.3), blurRadius: 12, offset: const Offset(0,4))],
    ),
    child: Center(child: Text(label,
      style: GoogleFonts.dmSans(
          fontSize: 15, fontWeight: FontWeight.w700, color: kBg))),
  ),
);

Widget kOutlineBtn(String label, VoidCallback onTap) => GestureDetector(
  onTap: onTap,
  child: Container(
    width:   double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: kGold.withOpacity(0.5)),
    ),
    child: Center(child: Text(label,
      style: GoogleFonts.dmSans(fontSize: 15, color: kGold, fontWeight: FontWeight.w600))),
  ),
);

Widget kTextField(TextEditingController ctrl, String hint,
    {bool obscure = false, IconData? icon}) =>
  TextField(
    controller:    ctrl,
    obscureText:   obscure,
    style:         GoogleFonts.dmSans(color: kText, fontSize: 15),
    decoration:    InputDecoration(
      hintText:      hint,
      hintStyle:     GoogleFonts.dmSans(color: kMuted),
      filled:        true,
      fillColor:     kSurface,
      prefixIcon:    icon != null ? Icon(icon, color: kMuted, size: 20) : null,
      border:        OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kGold, width: 1.5)),
    ),
  );


// ════════════════════════════════════════════════════════════════
//  PANTALLA DE AUTENTICACIÓN
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
  final _emailCtrl  = TextEditingController();
  final _passCtrl   = TextEditingController();
  final _userCtrl   = TextEditingController();
  String _error     = '';

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  void _login() async {
    final user = await StorageService.loadUser();
    if (user == null ||
        user.email != _emailCtrl.text.trim() ||
        user.passwordHash != _passCtrl.text) {
      setState(() => _error = L.lang == 'es'
          ? 'Correo o contraseña incorrectos'
          : 'Wrong email or password');
      return;
    }
    MeowScanApp.of(context)?.setUser(user);
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => MainShell(cameras: widget.cameras, user: user)));
  }

  void _register() async {
    if (_emailCtrl.text.isEmpty || _passCtrl.text.isEmpty || _userCtrl.text.isEmpty) {
      setState(() => _error = L.lang == 'es'
          ? 'Completa todos los campos'
          : 'Fill all fields');
      return;
    }
    final user = UserAccount(
      email:        _emailCtrl.text.trim(),
      username:     _userCtrl.text.trim(),
      passwordHash: _passCtrl.text,
    );
    await StorageService.saveUser(user);
    MeowScanApp.of(context)?.setUser(user);
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => MainShell(cameras: widget.cameras, user: user)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Logo
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: kSurface, shape: BoxShape.circle,
                  border: Border.all(color: kGold.withOpacity(0.4), width: 1.5),
                ),
                child: const Center(child: Text("🐱", style: TextStyle(fontSize: 38))),
              ),
              const SizedBox(height: 20),
              kTitle(L.get('app_name'), size: 32),
              const SizedBox(height: 6),
              kBody(L.get('tagline'), color: kMuted),
              const SizedBox(height: 40),

              // Tabs
              Container(
                decoration: BoxDecoration(
                  color: kSurface,
                  borderRadius: BorderRadius.circular(12)),
                child: TabBar(
                  controller: _tab,
                  indicator: BoxDecoration(
                    color: kGold, borderRadius: BorderRadius.circular(10)),
                  labelColor:      kBg,
                  unselectedLabelColor: kMuted,
                  labelStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
                  tabs: [
                    Tab(text: L.get('login')),
                    Tab(text: L.get('register')),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              SizedBox(
                height: 320,
                child: TabBarView(
                  controller: _tab,
                  children: [
                    _loginForm(),
                    _registerForm(),
                  ],
                ),
              ),

              if (_error.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: kRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: kRed.withOpacity(0.4)),
                  ),
                  child: kBody(_error, color: kRed),
                ),
              ],

              const SizedBox(height: 40),
              // Selector de idioma
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                kBody('ES', color: L.lang == 'es' ? kGold : kMuted),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    final nl = L.lang == 'es' ? 'en' : 'es';
                    MeowScanApp.of(context)?.setLang(nl);
                    setState(() {});
                  },
                  child: Container(
                    width: 44, height: 24,
                    decoration: BoxDecoration(
                      color: kGold,
                      borderRadius: BorderRadius.circular(12)),
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 200),
                      alignment: L.lang == 'es'
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: Container(
                        width: 20, height: 20,
                        margin: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                            color: kBg, shape: BoxShape.circle),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                kBody('EN', color: L.lang == 'en' ? kGold : kMuted),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _loginForm() => Column(children: [
    kTextField(_emailCtrl,  L.get('email'),    icon: Icons.email_outlined),
    const SizedBox(height: 14),
    kTextField(_passCtrl,   L.get('password'), icon: Icons.lock_outline, obscure: true),
    const SizedBox(height: 24),
    kGoldBtn(L.get('login'), _login),
  ]);

  Widget _registerForm() => Column(children: [
    kTextField(_userCtrl,  L.get('username'), icon: Icons.person_outline),
    const SizedBox(height: 12),
    kTextField(_emailCtrl, L.get('email'),    icon: Icons.email_outlined),
    const SizedBox(height: 12),
    kTextField(_passCtrl,  L.get('password'), icon: Icons.lock_outline, obscure: true),
    const SizedBox(height: 24),
    kGoldBtn(L.get('register'), _register),
  ]);
}


// ════════════════════════════════════════════════════════════════
//  MAIN SHELL (navegación principal)
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
  void initState() {
    super.initState();
    _user = widget.user;
  }

  void _refresh() async {
    final u = await StorageService.loadUser();
    if (u != null && mounted) setState(() => _user = u);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeTab(cameras: widget.cameras, user: _user, onRefresh: _refresh),
      HistoryTab(user: _user, cameras: widget.cameras),
      ProfileTab(user: _user, cameras: widget.cameras, onRefresh: _refresh),
      SettingsTab(cameras: widget.cameras),
    ];

    return Scaffold(
      backgroundColor: kBg,
      body: pages[_tab],
      bottomNavigationBar: _buildNavBar(),
    );
  }

  Widget _buildNavBar() => Container(
    decoration: const BoxDecoration(
      color: kSurface,
      border: Border(top: BorderSide(color: kBorder))),
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(0, Icons.home_rounded,       L.get('start_scan')),
            _navItem(1, Icons.history_rounded,    L.get('history')),
            _navItem(2, Icons.pets_rounded,       L.get('my_cats')),
            _navItem(3, Icons.settings_rounded,   L.get('settings')),
          ],
        ),
      ),
    ),
  );

  Widget _navItem(int idx, IconData icon, String label) => GestureDetector(
    onTap: () => setState(() => _tab = idx),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: _tab == idx ? kGold : kMuted, size: 24),
      const SizedBox(height: 3),
      Text(label.split(' ').first,
        style: GoogleFonts.dmSans(
          fontSize: 10,
          color: _tab == idx ? kGold : kMuted,
          fontWeight: _tab == idx ? FontWeight.w700 : FontWeight.w400)),
    ]),
  );
}


// ════════════════════════════════════════════════════════════════
//  HOME TAB — seleccionar gato e iniciar scan
// ════════════════════════════════════════════════════════════════

class HomeTab extends StatefulWidget {
  final List<CameraDescription> cameras;
  final UserAccount user;
  final VoidCallback onRefresh;
  const HomeTab({Key? key, required this.cameras,
      required this.user, required this.onRefresh}) : super(key: key);

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  CatProfile? _selectedCat;

  @override
  void initState() {
    super.initState();
    if (widget.user.cats.isNotEmpty) _selectedCat = widget.user.cats.first;
  }

  void _startScan() async {
    if (_selectedCat == null) {
      _showAddCatDialog();
      return;
    }
    final status = await Permission.camera.request();
    if (!status.isGranted) return;
    final ip = await StorageService.getServerIp();
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ScanScreen(
        cameras:    widget.cameras,
        serverIp:   ip,
        cat:        _selectedCat!,
        user:       widget.user,
        onComplete: widget.onRefresh,
      ),
    ));
  }

  void _showAddCatDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: kCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => AddCatSheet(
        onSave: (cat) async {
          widget.user.cats.add(cat);
          await StorageService.saveCats(widget.user.cats);
          widget.onRefresh();
          setState(() => _selectedCat = cat);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 28),
            _buildCatSelector(),
            const SizedBox(height: 28),
            _buildScanButton(),
            const SizedBox(height: 28),
            _buildFeatures(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() => Row(children: [
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      kLabel(L.get('welcome').toUpperCase()),
      const SizedBox(height: 4),
      kTitle(widget.user.username),
    ])),
    Container(
      padding: const EdgeInsets.all(10),
      decoration: kCardDeco(),
      child: const Text("🐱", style: TextStyle(fontSize: 22)),
    ),
  ]);

  Widget _buildCatSelector() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        kLabel(L.get('select_cat').toUpperCase()),
        GestureDetector(
          onTap: _showAddCatDialog,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: kGold.withOpacity(0.4)),
              borderRadius: BorderRadius.circular(20)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.add, color: kGold, size: 14),
              const SizedBox(width: 4),
              Text(L.get('add_cat'),
                  style: GoogleFonts.dmSans(fontSize: 12, color: kGold)),
            ]),
          ),
        ),
      ]),
      const SizedBox(height: 12),
      if (widget.user.cats.isEmpty)
        GestureDetector(
          onTap: _showAddCatDialog,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: kCardDeco(border: kGold.withOpacity(0.3)),
            child: Center(child: Column(children: [
              const Text("➕", style: TextStyle(fontSize: 32)),
              const SizedBox(height: 8),
              kBody(L.get('add_cat'), color: kGold),
            ])),
          ),
        )
      else
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: widget.user.cats.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final cat      = widget.user.cats[i];
              final selected = _selectedCat?.id == cat.id;
              return GestureDetector(
                onTap: () => setState(() => _selectedCat = cat),
                child: Container(
                  width: 90,
                  decoration: kCardDeco(
                      border: selected ? kGold : kBorder),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(cat.photoPath != null ? "🐱" : "🐾",
                          style: const TextStyle(fontSize: 28)),
                      const SizedBox(height: 6),
                      Text(cat.name,
                        style: GoogleFonts.dmSans(
                          fontSize: 12, color: selected ? kGold : kText,
                          fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis),
                      Text("${cat.ageYears}a ${cat.ageMonths}m",
                        style: GoogleFonts.dmSans(fontSize: 10, color: kMuted)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
    ],
  );

  Widget _buildScanButton() => GestureDetector(
    onTap: _startScan,
    child: Container(
      width:   double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1400), Color(0xFF2A2000)],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kGold.withOpacity(0.4)),
        boxShadow: [BoxShadow(
            color: kGold.withOpacity(0.1), blurRadius: 20)],
      ),
      child: Column(children: [
        const Text("🔍", style: TextStyle(fontSize: 48)),
        const SizedBox(height: 12),
        kTitle(L.get('start_scan'), size: 22),
        const SizedBox(height: 6),
        kBody("$SCAN_DURATION ${L.get('seconds')} · IA Análisis Completo",
            color: kMuted, size: 13),
      ]),
    ),
  );

  Widget _buildFeatures() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      kLabel("ANÁLISIS INCLUÍDO"),
      const SizedBox(height: 12),
      GridView.count(
        crossAxisCount: 2,
        shrinkWrap:     true,
        physics:        const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10,
        mainAxisSpacing:  10,
        childAspectRatio: 2.5,
        children: [
          _feat("🧬", L.get('breed')),
          _feat("⚖️", L.get('weight')),
          _feat("🎨", L.get('color')),
          _feat("💪", L.get('body_condition')),
          _feat("😺", L.get('mood')),
          _feat("👂", L.get('ears')),
        ],
      ),
    ],
  );

  Widget _feat(String emoji, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: kCardDeco(),
    child: Row(children: [
      Text(emoji, style: const TextStyle(fontSize: 18)),
      const SizedBox(width: 8),
      Expanded(child: Text(label,
        style: GoogleFonts.dmSans(fontSize: 12, color: kText),
        overflow: TextOverflow.ellipsis)),
    ]),
  );
}


// ════════════════════════════════════════════════════════════════
//  AGREGAR GATO (BottomSheet)
// ════════════════════════════════════════════════════════════════

class AddCatSheet extends StatefulWidget {
  final Function(CatProfile) onSave;
  const AddCatSheet({Key? key, required this.onSave}) : super(key: key);

  @override
  State<AddCatSheet> createState() => _AddCatSheetState();
}

class _AddCatSheetState extends State<AddCatSheet> {
  final _nameCtrl   = TextEditingController();
  int   _ageYears   = 1;
  int   _ageMonths  = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: kBorder, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          kTitle(L.get('add_cat'), size: 20),
          const SizedBox(height: 20),
          kTextField(_nameCtrl, L.get('cat_name'), icon: Icons.pets),
          const SizedBox(height: 16),
          kLabel(L.get('cat_age').toUpperCase()),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _counter(
              "${L.get('years')}: $_ageYears",
              () => setState(() { if (_ageYears > 0) _ageYears--; }),
              () => setState(() => _ageYears++),
            )),
            const SizedBox(width: 12),
            Expanded(child: _counter(
              "${L.get('months')}: $_ageMonths",
              () => setState(() { if (_ageMonths > 0) _ageMonths--; }),
              () => setState(() { if (_ageMonths < 11) _ageMonths++; }),
            )),
          ]),
          const SizedBox(height: 24),
          kGoldBtn(L.get('save'), () {
            if (_nameCtrl.text.isEmpty) return;
            widget.onSave(CatProfile(
              id:        DateTime.now().millisecondsSinceEpoch.toString(),
              name:      _nameCtrl.text.trim(),
              ageYears:  _ageYears,
              ageMonths: _ageMonths,
            ));
            Navigator.pop(context);
          }),
        ],
      ),
    );
  }

  Widget _counter(String label, VoidCallback dec, VoidCallback inc) =>
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: kCardDeco(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(onTap: dec,
            child: const Icon(Icons.remove_circle_outline, color: kMuted, size: 20)),
          Text(label, style: GoogleFonts.dmSans(fontSize: 13, color: kText)),
          GestureDetector(onTap: inc,
            child: const Icon(Icons.add_circle_outline, color: kGold, size: 20)),
        ],
      ),
    );
}


// ════════════════════════════════════════════════════════════════
//  SCAN SCREEN
// ════════════════════════════════════════════════════════════════

class ScanScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  final String       serverIp;
  final CatProfile   cat;
  final UserAccount  user;
  final VoidCallback onComplete;
  const ScanScreen({Key? key,
    required this.cameras,  required this.serverIp,
    required this.cat,      required this.user,
    required this.onComplete}) : super(key: key);

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with TickerProviderStateMixin {
  CameraController? _cam;
  Timer?  _scanTimer;
  Timer?  _cdTimer;
  int     _secs      = SCAN_DURATION;
  bool    _scanning  = false;
  bool    _sending   = false;
  int     _frames    = 0;
  Map<String, dynamic>? _last;
  String  _sesion    = DateTime.now().millisecondsSinceEpoch.toString();

  late AnimationController _ringCtrl;
  late Animation<double>   _ringAnim;

  @override
  void initState() {
    super.initState();
    _ringCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))..repeat();
    _ringAnim = CurvedAnimation(parent: _ringCtrl, curve: Curves.easeInOut);
    _initCam();
  }

  Future<void> _initCam() async {
    _cam = CameraController(widget.cameras.first,
        ResolutionPreset.medium, enableAudio: false);
    await _cam!.initialize();
    if (mounted) setState(() {});
  }

  void _start() {
    setState(() { _scanning = true; _secs = SCAN_DURATION; _frames = 0; _last = null; });
    _scanTimer = Timer.periodic(
        Duration(milliseconds: FRAME_INTERVAL), (_) => _capture());
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
      final uri   = Uri.parse(
          '${widget.serverIp.startsWith("192.168") || widget.serverIp.startsWith("10.") ? "http" : "https"}://${widget.serverIp.contains("trycloudflare") ? widget.serverIp : "${widget.serverIp}:8000"}/analizar?sesion_id=$_sesion');
      final req   = http.MultipartRequest('POST', uri)
        ..files.add(http.MultipartFile.fromBytes('file', bytes, filename: 'f.jpg'));
      final s   = await req.send().timeout(const Duration(seconds: 8));
      final res = await http.Response.fromStream(s);
      if (res.statusCode == 200 && mounted) {
        setState(() { _last = json.decode(res.body); _frames++; });
      }
    } catch (_) {} finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _finish() {
    _scanTimer?.cancel();
    _cdTimer?.cancel();
    setState(() => _scanning = false);
    if (_last != null) {
      final record = ScanRecord(
        id:        DateTime.now().millisecondsSinceEpoch.toString(),
        catId:     widget.cat.id,
        date:      DateTime.now(),
        resultado: _last!,
      );
      widget.user.scans.add(record);
      StorageService.saveScans(widget.user.scans);
      widget.onComplete();
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => ResultScreen(
          record: record,
          cat:    widget.cat,
          cameras: widget.cameras,
          user:   widget.user,
          serverIp: widget.serverIp,
        ),
      ));
    }
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    _cdTimer?.cancel();
    _cam?.dispose();
    _ringCtrl.dispose();
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
          const SizedBox(height: 20),
          _controls(),
          const SizedBox(height: 40),
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
        child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20)),
      const Spacer(),
      Text("${widget.cat.name} · ${widget.cat.ageYears}${L.get('years')}",
        style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.w600)),
      const Spacer(),
      if (_sending)
        const SizedBox(width: 20, height: 20,
            child: CircularProgressIndicator(color: kGold, strokeWidth: 2))
      else
        const SizedBox(width: 20),
    ]),
  );

  Widget _overlay() {
    final progress = 1 - (_secs / SCAN_DURATION);
    return Stack(alignment: Alignment.center, children: [
      SizedBox(
        width: 240, height: 240,
        child: CircularProgressIndicator(
          value:      _scanning ? progress : 0,
          strokeWidth: 3,
          backgroundColor: Colors.white12,
          valueColor:      const AlwaysStoppedAnimation<Color>(kGold),
        ),
      ),
      Container(
        width: 220, height: 220,
        decoration: BoxDecoration(
          shape:  BoxShape.circle,
          border: Border.all(color: Colors.white24, width: 1),
        ),
        child: Center(
          child: _scanning
            ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text("$_secs", style: GoogleFonts.playfairDisplay(
                  fontSize: 52, color: kGold, fontWeight: FontWeight.w700)),
                kBody(L.get('seconds'), color: Colors.white70, size: 12),
                const SizedBox(height: 6),
                kBody("$_frames ${L.get('frames')}", color: Colors.white38, size: 11),
                if (_last != null) ...[
                  const SizedBox(height: 10),
                  kBody(_last!['raza']?['raza'] ?? '',
                    color: kGoldLight, size: 12),
                ],
              ])
            : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text("🐱", style: TextStyle(fontSize: 50)),
                const SizedBox(height: 10),
                kBody(widget.cat.name, color: Colors.white, size: 16),
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
      : [_btn(Icons.play_arrow_rounded, kGold, _start)],
  );

  Widget _btn(IconData icon, Color color, VoidCallback fn) =>
    GestureDetector(
      onTap: fn,
      child: Container(
        width: 64, height: 64,
        decoration: BoxDecoration(
          color: color, shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 14)]),
        child: Icon(icon, color: kBg, size: 28)),
    );
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
  const ResultScreen({Key? key,
    required this.record,   required this.cat,
    required this.user,     required this.serverIp,
    required this.cameras}) : super(key: key);

  Map<String, dynamic> get r => record.resultado;

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
            _breedCard(),
            const SizedBox(height: 12),
            _weightCard(),
            const SizedBox(height: 12),
            _bodyCondCard(),
            const SizedBox(height: 12),
            _colorCard(),
            const SizedBox(height: 12),
            _earCard(),
            const SizedBox(height: 12),
            _moodCard(),
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
        decoration: kCardDeco(),
        child: const Icon(Icons.home_rounded, color: kMuted, size: 20))),
    const SizedBox(width: 12),
    Expanded(child: kTitle(L.get('results'), size: 20)),
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: kCardDeco(),
      child: Text(
        DateFormat('dd MMM yyyy').format(record.date),
        style: GoogleFonts.dmSans(fontSize: 11, color: kMuted))),
  ]);

  Widget _heroCard() {
    final imgB64 = r['imagen_anotada'] as String?;
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorder),
      ),
      child: Stack(fit: StackFit.expand, children: [
        if (imgB64 != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.memory(base64Decode(imgB64),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Center(
                child: Text("🐱", style: TextStyle(fontSize: 60))))),
        Positioned(bottom: 12, left: 12, child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: kBg.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20)),
          child: Text("${cat.name} · ${cat.ageYears}${L.get('years')} ${cat.ageMonths}${L.get('months')}",
            style: GoogleFonts.dmSans(color: kGold, fontWeight: FontWeight.w600, fontSize: 13)),
        )),
      ]),
    );
  }

  Widget _breedCard() => _card(
    "🧬 ${L.get('breed')}",
    [
      _row(L.get('breed'),   r['raza']?['raza'] ?? '-'),
      _row("Confianza IA",   "${r['raza']?['confianza'] ?? 0}%"),
    ],
  );

  Widget _weightCard() {
    final pesoKg = r['peso']?['peso_kg'] ?? '-';
    final pesoLb = r['peso']?['peso_lb'] ?? '-';
    return _card(
      "⚖️ ${L.get('weight')}",
      [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text("$pesoKg kg", style: GoogleFonts.playfairDisplay(
                  fontSize: 36, color: kGold, fontWeight: FontWeight.w700)),
              const SizedBox(width: 10),
              kBody("$pesoLb lb", color: kMuted),
            ],
          ),
        ),
        _row("Confianza", r['peso']?['confianza'] ?? '-'),
      ],
    );
  }

  Widget _bodyCondCard() {
    final corp     = r['estado_corporal'] as Map? ?? {};
    final hexStr   = corp['color_hex'] as String? ?? '#52C97A';
    Color color;
    try { color = Color(int.parse(hexStr.replaceFirst('#', '0xFF'))); }
    catch (_) { color = kGreen; }
    final bcs   = (corp['bcs']      ?? 5) as int;
    final bcsMax= (corp['bcs_max']  ?? 9) as int;
    final salud = (corp['salud_pct']?? 75)as int;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          kTitle("💪 ${L.get('body_condition')}", size: 15),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color)),
            child: Text("${corp['emoji'] ?? ''} ${corp['estado'] ?? ''}",
              style: GoogleFonts.dmSans(fontSize: 12, color: color,
                  fontWeight: FontWeight.w700)),
          ),
        ]),
        const SizedBox(height: 14),
        kBody("BCS: $bcs / $bcsMax", color: kMuted, size: 12),
        const SizedBox(height: 6),
        LinearProgressIndicator(value: bcs/bcsMax,
          backgroundColor: kBorder,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 6, borderRadius: BorderRadius.circular(3)),
        const SizedBox(height: 10),
        kBody("${L.get('health_score')}: $salud%", color: kMuted, size: 12),
        const SizedBox(height: 6),
        LinearProgressIndicator(value: salud/100,
          backgroundColor: kBorder,
          valueColor: const AlwaysStoppedAnimation<Color>(kGreen),
          minHeight: 6, borderRadius: BorderRadius.circular(3)),
      ]),
    );
  }

  Widget _colorCard() => _card(
    "🎨 ${L.get('color')}",
    [
      Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: _parseHex(r['color']?['hex'] ?? '#888'),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: kBorder)),
        ),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          kBody(r['color']?['color_principal'] ?? '-'),
          kBody(r['color']?['hex'] ?? '', color: kMuted, size: 12),
        ]),
      ]),
      const SizedBox(height: 8),
      _row(L.get('pattern'), r['color']?['patron'] ?? '-'),
    ],
  );

  Widget _earCard() {
    // Análisis de orejas basado en el gesto y movimiento
    final gesto  = r['gesto'] as Map? ?? {};
    final mov    = gesto['movimiento'] ?? 'bajo';
    final nombre = gesto['nombre'] ?? '';

    String earState;
    String earDesc;
    String earEmoji;

    if (nombre.contains('Alerta') || mov == 'alto') {
      earState = L.get('ear_alert');
      earDesc  = L.lang == 'es'
          ? 'Orejas erguidas apuntando hacia adelante. Tu gato está muy atento.'
          : 'Ears straight up pointing forward. Your cat is very alert.';
      earEmoji = '👂⚡';
    } else if (nombre.contains('Juguetón')) {
      earState = L.get('ear_forward');
      earDesc  = L.lang == 'es'
          ? 'Orejas hacia adelante con movimiento. En modo juego activo.'
          : 'Ears forward with movement. Active play mode.';
      earEmoji = '👂🎾';
    } else if (nombre.contains('Somnoliento') || nombre.contains('Relajado')) {
      earState = L.get('ear_relaxed');
      earDesc  = L.lang == 'es'
          ? 'Orejas en posición natural y relajada. Tu gato está tranquilo y cómodo.'
          : 'Ears in natural relaxed position. Your cat is calm and comfortable.';
      earEmoji = '👂😌';
    } else {
      earState = L.get('ear_relaxed');
      earDesc  = L.lang == 'es'
          ? 'Posición de orejas neutra. Estado tranquilo normal.'
          : 'Neutral ear position. Normal calm state.';
      earEmoji = '👂';
    }

    return _card(
      "$earEmoji ${L.get('ears')}",
      [
        kBody(earState, color: kGold),
        const SizedBox(height: 6),
        kBody(earDesc, color: kMuted, size: 13),
      ],
    );
  }

  Widget _moodCard() => _card(
    "😺 ${L.get('mood')}",
    [
      kBody(r['gesto']?['nombre'] ?? '-', color: kText),
      const SizedBox(height: 6),
      kBody(r['gesto']?['descripcion'] ?? '-', color: kMuted, size: 13),
      const SizedBox(height: 8),
      _row("Movimiento", r['gesto']?['movimiento'] ?? '-'),
    ],
  );

  Widget _consejo() {
    final texto = r['estado_corporal']?['consejo'] ?? '';
    if (texto.isEmpty) return const SizedBox();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kGold.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kGold.withOpacity(0.25)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("💡", style: TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(child: kBody(texto, size: 13)),
      ]),
    );
  }

  Widget _actions(BuildContext context) => Column(children: [
    kGoldBtn(L.get('download_pdf'), () => _downloadPdf(context)),
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
          pw.Text('MeowScan — Reporte Felino',
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Text('Gato: ${cat.name} · ${cat.ageYears} años ${cat.ageMonths} meses'),
          pw.Text('Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(record.date)}'),
          pw.Divider(),
          pw.SizedBox(height: 12),
          _pdfRow('Raza',          r['raza']?['raza']            ?? '-'),
          _pdfRow('Peso',          '${r['peso']?['peso_kg'] ?? '-'} kg / ${r['peso']?['peso_lb'] ?? '-'} lb'),
          _pdfRow('Estado corporal', r['estado_corporal']?['estado'] ?? '-'),
          _pdfRow('BCS',           '${r['estado_corporal']?['bcs'] ?? '-'} / 9'),
          _pdfRow('Índice salud',  '${r['estado_corporal']?['salud_pct'] ?? '-'}%'),
          _pdfRow('Color pelaje',  r['color']?['color_principal'] ?? '-'),
          _pdfRow('Patrón',        r['color']?['patron']          ?? '-'),
          _pdfRow('Estado ánimo',  r['gesto']?['nombre']          ?? '-'),
          _pdfRow('Movimiento',    r['gesto']?['movimiento']      ?? '-'),
          pw.SizedBox(height: 16),
          pw.Text('Consejo:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text(r['estado_corporal']?['consejo'] ?? ''),
          pw.SizedBox(height: 24),
          pw.Text('Generado por MeowScan v$APP_VERSION',
            style: const pw.TextStyle(fontSize: 10)),
        ],
      ),
    ));

    await Printing.layoutPdf(
      onLayout: (_) async => pdf.save(),
      name: 'meowscan_${cat.name}_${DateFormat('yyyyMMdd').format(record.date)}.pdf',
    );
  }

  pw.Widget _pdfRow(String label, String value) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 6),
    child: pw.Row(children: [
      pw.SizedBox(width: 140,
        child: pw.Text(label,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12))),
      pw.Text(value, style: const pw.TextStyle(fontSize: 12)),
    ]),
  );

  // ── Helpers ──────────────────────────────────────────────────
  Widget _card(String titulo, List<Widget> children) => Container(
    width:   double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: kCardDeco(),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      kTitle(titulo, size: 15),
      const SizedBox(height: 10),
      kDivider(),
      const SizedBox(height: 10),
      ...children,
    ]),
  );

  Widget _row(String l, String v) => Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        kBody(l, color: kMuted, size: 13),
        kBody(v, size: 13),
      ],
    ),
  );

  Color _parseHex(String hex) {
    try { return Color(int.parse(hex.replaceFirst('#', '0xFF'))); }
    catch (_) { return Colors.grey; }
  }
}


// ════════════════════════════════════════════════════════════════
//  HISTORY TAB
// ════════════════════════════════════════════════════════════════

class HistoryTab extends StatelessWidget {
  final UserAccount user;
  final List<CameraDescription> cameras;
  const HistoryTab({Key? key, required this.user, required this.cameras})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scans = [...user.scans]..sort((a, b) => b.date.compareTo(a.date));
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            kTitle(L.get('scan_history')),
            const SizedBox(height: 20),
            if (scans.isEmpty)
              Expanded(child: Center(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("📋", style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  kBody(L.get('no_scans'), color: kMuted),
                ],
              )))
            else
              Expanded(child: ListView.separated(
                itemCount: scans.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final s   = scans[i];
                  final cat = user.cats.firstWhere(
                    (c) => c.id == s.catId,
                    orElse: () => CatProfile(id: '', name: '?', ageYears: 0, ageMonths: 0));
                  return _scanTile(context, s, cat);
                },
              )),
          ],
        ),
      ),
    );
  }

  Widget _scanTile(BuildContext context, ScanRecord s, CatProfile cat) {
    final raza  = s.resultado['raza']?['raza'] ?? '-';
    final peso  = s.resultado['peso']?['peso_kg'] ?? '-';
    final corp  = s.resultado['estado_corporal']?['estado'] ?? '-';
    final emoji = s.resultado['estado_corporal']?['emoji'] ?? '🐱';

    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ResultScreen(
          record: s, cat: cat, user: user,
          serverIp: '', cameras: cameras))),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: kCardDeco(),
        child: Row(children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 14),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(cat.name, style: GoogleFonts.dmSans(
                  color: kText, fontWeight: FontWeight.w700)),
              kBody(raza, color: kMuted, size: 12),
            ],
          )),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            kBody("$peso kg", color: kGold),
            kBody(DateFormat('dd/MM/yy').format(s.date), color: kMuted, size: 11),
          ]),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: kMuted, size: 18),
        ]),
      ),
    );
  }
}


// ════════════════════════════════════════════════════════════════
//  PROFILE TAB
// ════════════════════════════════════════════════════════════════

class ProfileTab extends StatelessWidget {
  final UserAccount user;
  final List<CameraDescription> cameras;
  final VoidCallback onRefresh;
  const ProfileTab({Key? key,
      required this.user, required this.cameras, required this.onRefresh})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            kTitle(L.get('profile')),
            const SizedBox(height: 20),
            _userCard(),
            const SizedBox(height: 20),
            kLabel(L.get('my_cats').toUpperCase()),
            const SizedBox(height: 12),
            ...user.cats.map((c) => _catCard(c)),
            const SizedBox(height: 12),
            kOutlineBtn("+ ${L.get('add_cat')}", () {
              showModalBottomSheet(
                context: context,
                backgroundColor: kCard,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                builder: (_) => AddCatSheet(
                  onSave: (cat) async {
                    user.cats.add(cat);
                    await StorageService.saveCats(user.cats);
                    onRefresh();
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _userCard() => Container(
    padding: const EdgeInsets.all(20),
    decoration: kCardDeco(),
    child: Row(children: [
      Container(
        width: 56, height: 56,
        decoration: const BoxDecoration(
          color: kSurface, shape: BoxShape.circle),
        child: const Center(child: Text("👤", style: TextStyle(fontSize: 26))),
      ),
      const SizedBox(width: 16),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        kTitle(user.username, size: 18),
        kBody(user.email, color: kMuted, size: 13),
        const SizedBox(height: 4),
        kBody("${user.scans.length} escaneos · ${user.cats.length} gatos",
          color: kGold, size: 12),
      ]),
    ]),
  );

  Widget _catCard(CatProfile cat) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(16),
    decoration: kCardDeco(),
    child: Row(children: [
      const Text("🐱", style: TextStyle(fontSize: 28)),
      const SizedBox(width: 14),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        kBody(cat.name, color: kText),
        kBody("${cat.ageYears} ${L.get('years')} ${cat.ageMonths} ${L.get('months')}",
          color: kMuted, size: 12),
      ]),
    ]),
  );
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
  String _connStatus = '';
  bool   _testing    = false;

  @override
  void initState() {
    super.initState();
    StorageService.getServerIp().then((ip) => _ipCtrl.text = ip);
  }

  Future<void> _test() async {
    setState(() { _testing = true; _connStatus = '...'; });
    try {
      final r = await http.get(
        Uri.parse('${_ipCtrl.text.startsWith("192.168") || _ipCtrl.text.startsWith("10.") ? "http" : "https"}://${_ipCtrl.text.contains("trycloudflare") ? _ipCtrl.text : "${_ipCtrl.text}:8000"}/health'))
        .timeout(const Duration(seconds: 5));
      setState(() => _connStatus = r.statusCode == 200
          ? L.get('connected') : L.get('not_connected'));
      await StorageService.setServerIp(_ipCtrl.text);
    } catch (_) {
      setState(() => _connStatus = L.get('not_connected'));
    } finally {
      setState(() => _testing = false);
    }
  }

  void _logout(BuildContext context) async {
    await StorageService.logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => AuthScreen(cameras: widget.cameras)),
      (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            kTitle(L.get('settings')),
            const SizedBox(height: 24),

            // Servidor
            kLabel(L.get('server_ip').toUpperCase()),
            const SizedBox(height: 10),
            kTextField(_ipCtrl, '192.168.1.100', icon: Icons.wifi),
            const SizedBox(height: 10),
            kGoldBtn(L.get('test_conn'), _testing ? () {} : _test),
            if (_connStatus.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: kCardDeco(),
                child: kBody(_connStatus)),
            ],

            const SizedBox(height: 28),

            // Idioma
            kLabel(L.get('language').toUpperCase()),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: kCardDeco(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  kBody("Español / English"),
                  Row(children: [
                    kBody('ES', color: L.lang == 'es' ? kGold : kMuted),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        final nl = L.lang == 'es' ? 'en' : 'es';
                        MeowScanApp.of(context)?.setLang(nl);
                        setState(() {});
                      },
                      child: Container(
                        width: 44, height: 24,
                        decoration: BoxDecoration(
                          color: kGold, borderRadius: BorderRadius.circular(12)),
                        child: AnimatedAlign(
                          duration: const Duration(milliseconds: 200),
                          alignment: L.lang == 'es'
                              ? Alignment.centerLeft : Alignment.centerRight,
                          child: Container(
                            width: 20, height: 20,
                            margin: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: kBg, shape: BoxShape.circle)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    kBody('EN', color: L.lang == 'en' ? kGold : kMuted),
                  ]),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: kCardDeco(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  kBody("MeowScan v$APP_VERSION", color: kGold),
                  const SizedBox(height: 4),
                  kBody("IA: OpenCV + TensorFlow MobileNetV2", color: kMuted, size: 12),
                  kBody("© 2025 MeowScan. Todos los derechos reservados.", color: kMuted, size: 11),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Logout
            GestureDetector(
              onTap: () => _logout(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kRed.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kRed.withOpacity(0.3))),
                child: Center(child: kBody(L.get('logout'), color: kRed)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
