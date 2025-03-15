import 'package:flutter/material.dart';
import 'package:lul/utils/constants/sizes.dart';

class LulLogo extends StatelessWidget {
  final double size;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool showText;
  final bool isDark;

  const LulLogo({
    super.key,
    this.size = 100,
    this.backgroundColor,
    this.foregroundColor,
    this.showText = true,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        backgroundColor ?? (isDarkMode ? Colors.black : Colors.white);
    final fgColor = foregroundColor ??
        (isDarkMode ? Colors.white : const Color(0xFF1D6B6B));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo Image
        Container(
          width: size,
          height: size,
          padding: const EdgeInsets.all(TSizes.sm),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(size / 4),
          ),
          child: Image.asset(
            'assets/logos/logo1.png',
            color: fgColor,
          ),
        ),

        // Optional Logo Text
        if (showText)
          Padding(
            padding: const EdgeInsets.only(top: TSizes.sm),
            child: Text(
              'Lul',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1D6B6B),
                  ),
            ),
          ),
      ],
    );
  }
}
