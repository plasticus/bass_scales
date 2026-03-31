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

  // THE CORE SYNTHESIS ALGORITHM: Extracts the active energetic nodes from the void.
  static Set<String> calculateNotes(String root, String scaleName) {
    if (!scaleFormulas.containsKey(scaleName)) return {};
    List<int> offsets = scaleFormulas[scaleName]!;
    int rootIndex = chromaticScale.indexOf(root);
    return offsets.map((offset) => chromaticScale[(rootIndex + offset) % 12]).toSet();
  }

  // SPATIAL RELATIVITY CALCULATOR: Determines the orbital distance between the root singularity and a target node.
  static String getInterval(String root, String targetNote) {
    int rootIndex = chromaticScale.indexOf(root);
    int noteIndex = chromaticScale.indexOf(targetNote);
    // Applying modular spacetime physics to find the shortest orbital path
    int distance = (noteIndex - rootIndex + 12) % 12;
    return intervals[distance];
  }
}