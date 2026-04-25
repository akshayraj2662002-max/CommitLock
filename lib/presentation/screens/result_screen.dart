import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/session_model.dart';
import '../providers/session_provider.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  SessionModel? _session;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sessionProvider = context.read<SessionProvider>();
      final session = sessionProvider.finishAndGetResult();
      if (session == null) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
        return;
      }
      setState(() {
        _session = session;
      });
      _animController.forward();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sessionProvider = context.watch<SessionProvider>();

    if (_session == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isCompleted = _session!.status == 'completed';
    final plannedMins = _session!.plannedDurationMinutes;
    final actualMins = _session!.actualDurationSeconds ~/ 60;
    final actualSecs = _session!.actualDurationSeconds % 60;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
                )
              : const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFE8EAF6), Color(0xFFF3E5F5)],
                ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Status Icon
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: isCompleted
                          ? AppColors.successGradient
                          : AppColors.accentGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (isCompleted
                                  ? const Color(0xFF11998E)
                                  : const Color(0xFFE94560))
                              .withValues(alpha: 0.4),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Icon(
                      isCompleted
                          ? Icons.check_rounded
                          : Icons.close_rounded,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Status Text
                Text(
                  isCompleted
                      ? 'Session Completed! 🎉'
                      : 'Session Broken 💔',
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: isCompleted
                        ? const Color(0xFF38EF7D)
                        : const Color(0xFFE94560),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isCompleted
                      ? 'Great job! You stayed committed!'
                      : 'Don\'t worry, try again next time.',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 36),

                // Stats Cards
                _StatCard(
                  isDark: isDark,
                  icon: Icons.category_rounded,
                  iconColor: const Color(0xFF667EEA),
                  label: 'Habit Category',
                  value: _session!.habitCategory,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        isDark: isDark,
                        icon: Icons.flag_rounded,
                        iconColor: const Color(0xFFFFB703),
                        label: 'Planned',
                        value: '$plannedMins min',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        isDark: isDark,
                        icon: Icons.timer_rounded,
                        iconColor: isCompleted
                            ? const Color(0xFF11998E)
                            : const Color(0xFFE94560),
                        label: 'Actual',
                        value: '$actualMins m $actualSecs s',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        isDark: isDark,
                        icon: Icons.shield_rounded,
                        iconColor: const Color(0xFF764BA2),
                        label: 'Restriction',
                        value: _session!.restrictionLevel[0].toUpperCase() +
                            _session!.restrictionLevel.substring(1),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        isDark: isDark,
                        icon: Icons.currency_rupee_rounded,
                        iconColor: const Color(0xFFE94560),
                        label: 'Penalty',
                        value: '₹${_session!.penaltyAmount.toInt()}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (isCompleted)
                  _StatCard(
                    isDark: isDark,
                    icon: Icons.local_fire_department_rounded,
                    iconColor: const Color(0xFFFFB703),
                    label: 'Current Streak',
                    value: '${sessionProvider.streakCount} 🔥',
                  ),
                const SizedBox(height: 36),

                // Navigation Buttons
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          '/home', (route) => false);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 6,
                      shadowColor:
                          const Color(0xFF667EEA).withValues(alpha: 0.4),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.dashboard_rounded,
                                color: Colors.white),
                            const SizedBox(width: 8),
                            Text('Dashboard',
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil('/home', (route) => false);
                      Navigator.of(context).pushNamed('/history');
                    },
                    icon: const Icon(Icons.history_rounded),
                    label: Text('View History',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700, fontSize: 16)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                          isDark ? Colors.white70 : const Color(0xFF667EEA),
                      side: BorderSide(
                        color: isDark
                            ? Colors.white24
                            : const Color(0xFF667EEA).withValues(alpha: 0.5),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatCard({
    required this.isDark,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.grey.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: isDark ? Colors.white38 : Colors.black38,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
