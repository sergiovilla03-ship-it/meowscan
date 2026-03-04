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

import 'package:camera/camera.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ════════════════════════════════════════════════════════════════
//  PALETA DE COLORES — Claro, vibrante y jovial
// ════════════════════════════════════════════════════════════════

const Color kBg        = Color(0xFFFFF9F0);   // Crema cálido
const Color kSurface   = Color(0xFFFFFFFF);   // Blanco puro
const Color kCard      = Color(0xFFFFFFFF);   // Blanco
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
      'tagline':       '¡Analiza a tu gatito con IA! 🐾',
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
      'profile':       'Mis gatitos',
      'settings':      'Ajustes',
      'server_ip':     'Servidor',
      'test_conn':     'Probar conexión',
      'connected':     '✅ ¡Conectado!',
      'not_connected': '❌ Sin conexión',
      'language':      'Idioma',
      'logout':        'Cerrar sesión',
      'save':          'Guardar',
      'cancel':        'Cancelar',
      'add_cat':       '+ Agregar gatito',
      'my_cats':       'Mis gatitos',
      'scan_history':  'Historial',
      'no_scans':      'Aún no hay escaneos 😿',
      'no_cats':       'Aún no tienes gatitos 🐱',
      'tip':           '💡 Consejo',
      'welcome':       '¡Hola',
      'select_cat':    'Selecciona tu gatito',
      'seconds':       'seg',
      'frames':        'fotos',
      'delete_cat':    'Borrar gatito',
      'delete_scan':   'Borrar escaneo',
      'delete_confirm':'¿Estás seguro?',
      'delete_cat_msg':'Se borrarán el gatito y todos sus escaneos.',
      'delete_scan_msg':'Se borrará este escaneo.',
      'delete':        'Borrar',
      'cancel_delete': 'Cancelar',
    },
    'en': {
      'app_name':      'MeowScan',
      'tagline':       'Analyze your kitty with AI! 🐾',
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
      'profile':       'My cats',
      'settings':      'Settings',
      'server_ip':     'Server',
      'test_conn':     'Test connection',
      'connected':     '✅ Connected!',
      'not_connected': '❌ Not connected',
      'language':      'Language',
      'logout':        'Log out',
      'save':          'Save',
      'cancel':        'Cancel',
      'add_cat':       '+ Add cat',
      'my_cats':       'My cats',
      'scan_history':  'History',
      'no_scans':      'No scans yet 😿',
      'no_cats':       'No cats yet 🐱',
      'tip':           '💡 Tip',
      'welcome':       'Hello',
      'select_cat':    'Select your cat',
      'seconds':       'sec',
      'frames':        'photos',
      'delete_cat':    'Delete cat',
      'delete_scan':   'Delete scan',
      'delete_confirm':'Are you sure?',
      'delete_cat_msg':'This will delete the cat and all its scans.',
      'delete_scan_msg':'This scan will be deleted.',
      'delete':        'Delete',
      'cancel_delete': 'Cancel',
    },
  };

  static String get(String key) =>
      _t[_lang]?[key] ?? _t['es']?[key] ?? key;
}

// ════════════════════════════════════════════════════════════════
//  MODELOS
// ════════════════════════════════════════════════════════════════

class CatProfile {
  String id, name;
  int ageYears, ageMonths;
  String? photoPath;
  CatProfile({required this.id, required this.name,
      required this.ageYears, required this.ageMonths, this.photoPath});
  Map<String, dynamic> toJson() => {'id': id, 'name': name,
      'ageYears': ageYears, 'ageMonths': ageMonths, 'photoPath': photoPath};
  factory CatProfile.fromJson(Map<String, dynamic> j) => CatProfile(
      id: j['id'], name: j['name'],
      ageYears: j['ageYears'] ?? 0, ageMonths: j['ageMonths'] ?? 0,
      photoPath: j['photoPath']);
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

class UserAccount {
  String email, username, passwordHash;
  List<CatProfile> cats;
  List<ScanRecord>  scans;
  UserAccount({required this.email, required this.username,
      required this.passwordHash, List<CatProfile>? cats, List<ScanRecord>? scans})
      : cats = cats ?? [], scans = scans ?? [];
}

// ════════════════════════════════════════════════════════════════
//  STORAGE
// ════════════════════════════════════════════════════════════════

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

Widget kBody(String t, {double size = 14, Color color = kText}) =>
  Text(t, style: _nunito(size, color));

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
  GestureDetector(
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  final lang    = await StorageService.getLang();
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
  @override
  void initState() { super.initState(); currentUser = widget.initialUser; }
  void setLang(String lang) { StorageService.setLang(lang); setState(() {}); }
  void setUser(UserAccount? u) => setState(() => currentUser = u);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title:                    'MeowScan',
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

  @override
  void initState() { super.initState(); _tab = TabController(length: 2, vsync: this); }
  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  void _login() async {
    final user = await StorageService.loadUser();
    if (user == null || user.email != _emailCtrl.text.trim() ||
        user.passwordHash != _passCtrl.text) {
      setState(() => _error = L.lang == 'es'
          ? 'Correo o contraseña incorrectos 😿'
          : 'Wrong email or password 😿');
      return;
    }
    MeowScanApp.of(context)?.setUser(user);
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => MainShell(cameras: widget.cameras, user: user)));
  }

  void _register() async {
    if (_emailCtrl.text.isEmpty || _passCtrl.text.isEmpty || _userCtrl.text.isEmpty) {
      setState(() => _error = L.lang == 'es'
          ? 'Completa todos los campos 😅'
          : 'Fill all fields 😅');
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
          child: Column(children: [
            const SizedBox(height: 30),
            // Logo animado
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [kCoral, kPurple],
                  begin: Alignment.topLeft, end: Alignment.bottomRight),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(
                  color: kCoral.withOpacity(0.3),
                  blurRadius: 20, offset: const Offset(0, 8))],
              ),
              child: const Center(child: Text("🐱", style: TextStyle(fontSize: 48))),
            ),
            const SizedBox(height: 20),
            kTitle(L.get('app_name'), size: 36, color: kCoral),
            const SizedBox(height: 6),
            kBody(L.get('tagline'), color: kMuted, size: 15),
            const SizedBox(height: 36),

            // Tabs
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
            const SizedBox(height: 28),

            SizedBox(
              height: 280,
              child: TabBarView(controller: _tab, children: [
                _loginForm(),
                _registerForm(),
              ]),
            ),

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

            const SizedBox(height: 32),
            // Idioma
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _langBtn('ES'),
              const SizedBox(width: 8),
              _langBtn('EN'),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _loginForm() => Column(children: [
    kTextField(_emailCtrl, L.get('email'), icon: Icons.email_rounded),
    const SizedBox(height: 14),
    kTextField(_passCtrl,  L.get('password'), icon: Icons.lock_rounded, obscure: true),
    const SizedBox(height: 24),
    kGradBtn(L.get('login'), _login),
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
    if (u != null && mounted) setState(() => _user = u);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeTab(cameras: widget.cameras, user: _user, onRefresh: _refresh),
      HistoryTab(user: _user, cameras: widget.cameras, onRefresh: _refresh),
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
    final items = [
      ['🏠', L.get('start_scan').split('!').first],
      ['📋', L.get('history')],
      ['🐱', L.get('my_cats')],
      ['⚙️', L.get('settings')],
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
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(4, (i) => GestureDetector(
              onTap: () => setState(() => _tab = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _tab == i ? kCoral.withOpacity(0.12) : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(items[i][0], style: TextStyle(
                    fontSize: _tab == i ? 22 : 20)),
                  const SizedBox(height: 2),
                  Text(items[i][1],
                    style: _nunito(10,
                        _tab == i ? kCoral : kMuted,
                        weight: _tab == i ? FontWeight.w800 : FontWeight.w600)),
                ]),
              ),
            )),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  HOME TAB
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
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ScanScreen(
        cameras: widget.cameras, serverIp: ip,
        cat: _selected!, user: widget.user, onComplete: widget.onRefresh)));
  }

  void _addCat() {
    showModalBottomSheet(
      context: context,
      backgroundColor: kSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => AddCatSheet(onSave: (cat) async {
        widget.user.cats.add(cat);
        await StorageService.saveCats(widget.user.cats);
        widget.onRefresh();
        setState(() => _selected = cat);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _header(),
          const SizedBox(height: 24),
          _scanCard(),
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
      kTitle("¡Hora de escanear! 🐾", size: 22, color: kText),
    ])),
    Container(
      width: 48, height: 48,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [kCoral, kPurple]),
        shape: BoxShape.circle),
      child: const Center(child: Text("🐱", style: TextStyle(fontSize: 22))),
    ),
  ]);

  Widget _scanCard() => GestureDetector(
    onTap: _scan,
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
        const Text("🔍", style: TextStyle(fontSize: 56)),
        const SizedBox(height: 14),
        Text(L.get('start_scan'),
          style: _nunito(22, Colors.white, weight: FontWeight.w900)),
        const SizedBox(height: 6),
        Text("$SCAN_DURATION ${L.get('seconds')} · Análisis completo con IA",
          style: _nunito(13, Colors.white70)),
      ]),
    ),
  );

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
                      Text("🐱", style: TextStyle(fontSize: sel ? 32 : 28)),
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
      kLabel("¿Qué analiza MeowScan?"),
      const SizedBox(height: 12),
      Wrap(spacing: 8, runSpacing: 8, children: [
        _chip("🧬 Raza",           kPurple),
        _chip("⚖️ Peso",           kTurquoise),
        _chip("🎨 Color",          kYellow),
        _chip("💪 Estado corporal", kCoral),
        _chip("😺 Mood",           kGreen),
        _chip("👂 Orejas",         kBlue),
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
  int _ageYears    = 1;
  int _ageMonths   = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
          const Text("🐱", style: TextStyle(fontSize: 28)),
          const SizedBox(width: 10),
          kTitle(L.get('add_cat'), size: 20, color: kCoral),
        ]),
        const SizedBox(height: 20),
        kTextField(_nameCtrl, L.get('cat_name'),
            icon: Icons.pets_rounded, accent: kCoral),
        const SizedBox(height: 16),
        kLabel(L.get('cat_age')),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: _counter(
            "${L.get('years')}: $_ageYears",
            () => setState(() { if (_ageYears > 0) _ageYears--; }),
            () => setState(() => _ageYears++),
            kCoral)),
          const SizedBox(width: 12),
          Expanded(child: _counter(
            "${L.get('months')}: $_ageMonths",
            () => setState(() { if (_ageMonths > 0) _ageMonths--; }),
            () => setState(() { if (_ageMonths < 11) _ageMonths++; }),
            kTurquoise)),
        ]),
        const SizedBox(height: 24),
        kGradBtn(L.get('save'), () {
          if (_nameCtrl.text.isEmpty) return;
          widget.onSave(CatProfile(
            id:        DateTime.now().millisecondsSinceEpoch.toString(),
            name:      _nameCtrl.text.trim(),
            ageYears:  _ageYears,
            ageMonths: _ageMonths,
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
        ..files.add(http.MultipartFile.fromBytes('file', bytes, filename: 'f.jpg'));
      final s   = await req.send().timeout(const Duration(seconds: 10));
      final res = await http.Response.fromStream(s);
      if (res.statusCode == 200 && mounted)
        setState(() { _last = json.decode(res.body); _frames++; });
    } catch (_) {} finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _finish() {
    _scanTimer?.cancel(); _cdTimer?.cancel();
    setState(() => _scanning = false);
    if (_last != null) {
      final record = ScanRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        catId: widget.cat.id, date: DateTime.now(), resultado: _last!);
      widget.user.scans.add(record);
      StorageService.saveScans(widget.user.scans);
      widget.onComplete();
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => ResultScreen(
          record: record, cat: widget.cat,
          user: widget.user, serverIp: widget.serverIp,
          cameras: widget.cameras)));
    }
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
            _infoCard("🧬 ${L.get('breed')}", kPurple, [
              _row(L.get('breed'),    r['raza']?['raza']       ?? '-', kPurple),
              _row("Confianza IA",    "${r['raza']?['confianza'] ?? 0}%", kPurple),
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
              "${cat.name} · ${cat.ageYears}${L.get('years')} ${cat.ageMonths}${L.get('months')}",
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
        if (rango.isNotEmpty) kBody("Rango: $rango", color: kMuted, size: 12),
        const SizedBox(height: 6),
        _row("Confianza", r['peso']?['confianza'] ?? '-', kTurquoise),
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
      _row("Estado", estado, kBlue),
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
      kBody("Nivel de estrés: $estres/10", color: kMuted, size: 12),
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
        _row("Cola", cola.toString(), kPurple),
      ],
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
          pw.Text('MeowScan — Reporte Felino',
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Text('Gato: ${cat.name} · ${cat.ageYears} años ${cat.ageMonths} meses'),
          pw.Text('Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(record.date)}'),
          pw.Divider(),
          pw.SizedBox(height: 12),
          _pdfRow('Raza',           r['raza']?['raza']              ?? '-'),
          _pdfRow('Confianza IA',   '${r['raza']?['confianza'] ?? 0}%'),
          _pdfRow('Peso',           '${r['peso']?['peso_kg'] ?? '-'} kg / ${r['peso']?['peso_lb'] ?? '-'} lb'),
          _pdfRow('Estado corporal',r['estado_corporal']?['estado']  ?? '-'),
          _pdfRow('BCS',            '${r['estado_corporal']?['bcs'] ?? '-'} / 9'),
          _pdfRow('Índice salud',   '${r['estado_corporal']?['salud_pct'] ?? '-'}%'),
          _pdfRow('Color pelaje',   r['color']?['color_principal']   ?? '-'),
          _pdfRow('Patrón',         r['color']?['patron']            ?? '-'),
          _pdfRow('Orejas',         r['orejas']?['posicion']         ?? '-'),
          _pdfRow('Estado ánimo',   r['gesto']?['nombre']            ?? '-'),
          _pdfRow('Nivel estrés',   '${r['gesto']?['nivel_estres'] ?? 0}/10'),
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
      widget.onRefresh();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final scans = [...widget.user.scans]
        ..sort((a, b) => b.date.compareTo(a.date));

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            kTitle(L.get('scan_history'), size: 24),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: kCoral.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20)),
              child: Text("${scans.length} escaneos",
                style: _nunito(12, kCoral, weight: FontWeight.w700))),
          ]),
          const SizedBox(height: 20),
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
                      id: '', name: '?', ageYears: 0, ageMonths: 0));
                return _scanTile(context, s, cat);
              },
            )),
        ]),
      ),
    );
  }

  Widget _scanTile(BuildContext context, ScanRecord s, CatProfile cat) {
    final corp  = s.resultado['estado_corporal'] as Map? ?? {};
    final emoji = corp['emoji'] ?? '🐱';
    final estado= corp['estado'] ?? '-';
    final raza  = s.resultado['raza']?['raza'] ?? '-';
    final peso  = s.resultado['peso']?['peso_kg'] ?? '-';
    final hexStr= corp['color_hex'] as String? ?? '#4ECDC4';
    Color color;
    try { color = Color(int.parse(hexStr.replaceFirst('#', '0xFF'))); }
    catch (_) { color = kTurquoise; }

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
      confirmDismiss: (_) async {
        _deleteScan(s);
        return false;
      },
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => ResultScreen(
            record: s, cat: cat, user: widget.user,
            serverIp: '', cameras: widget.cameras))),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: kCardDeco(),
          child: Row(children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16)),
              child: Center(child: Text(emoji,
                  style: const TextStyle(fontSize: 26)))),
            const SizedBox(width: 14),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cat.name, style: _nunito(15, kText, weight: FontWeight.w800)),
                kBody(raza, color: kMuted, size: 12),
                kBody(estado, color: color, size: 12),
              ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text("$peso kg", style: _nunito(15, kTurquoise, weight: FontWeight.w800)),
              kBody(DateFormat('dd/MM/yy').format(s.date), color: kMuted, size: 11),
            ]),
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
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(L.get('delete_confirm'),
          style: _nunito(18, kText, weight: FontWeight.w800)),
        content: Text(L.get('delete_cat_msg'),
          style: _nunito(14, kMuted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(L.get('cancel_delete'), style: _nunito(14, kMuted))),
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
      widget.user.cats.removeWhere((c) => c.id == cat.id);
      widget.user.scans.removeWhere((s) => s.catId == cat.id);
      await StorageService.saveCats(widget.user.cats);
      await StorageService.saveScans(widget.user.scans);
      widget.onRefresh();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          kTitle(L.get('my_cats'), size: 24),
          const SizedBox(height: 20),
          _userCard(),
          const SizedBox(height: 20),
          kLabel("mis gatitos"),
          const SizedBox(height: 12),
          if (widget.user.cats.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: kCardDeco(),
              child: Center(child: kBody(L.get('no_cats'), color: kMuted)))
          else
            ...widget.user.cats.map((c) => _catCard(c)),
          const SizedBox(height: 12),
          kOutlineBtn("🐱 ${L.get('add_cat')}", () {
            showModalBottomSheet(
              context: context,
              backgroundColor: kSurface,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
              builder: (_) => AddCatSheet(onSave: (cat) async {
                widget.user.cats.add(cat);
                await StorageService.saveCats(widget.user.cats);
                widget.onRefresh();
                setState(() {});
              }),
            );
          }),
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
        Text("${widget.user.scans.length} escaneos · ${widget.user.cats.length} gatitos",
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
          child: const Center(child: Text("🐱", style: TextStyle(fontSize: 26)))),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(cat.name, style: _nunito(16, kText, weight: FontWeight.w800)),
          kBody("${cat.ageYears} ${L.get('years')} ${cat.ageMonths} ${L.get('months')}",
              color: kMuted, size: 12),
          kBody("$scans escaneos", color: kCoral, size: 12),
        ])),
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => QrGeneratorScreen(cat: cat, user: widget.user))),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.qr_code_rounded, color: kPurple, size: 20))),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => _deleteCat(cat),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kCoral.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.delete_rounded, color: kCoral, size: 20))),
      ]),
    );
  }
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
  String _status = '';
  bool   _testing = false;

  @override
  void initState() {
    super.initState();
    StorageService.getServerIp().then((ip) => _ipCtrl.text = ip);
  }

  Future<void> _test() async {
    setState(() { _testing = true; _status = '...'; });
    try {
      final ip    = _ipCtrl.text;
      final proto = ip.contains('onrender') || ip.contains('trycloudflare')
          ? 'https' : 'http';
      final port  = ip.contains('onrender') || ip.contains('trycloudflare')
          ? '' : ':8000';
      final r = await http.get(Uri.parse('$proto://$ip$port/health'))
          .timeout(const Duration(seconds: 8));
      setState(() => _status = r.statusCode == 200
          ? L.get('connected') : L.get('not_connected'));
      await StorageService.setServerIp(ip);
    } catch (_) {
      setState(() => _status = L.get('not_connected'));
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
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          kTitle(L.get('settings'), size: 24),
          const SizedBox(height: 24),

          // Servidor
          kLabel(L.get('server_ip')),
          const SizedBox(height: 10),
          kTextField(_ipCtrl, SERVER_URL,
              icon: Icons.cloud_rounded, accent: kTurquoise),
          const SizedBox(height: 10),
          kGradBtn(L.get('test_conn'), _testing ? () {} : _test,
              colors: const [kTurquoise, Color(0xFF00B894)]),

          if (_status.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _status.contains('✅')
                    ? kGreen.withOpacity(0.1) : kCoral.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _status.contains('✅')
                    ? kGreen : kCoral, width: 1.5)),
              child: kBody(_status,
                  color: _status.contains('✅') ? kGreen : kCoral)),
          ],

          const SizedBox(height: 28),

          // Idioma
          kLabel(L.get('language')),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: kCardDeco(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                kBody("Español / English"),
                Row(children: [
                  _langChip('ES'),
                  const SizedBox(width: 8),
                  _langChip('EN'),
                ]),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [kPurple.withOpacity(0.1), kCoral.withOpacity(0.05)]),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kPurple.withOpacity(0.2)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("🐱 MeowScan v$APP_VERSION",
                style: _nunito(15, kPurple, weight: FontWeight.w800)),
              const SizedBox(height: 4),
              kBody("IA: Groq Vision llama-4-maverick", color: kMuted, size: 12),
              kBody("© 2025 MeowScan", color: kMuted, size: 11),
            ]),
          ),

          const SizedBox(height: 20),

          GestureDetector(
            onTap: () => _logout(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kCoral.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kCoral.withOpacity(0.3))),
              child: Center(child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.logout_rounded, color: kCoral, size: 18),
                  const SizedBox(width: 8),
                  kBody(L.get('logout'), color: kCoral),
                ])),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _langChip(String lang) => GestureDetector(
    onTap: () {
      MeowScanApp.of(context)?.setLang(lang.toLowerCase());
      setState(() {});
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: L.lang == lang.toLowerCase()
            ? kCoral : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: L.lang == lang.toLowerCase()
            ? kCoral : kBorder)),
      child: Text(lang, style: _nunito(13,
          L.lang == lang.toLowerCase() ? Colors.white : kMuted,
          weight: FontWeight.w700))),
  );
}
