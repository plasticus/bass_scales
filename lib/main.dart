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
  double _fretWidth = 100.0;
  double _baseFretWidth = 100.0;

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
      _fretWidth = prefs.getDouble('fretWidth') ?? 100.0;
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
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    return GestureDetector(
                      onScaleStart: (d) => _baseFretWidth = _fretWidth,
                      onScaleUpdate: (d) => setState(() => _fretWidth = (_baseFretWidth * d.horizontalScale).clamp(60.0, 300.0)),
                      onScaleEnd: (d) => prefs.setDouble('fretWidth', _fretWidth),
                      child: Center(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            height: constraints.maxHeight * 0.98,
                            width: 26 * _fretWidth,
                            child: CustomPaint(
                              size: Size.infinite,
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
                    );
                  }
                ),
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
          ),
          if (isPortrait && _isAdLoaded && _bannerAd != null)
            SafeArea(top: false, child: SizedBox(width: _bannerAd!.size.width.toDouble(), height: _bannerAd!.size.height.toDouble(), child: AdWidget(ad: _bannerAd!))),
        ],
      ),
    );
  }
}