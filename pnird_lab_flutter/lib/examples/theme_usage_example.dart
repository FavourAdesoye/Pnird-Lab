import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import '../constants/app_colors.dart';

class ThemeUsageExample extends StatelessWidget {
  const ThemeUsageExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Usage Example'),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(
                  themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                ),
                onPressed: () => themeProvider.toggleTheme(),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Using theme colors
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Primary Color Container',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Using custom colors
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.accentBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Custom Accent Color',
                style: TextStyle(color: AppColors.primaryWhite),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Using theme text styles
            Text(
              'This is a heading',
              style: AppTheme.headingStyle,
            ),
            
            Text(
              'This is body text',
              style: AppTheme.bodyStyle,
            ),
            
            Text(
              'This is muted text',
              style: AppTheme.captionStyle,
            ),
            
            const SizedBox(height: 16),
            
            // Theme-aware buttons
            ElevatedButton(
              onPressed: () {},
              child: const Text('Primary Button'),
            ),
            
            const SizedBox(height: 8),
            
            OutlinedButton(
              onPressed: () {},
              child: const Text('Outlined Button'),
            ),
            
            const SizedBox(height: 16),
            
            // Theme-aware input field
            TextField(
              decoration: InputDecoration(
                labelText: 'Theme-aware input field',
                hintText: 'This follows the theme',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

