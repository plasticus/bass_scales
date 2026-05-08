class MusicEngine {
  // ===========================================================================
  // 1. MUSICAL CONSTANTS & FORMULAS
  // ===========================================================================
  static const List<String> chromaticScale = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];
  static const List<String> intervals = ['1', 'b2', '2', 'b3', '3', '4', 'b5', '5', 'b6', '6', 'b7', '7'];

  static const Map<String, List<int>> scaleFormulas = {
    'Major': [0, 2, 4, 5, 7, 9, 11],
    'Natural Minor': [0, 2, 3, 5, 7, 8, 10],
    'Pentatonic Major': [0, 2, 4, 7, 9],
    'Pentatonic Minor': [0, 3, 5, 7, 10],
    'Blues': [0, 3, 5, 6, 7, 10],
    'Dorian': [0, 2, 3, 5, 7, 9, 10],
    'Mixolydian': [0, 2, 4, 5, 7, 9, 10],
    'Phrygian Dominant': [0, 1, 4, 5, 7, 8, 10],
    'Harmonic Major': [0, 2, 4, 5, 7, 8, 11],
    'Harmonic Minor': [0, 2, 3, 5, 7, 8, 11],
    'Melodic Minor': [0, 2, 3, 5, 7, 9, 11],
    'Prometheus': [0, 2, 4, 6, 9, 10],
    'Phrygian': [0, 1, 3, 5, 7, 8, 10],
    'Lydian': [0, 2, 4, 6, 7, 9, 11],
    'Locrian': [0, 1, 3, 5, 6, 8, 10],
    'Whole Tone': [0, 2, 4, 6, 8, 10],
    'Diminished': [0, 1, 3, 4, 6, 7, 9, 10],
    'Hungarian Minor': [0, 2, 3, 6, 7, 8, 11],
    'Enigmatic': [0, 1, 4, 6, 8, 10, 11],
    'Neapolitan Major': [0, 1, 3, 5, 7, 9, 11],
    'Augmented': [0, 3, 4, 7, 8, 11],
    'Super Locrian': [0, 1, 3, 4, 6, 8, 10],
    'Lydian Dominant': [0, 2, 4, 6, 7, 9, 10]
  };

  // ===========================================================================
  // 2. INSTRUMENT & GROUP CATEGORIES
  // ===========================================================================
  static const Map<String, List<String>> scaleGroups = {
    'essentials': ['Major', 'Natural Minor', 'Pentatonic Major', 'Pentatonic Minor', 'Blues'],
    'modes': ['Dorian', 'Phrygian', 'Lydian', 'Mixolydian', 'Locrian'],
    'laboratory': [
      'Harmonic Major', 'Harmonic Minor', 'Melodic Minor', 'Phrygian Dominant',
      'Hungarian Minor', 'Prometheus', 'Whole Tone', 'Diminished', 'Enigmatic',
      'Neapolitan Major', 'Augmented', 'Super Locrian', 'Lydian Dominant'
    ],
  };

  static const Map<String, Map<int, List<int>>> instrumentTunings = {
    'Bass': {
      4: [7, 2, 9, 4], 5: [7, 2, 9, 4, 11], 6: [0, 7, 2, 9, 4, 11],
      104: [7, 2, 9, 2], 105: [7, 2, 9, 4, 9],
    },
    'Guitar': {
      6: [4, 11, 7, 2, 9, 4], 7: [4, 11, 7, 2, 9, 4, 11], 106: [4, 11, 7, 2, 9, 2],
    }
  };

  // ===========================================================================
  // 3. ENGINE LOGIC
  // ===========================================================================
  static Set<String> calculateNotes(String root, String scaleName) {
    if (!scaleFormulas.containsKey(scaleName)) return {};
    List<int> offsets = scaleFormulas[scaleName]!;
    int rootIndex = chromaticScale.indexOf(root);
    return offsets.map((offset) => chromaticScale[(rootIndex + offset) % 12]).toSet();
  }

  static String getInterval(String root, String targetNote) {
    int rootIndex = chromaticScale.indexOf(root);
    int noteIndex = chromaticScale.indexOf(targetNote);
    int distance = (noteIndex - rootIndex + 12) % 12;
    return intervals[distance];
  }

  // ===========================================================================
  // 4. TRANSLATIONS (EN/ES)
  // ===========================================================================
  static const Map<String, Map<String, String>> translations = {
    'en': {
      'dashboard': 'DASHBOARD', 'scale_settings': 'SCALE SETTINGS', 'root': 'Root',
      'scale': 'Scale', 'labels': 'Labels', 'instrument': 'INSTRUMENT', 'type': 'Type',
      'strings': 'Strings', 'luthier_shop': "LUTHIER'S SHOP", 'wood': 'Wood',
      'inlays': 'Inlays', 'cosmic': 'COSMIC', 'starfield': 'Starfield',
      'performance': 'PERFORMANCE', 'keep_awake': 'Keep Awake', 'visit_website': 'Visit Website',
      'by_author': 'by', 'Rosewood': 'Rosewood', 'Maple': 'Maple', 'Clear': 'Clear',
      'Quasar': 'Quasar', 'Dots': 'Dots', 'Blocks': 'Blocks', 'None': 'None',
      'Notes': 'Notes', 'Intervals': 'Intervals', 'Bass': 'Bass', 'Guitar': 'Guitar',
      'essentials': 'THE ESSENTIALS', 'modes': 'THE MODES', 'laboratory': 'THE LABORATORY',
      'Major': 'Major (Ionian)', 'Natural Minor': 'Natural Minor (Aeolian)',
      'Pentatonic Major': 'Pentatonic Major', 'Pentatonic Minor': 'Pentatonic Minor',
      'Blues': 'Blues', 'Dorian': 'Dorian', 'Phrygian': 'Phrygian', 'Lydian': 'Lydian',
      'Mixolydian': 'Mixolydian', 'Locrian': 'Locrian', 'Harmonic Major': 'Harmonic Major',
      'Harmonic Minor': 'Harmonic Minor', 'Melodic Minor': 'Melodic Minor',
      'Phrygian Dominant': 'Phrygian Dominant', 'Hungarian Minor': 'Hungarian Minor',
      'Prometheus': 'Prometheus', 'Whole Tone': 'Whole Tone', 'Diminished': 'Diminished',
      'Enigmatic': 'Enigmatic', 'Neapolitan Major': 'Neapolitan Major', 'Augmented': 'Augmented',
      'Super Locrian': 'Super Locrian (Altered)', 'Lydian Dominant': 'Lydian Dominant',
    },
    'es': {
      'dashboard': 'TABLERO', 'scale_settings': 'AJUSTES DE ESCALA', 'root': 'Raíz',
      'scale': 'Escala', 'labels': 'Etiquetas', 'instrument': 'INSTRUMENTO', 'type': 'Tipo',
      'strings': 'Cuerdas', 'luthier_shop': 'TALLER DE LUTHIER', 'wood': 'Madera',
      'inlays': 'Incrustaciones', 'cosmic': 'CÓSMICO', 'starfield': 'Campo de Estrellas',
      'performance': 'RENDIMIENTO', 'keep_awake': 'Mantener Encendido', 'visit_website': 'Visitar Sitio Web',
      'by_author': 'por', 'Rosewood': 'Palo de Rosa', 'Maple': 'Arce', 'Clear': 'Transparente',
      'Quasar': 'Cuásar', 'Dots': 'Puntos', 'Blocks': 'Bloques', 'None': 'Ninguno',
      'Notes': 'Notas', 'Intervals': 'Intervalos', 'Bass': 'Bajo', 'Guitar': 'Guitarra',
      'essentials': 'LO ESENCIAL', 'modes': 'LOS MODOS', 'laboratory': 'EL LABORATORIO',
      'Major': 'Mayor (Jónico)', 'Natural Minor': 'Menor Natural (Eólico)',
      'Pentatonic Major': 'Pentatónica Mayor', 'Pentatonic Minor': 'Pentatónica Menor',
      'Blues': 'Blues', 'Dorian': 'Dórico', 'Phrygian': 'Frigio', 'Lydian': 'Lidio',
      'Mixolydian': 'Mixolidio', 'Locrian': 'Locrio', 'Harmonic Major': 'Mayor Armónica',
      'Harmonic Minor': 'Menor Armónica', 'Melodic Minor': 'Menor Melódica',
      'Phrygian Dominant': 'Frigio Dominante', 'Hungarian Minor': 'Menor Húngara',
      'Prometheus': 'Prometeo', 'Whole Tone': 'Escala de Tonos', 'Diminished': 'Disminuida',
      'Enigmatic': 'Enigmática', 'Neapolitan Major': 'Napolitana Mayor', 'Augmented': 'Aumentada',
      'Super Locrian': 'Superlocria (Alterada)', 'Lydian Dominant': 'Lidia Dominante',
    }
  };
}