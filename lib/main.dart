import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'music_engine.dart';
import 'fretboard_painter.dart';
import 'settings_drawer.dart';

// ===========================================================================
// 1. ENTRY POINT & APP CONFIG
// ===========================================================================
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

// ===========================================================================
// 2. MAIN PAGE STATEFUL WIDGET
// ===========================================================================
class FretboardPage extends StatefulWidget {
  const FretboardPage({super.key});
  @override
  State<FretboardPage> createState() => _FretboardPageState();
}

class _FretboardPageState extends State<FretboardPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late SharedPreferences prefs;

  // --- State Variables ---
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
  bool _showRotationNotice = true;
  double _visibleFrets = 13.0;

  // --- Ads State ---
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  final String _adUnitId = 'ca-app-pub-3940256099942544/6300978111';

  // ===========================================================================
  // 3. LIFECYCLE & INITIALIZATION
  // ===========================================================================
  @override
    void initState() {
      super.initState();
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.black, 
      ));

      _loadPreferences();
      _initBannerAd();

      Future.delayed(const Duration(seconds: 5), () {
        if (mounted && _showRotationNotice) {
          setState(() => _showRotationNotice = false);
        }
      });
    }

  void _initBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: _adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => setState(() => _isAdLoaded = true),
        onAdFailedToLoad: (ad, error) { ad.dispose(); },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  // ===========================================================================
  // 4. DATA PERSISTENCE & SETTINGS
  // ===========================================================================
  Future<void> _loadPreferences() async {
    prefs = await SharedPreferences.getInstance();
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

  // ===========================================================================
  // 5. INTERACTIVE HEADER HELPERS (EXPERIMENTAL)
  // ===========================================================================
  Widget _headerChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange.withOpacity(0.4), width: 1.5),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.orange, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  // --- Section 5: INTERACTIVE HEADER HELPERS ---

  void _showRootPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 80.0), // Sits it right under the header
          child: Material(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(15),
            elevation: 10,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: 80, // Slim ribbon
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: MusicEngine.chromaticScale.length,
                itemBuilder: (context, index) {
                  String note = MusicEngine.chromaticScale[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                    child: ChoiceChip(
                      label: Text(note, style: const TextStyle(fontWeight: FontWeight.bold)),
                      selected: note == rootNote,
                      selectedColor: Colors.orange,
                      onSelected: (_) {
                        _updateSetting('rootNote', note);
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showScalePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      isScrollControlled: true,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: ListView(
          children: MusicEngine.scaleFormulas.keys.map((scale) => ListTile(
            title: Text(scale, style: TextStyle(color: scale == scaleType ? Colors.orange : Colors.white)),
            trailing: scale == scaleType ? const Icon(Icons.check, color: Colors.orange) : null,
            onTap: () {
              _updateSetting('scaleType', scale);
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
    );
  }

  // ===========================================================================
  // 6. MAIN UI BUILD METHOD
  // ===========================================================================
  @override
  Widget build(BuildContext context) {
    Set<String> activeNotes = MusicEngine.calculateNotes(rootNote, scaleType);
    List<int> tuning = MusicEngine.instrumentTunings[instrument]?[stringCount] ??
                      MusicEngine.instrumentTunings['Bass']![4]!;

    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    double screenWidth = MediaQuery.of(context).size.width;
    double currentFretWidth = screenWidth / _visibleFrets;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      drawer: SettingsDrawer(
        languageCode: languageCode, rootNote: rootNote, scaleType: scaleType,
        labelMode: labelMode, instrument: instrument, stringCount: stringCount,
        isLeftHanded: isLeftHanded, woodType: woodType, inlayStyle: inlayStyle,
        showStars: showStars, keepAwake: keepAwake, onSettingChanged: _updateSetting,
        onToggleWakelock: _toggleWakelock,
      ),
      body: Stack(
        children: [
          // Landmark: 6.1 FRETBOARD LAYER
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

          // Landmark: 6.2 ROTATION NOTICE
          if (_showRotationNotice)
            Align(
              alignment: Alignment.topCenter,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 60, left: 20, right: 20),
                  child: Material(
                    elevation: 8, color: Colors.orange.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(12),
                    child: ListTile(
                      leading: const Icon(Icons.screen_rotation, color: Colors.black),
                      title: const Text('Try Landscape mode for the best view!', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      trailing: IconButton(icon: const Icon(Icons.check_circle, color: Colors.black), onPressed: () => setState(() => _showRotationNotice = false)),
                    ),
                  ),
                ),
              ),
            ),

          // Landmark: 6.3 AD LAYER
          if (_isAdLoaded && _bannerAd != null)
            Align(
              alignment: isPortrait ? Alignment.bottomCenter : Alignment.bottomLeft,
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 10, left: isPortrait ? 0 : 10),
                  child: SizedBox(width: _bannerAd!.size.width.toDouble(), height: _bannerAd!.size.height.toDouble(), child: AdWidget(ad: _bannerAd!)),
                ),
              ),
            ),

          // Landmark: 6.4 ZOOM SLIDER
          Positioned(
            left: isPortrait ? 20 : null, right: 20,
            bottom: isPortrait ? (_isAdLoaded ? 70 : 20) : 35,
            child: SafeArea(
              child: Container(
                width: isPortrait ? double.infinity : 180,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    const Icon(Icons.zoom_out, color: Colors.orange, size: 14),
                    Expanded(child: Slider(
                      value: _visibleFrets.clamp(5.0, 24.0), min: 5.0, max: 24.0,
                      activeColor: Colors.orange, inactiveColor: Colors.orange.withOpacity(0.2),
                      onChanged: (v) => setState(() => _visibleFrets = v),
                      onChangeEnd: (v) => prefs.setDouble('visibleFrets', v),
                    )),
                    const Icon(Icons.zoom_in, color: Colors.orange, size: 14),
                  ],
                ),
              ),
            ),
          ),

          // Landmark: 6.5 INTERACTIVE HEADER
          Align(
            alignment: Alignment.topCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(onTap: () => _showRootPicker(context), child: _headerChip(rootNote)),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('•', style: TextStyle(color: Colors.orange, fontSize: 24))),
                    GestureDetector(onTap: () => _showScalePicker(context), child: _headerChip(scaleType)),
                  ],
                ),
              ),
            ),
          ),

          // Landmark: 6.6 MENU BUTTON
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