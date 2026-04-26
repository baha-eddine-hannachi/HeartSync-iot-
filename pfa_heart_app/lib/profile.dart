import 'package:flutter/material.dart';
import 'package:pfa_heart_app/alert.dart' show AlertScreen;
import 'package:pfa_heart_app/egc.dart';
import 'package:pfa_heart_app/home.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1A1F3A).withOpacity(0.95),
              const Color(0xFF2D1B42).withOpacity(0.95),
              const Color(0xFF1A1F3A).withOpacity(0.95),
            ],
          ),
        ),
        width: double.infinity,
        height: double.infinity,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeroSection(context),
                _buildStatsRow(),
                const SizedBox(height: 20),
                _buildDeviceCard(),
                const SizedBox(height: 12),
                _buildMenuSection(context),
                const SizedBox(height: 90),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildNavBar(context),
    );
  }

  // ═══════════════════════════════════════════════
  // HERO SECTION
  // ═══════════════════════════════════════════════
  Widget _buildHeroSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2D1B3D).withOpacity(0.95),
            const Color(0xFF1A1F3A).withOpacity(0.95),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20),
        ],
      ),
      child: Column(
        children: [
          // Top row: back + edit
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    border: Border.all(color: Colors.white.withOpacity(0.12)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      '←',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ),
              const Text(
                'My Profile',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF5A7E).withOpacity(0.15),
                    border: Border.all(
                      color: const Color(0xFFFF5A7E).withOpacity(0.3),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text('✏️', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Avatar
          Stack(
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF5A7E), Color(0xFFFF4757)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF5A7E).withOpacity(0.45),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.person, color: Colors.white, size: 42),
                ),
              ),
              // Online indicator
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF1A1F3A),
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withOpacity(0.5),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Name
          const Text(
            'UserName',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 4),

          // ID badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFF5A7E).withOpacity(0.15),
              border: Border.all(
                color: const Color(0xFFFF5A7E).withOpacity(0.3),
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'PATIENT · P-001',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 10,
                letterSpacing: 1,
                color: Color(0xFFFF5A7E),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Connected badges row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ConnectedBadge(
                icon: Icons.check_circle,
                label: 'Connected',
                color: const Color(0xFF10B981),
              ),
              const SizedBox(width: 10),
              _ConnectedBadge(
                icon: Icons.electrical_services,
                label: 'ESP-32',
                color: const Color(0xFF5B7EFF),
              ),
              const SizedBox(width: 10),
              _ConnectedBadge(
                icon: Icons.memory,
                label: 'TinyML',
                color: const Color(0xFFFF5A7E),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // STATS ROW
  // ═══════════════════════════════════════════════
  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        children: [
          Expanded(
            child: _StatMini(
              icon: Icons.favorite,
              iconColor: const Color(0xFFFF5A7E),
              bg: const Color(0xFFFEE2E8),
              value: '72',
              label: 'Avg BPM',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatMini(
              icon: Icons.bar_chart,
              iconColor: const Color(0xFF5B7EFF),
              bg: const Color(0xFFE2E9FF),
              value: '26',
              label: 'Readings',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatMini(
              icon: Icons.warning,
              iconColor: const Color(0xFFFFA500),
              bg: const Color(0xFFFFF4E2),
              value: '2',
              label: 'Alerts',
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // DEVICE CARD
  // ═══════════════════════════════════════════════
  Widget _buildDeviceCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFF5A7E), width: 1),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E9FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Icon(
                  Icons.electrical_services,
                  color: Color(0xFF5B7EFF),
                  size: 26,
                ),
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ESP-32 · HS-1042',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Last sync · Just now',
                    style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            ),
            // Signal dots
            Row(
              children: List.generate(
                4,
                (i) => Container(
                  width: 4,
                  height: 6.0 + i * 3,
                  margin: const EdgeInsets.only(left: 3),
                  decoration: BoxDecoration(
                    color: i < 3
                        ? const Color(0xFF10B981)
                        : const Color(0xFF10B981).withOpacity(0.25),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // MENU SECTION
  // ═══════════════════════════════════════════════
  Widget _buildMenuSection(BuildContext context) {
    final items = [
      _MenuItem(
        icon: Icons.person_outline,
        iconColor: const Color(0xFFFF5A7E),
        iconBg: const Color(0xFFFEE2E8),
        title: 'Personal Info',
        subtitle: 'Edit your details',
        onTap: () {},
      ),
      _MenuItem(
        icon: Icons.electrical_services,
        iconColor: const Color(0xFF5B7EFF),
        iconBg: const Color(0xFFE2E9FF),
        title: 'Device Settings',
        subtitle: 'HS-1042 connected',
        onTap: () {},
      ),
      _MenuItem(
        icon: Icons.notifications_outlined,
        iconColor: const Color(0xFFFFA500),
        iconBg: const Color(0xFFFFF4E2),
        title: 'Notifications',
        subtitle: 'Manage alerts',
        onTap: () {},
      ),
      _MenuItem(
        icon: Icons.lock_outline,
        iconColor: const Color(0xFF10B981),
        iconBg: const Color(0xFFDFFCF0),
        title: 'Security',
        subtitle: 'Password & privacy',
        onTap: () {},
      ),
      _MenuItem(
        icon: Icons.history,
        iconColor: const Color(0xFF5B7EFF),
        iconBg: const Color(0xFFE2E9FF),
        title: 'Medical History',
        subtitle: 'View all readings',
        onTap: () {},
      ),
      _MenuItem(
        icon: Icons.logout,
        iconColor: const Color(0xFFEF4444),
        iconBg: const Color(0xFFFEE2E2),
        title: 'Sign Out',
        subtitle: 'See you later!',
        titleColor: const Color(0xFFEF4444),
        borderColor: const Color(0xFFEF4444),
        onTap: () {
          showDialog(context: context, builder: (_) => _SignOutDialog());
        },
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildMenuItem(item),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(_MenuItem item) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: item.borderColor ?? const Color(0xFFFF5A7E),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: item.iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, color: item.iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: item.titleColor ?? Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[300], size: 20),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // BOTTOM NAVBAR
  // ═══════════════════════════════════════════════
  Widget _buildNavBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavItem(
                icon: Icons.home,
                label: 'HOME',
                isSelected: _selectedIndex == 0,
                onTap: () {
                  setState(() => _selectedIndex = 0);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                },
              ),
              _NavItem(
                icon: Icons.show_chart,
                label: 'ECG',
                isSelected: _selectedIndex == 1,
                onTap: () {
                  setState(() => _selectedIndex = 1);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const HeartSyncApp(),
                    ),
                  );
                },
              ),
              _NavItem(
                icon: Icons.notifications,
                label: 'ALERTS',
                isSelected: _selectedIndex == 2,
                badge: true,
                onTap: () {
                  setState(() => _selectedIndex = 2);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const AlertScreen()),
                  );
                },
              ),
              _NavItem(
                icon: Icons.person,
                label: 'PROFILE',
                isSelected: _selectedIndex == 3,
                onTap: () => setState(() => _selectedIndex = 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// SIGN OUT DIALOG
// ══════════════════════════════════════════════════════════════════════════
class _SignOutDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text('🚪', style: TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sign Out?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You will be logged out of your HeartSync account.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                // Cancel
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Sign out
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFEF4444).withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'Sign Out',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// HELPER MODELS
// ══════════════════════════════════════════════════════════════════════════
class _MenuItem {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final Color? titleColor;
  final Color? borderColor;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.titleColor,
    this.borderColor,
  });
}

// ══════════════════════════════════════════════════════════════════════════
// REUSABLE WIDGETS  (same style as your existing HomeScreen widgets)
// ══════════════════════════════════════════════════════════════════════════

class _ConnectedBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _ConnectedBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: color.withOpacity(0.15),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatMini extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bg;
  final String value;
  final String label;

  const _StatMini({
    required this.icon,
    required this.iconColor,
    required this.bg,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFF5A7E), width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool badge;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badge = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFFFF5A7E) : Colors.grey[400],
                size: 24,
              ),
              if (badge)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFFF5A7E),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFFFF5A7E) : Colors.grey[500],
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
