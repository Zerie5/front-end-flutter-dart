import 'package:flutter/material.dart';

class BuildMenuTile extends StatelessWidget {
  const BuildMenuTile({
    super.key,
    required this.icon,
    required this.iconSize,
    required this.title,
    required this.description,
    required this.onTap,
    this.titleStyle,
    this.subtitleStyle,
    this.showArrow = true, // Default is true for changable options
  });

  final IconData icon;
  final double iconSize;
  final String title;
  final String description;
  final VoidCallback onTap;
  final TextStyle? titleStyle; // Accept custom title style
  final TextStyle? subtitleStyle; // Accept custom description style
  final bool showArrow; // Determines if the right arrow is shown

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 0),
        leading: CircleAvatar(
          backgroundColor: Colors.white.withOpacity(0.2),
          child: Icon(icon, size: iconSize, color: Colors.white),
        ),
        title: Text(
          title,
          style: titleStyle ??
              const TextStyle(
                color: Colors.black, // Default text color
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
        ),
        subtitle: Text(
          description,
          style: subtitleStyle ??
              TextStyle(
                color: Colors.black.withOpacity(0.6), // Default subtitle color
                fontSize: 14,
              ),
        ),
        trailing: showArrow
            ? const Icon(Icons.chevron_right, color: Colors.white)
            : null,
        onTap: onTap,
      ),
    );
  }
}
