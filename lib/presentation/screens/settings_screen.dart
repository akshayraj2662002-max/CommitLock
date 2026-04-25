import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/history_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = context.watch<SettingsProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.withValues(alpha: 0.12)),
              ),
              child: Row(children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      auth.userName.isNotEmpty ? auth.userName[0].toUpperCase() : 'U',
                      style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(auth.userName, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black87)),
                  const SizedBox(height: 4),
                  Text(auth.userEmail, style: GoogleFonts.inter(fontSize: 13, color: isDark ? Colors.white54 : Colors.black45)),
                ])),
              ]),
            ),
            const SizedBox(height: 24),

            _SectionLabel('Appearance', isDark),
            const SizedBox(height: 10),
            _SettingsTile(
              isDark: isDark,
              icon: Icons.palette_rounded,
              iconColor: const Color(0xFF667EEA),
              title: 'Theme',
              trailing: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'light', icon: Icon(Icons.light_mode_rounded, size: 18)),
                  ButtonSegment(value: 'system', icon: Icon(Icons.settings_brightness_rounded, size: 18)),
                  ButtonSegment(value: 'dark', icon: Icon(Icons.dark_mode_rounded, size: 18)),
                ],
                selected: {settings.themeMode},
                onSelectionChanged: (v) => settings.setThemeMode(v.first),
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
            const SizedBox(height: 24),

            _SectionLabel('Preferences', isDark),
            const SizedBox(height: 10),
            _ToggleTile(isDark: isDark, icon: Icons.volume_up_rounded, iconColor: const Color(0xFF11998E), title: 'Sound Effects', value: settings.soundEnabled, onChanged: (v) => settings.setSoundEnabled(v)),
            const SizedBox(height: 8),
            _ToggleTile(isDark: isDark, icon: Icons.notifications_rounded, iconColor: const Color(0xFFFFB703), title: 'Completion Notification', value: settings.notificationEnabled, onChanged: (v) => settings.setNotificationEnabled(v)),
            const SizedBox(height: 24),

            _SectionLabel('Restriction Levels', isDark),
            const SizedBox(height: 10),
            _InfoTile(isDark: isDark, icon: Icons.shield_outlined, color: const Color(0xFF11998E), title: 'Normal', desc: 'Single confirmation dialog to exit a session.'),
            const SizedBox(height: 8),
            _InfoTile(isDark: isDark, icon: Icons.shield_rounded, color: const Color(0xFFFFB703), title: 'Strict', desc: 'Two-step confirmation with a 5-second wait before final exit.'),
            const SizedBox(height: 8),
            _InfoTile(isDark: isDark, icon: Icons.security_rounded, color: const Color(0xFFE94560), title: 'Extreme', desc: 'You must type "I am breaking my commitment" to exit.'),
            const SizedBox(height: 24),

            _SectionLabel('Blocked App Categories (Mock)', isDark),
            const SizedBox(height: 10),
            ...settings.blockedCategories.entries.map((e) {
              final icons = {'Social Media': Icons.people_alt_rounded, 'Video Streaming': Icons.play_circle_rounded, 'Games': Icons.sports_esports_rounded, 'News': Icons.newspaper_rounded};
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _ToggleTile(isDark: isDark, icon: icons[e.key] ?? Icons.block, iconColor: const Color(0xFF764BA2), title: e.key, value: e.value, onChanged: (_) => settings.toggleBlockedCategory(e.key)),
              );
            }),
            const SizedBox(height: 24),

            _SectionLabel('Account', isDark),
            const SizedBox(height: 10),
            _ActionTile(isDark: isDark, icon: Icons.delete_forever_rounded, iconColor: const Color(0xFFE94560), title: 'Clear All History', onTap: () => _clearHistory(context)),
            const SizedBox(height: 8),
            _ActionTile(isDark: isDark, icon: Icons.logout_rounded, iconColor: const Color(0xFFE94560), title: 'Logout', onTap: () => _logout(context)),
            const SizedBox(height: 32),

            Center(child: Text('CommitLock v1.0.0', style: GoogleFonts.inter(fontSize: 12, color: isDark ? Colors.white24 : Colors.black26))),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _clearHistory(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Clear All History?', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        content: Text('This will permanently delete all session history. This cannot be undone.', style: GoogleFonts.inter(fontSize: 14)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              context.read<HistoryProvider>().clearAllHistory();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('History cleared'), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE94560), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Logout?', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to logout?', style: GoogleFonts.inter(fontSize: 14)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              context.read<AuthProvider>().logout();
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE94560), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final bool isDark;
  const _SectionLabel(this.text, this.isDark);
  @override
  Widget build(BuildContext context) => Text(text, style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black87));
}

class _SettingsTile extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget trailing;
  const _SettingsTile({required this.isDark, required this.icon, required this.iconColor, required this.title, required this.trailing});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.withValues(alpha: 0.12))),
    child: Row(children: [
      Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: iconColor, size: 20)),
      const SizedBox(width: 12),
      Text(title, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87)),
      const Spacer(),
      trailing,
    ]),
  );
}

class _ToggleTile extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final Color iconColor;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleTile({required this.isDark, required this.icon, required this.iconColor, required this.title, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
    decoration: BoxDecoration(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.withValues(alpha: 0.12))),
    child: Row(children: [
      Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: iconColor, size: 20)),
      const SizedBox(width: 12),
      Expanded(child: Text(title, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87))),
      Switch(value: value, activeTrackColor: const Color(0xFF667EEA).withValues(alpha: 0.5), activeThumbColor: const Color(0xFF667EEA), onChanged: onChanged),
    ]),
  );
}

class _InfoTile extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final Color color;
  final String title, desc;
  const _InfoTile({required this.isDark, required this.icon, required this.color, required this.title, required this.desc});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.withValues(alpha: 0.12))),
    child: Row(children: [
      Icon(icon, color: color, size: 24),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black87)),
        const SizedBox(height: 2),
        Text(desc, style: GoogleFonts.inter(fontSize: 12, color: isDark ? Colors.white54 : Colors.black45)),
      ])),
    ]),
  );
}

class _ActionTile extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;
  const _ActionTile({required this.isDark, required this.icon, required this.iconColor, required this.title, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.withValues(alpha: 0.12))),
      child: Row(children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(width: 12),
        Text(title, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: iconColor)),
        const Spacer(),
        Icon(Icons.arrow_forward_ios_rounded, size: 16, color: isDark ? Colors.white24 : Colors.black26),
      ]),
    ),
  );
}
