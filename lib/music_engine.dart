class MusicEngine {
  // THE CHROMATIC BASELINE: The fundamental atomic frequencies of the audible universe.
  static const List<String> chromaticScale = [
    'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'
  ];

  // RELATIVE HARMONIC DISTANCES: The nomenclature for spatial relativity between nodes.
  static const List<String> intervals = [
    '1', 'b2', '2', 'b3', '3', '4', 'b5', '5', 'b6', '6', 'b7', '7'
  ];

  // RESONANCE BLUEPRINTS: Mathematical orbital patterns defining specific scalar dimensions.
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
  };

  // CATEGORIZATION MATRICES: Organizing the workbench for high-efficiency access.
  static const Map<String, List<String>> scaleGroups = {
    'essentials': ['Major', 'Natural Minor', 'Pentatonic Major', 'Pentatonic Minor', 'Blues'],
    'modes': ['Dorian', 'Phrygian', 'Lydian', 'Mixolydian', 'Locrian'],
    'laboratory': [
      'Harmonic Major',
      'Harmonic Minor',
      'Melodic Minor',
      'Phrygian Dominant',
      'Hungarian Minor',
      'Prometheus',
      'Whole Tone',
      'Diminished'
    ],
  };

  // VESSEL CALIBRATION MATRICES: Baseline frequency coordinates for standard exploration craft.
  static const Map<String, Map<int, List<int>>> instrumentTunings = {
    'Bass': {
      4: [7, 2, 9, 4],          // G, D, A, E
      5: [7, 2, 9, 4, 11],      // G, D, A, E, B
      6: [0, 7, 2, 9, 4, 11],   // C, G, D, A, E, B
    },
    'Guitar': {
      6: [4, 11, 7, 2, 9, 4],   // E, B, G, D, A, E
      7: [4, 11, 7, 2, 9, 4, 11], // E, B, G, D, A, E, B
    }
  };

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

  // LANGUAGES
  static const Map<String, Map<String, String>> translations = {
    'en': {
      'dashboard': 'DASHBOARD',
      'scale_settings': 'SCALE SETTINGS',
      'root': 'Root',
      'scale': 'Scale',
      'labels': 'Labels',
      'instrument': 'INSTRUMENT',
      'type': 'Type',
      'strings': 'Strings',
      'luthier_shop': "LUTHIER'S SHOP",
      'wood': 'Wood',
      'inlays': 'Inlays',
      'cosmic': 'COSMIC',
      'starfield': 'Starfield',
      'performance': 'PERFORMANCE',
      'keep_awake': 'Keep Awake',
      'visit_website': 'Visit Website',
      'by_author': 'by',
      'Rosewood': 'Rosewood',
      'Maple': 'Maple',
      'Clear': 'Clear',
      'Quasar': 'Quasar',
      'Dots': 'Dots',
      'Blocks': 'Blocks',
      'None': 'None',
      'Notes': 'Notes',
      'Intervals': 'Intervals',
      'Bass': 'Bass',
      'Guitar': 'Guitar',
      // Group Headers
      'essentials': 'THE ESSENTIALS',
      'modes': 'THE MODES',
      'laboratory': 'THE LABORATORY',
      // Scales with Parenthetical names
      'Major': 'Major (Ionian)',
      'Natural Minor': 'Natural Minor (Aeolian)',
      'Harmonic Major': 'Harmonic Major',
      'Phrygian': 'Phrygian',
      'Lydian': 'Lydian',
      'Locrian': 'Locrian',
      'Whole Tone': 'Whole Tone',
      'Diminished': 'Diminished',
      'Hungarian Minor': 'Hungarian Minor',
    },
    'es': {
      'dashboard': 'TABLERO',
      'scale_settings': 'AJUSTES DE ESCALA',
      'root': 'Raíz',
      'scale': 'Escala',
      'labels': 'Etiquetas',
      'instrument': 'INSTRUMENTO',
      'type': 'Type',
      'strings': 'Cuerdas',
      'luthier_shop': 'TALLER DE LUTHIER',
      'wood': 'Madera',
      'inlays': 'Incrustaciones',
      'cosmic': 'CÓSMICO',
      'starfield': 'Campo de Estrellas',
      'performance': 'RENDIMIENTO',
      'keep_awake': 'Mantener Encendido',
      'visit_website': 'Visitar Sitio Web',
      'by_author': 'por',
      'Rosewood': 'Palo de Rosa',
      'Maple': 'Arce',
      'Clear': 'Transparente',
      'Quasar': 'Cuásar',
      'Dots': 'Puntos',
      'Blocks': 'Bloques',
      'None': 'Ninguno',
      'Notes': 'Notas',
      'Intervals': 'Intervalos',
      'Bass': 'Bajo',
      'Guitar': 'Guitarra',
      // Group Headers
      'essentials': 'LO ESENCIAL',
      'modes': 'LOS MODOS',
      'laboratory': 'EL LABORATORIO',
      // Scales
      'Major': 'Mayor (Jónico)',
      'Natural Minor': 'Menor Natural (Eólico)',
      'Harmonic Major': 'Mayor Armónica',
      'Phrygian': 'Frigio',
      'Lydian': 'Lidio',
      'Locrian': 'Locrio',
      'Whole Tone': 'Escala de Tonos',
      'Diminished': 'Disminuida',
      'Hungarian Minor': 'Menor Húngara',
    }
  };
}