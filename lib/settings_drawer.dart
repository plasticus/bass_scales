import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'music_engine.dart';

class SettingsDrawer extends StatelessWidget {
  final String languageCode;
  final String rootNote;
  final String scaleType;
  final String labelMode;
  final String instrument;
  final int stringCount;
  final bool isLeftHanded;
  final String woodType;
  final String inlayStyle;
  final bool showStars;
  final bool keepAwake;
  final Function(String, dynamic) onSettingChanged;
  final VoidCallback onToggleWakelock;

  const SettingsDrawer({
    super.key,
    required this.languageCode,
    required this.rootNote,
    required this.scaleType,
    required this.labelMode,
    required this.instrument,
    required this.stringCount,
    required this.isLeftHanded,
    required this.woodType,
    required this.inlayStyle,
    required this.showStars,
    required this.keepAwake,
    required this.onSettingChanged,
    required this.onToggleWakelock,
  });

  String t(String key) => MusicEngine.translations[languageCode]?[key] ?? key;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 400,
      child: ListView(
        children: [
          DrawerHeader(child: Center(child: Text(t('dashboard'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)))),
          _sectionHeader(t('scale_settings')),
          _buildDropdown(t('root'), rootNote, MusicEngine.chromaticScale, (v) => onSettingChanged('rootNote', v)),
          _buildDropdown(t('scale'), scaleType, MusicEngine.scaleFormulas.keys.toList(), (v) => onSettingChanged('scaleType', v)),
          _buildDropdown(t('labels'), labelMode, ['Notes', 'Intervals', 'None'], (v) => onSettingChanged('labelMode', v)),
          _sectionHeader(t('instrument')),
          _buildToggle(t('type'), ['Bass', 'Guitar'], instrument, (v) => onSettingChanged('instrument', v), formatLabel: (label) => t(label)),
          _buildStringCountToggle(),
          SwitchListTile(
            title: const Text('Left-Handed Mode'),
            secondary: const Icon(Icons.swap_horiz, color: Colors.orange),
            value: isLeftHanded,
            onChanged: (v) => onSettingChanged('isLeftHanded', v),
          ),
          _sectionHeader(t('luthier_shop')),
          _buildToggle(t('wood'), ['Rosewood', 'Maple', 'Clear'], woodType, (v) => onSettingChanged('woodType', v), formatLabel: (label) => t(label)),
          _buildDropdown(t('inlays'), inlayStyle, ['Quasar', 'Dots', 'Blocks', 'None'], (v) => onSettingChanged('inlayStyle', v)),
          _sectionHeader(t('cosmic')),
          SwitchListTile(
            title: Text(t('starfield')),
            value: showStars,
            onChanged: (v) => onSettingChanged('showStars', v),
          ),
          _sectionHeader(t('performance')),
          SwitchListTile(
            title: Text(t('keep_awake')),
            value: keepAwake,
            onChanged: (v) => onToggleWakelock(),
          ),
          _sectionHeader('LANGUAGE / IDIOMA'),
          _buildToggle('Lang', ['en', 'es'], languageCode, (v) => onSettingChanged('languageCode', v)),
          ListTile(
            title: Text("${t('by_author')} LowEndLabs"),
            subtitle: Text(t('visit_website')),
            onTap: () => launchUrl(Uri.parse('https://lowendlabs.oaf.monster')),
          ),
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
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(t(e)))).toList(),
        onChanged: onChanged
      ),
    );
  }

  Widget _buildToggle(String label, List<String> options, String current, ValueChanged<String> onChanged, {String Function(String)? formatLabel}) {
    return ListTile(
      title: Text(label),
      trailing: Container(
        constraints: const BoxConstraints(maxWidth: 160),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: ToggleButtons(
            isSelected: options.map((e) => e == current).toList(),
            onPressed: (index) => onChanged(options[index]),
            children: options.map((e) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(formatLabel != null ? formatLabel(e) : e)
            )).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildStringCountToggle() {
    List<int> options = (instrument == 'Guitar') ? [6, 7] : [4, 5, 6];
    return ListTile(
      title: Text(t('strings')),
      trailing: Container(
        constraints: const BoxConstraints(maxWidth: 140),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: ToggleButtons(
            isSelected: options.map((e) => e == stringCount).toList(),
            onPressed: (index) => onSettingChanged('stringCount', options[index]),
            children: options.map((e) => Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text(e.toString()))).toList(),
          ),
        ),
      ),
    );
  }
}