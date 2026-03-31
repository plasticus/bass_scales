import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:math' as math;
import 'music_engine.dart';

// IGNITION SEQUENCE START: Bootstrapping the localized spacetime rendering engine.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
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

  // NEURAL TELEMETRY STORAGE: Retains orbital parameters across temporal jumps.
  late SharedPreferences prefs;

  // CORE REACTOR VARIABLES: These variables dictate the harmonic frequency and structural dimensions.
  String rootNote = 'E';
  String scaleType = 'Pentatonic Minor';
  String labelMode = 'Notes'; // Replaced 'showNotes' with a multi-state telemetry mode
  String instrument = 'Bass';
  int stringCount = 4;
  bool isLeftHanded = false;
  String woodType = 'Clear';
  String inlayStyle = 'Quasar';
  bool showStars = true;
  double starIntensity = 0.5;
  bool keepAwake = false;

  final Uri _url = Uri.parse('https://lowendlabs.oaf.monster');

  // --- AD MOBILIZATION UNIT ---
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  // Google Test ID for Android
  final String _adUnitId = 'ca-app-pub-3940256099942544/6300978111';

  // PRE-FLIGHT CHECK: Executed immediately upon entering the current dimension.
  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _initBannerAd(); // Fire up the engines!
  }

  void _initBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: _adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() => _isAdLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('Ad failed to load: $error');
        },
      ),
    );
    _bannerAd?.load();
  }

  @override
  void dispose() {
    // CLEANUP CREW: Don't leave the lights on when you leave the house!
    _bannerAd?.dispose();
    super.dispose();
  }

  // TEMPORAL RECOVERY: Extracting the previous epoch's parameters from the cryo-banks.
  Future<void> _loadPreferences() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      rootNote = prefs.getString('rootNote') ?? 'E';
      scaleType = prefs.getString('scaleType') ?? 'Pentatonic Minor';
      labelMode = prefs.getString('labelMode') ?? 'Notes';
      instrument = prefs.getString('instrument') ?? 'Bass';
      stringCount = prefs.getInt('stringCount') ?? 4;
      isLeftHanded = prefs.getBool('isLeftHanded') ?? false;
      woodType = prefs.getString('woodType') ?? 'Clear';
      inlayStyle = prefs.getString('inlayStyle') ?? 'Quasar';
      showStars = prefs.getBool('showStars') ?? true;
      starIntensity = prefs.getDouble('starIntensity') ?? 0.5;
      keepAwake = prefs.getBool('keepAwake') ?? false;
    });
    if (keepAwake) WakelockPlus.enable();
  }

  // STASIS CONTROL: Overrides local entropy to prevent the display from collapsing into a dark state.
  void _toggleWakelock(bool value) {
    setState(() {
      keepAwake = value;
      prefs.setBool('keepAwake', value);
      WakelockPlus.toggle(enable: keepAwake);
    });
  }

  @override
  Widget build(BuildContext context) {
    // QUANTUM STATE CALCULATION: Deriving the active energetic nodes and string matrices.
    Set<String> activeNotes = MusicEngine.calculateNotes(rootNote, scaleType);
    List<int> tuning = MusicEngine.instrumentTunings[instrument]![stringCount] ?? MusicEngine.instrumentTunings['Bass']![4]!;

    // Check if we are in Portrait mode
    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      drawer: _buildDrawer(),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // THE OBSERVATION DECK: A dynamically scaling viewport capable of infinite horizontal traversal.
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
                              labelMode: labelMode,
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

                // COMMAND UPLINK: An ethereal, localized anomaly permitting access to the main bridge UI.
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
          ),

          // THE AD FRONTIER: Only shows in Portrait if loaded
          if (isPortrait && _isAdLoaded && _bannerAd != null)
            SafeArea(
              top: false,
              child: SizedBox(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
            ),
        ],
      ),
    );
  }

  // THE COMMAND BRIDGE: Interface arrays for manipulating the localized gravitational constants.
  Widget _buildDrawer() {
    return Drawer(
      width: 400,
      child: ListView(
        children: [
          const DrawerHeader(child: Center(child: Text('DASHBOARD', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)))),
          _sectionHeader('SCALE SETTINGS'),
          _buildDropdown('Root', rootNote, MusicEngine.chromaticScale, (v) {
            setState(() { rootNote = v!; prefs.setString('rootNote', v); });
          }),
          _buildDropdown('Scale', scaleType, MusicEngine.scaleFormulas.keys.toList(), (v) {
            setState(() { scaleType = v!; prefs.setString('scaleType', v); });
          }),
          _buildDropdown('Labels', labelMode, ['Notes', 'Intervals', 'None'], (v) {
            setState(() { labelMode = v!; prefs.setString('labelMode', v); });
          }),
          _sectionHeader('INSTRUMENT'),
          _buildToggle('Type', ['Bass', 'Guitar'], instrument, (v) {
            setState(() {
              instrument = v;
              stringCount = (instrument == 'Guitar') ? 6 : 4;
              prefs.setString('instrument', instrument);
              prefs.setInt('stringCount', stringCount);
            });
          }),
          _buildStringCountToggle(),
          _sectionHeader("LUTHIER'S SHOP"),
          _buildToggle('Wood', ['Rosewood', 'Maple', 'Clear'], woodType, (v) {
            setState(() { woodType = v; prefs.setString('woodType', v); });
          }),
          _buildDropdown('Inlays', inlayStyle, ['Quasar', 'Dots', 'Blocks', 'None'], (v) {
            setState(() { inlayStyle = v!; prefs.setString('inlayStyle', v); });
          }),
          _sectionHeader('COSMIC'),
          SwitchListTile(title: const Text('Starfield'), value: showStars, onChanged: (v) {
            setState(() { showStars = v; prefs.setBool('showStars', v); });
          }),
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
            onPressed: (index) {
              setState(() {
                stringCount = options[index];
                prefs.setInt('stringCount', stringCount);
              });
            },
            children: options.map((e) => Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text(e.toString()))).toList(),
          ),
        ),
      ),
    );
  }
}

// THE HOLOGRAPHIC PROJECTION MATRIX: Renders the multi-dimensional string continuum and celestial anomalies.
class FretboardPainter extends CustomPainter {
  final String rootNote;
  final Set<String> activeNotes;
  final List<int> tuning;
  final String labelMode; // Multi-state telemetry directive
  final bool isLeftHanded;
  final String woodType;
  final String inlayStyle;
  final bool showStars;
  final double starIntensity;
  final double fretWidth;

  FretboardPainter({
    required this.rootNote, required this.activeNotes, required this.tuning,
    required this.labelMode, required this.isLeftHanded, required this.woodType,
    required this.inlayStyle, required this.showStars, required this.starIntensity,
    required this.fretWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final double stringCount = tuning.length.toDouble();
    final double chartHeight = size.height - 30;
    final double stringHeight = chartHeight / (stringCount + 1);

    // STELLAR BACKGROUND GENERATOR
    if (showStars) {
      final random = math.Random(42);
      paint.color = Colors.white.withOpacity(starIntensity);
      for (int i = 0; i < 600; i++) {
        canvas.drawCircle(Offset(random.nextDouble() * size.width, random.nextDouble() * size.height), random.nextDouble() * 2, paint);
      }
    }

    // MATERIEL SYNTHESIS
    if (woodType != 'Clear') {
      paint.color = (woodType == 'Rosewood') ? const Color(0xFF3E2723) : const Color(0xFFFFF9C4);
      canvas.drawRect(Rect.fromLTWH(fretWidth, stringHeight / 2, size.width - fretWidth, chartHeight - stringHeight), paint);
    }

    // ASTROMETRIC MARKERS
    _drawInlays(canvas, chartHeight, fretWidth, stringHeight);

    // DIMENSIONAL BOUNDARIES
    for (int i = 0; i <= 24; i++) {
      double x = (i + 1) * fretWidth;

      if (i == 0) {
        paint.color = Colors.white; // The Event Horizon (Nut)
        paint.strokeWidth = 12;
      } else {
        paint.color = const Color(0xFFBDBDBD); // Standard Spatial Dividers
        paint.strokeWidth = 4;
      }

      canvas.drawLine(Offset(x, stringHeight / 2), Offset(x, chartHeight - stringHeight / 2), paint);

      // TELEMETRIC READOUTS
      if (i > 0) {
        final numPainter = TextPainter(
          text: TextSpan(text: i.toString(), style: TextStyle(color: Colors.grey[500], fontSize: 16, fontWeight: FontWeight.bold)),
          textDirection: TextDirection.ltr,
        )..layout();
        numPainter.paint(canvas, Offset(x - numPainter.width / 2, chartHeight + 4));
      }
    }

    // SUPERSTRING INSTANTIATION & PLASMIC NODE HIGHLIGHTING
    for (int i = 0; i < tuning.length; i++) {
      double y = (i + 1) * stringHeight;

      paint.color = Colors.grey[400]!;
      paint.strokeWidth = 3 + (i * 1.2);
      canvas.drawLine(Offset(fretWidth, y), Offset(size.width, y), paint);

      int openNoteIndex = tuning[i];
      for (int f = 0; f <= 24; f++) {
        int currentNoteIndex = (openNoteIndex + f) % 12;
        String noteName = MusicEngine.chromaticScale[currentNoteIndex];

        // IGNITE PLASMA SPHERES
        if (activeNotes.contains(noteName)) {
          double x = (f + 0.5) * fretWidth;
          if (isLeftHanded) x = size.width - x;

          paint.color = (noteName == rootNote) ? Colors.orange : Colors.blueAccent;
          canvas.drawCircle(Offset(x, y), 28, paint);

          // HOLOGRAPHIC OVERLAYS: Rendering standard atomic names or relative quantum distances
          if (labelMode != 'None') {
            String displayText = (labelMode == 'Intervals')
                ? MusicEngine.getInterval(rootNote, noteName)
                : noteName;

            final textPainter = TextPainter(
              text: TextSpan(text: displayText, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
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

  // QUASAR IGNITION
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