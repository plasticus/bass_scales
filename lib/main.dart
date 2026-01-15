import 'package:flutter/material.dart';

void main() {
  runApp(const BassScalesApp());
}

class BassScalesApp extends StatelessWidget {
  const BassScalesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bass Fretboard Visualizer',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: const FretboardPage(),
    );
  }
}

class FretboardPage extends StatefulWidget {
  const FretboardPage({super.key});

  @override
  State<FretboardPage> createState() => _FretboardPageState();
}

class _FretboardPageState extends State<FretboardPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // --- DATA ---
  final List<String> chromaticScale = [
    'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'
  ];

  final List<int> stringOpenNotes = [7, 2, 9, 4]; // G, D, A, E

  final Map<String, List<int>> scaleFormulas = {
    'Major': [2, 2, 1, 2, 2, 2, 1],
    'Natural Minor': [2, 1, 2, 2, 1, 2, 2],
    'Pentatonic Minor': [3, 2, 2, 3, 2],
    'Pentatonic Major': [2, 2, 3, 2, 3],
    'Blues': [3, 2, 1, 1, 3, 2],
    'Dorian': [2, 1, 2, 2, 2, 1, 2],
    'Mixolydian': [2, 2, 1, 2, 2, 1, 2],
  };

  String selectedRoot = 'C';
  String selectedScale = 'Mixolydian';

  // --- LOGIC ---
  Set<String> calculateScaleNotes() {
    List<int> formula = scaleFormulas[selectedScale]!;
    int rootIndex = chromaticScale.indexOf(selectedRoot);

    Set<String> validNotes = {};
    validNotes.add(chromaticScale[rootIndex]);

    int currentIndex = rootIndex;
    for (int interval in formula) {
      currentIndex = (currentIndex + interval) % 12;
      validNotes.add(chromaticScale[currentIndex]);
    }
    return validNotes;
  }

  @override
  Widget build(BuildContext context) {
    Set<String> activeNotes = calculateScaleNotes();

    return Scaffold(
      key: _scaffoldKey,

      // DRAWER MENU (Wrapped in ScrollView to fix overflow)
      drawer: Drawer(
        width: 300,
        backgroundColor: Colors.grey[900],
        child: SingleChildScrollView( // <--- THIS FIXES THE STRIPED ERROR
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Settings", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 40),

                const Text("ROOT NOTE", style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold)),
                DropdownButton<String>(
                  isExpanded: true,
                  value: selectedRoot,
                  dropdownColor: Colors.grey[800],
                  style: const TextStyle(color: Colors.white, fontSize: 22),
                  underline: Container(height: 2, color: Colors.deepPurple),
                  items: chromaticScale.map((n) => DropdownMenuItem(value: n, child: Text(n))).toList(),
                  onChanged: (v) => setState(() => selectedRoot = v!),
                ),

                const SizedBox(height: 40),

                const Text("SCALE TYPE", style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold)),
                DropdownButton<String>(
                  isExpanded: true,
                  value: selectedScale,
                  dropdownColor: Colors.grey[800],
                  style: const TextStyle(color: Colors.amber, fontSize: 22),
                  underline: Container(height: 2, color: Colors.amber),
                  items: scaleFormulas.keys.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (v) => setState(() => selectedScale = v!),
                ),

                const SizedBox(height: 60), // Space before button

                Center(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.check),
                    label: const Text("Done"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.tune),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,

      body: Container(
        color: const Color(0xFF121212),
        alignment: Alignment.centerLeft,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: CustomPaint(
            size: const Size(3200, 350),
            painter: FretboardPainter(
              chromaticScale: chromaticScale,
              stringOpenNotes: stringOpenNotes,
              rootNote: selectedRoot,
              activeNotes: activeNotes,
            ),
          ),
        ),
      ),
    );
  }
}

class FretboardPainter extends CustomPainter {
  final List<String> chromaticScale;
  final List<int> stringOpenNotes;
  final String rootNote;
  final Set<String> activeNotes;

  FretboardPainter({
    required this.chromaticScale,
    required this.stringOpenNotes,
    required this.rootNote,
    required this.activeNotes,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // --- STYLES ---
    final paintLine = Paint()
      ..color = Colors.grey
      ..strokeWidth = 3;

    final paintString = Paint()
      ..color = Colors.white
      ..strokeWidth = 4;

    final paintFret = Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = 5;

    final paintNut = Paint()
      ..color = Colors.white
      ..strokeWidth = 10;

    final paintInlay = Paint()
      // Slightly more visible (0.12 -> 0.18) since you asked!
      ..color = Colors.white.withOpacity(0.18)
      ..style = PaintingStyle.fill;

    // --- METRICS ---
    double topPadding = 35.0;
    double bottomPadding = 50.0;

    double boardHeight = size.height - topPadding - bottomPadding;
    double stringSpacing = boardHeight / 3;

    double fretWidth = size.width / 25;

    // 0. DRAW INLAYS (Background Markers)
    List<int> singleDots = [3, 5, 7, 9, 15, 17, 19, 21];
    List<int> doubleDots = [12, 24];

    double midY = topPadding + (boardHeight / 2);

    // Draw Single Dots (Center of board)
    for (int fret in singleDots) {
      double x = (fret * fretWidth) - (fretWidth / 2);
      canvas.drawCircle(Offset(x, midY), 18, paintInlay);
    }

    // Draw Double Dots (Spread vertically)
    for (int fret in doubleDots) {
      double x = (fret * fretWidth) - (fretWidth / 2);

      // FIX: Move them into the outer gaps (between strings 1-2 and 3-4)
      // This puts them nicely away from the center strings
      double topDotY = midY - stringSpacing;
      double bottomDotY = midY + stringSpacing;

      canvas.drawCircle(Offset(x, topDotY), 18, paintInlay);
      canvas.drawCircle(Offset(x, bottomDotY), 18, paintInlay);
    }

    // 1. DRAW FRETS
    for (int i = 0; i <= 24; i++) {
      double x = i * fretWidth;

      double lineBottom = topPadding + boardHeight;

      if (i == 0) {
        canvas.drawLine(Offset(x, topPadding), Offset(x, lineBottom), paintNut);
      } else {
        canvas.drawLine(Offset(x, topPadding), Offset(x, lineBottom), paintFret);
      }

      if (i > 0) {
        TextSpan span = TextSpan(
          style: const TextStyle(color: Colors.grey, fontSize: 24, fontWeight: FontWeight.bold),
          text: "$i"
        );
        TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
        tp.layout();
        tp.paint(canvas, Offset(x - (fretWidth / 2) - (tp.width / 2), lineBottom + 15));
      }
    }

    // 2. DRAW STRINGS
    for (int i = 0; i < 4; i++) {
      double y = topPadding + (i * stringSpacing);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paintString);
    }

    // 3. DRAW NOTES
    for (int stringIdx = 0; stringIdx < 4; stringIdx++) {
      int openNoteIndex = stringOpenNotes[stringIdx];

      for (int fret = 0; fret <= 24; fret++) {
        int currentNoteIndex = (openNoteIndex + fret) % 12;
        String noteName = chromaticScale[currentNoteIndex];

        if (activeNotes.contains(noteName)) {
          double x = fret == 0 ? 0 : (fret * fretWidth) - (fretWidth / 2);
          double y = topPadding + (stringIdx * stringSpacing);

          bool isRoot = (noteName == rootNote);

          double dotRadius = 24.0;

          Paint dotPaint = Paint()
            ..color = isRoot ? Colors.red : Colors.black
            ..style = PaintingStyle.fill;

          Paint borderPaint = Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3;

          canvas.drawCircle(Offset(x, y), dotRadius, dotPaint);
          canvas.drawCircle(Offset(x, y), dotRadius, borderPaint);

          TextSpan span = TextSpan(
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold
            ),
            text: noteName
          );
          TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
          tp.layout();
          tp.paint(canvas, Offset(x - (tp.width / 2), y - (tp.height / 2)));
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}