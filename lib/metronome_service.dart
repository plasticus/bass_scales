import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

// ===========================================================================
// 1. IN-MEMORY WAV GENERATOR
// ===========================================================================
class MetronomeSoundGenerator {
  static const int sampleRate = 44100;
  static const int bitsPerSample = 16;
  static const int channels = 1;

  static final Map<String, Uint8List> _cache = {};

  static Uint8List _cached(String key, Uint8List Function() generator) {
    return _cache.putIfAbsent(key, generator);
  }

  static Uint8List woodBlock() => _cached('woodBlock', _woodBlock);
  static Uint8List click() => _cached('click', _click);
  static Uint8List hiHat() => _cached('hiHat', _hiHat);

  static Uint8List _woodBlock() {
    const durationMs = 55;
    const decayMs = 35.0;
    const frequency = 720.0;
    final samples = _generateBuffer(durationMs);

    for (int i = 0; i < samples.length; i++) {
      final t = i / sampleRate;
      final envelope = exp(-t / (decayMs / 1000));
      // Square-ish wave plus a click of noise at the attack.
      double wave = (sin(2 * pi * frequency * t) >= 0) ? 1.0 : -1.0;
      wave += 0.2 * ((sin(2 * pi * frequency * 2.3 * t) >= 0) ? 1.0 : -1.0);
      if (i < 100) {
        wave += (Random().nextDouble() * 2.0 - 1.0) * (1.0 - i / 100);
      }
      samples[i] = wave * envelope * 0.7;
    }
    return _makeWav(samples);
  }

  static Uint8List _click() {
    const durationMs = 22;
    const decayMs = 14.0;
    const frequency = 3200.0;
    final samples = _generateBuffer(durationMs);

    for (int i = 0; i < samples.length; i++) {
      final t = i / sampleRate;
      final envelope = exp(-t / (decayMs / 1000));
      // High sine plus a bit of broadband noise for bite.
      double wave = sin(2 * pi * frequency * t);
      if (i < 50) {
        wave += (Random().nextDouble() * 2.0 - 1.0) * 0.4;
      }
      samples[i] = wave * envelope * 0.95;
    }
    return _makeWav(samples);
  }

  static Uint8List _hiHat() {
    const durationMs = 55;
    const decayMs = 32.0;
    final samples = _generateBuffer(durationMs);
    final random = Random(42);
    double prevNoise = 0.0;

    for (int i = 0; i < samples.length; i++) {
      final t = i / sampleRate;
      final envelope = exp(-t / (decayMs / 1000));
      final noise = random.nextDouble() * 2.0 - 1.0;
      // High-pass-ish noise for a bright hat character.
      final highPass = (noise - prevNoise) * 0.6;
      prevNoise = noise;
      samples[i] = highPass * envelope * 0.55;
    }
    return _makeWav(samples);
  }

  static Float64List _generateBuffer(int durationMs) {
    return Float64List((sampleRate * durationMs / 1000).round());
  }

  static Uint8List _makeWav(Float64List samples) {
    final byteRate = sampleRate * channels * bitsPerSample ~/ 8;
    final dataSize = samples.length * channels * bitsPerSample ~/ 8;
    final fileSize = 36 + dataSize;

    final builder = BytesBuilder()
      ..add(_toBytes('RIFF'))
      ..add(_int32(fileSize))
      ..add(_toBytes('WAVE'))
      ..add(_toBytes('fmt '))
      ..add(_int32(16)) // PCM chunk size
      ..add(_int16(1)) // PCM format
      ..add(_int16(channels))
      ..add(_int32(sampleRate))
      ..add(_int32(byteRate))
      ..add(_int16(bitsPerSample ~/ 8))
      ..add(_int16(bitsPerSample))
      ..add(_toBytes('data'))
      ..add(_int32(dataSize));

    final byteData = ByteData(dataSize);
    for (int i = 0; i < samples.length; i++) {
      final clamped = samples[i].clamp(-1.0, 1.0);
      byteData.setInt16(i * 2, (clamped * 32767).toInt(), Endian.little);
    }
    builder.add(byteData.buffer.asUint8List());

    return Uint8List.fromList(builder.toBytes());
  }

  static List<int> _toBytes(String value) => value.codeUnits;

  static List<int> _int16(int value) {
    final b = ByteData(2);
    b.setInt16(0, value, Endian.little);
    return b.buffer.asUint8List();
  }

  static List<int> _int32(int value) {
    final b = ByteData(4);
    b.setInt32(0, value, Endian.little);
    return b.buffer.asUint8List();
  }
}

// ===========================================================================
// 2. METRONOME ENGINE
// ===========================================================================
class MetronomeEngine extends ChangeNotifier {
  SoLoud get _soloud => SoLoud.instance;

  bool _enabled = false;
  bool _initialized = false;
  Timer? _timer;
  DateTime? _startTime;
  int _tickCount = 0;

  int bpm = 110;
  String timeSignature = '4/4';
  String subdivision = 'Quarter';
  String soundType = 'Wood block';

  AudioSource? _woodBlockSource;
  AudioSource? _clickSource;
  AudioSource? _hiHatSource;

  bool get enabled => _enabled;

  int get beatsPerMeasure {
    return switch (timeSignature) {
      '3/4' => 3,
      '2/4' => 2,
      '6/8' => 6,
      '5/4' => 5,
      '7/8' => 7,
      _ => 4,
    };
  }

  int get ticksPerBeat {
    return switch (subdivision) {
      'Eighth' => 2,
      'Sixteenth' => 4,
      'Triplet' => 3,
      _ => 1,
    };
  }

  int get ticksPerMeasure => beatsPerMeasure * ticksPerBeat;

  Duration get _tickDuration {
    final seconds = 60.0 / (bpm * ticksPerBeat);
    return Duration(microseconds: (seconds * 1000000).round());
  }

  Future<void> _ensureInitialized() async {
    if (_initialized) return;

    if (!_soloud.isInitialized) {
      await _soloud.init();
    }

    _woodBlockSource = await _soloud.loadMem(
      'metronome_wood_block.wav',
      MetronomeSoundGenerator.woodBlock(),
    );
    _clickSource = await _soloud.loadMem(
      'metronome_click.wav',
      MetronomeSoundGenerator.click(),
    );
    _hiHatSource = await _soloud.loadMem(
      'metronome_hi_hat.wav',
      MetronomeSoundGenerator.hiHat(),
    );

    _initialized = true;
  }

  void start() {
    if (_enabled) return;
    _enabled = true;
    _startTime = DateTime.now();
    _tickCount = 1;
    notifyListeners();
    _scheduleNextTick(immediate: true);
  }

  void stop() {
    if (!_enabled) return;
    _enabled = false;
    _timer?.cancel();
    _timer = null;
    notifyListeners();
  }

  void toggle() => _enabled ? stop() : start();

  void reschedule() {
    if (!_enabled) return;
    _timer?.cancel();
    _scheduleNextTick();
  }

  void _scheduleNextTick({bool immediate = false}) {
    if (!_enabled || _startTime == null) return;

    final nextTick = _startTime!.add(_tickDuration * _tickCount);
    var delay = nextTick.difference(DateTime.now());
    if (delay < Duration.zero || immediate) delay = Duration.zero;

    _timer?.cancel();
    _timer = Timer(delay, _onTick);
  }

  Future<void> _onTick() async {
    if (!_enabled) return;

    final tickInMeasure = _tickCount % ticksPerMeasure;
    final beatIndex = tickInMeasure ~/ ticksPerBeat;
    final isSubdivision = tickInMeasure % ticksPerBeat != 0;

    final double volume;
    if (beatIndex == 0 && !isSubdivision) {
      volume = 1.0; // downbeat
    } else if (!isSubdivision) {
      volume = 0.45; // other main beats
    } else {
      volume = 0.22; // subdivisions
    }

    await _playSound(volume);

    _tickCount++;
    _scheduleNextTick();
  }

  Future<void> _playSound(double volume) async {
    await _ensureInitialized();

    final source = switch (soundType) {
      'Click' => _clickSource,
      'Hi-hat' => _hiHatSource,
      _ => _woodBlockSource,
    };

    if (source == null) return;
    await _soloud.play(source, volume: volume);
  }

  @override
  void dispose() {
    stop();
    if (_initialized && _soloud.isInitialized) {
      _soloud.deinit();
    }
    super.dispose();
  }
}
