import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../providers/session_provider.dart';

class ActiveSessionScreen extends StatefulWidget {
  const ActiveSessionScreen({super.key});

  @override
  State<ActiveSessionScreen> createState() => _ActiveSessionScreenState();
}

class _ActiveSessionScreenState extends State<ActiveSessionScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sessionProvider = context.watch<SessionProvider>();
    final session = sessionProvider.activeSession;

    if (session == null) {
      return const Scaffold(
        body: Center(child: Text('No active session')),
      );
    }

    // If session completed or broken, navigate to result
    if (session.status != 'active') {
      if (!_isNavigating) {
        _isNavigating = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/result');
          }
        });
      }
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final restrictionColor = session.restrictionLevel == 'extreme'
        ? const Color(0xFFE94560)
        : session.restrictionLevel == 'strict'
            ? const Color(0xFFFFB703)
            : const Color(0xFF11998E);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleExit(context, session.restrictionLevel);
        }
      },
      child: Scaffold(
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
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Top bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: restrictionColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: restrictionColor.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.shield_rounded,
                                color: restrictionColor, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              session.restrictionLevel.toUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: restrictionColor,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE94560).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('₹',
                                style: TextStyle(
                                    color: Color(0xFFE94560), fontSize: 14)),
                            const SizedBox(width: 4),
                            Text(
                              session.penaltyAmount.toInt().toString(),
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFE94560),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Habit Name
                  Text(
                    session.habitCategory,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${session.plannedDurationMinutes} minute session',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                  const Spacer(),

                  // Countdown Timer Ring
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + (_pulseController.value * 0.02),
                        child: CircularPercentIndicator(
                          radius: 130,
                          lineWidth: 14,
                          percent: sessionProvider.progress.clamp(0.0, 1.0),
                          center: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                sessionProvider.formattedTime,
                                style: GoogleFonts.outfit(
                                  fontSize: 52,
                                  fontWeight: FontWeight.w800,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF1A1A2E),
                                  letterSpacing: -2,
                                ),
                              ),
                              Text(
                                'remaining',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color:
                                      isDark ? Colors.white38 : Colors.black38,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          progressColor: const Color(0xFF667EEA),
                          backgroundColor: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.black.withValues(alpha: 0.08),
                          circularStrokeCap: CircularStrokeCap.round,
                          animation: false,
                        ),
                      );
                    },
                  ),

                  const Spacer(),

                  // Motivational Quote
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.grey.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Text('💡', style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            sessionProvider.currentQuote,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: isDark ? Colors.white60 : Colors.black54,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Exit Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _handleExit(context, session.restrictionLevel),
                      icon:
                          const Icon(Icons.exit_to_app_rounded, size: 20),
                      label: Text(
                        'Attempt Exit',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFE94560),
                        side: const BorderSide(
                            color: Color(0xFFE94560), width: 1.5),
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
      ),
    );
  }

  void _handleExit(BuildContext context, String restrictionLevel) {
    switch (restrictionLevel) {
      case 'normal':
        _showNormalExitDialog(context);
        break;
      case 'strict':
        _showStrictExitDialog(context);
        break;
      case 'extreme':
        _showExtremeExitDialog(context);
        break;
    }
  }

  void _showNormalExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.cardDark
            : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Break Commitment?',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        content: Text(
          'Are you sure you want to break your commitment? This will mark your session as broken.',
          style: GoogleFonts.inter(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Stay Focused',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _breakAndNavigate();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE94560),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Break Session',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showStrictExitDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _StrictExitStep1Dialog(
        onProceed: () {
          Navigator.pop(ctx);
          _showStrictExitStep2(context);
        },
        onCancel: () => Navigator.pop(ctx),
      ),
    );
  }

  void _showStrictExitStep2(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _StrictExitStep2Dialog(
        onConfirm: () {
          Navigator.pop(ctx);
          _breakAndNavigate();
        },
        onCancel: () => Navigator.pop(ctx),
      ),
    );
  }

  void _showExtremeExitDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _ExtremeExitDialog(
        onConfirm: () {
          Navigator.pop(ctx);
          _breakAndNavigate();
        },
        onCancel: () => Navigator.pop(ctx),
      ),
    );
  }

  void _breakAndNavigate() async {
    final sessionProvider = context.read<SessionProvider>();
    await sessionProvider.breakSession();
    // Navigation is handled by the build method reacting to state change
  }
}

// Strict Exit - Step 1
class _StrictExitStep1Dialog extends StatelessWidget {
  final VoidCallback onProceed;
  final VoidCallback onCancel;

  const _StrictExitStep1Dialog({
    required this.onProceed,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AlertDialog(
      backgroundColor: isDark ? AppColors.cardDark : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: Color(0xFFFFB703), size: 28),
          const SizedBox(width: 10),
          Text('Step 1 of 2',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        ],
      ),
      content: Text(
        'Breaking this session will reset your streak and mark it as broken. Are you absolutely sure?',
        style: GoogleFonts.inter(fontSize: 14, height: 1.5),
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: Text('Go Back',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        ),
        ElevatedButton(
          onPressed: onProceed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFB703),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text('Proceed',
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600, color: Colors.black87)),
        ),
      ],
    );
  }
}

// Strict Exit - Step 2 (with countdown)
class _StrictExitStep2Dialog extends StatefulWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _StrictExitStep2Dialog({
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  State<_StrictExitStep2Dialog> createState() => _StrictExitStep2DialogState();
}

class _StrictExitStep2DialogState extends State<_StrictExitStep2Dialog> {
  int _countdown = 5;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AlertDialog(
      backgroundColor: isDark ? AppColors.cardDark : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.timer_rounded,
              color: Color(0xFFE94560), size: 28),
          const SizedBox(width: 10),
          Text('Final Confirmation',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'This is your last chance to stay committed.',
            style: GoogleFonts.inter(fontSize: 14, height: 1.5),
          ),
          if (_countdown > 0) ...[
            const SizedBox(height: 16),
            Text(
              'Wait $_countdown seconds...',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFE94560),
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: widget.onCancel,
          child: Text('Stay Focused',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        ),
        ElevatedButton(
          onPressed: _countdown == 0 ? widget.onConfirm : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE94560),
            disabledBackgroundColor:
                const Color(0xFFE94560).withValues(alpha: 0.3),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            _countdown > 0 ? 'Wait...' : 'Break Session',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

// Extreme Exit Dialog
class _ExtremeExitDialog extends StatefulWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _ExtremeExitDialog({
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  State<_ExtremeExitDialog> createState() => _ExtremeExitDialogState();
}

class _ExtremeExitDialogState extends State<_ExtremeExitDialog> {
  final _controller = TextEditingController();
  bool _isMatch = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AlertDialog(
      backgroundColor: isDark ? AppColors.cardDark : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.security_rounded,
              color: Color(0xFFE94560), size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Text('Extreme Exit',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'To break your commitment, type exactly:',
            style: GoogleFonts.inter(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE94560).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border:
                  Border.all(color: const Color(0xFFE94560).withValues(alpha: 0.3)),
            ),
            child: Text(
              AppConstants.breakCommitmentText,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFE94560),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            onChanged: (v) {
              setState(() {
                _isMatch = v.trim() == AppConstants.breakCommitmentText;
              });
            },
            decoration: InputDecoration(
              hintText: 'Type the phrase here...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: _isMatch
                  ? const Icon(Icons.check_circle, color: Color(0xFFE94560))
                  : null,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: widget.onCancel,
          child: Text('Stay Focused',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        ),
        ElevatedButton(
          onPressed: _isMatch ? widget.onConfirm : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE94560),
            disabledBackgroundColor:
                const Color(0xFFE94560).withValues(alpha: 0.3),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text('Break Session',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
