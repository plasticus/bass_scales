import 'ad_config.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/services.dart';
import 'music_engine.dart';
import 'fretboard_painter.dart';
import 'settings_drawer.dart';
import 'metronome_service.dart';
import 'metronome_page.dart';

// ===========================================================================
// 1. ENTRY POINT & APP CONFIG
// ===========================================================================
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final RequestConfiguration requestConfiguration = RequestConfiguration(
    tagForChildDirectedTreatment: TagForChildDirectedTreatment.unspecified,
    testDeviceIds: [],
  );
  MobileAds.instance.updateRequestConfiguration(requestConfiguration);

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
  Timer? _rotationNoticeTimer;

  // --- Metronome State ---
  late MetronomeEngine _metronomeEngine;
  bool metronomeEnabled = false;
  int metronomeBpm = 110;
  String metronomeTimeSignature = '4/4';
  String metronomeSubdivision = 'Quarter';
  String metronomeSound = 'Wood block';

  // --- Ads State ---
  bool _isAdLoaded = false;
  final String _adUnitId = AdConfig.bannerAdUnitId;

  // ===========================================================================
  // 3. LIFECYCLE & INITIALIZATION
  // ===========================================================================
  @override
  void initState() {
    super.initState();

    _metronomeEngine = MetronomeEngine();
    _metronomeEngine.addListener(() {
      if (mounted) setState(() => metronomeEnabled = _metronomeEngine.enabled);
    });

    // LANDMARK: THE NATIVE EDGE-TO-EDGE FIX
    // This tells Android 15 to let the app draw behind the system bars
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      statusBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
    ));

    _loadPreferences();

    _rotationNoticeTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && _showRotationNotice) {
        setState(() => _showRotationNotice = false);
      }
    });
  }

  @override
  void dispose() {
    _rotationNoticeTimer?.cancel();
    _metronomeEngine.dispose();
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

      metronomeEnabled = prefs.getBool('metronomeEnabled') ?? false;
      metronomeBpm = prefs.getInt('metronomeBpm') ?? 110;
      metronomeTimeSignature = prefs.getString('metronomeTimeSignature') ?? '4/4';
      metronomeSubdivision = prefs.getString('metronomeSubdivision') ?? 'Quarter';
      metronomeSound = prefs.getString('metronomeSound') ?? 'Wood block';
    });

    _metronomeEngine.bpm = metronomeBpm;
    _metronomeEngine.timeSignature = metronomeTimeSignature;
    _metronomeEngine.subdivision = metronomeSubdivision;
    _metronomeEngine.soundType = metronomeSound;
    if (metronomeEnabled) _metronomeEngine.start();

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
  // 5. METRONOME HELPERS
  // ===========================================================================
  void _saveMetronomeSettings() {
    prefs.setBool('metronomeEnabled', metronomeEnabled);
    prefs.setInt('metronomeBpm', metronomeBpm);
    prefs.setString('metronomeTimeSignature', metronomeTimeSignature);
    prefs.setString('metronomeSubdivision', metronomeSubdivision);
    prefs.setString('metronomeSound', metronomeSound);
  }

  void _onMetronomeBpmChanged(int value) {
    setState(() => metronomeBpm = value);
    _metronomeEngine.bpm = value;
    _metronomeEngine.reschedule();
    _saveMetronomeSettings();
  }

  void _onMetronomeTimeSignatureChanged(String value) {
    setState(() => metronomeTimeSignature = value);
    _metronomeEngine.timeSignature = value;
    _saveMetronomeSettings();
  }

  void _onMetronomeSubdivisionChanged(String value) {
    setState(() => metronomeSubdivision = value);
    _metronomeEngine.subdivision = value;
    _metronomeEngine.reschedule();
    _saveMetronomeSettings();
  }

  void _onMetronomeSoundTypeChanged(String value) {
    setState(() => metronomeSound = value);
    _metronomeEngine.soundType = value;
    _saveMetronomeSettings();
  }

  void _toggleMetronome() {
    _metronomeEngine.toggle();
    setState(() => metronomeEnabled = _metronomeEngine.enabled);
    _saveMetronomeSettings();
  }

  void _openMetronomePage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MetronomePage(
          engine: _metronomeEngine,
          bpm: metronomeBpm,
          timeSignature: metronomeTimeSignature,
          subdivision: metronomeSubdivision,
          soundType: metronomeSound,
          onBpmChanged: _onMetronomeBpmChanged,
          onTimeSignatureChanged: _onMetronomeTimeSignatureChanged,
          onSubdivisionChanged: _onMetronomeSubdivisionChanged,
          onSoundTypeChanged: _onMetronomeSoundTypeChanged,
          onToggle: _toggleMetronome,
        ),
      ),
    );
  }

  Widget _buildMiniFab({
    required Widget icon,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
  }) {
    return Material(
      color: Colors.black87,
      elevation: 6,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Center(child: icon),
        ),
      ),
    );
  }

  // ===========================================================================
  // 6. INTERACTIVE HEADER HELPERS
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

  void _showRootPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 80.0),
          child: Material(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(15),
            elevation: 10,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: 80,
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
  // 7. MAIN UI BUILD METHOD
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
          // Keep the banner widget in the tree (Offstage) so the AdWidget's
          // element isn't repeatedly mounted/unmounted, which causes the
          // "AdWidget is already in the Widget tree" error.
          Align(
            alignment: isPortrait ? Alignment.bottomCenter : Alignment.bottomLeft,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(bottom: 10, left: isPortrait ? 0 : 10),
                child: Offstage(
                  offstage: !_isAdLoaded,
                  child: _AdBanner(
                    adUnitId: _adUnitId,
                    adSize: AdSize.banner,
                    onLoaded: () {
                      if (!_isAdLoaded && mounted) setState(() => _isAdLoaded = true);
                    },
                  ),
                ),
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
          // In landscape, disable top SafeArea padding so the chips can sit
          // high and clear the fretboard; align their top edge with the menu
          // row. In portrait, keep a conservative gap from the status bar and
          // drop below the menu row so the chips don't overlap the buttons.
          Align(
            alignment: Alignment.topCenter,
            child: SafeArea(
              top: isPortrait,
              bottom: false,
              child: Padding(
                padding: EdgeInsets.only(top: isPortrait ? 36 : 20),
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

          // Landmark: 7.6 MENU & METRONOME BUTTONS
          Positioned(
            top: isPortrait ? 40 : 20, left: 20,
            child: Opacity(
              opacity: 0.5,
              child: Row(
                children: [
                  FloatingActionButton(
                    mini: true, backgroundColor: Colors.black87,
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                    child: const Icon(Icons.menu, color: Colors.orange),
                  ),
                  const SizedBox(width: 12),
                  _buildMiniFab(
                    icon: Image.asset(
                      'assets/metronome_icon.png',
                      width: 24,
                      height: 24,
                      color: _metronomeEngine.enabled ? Colors.redAccent : Colors.orange,
                      colorBlendMode: BlendMode.srcIn,
                    ),
                    onTap: _openMetronomePage,
                    onLongPress: _toggleMetronome,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// ===========================================================================
// 8. BANNER AD WIDGET
// ===========================================================================
// Wraps the AdWidget in its own StatefulWidget so the AdWidget instance stays
// stable across rebuilds of the parent. This avoids the "AdWidget is already
// in the Widget tree" error from google_mobile_ads.
class _AdBanner extends StatefulWidget {
  final String adUnitId;
  final AdSize adSize;
  final VoidCallback? onLoaded;

  const _AdBanner({
    required this.adUnitId,
    required this.adSize,
    this.onLoaded,
  });

  @override
  State<_AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<_AdBanner> {
  BannerAd? _bannerAd;
  AdWidget? _adWidget;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _bannerAd = BannerAd(
      adUnitId: widget.adUnitId,
      size: widget.adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) return;
          _adWidget = AdWidget(ad: _bannerAd!);
          setState(() => _isLoaded = true);
          widget.onLoaded?.call();
        },
        onAdFailedToLoad: (ad, error) => ad.dispose(),
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null || _adWidget == null) {
      return SizedBox(
        width: widget.adSize.width.toDouble(),
        height: widget.adSize.height.toDouble(),
      );
    }
    return SizedBox(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: _adWidget,
    );
  }
}
