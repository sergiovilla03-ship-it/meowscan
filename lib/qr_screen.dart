// ════════════════════════════════════════════════════════════════
// 🐱 MEOWSCAN — PANTALLA GENERADOR DE QR
// ════════════════════════════════════════════════════════════════
// Agregar estas dependencias al pubspec.yaml:
//   qr_flutter: ^4.1.0
//   image_picker: ^1.1.2
//
// Agregar este import al main.dart:
//   import 'package:qr_flutter/qr_flutter.dart';
//
// Esta pantalla se llama así desde ProfileTab:
//   Navigator.push(context, MaterialPageRoute(
//     builder: (_) => QrGeneratorScreen(cat: cat, user: user)));
// ════════════════════════════════════════════════════════════════

import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';

// URL base donde está alojada la página cat_profile.html
// Cambia esto por tu URL real cuando lo subas a internet
const String QR_BASE_URL = "https://meowscan-api.onrender.com/perfil";

// ════════════════════════════════════════════════════════════════
//  PANTALLA GENERADOR QR
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
                      pw.Text('Dueño: ${widget.user.username}',
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
              kLabel("TU NÚMERO DE WHATSAPP"),
              const SizedBox(height: 10),
              kTextField(
                _waCtrl,
                'Ej: 573001234567 (con código de país)',
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
                    kTitle("¡Listo! 🎉", size: 20, color: kCoral),
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
