import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/session_model.dart';
import '../providers/history_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hp = context.watch<HistoryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Session History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Summary
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667EEA).withValues(alpha: 0.3),
                  blurRadius: 20, offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                _SummaryCol('${hp.totalSessions}', 'Total'),
                Container(width: 1, height: 40, color: Colors.white24),
                _SummaryCol('${hp.successRate.toStringAsFixed(0)}%', 'Success'),
                Container(width: 1, height: 40, color: Colors.white24),
                _SummaryCol(_fmtMin(hp.totalCommittedMinutes), 'Time'),
              ],
            ),
          ),
          // Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['All', 'Completed', 'Broken'].map((f) {
                        final sel = hp.filter == f;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => hp.setFilter(f),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                gradient: sel ? AppColors.primaryGradient : null,
                                color: sel ? null : (isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F3F5)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(f, style: GoogleFonts.inter(
                                fontSize: 13, fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                                color: sel ? Colors.white : (isDark ? Colors.white54 : Colors.black45),
                              )),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (v) => hp.setSort(v),
                  icon: Icon(Icons.sort_rounded, color: isDark ? Colors.white54 : Colors.black45),
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'Newest', child: Text('Newest First')),
                    const PopupMenuItem(value: 'Oldest', child: Text('Oldest First')),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: hp.sessions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history_rounded, size: 64, color: isDark ? Colors.white12 : Colors.black12),
                        const SizedBox(height: 16),
                        Text('No sessions yet', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: isDark ? Colors.white24 : Colors.black26)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: hp.sessions.length,
                    itemBuilder: (ctx, i) => _SessionCard(session: hp.sessions[i], isDark: isDark),
                  ),
          ),
        ],
      ),
    );
  }

  String _fmtMin(int m) => m < 60 ? '${m}m' : '${m ~/ 60}h ${m % 60}m';
}

class _SummaryCol extends StatelessWidget {
  final String value, label;
  const _SummaryCol(this.value, this.label);
  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(children: [
          Text(value, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.inter(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500)),
        ]),
      );
}

class _SessionCard extends StatelessWidget {
  final SessionModel session;
  final bool isDark;
  const _SessionCard({required this.session, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final ok = session.status == 'completed';
    final sc = ok ? const Color(0xFF38EF7D) : const Color(0xFFE94560);
    final am = session.actualDurationSeconds ~/ 60;
    final ds = DateFormat('MMM d, yyyy • h:mm a').format(session.startTimestamp);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.withValues(alpha: 0.12)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: sc.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(ok ? Icons.check_circle_rounded : Icons.cancel_rounded, color: sc, size: 14),
              const SizedBox(width: 4),
              Text(ok ? 'Completed' : 'Broken', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: sc)),
            ]),
          ),
          const Spacer(),
          Text(ds, style: GoogleFonts.inter(fontSize: 11, color: isDark ? Colors.white38 : Colors.black38)),
        ]),
        const SizedBox(height: 12),
        Text(session.habitCategory, style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black87)),
        const SizedBox(height: 10),
        Row(children: [
          Icon(Icons.flag_rounded, size: 14, color: isDark ? Colors.white30 : Colors.black26),
          const SizedBox(width: 4),
          Text('${session.plannedDurationMinutes}m', style: GoogleFonts.inter(fontSize: 11, color: isDark ? Colors.white38 : Colors.black38)),
          const SizedBox(width: 14),
          Icon(Icons.timer_rounded, size: 14, color: isDark ? Colors.white30 : Colors.black26),
          const SizedBox(width: 4),
          Text('${am}m actual', style: GoogleFonts.inter(fontSize: 11, color: isDark ? Colors.white38 : Colors.black38)),
          const SizedBox(width: 14),
          Icon(Icons.currency_rupee_rounded, size: 14, color: isDark ? Colors.white30 : Colors.black26),
          const SizedBox(width: 4),
          Text('₹${session.penaltyAmount.toInt()}', style: GoogleFonts.inter(fontSize: 11, color: isDark ? Colors.white38 : Colors.black38)),
        ]),
      ]),
    );
  }
}
