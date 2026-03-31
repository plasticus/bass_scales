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
      debugShowCheckedModeBanner: false,
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String rootNote = 'E';
  String scaleType = 'Pentatonic Minor';
  bool showNotes = true;
  String instrument = 'Bass';
  int stringCount = 4;
  bool isLeftHanded = false;
  String woodType = 'Clear';
  String inlayStyle = 'Quasar';
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

  @override
  Widget build(BuildContext context) {
    Set<String> activeNotes = MusicEngine.calculateNotes(rootNote, scaleType);
    List<int> tuning = MusicEngine.instrumentTunings[instrument]![stringCount] ?? MusicEngine.instrumentTunings['Bass']![4]!;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      drawer: _buildDrawer(),
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    height: constraints.maxHeight * 0.98,
                    width: 26 * 100.0,
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
                        fretWidth: 100.0,
                      ),
                    ),
                  ),
                ),
              );
            }
          ),

          Positioned(
            top: 40,
            left: 20,
            child: Opacity(
              opacity: 0.5,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: Colors.black87,
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                child: const Icon(Icons.menu, color: Colors.orange),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      width: 340, // Stretched out for more breathing room!
      child: ListView(
        children: [
          const DrawerHeader(child: Center(child: Text('DASHBOARD', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)))),
          _sectionHeader('SCALE SETTINGS'),
          _buildDropdown('Root', rootNote, MusicEngine.chromaticScale, (v) => setState(() => rootNote = v!)),
          _buildDropdown('Scale', scaleType, MusicEngine.scaleFormulas.keys.toList(), (v) => setState(() => scaleType = v!)),
          SwitchListTile(title: const Text('Show Notes'), value: showNotes, onChanged: (v) => setState(() => showNotes = v)),
          _sectionHeader('INSTRUMENT'),
          _buildToggle('Type', ['Bass', 'Guitar'], instrument, (v) {
            setState(() { instrument = v; stringCount = (instrument == 'Guitar') ? 6 : 4; });
          }),
          _buildStringCountToggle(),
          _sectionHeader("LUTHIER'S SHOP"),
          _buildToggle('Wood', ['Rosewood', 'Maple', 'Clear'], woodType, (v) => setState(() => woodType = v)),
          _buildDropdown('Inlays', inlayStyle, ['Quasar', 'Dots', 'Blocks', 'None'], (v) => setState(() => inlayStyle = v!)),
          _sectionHeader('COSMIC'),
          SwitchListTile(title: const Text('Starfield'), value: showStars, onChanged: (v) => setState(() => showStars = v)),
          _sectionHeader('PERFORMANCE'),
          SwitchListTile(title: const Text('Keep Awake'), value: keepAwake, onChanged: _toggleWakelock),
          ListTile(title: const Text('Vessel: LowEndLabs'), subtitle: const Text('Visit Website'), onTap: () => launchUrl(_url)),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
    child: Text(title, style: const TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold)),
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
        constraints: const BoxConstraints(maxWidth: 140),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: ToggleButtons(
            isSelected: options.map((e) => e == current).toList(),
            onPressed: (index) => onChanged(options[index]),
            children: options.map((e) => Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text(e))).toList(),
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
        constraints: const BoxConstraints(maxWidth: 140),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: ToggleButtons(
            isSelected: options.map((e) => e == stringCount).toList(),
            onPressed: (index) => setState(() => stringCount = options[index]),
            children: options.map((e) => Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text(e.toString()))).toList(),
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
  final double fretWidth;

  FretboardPainter({
    required this.rootNote, required this.activeNotes, required this.tuning,
    required this.showNotes, required this.isLeftHanded, required this.woodType,
    required this.inlayStyle, required this.showStars, required this.starIntensity,
    required this.fretWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final double stringCount = tuning.length.toDouble();
    final double chartHeight = size.height - 30;
    final double stringHeight = chartHeight / (stringCount + 1);

    // 1. Stars
    if (showStars) {
      final random = math.Random(42);
      paint.color = Colors.white.withOpacity(starIntensity);
      for (int i = 0; i < 600; i++) {
        canvas.drawCircle(Offset(random.nextDouble() * size.width, random.nextDouble() * size.height), random.nextDouble() * 2, paint);
      }
    }

    // 2. Wood
    if (woodType != 'Clear') {
      paint.color = (woodType == 'Rosewood') ? const Color(0xFF3E2723) : const Color(0xFFFFF9C4);
      canvas.drawRect(Rect.fromLTWH(fretWidth, stringHeight / 2, size.width - fretWidth, chartHeight - stringHeight), paint);
    }

    // 3. Inlays (Now dimmed by ~25%)
    _drawInlays(canvas, chartHeight, fretWidth, stringHeight);

    // 4. Frets, Nut, and Numbers
    for (int i = 0; i <= 24; i++) {
      double x = (i + 1) * fretWidth;

      if (i == 0) {
        paint.color = Colors.white; // The Nut
        paint.strokeWidth = 12;
      } else {
        paint.color = const Color(0xFFBDBDBD);
        paint.strokeWidth = 4;
      }

      canvas.drawLine(Offset(x, stringHeight / 2), Offset(x, chartHeight - stringHeight / 2), paint);

      if (i > 0) {
        final numPainter = TextPainter(
          text: TextSpan(text: i.toString(), style: TextStyle(color: Colors.grey[500], fontSize: 16, fontWeight: FontWeight.bold)),
          textDirection: TextDirection.ltr,
        )..layout();
        numPainter.paint(canvas, Offset(x - numPainter.width / 2, chartHeight + 4));
      }
    }

    // 5. Strings and Notes
    for (int i = 0; i < tuning.length; i++) {
      double y = (i + 1) * stringHeight;

      paint.color = Colors.grey[400]!;
      paint.strokeWidth = 3 + (i * 1.2);
      canvas.drawLine(Offset(fretWidth, y), Offset(size.width, y), paint);

      int openNoteIndex = tuning[i];
      for (int f = 0; f <= 24; f++) {
        int currentNoteIndex = (openNoteIndex + f) % 12;
        String noteName = MusicEngine.chromaticScale[currentNoteIndex];

        if (activeNotes.contains(noteName)) {
          double x = (f + 0.5) * fretWidth;
          if (isLeftHanded) x = size.width - x;

          paint.color = (noteName == rootNote) ? Colors.orange : Colors.blueAccent;
          canvas.drawCircle(Offset(x, y), 28, paint);

          if (showNotes) {
            final textPainter = TextPainter(
              text: TextSpan(text: noteName, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              textDirection: TextDirection.ltr,
            )..layout();
            textPainter.paint(canvas, Offset(x - textPainter.width / 2, y - textPainter.height / 2));
          }
        }
      }
    }
  }

  void _drawInlays(Canvas canvas, double chartHeight, double fretWidth, double stringHeight) {
    if (inlayStyle == 'None') return;
    final List<int> markFrets = [3, 5, 7, 9, 12, 15, 17, 19, 21, 24];
    final paint = Paint();

    // Dimmed colors for all inlays to push them back visually
    paint.color = (woodType == 'Maple')
        ? Colors.black.withOpacity(0.35)
        : Colors.white.withOpacity(0.50);

    for (int f in markFrets) {
      double x = (f + 0.5) * fretWidth;
      double y = chartHeight / 2;

      bool isDouble = (f == 12 || f == 24);

      if (inlayStyle == 'Quasar') {
         _drawBigQuasar(canvas, Offset(x, y), paint.color, isDouble);
      } else if (inlayStyle == 'Dots') {
         if (isDouble) {
           canvas.drawCircle(Offset(x, y - stringHeight), 12, paint);
           canvas.drawCircle(Offset(x, y + stringHeight), 12, paint);
         } else {
           canvas.drawCircle(Offset(x, y), 12, paint);
         }
      } else if (inlayStyle == 'Blocks') {
         canvas.drawRect(Rect.fromCenter(center: Offset(x, y), width: fretWidth * 0.5, height: chartHeight * 0.5), paint);
      }
    }
  }

  void _drawBigQuasar(Canvas canvas, Offset center, Color color, bool isDouble) {
    final qPaint = Paint()..color = color..strokeWidth = 5;

    void drawOne(Offset c) {
      canvas.drawCircle(c, 15, qPaint);
      canvas.drawLine(Offset(c.dx, c.dy - 60), Offset(c.dx, c.dy + 60), qPaint);
      canvas.drawLine(Offset(c.dx - 35, c.dy), Offset(c.dx + 35, c.dy), qPaint);
    }

    if (isDouble) {
      drawOne(center.translate(0, -80));
      drawOne(center.translate(0, 80));
    } else {
      drawOne(center);
    }
  }

  @override
  bool shouldRepaint(covariant FretboardPainter oldDelegate) => true;
}