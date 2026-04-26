import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'login.dart';
import 'egc.dart';
import 'alert.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  String prediction = '--';
  double confidence = 0.0;
  double bpm        = 0.0;

  @override
  void initState() {
    super.initState();

    // ✅ Keep reference alive — never loses connection
    FirebaseDatabase.instance
        .ref('users/user001/heart_data')
        .onChildAdded
        .listen(_onNewData);

    FirebaseDatabase.instance
        .ref('users/user001/heart_data')
        .onChildChanged
        .listen(_onNewData);
  }

  void _onNewData(DatabaseEvent event) {
    final data = event.snapshot.value;
    if (data == null) return;
    final entry = Map<String, dynamic>.from(data as Map);
    if (mounted) {
      setState(() {
        bpm        = (entry['bpm']        ?? 0.0).toDouble();
        confidence = (entry['confidence'] ?? 0.0).toDouble();
        prediction = (entry['prediction'] ?? '--').toString();
      });
    }
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Widget _monitorPage() {
    final isAbnormal  = prediction.toUpperCase() == 'ABNORMAL';
    final bgColor     = isAbnormal ? const Color(0xFFFFEBEE) : Colors.white;
    final statusColor = isAbnormal ? Colors.red : Colors.green;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      color: bgColor,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: statusColor, width: 2),
            ),
            child: Column(
              children: [
                Icon(
                  isAbnormal ? Icons.warning_amber_rounded : Icons.check_circle,
                  color: statusColor, size: 64,
                ),
                const SizedBox(height: 12),
                Text(
                  prediction,
                  style: TextStyle(
                    fontSize: 32, fontWeight: FontWeight.bold, color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _DataRow(label: 'BPM',        value: bpm.toStringAsFixed(1),                       icon: Icons.favorite,  color: Colors.red),
          const SizedBox(height: 12),
          _DataRow(label: 'Confidence', value: '${(confidence * 100).toStringAsFixed(1)}%',  icon: Icons.analytics, color: Colors.blue),
          const SizedBox(height: 24),
          if (isAbnormal)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
              child: const Row(
                children: [
                  Icon(Icons.notifications_active, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Abnormal rhythm detected!',
                      style: TextStyle(color: Colors.white, fontSize: 15)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAbnormal = prediction.toUpperCase() == 'ABNORMAL';
    final bgColor    = isAbnormal ? const Color(0xFFFFEBEE) : Colors.white;

    final pages = [
      _monitorPage(),
      const HeartSyncApp(),           // ✅ pass bpm to ECG page
      AlertScreen(
        condition: prediction,
        bpm: bpm.toInt(),
        time: TimeOfDay.now().format(context),
      ),
    ];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text('HeartSync', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: logout,
          ),
        ],
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.monitor_heart), label: 'Monitor'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart),    label: 'ECG'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Alerts'),
        ],
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _DataRow({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 6)],
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          const Spacer(),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}