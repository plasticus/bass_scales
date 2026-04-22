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

  // NEW ACCORDION ZOOM STATE
  double _visibleFrets = 13.0;

  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  final String _adUnitId = 'ca-app-pub-3940256099942544/6300978111';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
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

    // Use a temporary context-aware check for the initial default
    // We'll handle the orientation switch dynamically in the build method too
    bool isPortrait = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.aspectRatio < 1.0;

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

      // Smart Default: 5 frets for portrait, 13 for landscape
      double defaultZoom = isPortrait ? 5.0 : 13.0;
      _visibleFrets = prefs.getDouble('visibleFrets') ?? defaultZoom;
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

    double screenWidth = MediaQuery.of(context).size.width;
    double currentFretWidth = screenWidth / _visibleFrets;

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
                  width: 26 * currentFretWidth,
                  height: MediaQuery.of(context).size.height * 0.82,
                  child: CustomPaint(
                    painter: FretboardPainter(
                      rootNote: rootNote, activeNotes: activeNotes, tuning: tuning,
                      labelMode: labelMode, isLeftHanded: isLeftHanded, woodType: woodType,
                      inlayStyle: inlayStyle, showStars: showStars, starIntensity: starIntensity,
                      fretWidth: currentFretWidth,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 2. THE DYNAMIC AD
          if (_isAdLoaded && _bannerAd != null)
            Align(
              alignment: isPortrait ? Alignment.bottomCenter : Alignment.bottomLeft,
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: 10,
                    left: isPortrait ? 0 : 10,
                  ),
                  child: SizedBox(
                    width: _bannerAd!.size.width.toDouble(),
                    height: _bannerAd!.size.height.toDouble(),
                    child: AdWidget(ad: _bannerAd!),
                  ),
                ),
              ),
            ),

          // 3. THE UNIVERSAL ZOOM SLIDER (Now with Portrait Support!)
          Positioned(
            left: isPortrait ? 20 : null,
            right: 20,
            // If in portrait, sit 70px up to clear the ad; otherwise 35px in landscape
            bottom: isPortrait ? (_isAdLoaded ? 70 : 20) : 35,
            child: SafeArea(
              child: Container(
                width: isPortrait ? double.infinity : 180,
                padding: const EdgeInsets.symmetric(horizontal: 10),
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
                          value: _visibleFrets.clamp(5.0, 24.0),
                          min: 5.0,
                          max: 24.0,
                          activeColor: Colors.orange,
                          inactiveColor: Colors.orange.withOpacity(0.2),
                          onChanged: (v) => setState(() => _visibleFrets = v),
                          onChangeEnd: (v) => prefs.setDouble('visibleFrets', v),
                        ),
                      ),
                    ),
                    const Icon(Icons.zoom_in, color: Colors.orange, size: 14),
                  ],
                ),
              ),
            ),
          ),

          // 4. THE SCALE HEADER
          Align(
            alignment: Alignment.topCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Text(
                  '$rootNote • $scaleType',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    shadows: [
                      Shadow(blurRadius: 10, color: Colors.orange.withOpacity(0.3)),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 5. THE MENU BUTTON
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