class MusicEngine {
  static const List<String> chromaticScale = [
    'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'
  ];

  static const Map<int, String> intervalNames = {
    0: 'R', 1: 'b2', 2: '2', 3: 'b3', 4: '3', 5: '4',
    6: 'b5', 7: '5', 8: 'b6', 9: '6', 10: 'b7', 11: '7'
  };

  static const Map<int, List<int>> tunings = {
    4: [7, 2, 9, 4],             // G, D, A, E
    5: [7, 2, 9, 4, 11],         // G, D, A, E, B
    6: [0, 7, 2, 9, 4, 11],      // C, G, D, A, E, B
  };

  static const Map<String, List<int>> scaleFormulas = {
    'Major': [2, 2, 1, 2, 2, 2, 1],
    'Natural Minor': [2, 1, 2, 2, 1, 2, 2],
    'Pentatonic Minor': [3, 2, 2, 3, 2],
    'Pentatonic Major': [2, 2, 3, 2, 3],
    'Blues': [3, 2, 1, 1, 3, 2],
    'Dorian': [2, 1, 2, 2, 2, 1, 2],
    'Mixolydian': [2, 2, 1, 2, 2, 1, 2],
    'Phrygian Dominant': [1, 3, 1, 2, 1, 2, 2],
    'Harmonic Minor': [2, 1, 2, 2, 1, 3, 1],
    'Melodic Minor': [2, 1, 2, 2, 2, 2, 1],
    'Prometheus': [2, 2, 2, 3, 1, 2],
  };

  // The Pure Function: No UI code allowed here!
  static Set<String> calculateNotes(String root, String scaleName) {
    if (!scaleFormulas.containsKey(scaleName)) return {};

    List<int> formula = scaleFormulas[scaleName]!;
    int rootIndex = chromaticScale.indexOf(root);

    Set<String> validNotes = {};
    validNotes.add(chromaticScale[rootIndex]);

    int currentIndex = rootIndex;
    for (int interval in formula) {
      currentIndex = (currentIndex + interval) % 12;
      validNotes.add(chromaticScale[currentIndex]);
    }
    return validNotes;
  }
}