import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/theme_provider.dart';
import '../feature_selection_screen.dart';

class SplitwiseSettingsTab extends StatelessWidget {
  const SplitwiseSettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColorsDark.background : const Color.fromARGB(255, 228, 228, 228);
    final surfaceColor = isDark ? AppColorsDark.surface : AppColors.surface;
    final textPrimaryColor = isDark ? AppColorsDark.textPrimary : AppColors.textPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme Settings
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Appearance',
                  style: AppTextStyles.heading3.copyWith(color: textPrimaryColor),
                ),
                const SizedBox(height: 16),
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, _) {
                    return Column(
                      children: [
                        _buildThemeOption(
                          context,
                          'Light',
                          Icons.light_mode,
                          ThemeMode.light,
                          themeProvider.themeMode == ThemeMode.light,
                          () => themeProvider.setThemeMode(ThemeMode.light),
                        ),
                        const SizedBox(height: 12),
                        _buildThemeOption(
                          context,
                          'Dark',
                          Icons.dark_mode,
                          ThemeMode.dark,
                          themeProvider.themeMode == ThemeMode.dark,
                          () => themeProvider.setThemeMode(ThemeMode.dark),
                        ),
                        const SizedBox(height: 12),
                        _buildThemeOption(
                          context,
                          'System',
                          Icons.auto_awesome,
                          ThemeMode.system,
                          themeProvider.themeMode == ThemeMode.system,
                          () => themeProvider.setThemeMode(ThemeMode.system),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Feature Selection
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Features',
                  style: AppTextStyles.heading3.copyWith(color: textPrimaryColor),
                ),
                const SizedBox(height: 16),
                _buildSettingsTile(
                  context,
                  icon: Icons.switch_account,
                  title: 'Switch Feature',
                  subtitle: 'Switch between Personal Finance and Group Expenses',
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Switch Feature'),
                        content: const Text('Go back to feature selection?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => const FeatureSelectionScreen(),
                                ),
                              );
                            },
                            child: const Text('Switch'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // About
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'About',
                  style: AppTextStyles.heading3.copyWith(color: textPrimaryColor),
                ),
                const SizedBox(height: 16),
                _buildSettingsTile(
                  context,
                  icon: Icons.info_outline,
                  title: 'App Version',
                  subtitle: '1.0.0',
                  onTap: null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    String title,
    IconData icon,
    ThemeMode mode,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColorsDark.primary : AppColors.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? primaryColor : AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? primaryColor : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check_circle, color: primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColorsDark.primary : AppColors.primary;
    final textSecondaryColor = isDark ? AppColorsDark.textSecondary : AppColors.textSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: primaryColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.chevron_right, color: textSecondaryColor),
          ],
        ),
      ),
    );
  }
}


