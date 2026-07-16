import 'package:flutter/material.dart';
import 'metronome_service.dart';

// ===========================================================================
// 1. METRONOME SETTINGS PAGE
// ===========================================================================
class MetronomePage extends StatefulWidget {
  final MetronomeEngine engine;
  final int bpm;
  final String timeSignature;
  final String subdivision;
  final String soundType;
  final ValueChanged<int> onBpmChanged;
  final ValueChanged<String> onTimeSignatureChanged;
  final ValueChanged<String> onSubdivisionChanged;
  final ValueChanged<String> onSoundTypeChanged;
  final VoidCallback onToggle;

  const MetronomePage({
    super.key,
    required this.engine,
    required this.bpm,
    required this.timeSignature,
    required this.subdivision,
    required this.soundType,
    required this.onBpmChanged,
    required this.onTimeSignatureChanged,
    required this.onSubdivisionChanged,
    required this.onSoundTypeChanged,
    required this.onToggle,
  });

  @override
  State<MetronomePage> createState() => _MetronomePageState();
}

class _MetronomePageState extends State<MetronomePage> {
  late int _bpm;
  late String _timeSignature;
  late String _subdivision;
  late String _soundType;

  final List<String> _timeSignatures = const ['2/4', '3/4', '4/4', '5/4', '6/8', '7/8'];
  final List<String> _subdivisions = const ['Quarter', 'Eighth', 'Sixteenth', 'Triplet'];
  final List<String> _sounds = const ['Wood block', 'Click', 'Hi-hat'];

  @override
  void initState() {
    super.initState();
    _bpm = widget.bpm;
    _timeSignature = widget.timeSignature;
    _subdivision = widget.subdivision;
    _soundType = widget.soundType;
    widget.engine.addListener(_onEngineChanged);
  }

  @override
  void didUpdateWidget(covariant MetronomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.engine.removeListener(_onEngineChanged);
    widget.engine.addListener(_onEngineChanged);
  }

  @override
  void dispose() {
    widget.engine.removeListener(_onEngineChanged);
    super.dispose();
  }

  void _onEngineChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.orange),
        title: const Text('Metronome', style: TextStyle(color: Colors.orange)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Play / Stop
          Center(
            child: ElevatedButton.icon(
              onPressed: widget.onToggle,
              icon: Icon(
                widget.engine.enabled ? Icons.stop : Icons.play_arrow,
                color: Colors.black,
              ),
              label: Text(
                widget.engine.enabled ? 'STOP' : 'START',
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.engine.enabled ? Colors.redAccent : Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              'Long-press the metronome icon on the fretboard to start or stop.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          const SizedBox(height: 32),

          // Tempo
          _sectionHeader('TEMPO'),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove, color: Colors.orange),
                onPressed: _bpm > 40 ? () => _setBpm(_bpm - 1) : null,
              ),
              SizedBox(
                width: 120,
                child: Text(
                  '$_bpm BPM',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.orange),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.orange),
                onPressed: _bpm < 240 ? () => _setBpm(_bpm + 1) : null,
              ),
            ],
          ),
          Slider(
            value: _bpm.toDouble(),
            min: 40,
            max: 240,
            divisions: 200,
            activeColor: Colors.orange,
            inactiveColor: Colors.orange.withValues(alpha: 0.2),
            label: '$_bpm BPM',
            onChanged: (v) => _setBpm(v.round()),
          ),
          const SizedBox(height: 24),

          // Time signature
          _sectionHeader('TIME SIGNATURE'),
          _buildChoiceChips(_timeSignatures, _timeSignature, (v) {
            setState(() => _timeSignature = v);
            widget.onTimeSignatureChanged(v);
          }),
          const SizedBox(height: 24),

          // Subdivision
          _sectionHeader('SUBDIVISION'),
          _buildChoiceChips(_subdivisions, _subdivision, (v) {
            setState(() => _subdivision = v);
            widget.onSubdivisionChanged(v);
          }),
          const SizedBox(height: 24),

          // Sound
          _sectionHeader('SOUND'),
          _buildChoiceChips(_sounds, _soundType, (v) {
            setState(() => _soundType = v);
            widget.onSoundTypeChanged(v);
          }),
        ],
      ),
    );
  }

  void _setBpm(int value) {
    if (value == _bpm) return;
    setState(() => _bpm = value.clamp(40, 240));
    widget.onBpmChanged(_bpm);
  }

  Widget _sectionHeader(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(title, style: const TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold)),
  );

  Widget _buildChoiceChips(List<String> options, String current, ValueChanged<String> onChanged) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: options.map((e) => ChoiceChip(
        label: Text(e),
        selected: e == current,
        selectedColor: Colors.orange,
        backgroundColor: Colors.grey[900],
        labelStyle: TextStyle(color: e == current ? Colors.black : Colors.white),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: e == current ? Colors.orange : Colors.grey[700]!),
          borderRadius: BorderRadius.circular(8),
        ),
        onSelected: (_) => onChanged(e),
      )).toList(),
    );
  }
}
