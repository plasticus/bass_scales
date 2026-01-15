import 'package:flutter/material.dart';
import 'music_engine.dart'; // <--- Connects to the new file

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
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) return Colors.deepPurple;
            return Colors.grey;
          }),
          trackColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) return Colors.deepPurple.shade200;
            return Colors.grey.shade800;
          }),
        ),
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

  // STATE VARIABLES (Data now lives in MusicEngine)
  String selectedRoot = 'C';
  String selectedScale = 'Major';
  int stringCount = 4;
  bool showIntervals = false;

  @override
  Widget build(BuildContext context) {
    // ASK THE ENGINE FOR DATA
    Set<String> activeNotes = MusicEngine.calculateNotes(selectedRoot, selectedScale);
    List<int> currentTuning = MusicEngine.tunings[stringCount]!;

    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        width: 320,
        backgroundColor: Colors.grey[900],
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Settings", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 30),

                const Text("ROOT NOTE", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                DropdownButton<String>(
                  isExpanded: true,
                  value: selectedRoot,
                  dropdownColor: Colors.grey[800],
                  style: const TextStyle(color: Colors.white, fontSize: 22),
                  underline: Container(height: 2, color: Colors.deepPurple),
                  items: MusicEngine.chromaticScale.map((n) => DropdownMenuItem(value: n, child: Text(n))).toList(),
                  onChanged: (v) => setState(() => selectedRoot = v!),
                ),

                const SizedBox(height: 30),

                const Text("SCALE TYPE", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                DropdownButton<String>(
                  isExpanded: true,
                  value: selectedScale,
                  dropdownColor: Colors.grey[800],
                  style: const TextStyle(color: Colors.amber, fontSize: 22),
                  underline: Container(height: 2, color: Colors.amber),
                  items: MusicEngine.scaleFormulas.keys.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (v) => setState(() => selectedScale = v!),
                ),

                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("SHOW INTERVALS", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                    Switch(
                      value: showIntervals,
                      onChanged: (val) => setState(() => showIntervals = val),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                const Text("STRINGS", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [4, 5, 6].map((count) {
                    bool isSelected = (stringCount == count);
                    return GestureDetector(
                      onTap: () => setState(() => stringCount = count),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.deepPurple : Colors.grey[800],
                          borderRadius: BorderRadius.circular(8),
                          border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
                        ),
                        child: Text(
                          "$count",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.grey[400]
                          )
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 40),

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
              chromaticScale: MusicEngine.chromaticScale,
              stringOpenNotes: currentTuning,
              rootNote: selectedRoot,
              activeNotes: activeNotes,
              showIntervals: showIntervals,
              intervalNames: MusicEngine.intervalNames,
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
  final bool showIntervals;
  final Map<int, String> intervalNames;

  FretboardPainter({
    required this.chromaticScale,
    required this.stringOpenNotes,
    required this.rootNote,
    required this.activeNotes,
    required this.showIntervals,
    required this.intervalNames,
  });

  @override
  void paint(Canvas canvas, Size size) {
    int stringCount = stringOpenNotes.length;
    double dotRadius = stringCount == 4 ? 24.0 : (stringCount == 5 ? 21.0 : 18.0);
    double fontSize = stringCount == 4 ? 20.0 : 16.0;

    final paintLine = Paint()..color = Colors.grey..strokeWidth = 3;
    final paintString = Paint()..color = Colors.white..strokeWidth = stringCount > 5 ? 3 : 4;
    final paintFret = Paint()..color = Colors.grey[400]!..strokeWidth = 5;
    final paintNut = Paint()..color = Colors.white..strokeWidth = 10;
    final paintInlay = Paint()..color = Colors.white.withOpacity(0.18)..style = PaintingStyle.fill;

    double topPadding = 35.0;
    double bottomPadding = 50.0;
    double boardHeight = size.height - topPadding - bottomPadding;
    double stringSpacing = boardHeight / (stringCount - 1);
    double fretWidth = size.width / 25;

    List<int> singleDots = [3, 5, 7, 9, 15, 17, 19, 21];
    List<int> doubleDots = [12, 24];

    double midY = topPadding + (boardHeight / 2);

    for (int fret in singleDots) {
      double x = (fret * fretWidth) - (fretWidth / 2);
      canvas.drawCircle(Offset(x, midY), 18, paintInlay);
    }
    for (int fret in doubleDots) {
      double x = (fret * fretWidth) - (fretWidth / 2);
      double offset = stringCount == 4 ? 60 : 45;
      canvas.drawCircle(Offset(x, midY - offset), 18, paintInlay);
      canvas.drawCircle(Offset(x, midY + offset), 18, paintInlay);
    }

    for (int i = 0; i <= 24; i++) {
      double x = i * fretWidth;
      double lineBottom = topPadding + boardHeight;
      if (i == 0) {
        canvas.drawLine(Offset(x, topPadding), Offset(x, lineBottom), paintNut);
      } else {
        canvas.drawLine(Offset(x, topPadding), Offset(x, lineBottom), paintFret);
      }
      if (i > 0) {
        TextSpan span = TextSpan(style: const TextStyle(color: Colors.grey, fontSize: 24, fontWeight: FontWeight.bold), text: "$i");
        TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
        tp.layout();
        tp.paint(canvas, Offset(x - (fretWidth / 2) - (tp.width / 2), lineBottom + 15));
      }
    }

    for (int i = 0; i < stringCount; i++) {
      double y = topPadding + (i * stringSpacing);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paintString);
    }

    int rootIndex = chromaticScale.indexOf(rootNote);

    for (int stringIdx = 0; stringIdx < stringCount; stringIdx++) {
      int openNoteIndex = stringOpenNotes[stringIdx];
      for (int fret = 0; fret <= 24; fret++) {
        int currentNoteIndex = (openNoteIndex + fret) % 12;
        String noteName = chromaticScale[currentNoteIndex];

        if (activeNotes.contains(noteName)) {
          double x = fret == 0 ? 0 : (fret * fretWidth) - (fretWidth / 2);
          double y = topPadding + (stringIdx * stringSpacing);
          bool isRoot = (noteName == rootNote);

          Paint dotPaint = Paint()..color = isRoot ? Colors.red : Colors.black..style = PaintingStyle.fill;
          Paint borderPaint = Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 3;

          canvas.drawCircle(Offset(x, y), dotRadius, dotPaint);
          canvas.drawCircle(Offset(x, y), dotRadius, borderPaint);

          String textToDraw = noteName;
          if (showIntervals) {
            int semitoneDistance = (currentNoteIndex - rootIndex + 12) % 12;
            textToDraw = intervalNames[semitoneDistance] ?? "?";
          }

          TextSpan span = TextSpan(style: TextStyle(color: Colors.white, fontSize: fontSize, fontWeight: FontWeight.bold), text: textToDraw);
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