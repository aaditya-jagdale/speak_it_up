import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speak_it_up/shared/services/settings_service.dart';
import 'package:speak_it_up/shared/widgets/colors.dart';
import 'package:url_launcher/url_launcher_string.dart';

// ── Language model ────────────────────────────────────────────────────────────

class _Language {
  final String name;
  final String code;
  final String flag;

  const _Language({required this.name, required this.code, required this.flag});
}

const List<_Language> _languages = [
  _Language(name: 'English', code: 'en-US', flag: '🇺🇸'),
  _Language(name: 'Mandarin', code: 'zh-CN', flag: '🇨🇳'),
  _Language(name: 'Hindi', code: 'hi-IN', flag: '🇮🇳'),
  _Language(name: 'Spanish', code: 'es-ES', flag: '🇪🇸'),
  _Language(name: 'French', code: 'fr-FR', flag: '🇫🇷'),
  _Language(name: 'Arabic', code: 'ar-SA', flag: '🇸🇦'),
  _Language(name: 'Portuguese', code: 'pt-BR', flag: '🇧🇷'),
  _Language(name: 'Russian', code: 'ru-RU', flag: '🇷🇺'),
];

// ── Duration constraints ──────────────────────────────────────────────────
const int _minDuration = 30;
const int _maxDuration = 600;

String _formatDuration(int seconds) {
  if (seconds < 60) return '$seconds sec';
  final int min = seconds ~/ 60;
  final int sec = seconds % 60;
  return sec == 0 ? '$min min' : '$min:${sec.toString().padLeft(2, '0')} min';
}

// ── Screen ────────────────────────────────────────────────────────────────────

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _soundEnabled;
  late bool _vibrationEnabled;
  late String _languageCode;
  late int _timerDuration;

  @override
  void initState() {
    super.initState();
    final s = SettingsService.instance;
    _soundEnabled = s.soundEnabled;
    _vibrationEnabled = s.vibrationEnabled;
    _languageCode = s.languageCode;
    _timerDuration = s.timerDuration;
  }

  // ── Helpers ───────────────────────────────────────────────────────────

  Future<void> _toggleSound(bool value) async {
    if (_vibrationEnabled) HapticFeedback.lightImpact();
    setState(() => _soundEnabled = value);
    await SettingsService.instance.setSoundEnabled(value);
  }

  Future<void> _toggleVibration(bool value) async {
    if (value) HapticFeedback.lightImpact();
    setState(() => _vibrationEnabled = value);
    await SettingsService.instance.setVibrationEnabled(value);
  }

  Future<void> _setLanguage(String code) async {
    if (_vibrationEnabled) HapticFeedback.lightImpact();
    setState(() => _languageCode = code);
    await SettingsService.instance.setLanguageCode(code);
  }

  Future<void> _setDuration(int seconds) async {
    final int bounded = seconds.clamp(_minDuration, _maxDuration);
    if (bounded == _timerDuration) return;

    if (_vibrationEnabled) HapticFeedback.lightImpact();
    await SettingsService.instance.setTimerDuration(bounded);
    setState(() => _timerDuration = bounded);
  }

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (_vibrationEnabled) HapticFeedback.lightImpact();
            Navigator.of(context).pop();
          },
          child: const Padding(
            padding: EdgeInsets.only(left: 16),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: Color(0xFF090909),
            ),
          ),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            fontFamily: 'geist',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF090909),
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),

              // ── Preferences section ──────────────────────────────────────
              _buildSectionLabel('Preferences'),
              const SizedBox(height: 12),
              _buildToggleCard(
                icon: Icons.volume_up_rounded,
                label: 'Sound',
                sublabel: 'Announce topic aloud when spinning',
                value: _soundEnabled,
                onChanged: _toggleSound,
              ),
              const SizedBox(height: 10),
              _buildToggleCard(
                icon: Icons.vibration_rounded,
                label: 'Vibrations',
                sublabel: 'Haptic feedback on interactions',
                value: _vibrationEnabled,
                onChanged: _toggleVibration,
              ),

              const SizedBox(height: 32),

              // ── Language section ─────────────────────────────────────────
              if (Platform.isAndroid) ...[
                _buildSectionLabel('Announcement Language'),
                const SizedBox(height: 4),
                _buildSectionSublabel('Voice used when announcing the topic'),
                const SizedBox(height: 12),
                _buildLanguagePicker(),
                const SizedBox(height: 32),
              ],

              // ── Timer section ────────────────────────────────────────────
              _buildSectionLabel('Default Timer Duration'),
              const SizedBox(height: 4),
              _buildSectionSublabel('How long each speaking session lasts'),
              const SizedBox(height: 12),
              _buildDurationPicker(),

              const SizedBox(height: 40),
              Center(
                child: GestureDetector(
                  onTap: () {
                    launchUrlString("https://x.com/aaditya_fr");
                  },
                  child: Text(
                    "Creation of @aaditya_fr",
                    style: TextStyle(
                      fontFamily: 'geist',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black50,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Section builders
  // ────────────────────────────────────────────────────────────────────────────

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontFamily: 'geist',
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.black50,
        letterSpacing: 0.6,
      ),
    );
  }

  Widget _buildSectionSublabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'geist',
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.black50,
      ),
    );
  }

  Widget _buildToggleCard({
    required IconData icon,
    required String label,
    required String sublabel,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: value
                ? AppColors.primary.withValues(alpha: 0.3)
                : const Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // ── Icon container ─────────────────────────────────────
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: value ? AppColors.primary10 : const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 18,
                color: value ? AppColors.primary : AppColors.black50,
              ),
            ),
            const SizedBox(width: 14),

            // ── Label + sublabel ──────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'geist',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF090909),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sublabel,
                    style: const TextStyle(
                      fontFamily: 'geist',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.black50,
                    ),
                  ),
                ],
              ),
            ),

            // ── Custom toggle ─────────────────────────────────────
            _ToggleChip(value: value),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguagePicker() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selected language preview
          _LanguageDropdownRow(
            selected: _languages.firstWhere(
              (l) => l.code == _languageCode,
              orElse: () => _languages.first,
            ),
            languages: _languages,
            onSelected: _setLanguage,
          ),
        ],
      ),
    );
  }

  Widget _buildDurationPicker() {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
      ),
      child: Row(
        children: [
          // ── Decrement button ────────────────────────────────────
          _buildAdjustButton(
            label: '-30s',
            onTap: () => _setDuration(_timerDuration - 30),
            enabled: _timerDuration > _minDuration,
          ),

          // ── Divider ─────────────────────────────────────────────
          Container(width: 1, height: 24, color: const Color(0xFFE0E0E0)),

          // ── Current value ───────────────────────────────────────
          Expanded(
            child: Center(
              child: Text(
                _formatDuration(_timerDuration),
                style: const TextStyle(
                  fontFamily: 'geist',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF090909),
                ),
              ),
            ),
          ),

          // ── Divider ─────────────────────────────────────────────
          Container(width: 1, height: 24, color: const Color(0xFFE0E0E0)),

          // ── Increment button ────────────────────────────────────
          _buildAdjustButton(
            label: '+30s',
            onTap: () => _setDuration(_timerDuration + 30),
            enabled: _timerDuration < _maxDuration,
          ),
        ],
      ),
    );
  }

  Widget _buildAdjustButton({
    required String label,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 80,
        height: double.infinity,
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'geist',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: enabled ? AppColors.primary : AppColors.black50,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Pill-style on/off toggle chip.
class _ToggleChip extends StatelessWidget {
  final bool value;

  const _ToggleChip({required this.value});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 44,
      height: 26,
      decoration: BoxDecoration(
        color: value ? AppColors.primary : const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom dropdown for language selection with flag + name.
class _LanguageDropdownRow extends StatelessWidget {
  final _Language selected;
  final List<_Language> languages;
  final ValueChanged<String> onSelected;

  const _LanguageDropdownRow({
    required this.selected,
    required this.languages,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _showPicker(context),
      child: Row(
        children: [
          Text(selected.flag, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selected.name,
                  style: const TextStyle(
                    fontFamily: 'geist',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF090909),
                  ),
                ),
                Text(
                  selected.code,
                  style: const TextStyle(
                    fontFamily: 'geist',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.black50,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 20,
            color: AppColors.black50,
          ),
        ],
      ),
    );
  }

  void _showPicker(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _LanguagePickerSheet(
        languages: languages,
        selectedCode: selected.code,
        onSelected: (code) {
          Navigator.of(context).pop();
          onSelected(code);
        },
      ),
    );
  }
}

/// Bottom sheet that lists all language options.
class _LanguagePickerSheet extends StatelessWidget {
  final List<_Language> languages;
  final String selectedCode;
  final ValueChanged<String> onSelected;

  const _LanguagePickerSheet({
    required this.languages,
    required this.selectedCode,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFAFAFA),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Handle ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // ── Title ────────────────────────────────────────────────────
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Select Language',
                  style: TextStyle(
                    fontFamily: 'geist',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF090909),
                  ),
                ),
              ),
            ),

            const Divider(height: 1, color: Color(0xFFE0E0E0)),

            // ── List ──────────────────────────────────────────────────────
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: languages.length,
              separatorBuilder: (_, _) => const Divider(
                height: 1,
                indent: 20,
                color: Color(0xFFE0E0E0),
              ),
              itemBuilder: (_, i) {
                final lang = languages[i];
                final bool isSelected = lang.code == selectedCode;

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onSelected(lang.code),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Text(lang.flag, style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            lang.name,
                            style: TextStyle(
                              fontFamily: 'geist',
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected
                                  ? AppColors.primary
                                  : const Color(0xFF090909),
                            ),
                          ),
                        ),
                        Text(
                          lang.code,
                          style: const TextStyle(
                            fontFamily: 'geist',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.black50,
                          ),
                        ),
                        const SizedBox(width: 8),
                        AnimatedOpacity(
                          opacity: isSelected ? 1 : 0,
                          duration: const Duration(milliseconds: 150),
                          child: const Icon(
                            Icons.check_rounded,
                            size: 18,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // ── Bottom safe area ─────────────────────────────────────────
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }
}
