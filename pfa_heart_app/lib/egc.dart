import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class HeartSyncApp extends StatefulWidget {
  const HeartSyncApp({super.key});

  @override
  State<HeartSyncApp> createState() => _HeartSyncAppState();
}

class _HeartSyncAppState extends State<HeartSyncApp> {
  double bpm = 0;
  String prediction = '--';
  
  // This list will hold your REAL data to draw the wave
  List<double> bpmHistory = [];
  final int maxDataPoints = 30; // How many points to show on screen at once

  @override
  void initState() {
    super.initState();

    // Listen to Firebase Realtime Database
    DatabaseReference ref = FirebaseDatabase.instance.ref('users/user001/heart_data');
    
    ref.onChildAdded.listen(_onData);
    ref.onChildChanged.listen(_onData);
  }

  void _onData(DatabaseEvent event) {
    final data = event.snapshot.value;
    if (data == null) return;
    
    final entry = Map<String, dynamic>.from(data as Map);
    final newBpm = (entry['bpm'] ?? 0.0).toDouble();

    if (mounted && newBpm > 0) {
      setState(() {
        bpm = newBpm;
        prediction = (entry['prediction'] ?? '--').toString();
        
        // Add the real database value to our wave history
        bpmHistory.add(newBpm);
        
        // Keep the wave scrolling by removing old data when it gets too full
        if (bpmHistory.length > maxDataPoints) {
          bpmHistory.removeAt(0);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAbnormal = prediction.toUpperCase() == 'ABNORMAL';
    final waveColor = isAbnormal ? Colors.red : const Color(0xFF2ECC71);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // BPM display
            Text(
              bpm > 0 ? bpm.toStringAsFixed(1) : '--',
              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: waveColor,
              ),
            ),
            Text(
              'Real-Time BPM',
              style: TextStyle(fontSize: 18, color: Colors.grey[500]),
            ),
            const SizedBox(height: 8),
            Text(
              prediction,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: waveColor,
              ),
            ),

            const SizedBox(height: 40),

            // Real Data Graph
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CustomPaint(
                  painter: RealDataGraphPainter(
                    history: bpmHistory,
                    color: waveColor,
                  ),
                  size: Size.infinite,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RealDataGraphPainter extends CustomPainter {
  final List<double> history;
  final Color color;

  RealDataGraphPainter({
    required this.history,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw Grid lines
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.15)
      ..strokeWidth = 0.8;

    for (int i = 1; i < 6; i++) {
      canvas.drawLine(Offset(i * size.width / 6, 0),
          Offset(i * size.width / 6, size.height), gridPaint);
    }
    for (int i = 1; i < 4; i++) {
      canvas.drawLine(Offset(0, i * size.height / 4),
          Offset(size.width, i * size.height / 4), gridPaint);
    }

    // If we don't have enough data yet, don't draw the line
    if (history.isEmpty) return;

    // Set up the wave styling
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    
    // We want the graph to scale dynamically. Let's set a standard BPM range (e.g., 40 to 180)
    double minBpm = 40.0;
    double maxBpm = 180.0;

    // Calculate spacing between points on the X axis
    double xSpacing = size.width / (history.length > 1 ? history.length - 1 : 1);

    for (int i = 0; i < history.length; i++) {
      double currentBpm = history[i];
      
      // Clamp the values so they don't draw outside the box
      if (currentBpm < minBpm) currentBpm = minBpm;
      if (currentBpm > maxBpm) currentBpm = maxBpm;

      // Calculate X and Y coordinates
      double x = i * xSpacing;
      // Invert Y so higher BPM goes UP on the screen
      double y = size.height - ((currentBpm - minBpm) / (maxBpm - minBpm) * size.height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(RealDataGraphPainter old) => true; 
}