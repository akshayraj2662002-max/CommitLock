import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../providers/session_provider.dart';


class NewCommitmentScreen extends StatefulWidget {
  const NewCommitmentScreen({super.key});

  @override
  State<NewCommitmentScreen> createState() => _NewCommitmentScreenState();
}

class _NewCommitmentScreenState extends State<NewCommitmentScreen> {
  String _selectedCategory = 'Reading';
  int _selectedDuration = 30;
  bool _customDuration = false;
  double _penaltyAmount = 50;
  String _restrictionLevel = 'normal';
  final Map<String, bool> _blockedApps = {
    'Social Media': true,
    'Video Streaming': true,
    'Games': false,
    'News': false,
  };
  String _customCategoryName = '';

  final Map<String, IconData> _categoryIcons = {
    'Reading': Icons.auto_stories_rounded,
    'Exercise': Icons.fitness_center_rounded,
    'Language Study': Icons.translate_rounded,
    'Coding Practice': Icons.code_rounded,
    'Meditation': Icons.self_improvement_rounded,
    'Custom': Icons.edit_rounded,
  };

  final Map<String, Color> _categoryColors = {
    'Reading': const Color(0xFF667EEA),
    'Exercise': const Color(0xFFE94560),
    'Language Study': const Color(0xFF11998E),
    'Coding Practice': const Color(0xFFFFB703),
    'Meditation': const Color(0xFF764BA2),
    'Custom': const Color(0xFF00B4D8),
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Commitment'),
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
            // Category Selection
            _SectionTitle(title: 'Choose Habit', icon: Icons.category_rounded),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.0,
              children: AppConstants.habitCategories.map((cat) {
                final isSelected = _selectedCategory == cat;
                final color = _categoryColors[cat] ?? const Color(0xFF667EEA);
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(colors: [
                              color,
                              color.withValues(alpha: 0.7),
                            ])
                          : null,
                      color: isSelected
                          ? null
                          : (isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : const Color(0xFFF1F3F5)),
                      borderRadius: BorderRadius.circular(18),
                      border: isSelected
                          ? null
                          : Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Colors.grey.withValues(alpha: 0.15),
                            ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withValues(alpha: 0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 6),
                              ),
                            ]
                          : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _categoryIcons[cat],
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.white54 : Colors.black54),
                          size: 30,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          cat,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : (isDark ? Colors.white60 : Colors.black54),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            if (_selectedCategory == 'Custom') ...[
              const SizedBox(height: 12),
              TextField(
                onChanged: (v) => _customCategoryName = v,
                decoration: const InputDecoration(
                  hintText: 'Enter custom habit name...',
                  prefixIcon: Icon(Icons.edit_rounded),
                ),
              ),
            ],
            const SizedBox(height: 28),

            // Duration Selection
            _SectionTitle(title: 'Duration', icon: Icons.timer_rounded),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ...AppConstants.durationPresets.map((dur) {
                  final isSelected = !_customDuration && _selectedDuration == dur;
                  return GestureDetector(
                    onTap: () => setState(() {
                      _selectedDuration = dur;
                      _customDuration = false;
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        gradient: isSelected ? AppColors.primaryGradient : null,
                        color: isSelected
                            ? null
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : const Color(0xFFF1F3F5)),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF667EEA)
                                      .withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: Text(
                        '$dur min',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.white60 : Colors.black54),
                        ),
                      ),
                    ),
                  );
                }),
                GestureDetector(
                  onTap: () => setState(() => _customDuration = true),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: _customDuration ? AppColors.accentGradient : null,
                      color: _customDuration
                          ? null
                          : (isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : const Color(0xFFF1F3F5)),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      'Custom',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight:
                            _customDuration ? FontWeight.w700 : FontWeight.w500,
                        color: _customDuration
                            ? Colors.white
                            : (isDark ? Colors.white60 : Colors.black54),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_customDuration) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Text(
                    '$_selectedDuration min',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              Slider(
                value: _selectedDuration.toDouble(),
                min: 5,
                max: 180,
                divisions: 35,
                // ignore: deprecated_member_use
                activeColor: const Color(0xFFE94560),
                onChanged: (v) =>
                    setState(() => _selectedDuration = v.toInt()),
              ),
            ],
            const SizedBox(height: 28),

            // Penalty Amount
            _SectionTitle(
                title: 'Penalty Amount', icon: Icons.currency_rupee_rounded),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : const Color(0xFFF1F3F5),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.grey.withValues(alpha: 0.15),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '₹',
                        style: GoogleFonts.outfit(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFE94560),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _penaltyAmount.toInt().toString(),
                        style: GoogleFonts.outfit(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _penaltyAmount,
                    min: 0,
                    max: 500,
                    divisions: 50,
                    // ignore: deprecated_member_use
                    activeColor: const Color(0xFFE94560),
                    onChanged: (v) => setState(() => _penaltyAmount = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Restriction Level
            _SectionTitle(
                title: 'Restriction Level', icon: Icons.shield_rounded),
            const SizedBox(height: 12),
            ...['normal', 'strict', 'extreme'].map((level) {
              final isSelected = _restrictionLevel == level;
              final Map<String, Map<String, dynamic>> levelData = {
                'normal': {
                  'icon': Icons.shield_outlined,
                  'color': const Color(0xFF11998E),
                  'title': 'Normal',
                  'desc': 'Single confirmation to exit',
                },
                'strict': {
                  'icon': Icons.shield_rounded,
                  'color': const Color(0xFFFFB703),
                  'title': 'Strict',
                  'desc': 'Two-step confirmation with 5s wait',
                },
                'extreme': {
                  'icon': Icons.security_rounded,
                  'color': const Color(0xFFE94560),
                  'title': 'Extreme',
                  'desc': 'Type exact commitment-break phrase',
                },
              };
              final data = levelData[level]!;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: () => setState(() => _restrictionLevel = level),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (data['color'] as Color).withValues(alpha: 0.15)
                          : (isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : const Color(0xFFF1F3F5)),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? (data['color'] as Color).withValues(alpha: 0.5)
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.grey.withValues(alpha: 0.15)),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(data['icon'] as IconData,
                            color: data['color'] as Color, size: 28),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['title'] as String,
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color:
                                      isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                data['desc'] as String,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.white54
                                      : Colors.black45,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check_circle_rounded,
                              color: data['color'] as Color, size: 24),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 28),

            // Blocked Apps
            _SectionTitle(
                title: 'Block App Categories',
                icon: Icons.block_rounded),
            const SizedBox(height: 12),
            ...AppConstants.blockedAppCategories.map((cat) {
              final Map<String, IconData> catIcons = {
                'Social Media': Icons.people_alt_rounded,
                'Video Streaming': Icons.play_circle_rounded,
                'Games': Icons.sports_esports_rounded,
                'News': Icons.newspaper_rounded,
              };
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : const Color(0xFFF1F3F5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.grey.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(catIcons[cat], size: 22,
                        color: isDark ? Colors.white54 : Colors.black45),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        cat,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ),
                    Switch(
                      value: _blockedApps[cat] ?? false,
                      activeTrackColor: const Color(0xFF667EEA).withValues(alpha: 0.5),
                      activeThumbColor: const Color(0xFF667EEA),
                      onChanged: (v) =>
                          setState(() => _blockedApps[cat] = v),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 32),

            // Start Button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () => _startSession(context),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 8,
                  shadowColor: const Color(0xFF667EEA).withValues(alpha: 0.5),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.play_arrow_rounded,
                            color: Colors.white, size: 28),
                        const SizedBox(width: 8),
                        Text(
                          'Start Commitment',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _startSession(BuildContext context) async {
    final sessionProvider = context.read<SessionProvider>();
    final category = _selectedCategory == 'Custom'
        ? (_customCategoryName.isNotEmpty ? _customCategoryName : 'Custom')
        : _selectedCategory;

    final blockedCats = _blockedApps.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    await sessionProvider.startSession(
      habitCategory: category,
      durationMinutes: _selectedDuration,
      penaltyAmount: _penaltyAmount,
      restrictionLevel: _restrictionLevel,
      blockedCategories: blockedCats,
    );

    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed('/active-session');
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(icon, size: 20,
            color: isDark ? Colors.white60 : Colors.black54),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }
}
