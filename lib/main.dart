import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'music_engine.dart';
import 'fretboard_painter.dart';
import 'settings_drawer.dart';

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
      title: 'Bass Scale Visualizer',
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
  late SharedPreferences prefs;

  // NEURAL TELEMETRY STORAGE
  String languageCode = 'en';
  String rootNote = 'E';
  String scaleType = 'Pentatonic Minor';
  String labelMode = 'Notes';
  String instrument = 'Bass';
  int stringCount = 4;
  bool isLeftHanded = false;
  String woodType = 'Clear';
  String inlayStyle = 'Quasar';
  bool showStars = true;
  double starIntensity = 0.5;
  bool keepAwake = false;

  // ACCORDION ZOOM STATE
  double _fretWidth = 100.0;

  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  final String _adUnitId = 'ca-app-pub-3940256099942544/6300978111';

  @override
  void initState() {
    super.initState();
    // Calculate 12-fret default on the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPreferences());
    _initBannerAd();
  }

  void _initBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: _adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => setState(() => _isAdLoaded = true),
        onAdFailedToLoad: (ad, error) { ad.dispose(); print('Ad failed to load: $error'); },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    prefs = await SharedPreferences.getInstance();

    // Calculate the "High Noon" 12-fret default for this specific screen
    double screenWidth = MediaQuery.of(context).size.width;
    double default12FretWidth = screenWidth / 12.5;

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
      languageCode = prefs.getString('languageCode') ?? 'en';

      // Load saved width or fall back to the 12-fret default
      _fretWidth = prefs.getDouble('fretWidth') ?? default12FretWidth;
    });
    if (keepAwake) WakelockPlus.enable();
  }

  void _updateSetting(String key, dynamic value) {
    setState(() {
      if (key == 'rootNote') { rootNote = value; prefs.setString(key, value); }
      if (key == 'scaleType') { scaleType = value; prefs.setString(key, value); }
      if (key == 'labelMode') { labelMode = value; prefs.setString(key, value); }
      if (key == 'instrument') {
        instrument = value;
        stringCount = (instrument == 'Guitar') ? 6 : 4;
        prefs.setString(key, value);
        prefs.setInt('stringCount', stringCount);
      }
      if (key == 'stringCount') { stringCount = value; prefs.setInt(key, value); }
      if (key == 'isLeftHanded') { isLeftHanded = value; prefs.setBool(key, value); }
      if (key == 'woodType') { woodType = value; prefs.setString(key, value); }
      if (key == 'inlayStyle') { inlayStyle = value; prefs.setString(key, value); }
      if (key == 'showStars') { showStars = value; prefs.setBool(key, value); }
      if (key == 'languageCode') { languageCode = value; prefs.setString(key, value); }
    });
  }

  void _toggleWakelock() {
    setState(() {
      keepAwake = !keepAwake;
      prefs.setBool('keepAwake', keepAwake);
      WakelockPlus.toggle(enable: keepAwake);
    });
  }

  @override
  Widget build(BuildContext context) {
    Set<String> activeNotes = MusicEngine.calculateNotes(rootNote, scaleType);
    List<int> tuning = MusicEngine.instrumentTunings[instrument]![stringCount] ?? MusicEngine.instrumentTunings['Bass']![4]!;
    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      drawer: SettingsDrawer(
        languageCode: languageCode,
        rootNote: rootNote,
        scaleType: scaleType,
        labelMode: labelMode,
        instrument: instrument,
        stringCount: stringCount,
        isLeftHanded: isLeftHanded,
        woodType: woodType,
        inlayStyle: inlayStyle,
        showStars: showStars,
        keepAwake: keepAwake,
        onSettingChanged: _updateSetting,
        onToggleWakelock: _toggleWakelock,
      ),
      body: Stack(
        children: [
          // 1. THE FRETBOARD FOUNDATION
          Positioned.fill(
            child: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: 26 * _fretWidth,
                  // Tucked up slightly to make room for the slider underneath
                  height: MediaQuery.of(context).size.height * 0.82,
                  child: CustomPaint(
                    painter: FretboardPainter(
                      rootNote: rootNote, activeNotes: activeNotes, tuning: tuning,
                      labelMode: labelMode, isLeftHanded: isLeftHanded, woodType: woodType,
                      inlayStyle: inlayStyle, showStars: showStars, starIntensity: starIntensity,
                      fretWidth: _fretWidth,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 2. THE LANDSCAPE AD (Bottom Left - Kept low)
          if (!isPortrait && _isAdLoaded && _bannerAd != null)
            Positioned(
              left: 10,
              bottom: 5,
              child: SafeArea(
                child: SizedBox(
                  width: _bannerAd!.size.width.toDouble(),
                  height: _bannerAd!.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd!),
                ),
              ),
            ),

          // 3. THE ZOOM SLIDER (Bottom Right - Tucked just under the numbers)
          if (!isPortrait)
            Positioned(
              right: 20,
              bottom: 35, // Positioned to clear system bar but hug numbers
              child: SafeArea(
                child: Container(
                  width: 180,
                  child: Row(
                    children: [
                      const Icon(Icons.zoom_out, color: Colors.orange, size: 14),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            overlayShape: SliderComponentShape.noOverlay,
                            trackHeight: 2,
                          ),
                          child: Slider(
                            value: _fretWidth.clamp(35.0, 180.0),
                            min: 35.0,
                            max: 180.0,
                            activeColor: Colors.orange,
                            inactiveColor: Colors.orange.withOpacity(0.2),
                            onChanged: (v) => setState(() => _fretWidth = v),
                            onChangeEnd: (v) => prefs.setDouble('fretWidth', v),
                          ),
                        ),
                      ),
                      const Icon(Icons.zoom_in, color: Colors.orange, size: 14),
                    ],
                  ),
                ),
              ),
            ),

          // 4. PORTRAIT AD (Centered low)
          if (isPortrait && _isAdLoaded && _bannerAd != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SizedBox(
                    width: _bannerAd!.size.width.toDouble(),
                    height: _bannerAd!.size.height.toDouble(),
                    child: AdWidget(ad: _bannerAd!),
                  ),
                ),
              ),
            ),

          // 5. THE MENU BUTTON (Top Left)
          Positioned(
            top: 40, left: 20,
            child: Opacity(
              opacity: 0.5,
              child: FloatingActionButton(
                mini: true, backgroundColor: Colors.black87,
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                child: const Icon(Icons.menu, color: Colors.orange),
              ),
            ),
          ),
        ],
      ),
    );
  }
}