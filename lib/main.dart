import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;
import 'music_engine.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BassScalesApp());
}

class BassScalesApp extends StatelessWidget {
  const BassScalesApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LowEndLabs Scale Visualizer',
      theme: ThemeData(brightness: Brightness.dark, useMaterial3: true),
      home: const FretboardPage(),
    );
  }
}

class FretboardPage extends StatefulWidget {
  const FretboardPage({super.key});
  @override
  State<FretboardPage> createState() => _FretboardPageState();
}

class _FretboardPageState extends State<FretboardPage> {
  // SCALE SETTINGS
  String rootNote = 'E';
  String scaleType = 'Pentatonic Minor';
  bool showNotes = true;

  // INSTRUMENT SETUP
  String instrument = 'Bass';
  int stringCount = 4;
  bool isLeftHanded = false;

  // LUTHIER'S SHOP
  String woodType = 'Clear'; // Set to Clear by default!
  String inlayStyle = 'Dots'; // Dots, Blocks, Quasar 1, 2, 3, None

  // COSMIC VISUALS
  bool showStars = true;
  double starIntensity = 0.5;
  bool keepAwake = false;

  final Uri _url = Uri.parse('https://lowendlabs.oaf.monster');

  void _toggleWakelock(bool value) {
    setState(() {
      keepAwake = value;
      WakelockPlus.toggle(enable: keepAwake);
    });
  }

  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) throw Exception('Could not launch $_url');
  }

  @override
  Widget build(BuildContext context) {
    Set<String> activeNotes = MusicEngine.calculateNotes(rootNote, scaleType);
    List<int> tuning = MusicEngine.instrumentTunings[instrument]![stringCount] ?? MusicEngine.instrumentTunings['Bass']![4]!;

    return Scaffold(
      appBar: AppBar(title: const Text('LowEndLabs')),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
                child: Center(
                    child: Text('DASHBOARD',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2.0)
                    )
                )
            ),

            // SCALE SETTINGS
            _sectionHeader('SCALE SETTINGS'),
            _buildDropdown('Root', rootNote, MusicEngine.chromaticScale, (v) => setState(() => rootNote = v!)),
            _buildDropdown('Scale', scaleType, MusicEngine.scaleFormulas.keys.toList(), (v) => setState(() => scaleType = v!)),
            SwitchListTile(title: const Text('Show Notes'), value: showNotes, onChanged: (v) => setState(() => showNotes = v)),

            // INSTRUMENT SETUP
            _sectionHeader('INSTRUMENT SETUP'),
            _buildToggle('Type', ['Bass', 'Guitar'], instrument, (v) {
              setState(() {
                instrument = v;
                stringCount = (instrument == 'Guitar') ? 6 : 4;
              });
            }),
            _buildStringCountToggle(),
            SwitchListTile(title: const Text('Left-Handed Mode'), value: isLeftHanded, onChanged: (v) => setState(() => isLeftHanded = v)),

            // LUTHIER'S SHOP
            _sectionHeader("LUTHIER'S SHOP"),
            _buildToggle('Wood', ['Rosewood', 'Maple', 'Clear'], woodType, (v) => setState(() => woodType = v)),
            _buildDropdown('Inlays', inlayStyle, ['Dots', 'Blocks', 'Quasar 1', 'Quasar 2', 'Quasar 3', 'None'], (v) => setState(() => inlayStyle = v!)),

            // COSMIC VISUALS
            _sectionHeader('COSMIC VISUALS'),
            SwitchListTile(title: const Text('Starfield'), value: showStars, onChanged: (v) => setState(() => showStars = v)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Intensity', style: TextStyle(fontSize: 12)),
                Slider(value: starIntensity, onChanged: (v) => setState(() => starIntensity = v)),
              ]),
            ),

            // PERFORMANCE
            _sectionHeader('PERFORMANCE'),
            SwitchListTile(title: const Text('Keep Awake'), subtitle: const Text('For the long jams'), value: keepAwake, onChanged: _toggleWakelock),

            // ABOUT
            _sectionHeader('ABOUT'),
            ListTile(
                title: const Text('Vessel: LowEndLabs'),
                subtitle: const Text('Visit Website'),
                trailing: const Icon(Icons.launch, size: 16),
                onTap: _launchUrl
            ),
          ],
        ),
      ),
      body: Container(
        color: Colors.black,
        child: CustomPaint(
          size: Size.infinite,
          painter: FretboardPainter(
            rootNote: rootNote,
            activeNotes: activeNotes,
            tuning: tuning,
            showNotes: showNotes,
            isLeftHanded: isLeftHanded,
            woodType: woodType,
            inlayStyle: inlayStyle,
            showStars: showStars,
            starIntensity: starIntensity,
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
    child: Text(title, style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 12)),
  );

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return ListTile(
      title: Text(label),
      trailing: DropdownButton<String>(
          value: value,
          underline: Container(),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged
      ),
    );
  }

  Widget _buildToggle(String label, List<String> options, String current, ValueChanged<String> onChanged) {
    return ListTile(
      title: Text(label),
      trailing: Container(
        constraints: const BoxConstraints(maxWidth: 150),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: ToggleButtons(
            isSelected: options.map((e) => e == current).toList(),
            onPressed: (index) => onChanged(options[index]),
            borderRadius: BorderRadius.circular(8),
            children: options.map((e) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(e)
            )).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildStringCountToggle() {
    List<int> options = (instrument == 'Guitar') ? [6, 7] : [4, 5, 6];
    return ListTile(
      title: const Text('Strings'),
      trailing: Container(
        constraints: const BoxConstraints(maxWidth: 150),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: ToggleButtons(
            isSelected: options.map((e) => e == stringCount).toList(),
            onPressed: (index) => setState(() => stringCount = options[index]),
            borderRadius: BorderRadius.circular(8),
            children: options.map((e) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(e.toString())
            )).toList(),
          ),
        ),
      ),
    );
  }
}

class FretboardPainter extends CustomPainter {
  final String rootNote;
  final Set<String> activeNotes;
  final List<int> tuning;
  final bool showNotes;
  final bool isLeftHanded;
  final String woodType;
  final String inlayStyle;
  final bool showStars;
  final double starIntensity;

  FretboardPainter({
    required this.rootNote, required this.activeNotes, required this.tuning,
    required this.showNotes, required this.isLeftHanded, required this.woodType,
    required this.inlayStyle, required this.showStars, required this.starIntensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    const double fretCount = 13;
    final double stringCount = tuning.length.toDouble();

    final double fretWidth = size.width / fretCount;
    final double stringHeight = size.height / (stringCount + 1);

    // 1. Draw Stars
    if (showStars) {
      final random = math.Random(42);
      paint.color = Colors.white.withOpacity(starIntensity);
      for (int i = 0; i < 200; i++) {
        canvas.drawCircle(
            Offset(random.nextDouble() * size.width, random.nextDouble() * size.height),
            random.nextDouble() * 1.8,
            paint
        );
      }
    }

    // 2. Draw Fretboard Wood
    if (woodType != 'Clear') {
      paint.color = (woodType == 'Rosewood') ? const Color(0xFF3E2723) : const Color(0xFFFFF9C4);
      canvas.drawRect(Rect.fromLTWH(0, stringHeight / 2, size.width, size.height - stringHeight), paint);
    }

    // 3. Draw Inlays
    _drawInlays(canvas, size, fretWidth, stringHeight);

    // 4. Draw Frets (Opaque)
    paint.color = const Color(0xFFBDBDBD);
    paint.strokeWidth = 3;
    for (int i = 0; i <= fretCount; i++) {
      double x = i * fretWidth;
      canvas.drawLine(Offset(x, stringHeight / 2), Offset(x, size.height - stringHeight / 2), paint);
    }

    // 5. Draw Strings and Notes
    for (int i = 0; i < tuning.length; i++) {
      double y = (i + 1) * stringHeight;
      paint.color = Colors.grey[400]!;
      paint.strokeWidth = 2 + (i * 0.7);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);

      int openNoteIndex = tuning[i];
      for (int f = 0; f < fretCount; f++) {
        int currentNoteIndex = (openNoteIndex + f) % 12;
        String noteName = MusicEngine.chromaticScale[currentNoteIndex];

        if (activeNotes.contains(noteName)) {
          double x = (f + 0.5) * fretWidth;
          if (isLeftHanded) x = size.width - x;

          paint.color = (noteName == rootNote) ? Colors.orange : Colors.blueAccent;
          canvas.drawCircle(Offset(x, y), 18, paint);

          if (showNotes) {
            final textPainter = TextPainter(
              text: TextSpan(text: noteName, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              textDirection: TextDirection.ltr,
            )..layout();
            textPainter.paint(canvas, Offset(x - textPainter.width / 2, y - textPainter.height / 2));
          }
        }
      }
    }
  }

  void _drawInlays(Canvas canvas, Size size, double fretWidth, double stringHeight) {
    if (inlayStyle == 'None') return;
    final List<int> markFrets = [3, 5, 7, 9, 12];
    final paint = Paint();
    paint.color = (woodType == 'Maple') ? Colors.black54 : Colors.white.withOpacity(0.8);

    for (int f in markFrets) {
      double x = (f - 0.5) * fretWidth;
      if (isLeftHanded) x = size.width - x;
      double y = size.height / 2;

      if (inlayStyle == 'Dots') {
        if (f == 12) {
          canvas.drawCircle(Offset(x, y - stringHeight), 8, paint);
          canvas.drawCircle(Offset(x, y + stringHeight), 8, paint);
        } else {
          canvas.drawCircle(Offset(x, y), 8, paint);
        }
      } else if (inlayStyle == 'Blocks') {
        double bW = fretWidth * 0.5;
        double bH = size.height * 0.4;
        canvas.drawRect(Rect.fromCenter(center: Offset(x, y), width: bW, height: bH), paint);
      } else if (inlayStyle.contains('Quasar')) {
        _drawQuasar(canvas, Offset(x, y), fretWidth, inlayStyle, paint.color);
      }
    }
  }

  void _drawQuasar(Canvas canvas, Offset center, double fretWidth, String style, Color color) {
    final paint = Paint()..color = color;
    canvas.drawCircle(center, 6, paint);

    if (style == 'Quasar 1') {
      canvas.drawLine(center.translate(0, -25), center.translate(0, 25), paint..strokeWidth = 2);
      canvas.drawLine(center.translate(-10, 0), center.translate(10, 0), paint..strokeWidth = 2);
    } else if (style == 'Quasar 2') {
      canvas.drawOval(Rect.fromCenter(center: center, width: fretWidth * 0.8, height: 12), paint..style = PaintingStyle.stroke..strokeWidth = 2);
    } else if (style == 'Quasar 3') {
      final path = Path();
      path.moveTo(center.dx, center.dy - 18);
      path.lineTo(center.dx + 6, center.dy);
      path.lineTo(center.dx, center.dy + 18);
      path.lineTo(center.dx - 6, center.dy);
      path.close();
      canvas.drawPath(path, paint);
      canvas.drawPath(Path()..moveTo(center.dx - 25, center.dy)..lineTo(center.dx, center.dy - 6)..lineTo(center.dx + 25, center.dy)..lineTo(center.dx, center.dy + 6)..close(), paint);
    }
  }

  @override
  bool shouldRepaint(covariant FretboardPainter oldDelegate) => true;
}