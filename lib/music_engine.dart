class MusicEngine {
  static const List<String> chromaticScale = [
    'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'
  ];

  static const Map<int, String> intervalNames = {
    0: 'R', 1: 'b2', 2: '2', 3: 'b3', 4: '3', 5: '4',
    6: 'b5', 7: '5', 8: 'b6', 9: '6', 10: 'b7', 11: '7'
  };

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

  static const Map<String, List<int>> scaleFormulas = {
    'Major': [0, 2, 4, 5, 7, 9, 11],
    'Natural Minor': [0, 2, 3, 5, 7, 8, 10],
    'Pentatonic Minor': [0, 3, 5, 7, 10],
    'Pentatonic Major': [0, 2, 4, 7, 9],
    'Blues': [0, 3, 5, 6, 7, 10],
    'Dorian': [0, 2, 3, 5, 7, 9, 10],
    'Mixolydian': [0, 2, 4, 5, 7, 9, 10],
    'Phrygian Dominant': [0, 1, 4, 5, 7, 8, 10],
    'Harmonic Minor': [0, 2, 3, 5, 7, 8, 11],
    'Melodic Minor': [0, 2, 3, 5, 7, 9, 11],
    'Prometheus': [0, 2, 4, 6, 9, 10],
  };

  // The Pure Function: No UI code allowed here!
  static Set<String> calculateNotes(String root, String scaleName) {
    if (!scaleFormulas.containsKey(scaleName)) return {};

    List<int> offsets = scaleFormulas[scaleName]!;
    int rootIndex = chromaticScale.indexOf(root);

    return offsets.map((offset) {
      return chromaticScale[(rootIndex + offset) % 12];
    }).toSet();
  }
}