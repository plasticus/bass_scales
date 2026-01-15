import 'package:flutter_test/flutter_test.dart';
import 'package:bass_scales/music_engine.dart'; // This assumes your pubspec name is 'bass_scales'

void main() {
  group('Music Engine Logic', () {

    // TEST 1: The Standard Check
    test('C Major should contain standard natural notes', () {
      final notes = MusicEngine.calculateNotes('C', 'Major');

      // C Major = C, D, E, F, G, A, B
      expect(notes.contains('C'), true);
      expect(notes.contains('E'), true); // The Major 3rd
      expect(notes.contains('G'), true); // The Perfect 5th
      expect(notes.contains('F#'), false); // Should NOT be here
      expect(notes.length, 7);
    });

    // TEST 2: The Relative Minor Check
    test('A Natural Minor should be all white keys (No Sharps)', () {
      final notes = MusicEngine.calculateNotes('A', 'Natural Minor');

      // A Minor = A, B, C, D, E, F, G
      expect(notes.contains('C'), true);
      expect(notes.contains('G#'), false); // Harmonic minor has G#, Natural does not
      expect(notes.length, 7);
    });

    // TEST 3: The "Prometheus" Feature Check
    test('Prometheus scale should be Hexatonic (6 notes)', () {
      final notes = MusicEngine.calculateNotes('C', 'Prometheus');

      // Prometheus formula: R, 2, 3, #4, 6, b7
      // In C: C, D, E, F#, A, A# (Bb)
      expect(notes.length, 6); // It is a hexatonic scale (6 notes)
      expect(notes.contains('F#'), true); // The mystic raised 4th
      expect(notes.contains('A#'), true); // The dominant 7th (Bb)
    });

    // TEST 4: Error Handling
    test('Invalid scale name returns empty set', () {
      final notes = MusicEngine.calculateNotes('C', 'FakeScaleName');
      expect(notes.isEmpty, true);
    });

  });
}