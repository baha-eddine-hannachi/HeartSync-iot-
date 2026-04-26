import 'package:flutter/material.dart';

class AlertScreen extends StatelessWidget {
  final String condition;
  final int bpm;
  final String time;

  const AlertScreen({
    super.key,
    this.condition = '--',
    this.bpm = 0,
    this.time = '',
  });

  @override
  Widget build(BuildContext context) {
    final isAbnormal = condition.toUpperCase() == 'ABNORMAL';
    final color      = isAbnormal ? const Color(0xFFFF3B5C) : const Color(0xFF2ECC71);
    final bgColor    = isAbnormal ? const Color(0xFFFFF0F3) : const Color(0xFFF0FFF8);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            // ── Status Hero Card ──────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: color.withOpacity(0.3), width: 1.5),
                boxShadow: [
                  BoxShadow(color: color.withOpacity(0.12), blurRadius: 20, offset: const Offset(0, 8)),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isAbnormal ? Icons.warning_amber_rounded : Icons.favorite,
                      color: color, size: 42,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isAbnormal ? 'Abnormal Detected' : 'All Good',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: color),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isAbnormal
                        ? 'An irregular heart rhythm was detected.\nPlease consult your doctor.'
                        : 'Your heart rhythm is normal.\nKeep up the healthy lifestyle!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.6),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Stats Row ─────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.favorite,
                    iconColor: Colors.red,
                    label: 'Heart Rate',
                    value: '$bpm',
                    unit: 'BPM',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.access_time,
                    iconColor: Colors.blue,
                    label: 'Detected At',
                    value: time.isEmpty ? 'Now' : time,
                    unit: '',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Tips Card ─────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAbnormal ? '  What to do now' : '  Stay healthy',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),
                  ..._tips(isAbnormal).map((tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 5),
                          width: 7, height: 7,
                          decoration: BoxDecoration(
                            color: color, shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(tip,
                              style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.5)),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),

            // ── Emergency Banner (only abnormal) ──────────────────────────
            if (isAbnormal) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF3B5C), Color(0xFFFF6584)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.local_hospital, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Alert Sent',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                          SizedBox(height: 2),
                          Text('Your doctor has been notified via Firebase.',
                              style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  List<String> _tips(bool isAbnormal) {
    if (isAbnormal) {
      return [
        'Stay calm and sit or lie down in a comfortable position.',
        'Avoid caffeine, alcohol, and physical exertion.',
        'Contact your cardiologist immediately if symptoms worsen.',
      ];
    }
    return [
      'Continue monitoring your heart rate regularly.',
      'Maintain a healthy diet and exercise routine.',
      'Stay hydrated and get enough sleep every night.',
    ];
  }
}

// ── Stat Card ─────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String unit;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 10),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                if (unit.isNotEmpty)
                  TextSpan(
                    text: ' $unit',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}