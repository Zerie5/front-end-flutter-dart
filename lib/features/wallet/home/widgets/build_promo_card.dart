import 'package:flutter/material.dart';

class BuildPromoCard extends StatelessWidget {
  const BuildPromoCard({
    super.key,
    required this.title,
    required this.description,
    required this.backgroundColor,
    required this.darkMode,
  });

  final String title;
  final String description;
  final Color backgroundColor;
  final bool darkMode;

  @override
  Widget build(BuildContext context) {
    // Ensure responsive sizing
    final double maxHeight = MediaQuery.of(context).size.height * 0.15;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight), // Limit card height
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Avoid unnecessary height
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            title,
            style: TextStyle(
              color: darkMode ? Colors.white : Colors.black, // Dynamic color
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // Description
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                color:
                    darkMode ? Colors.white70 : Colors.black87, // Dynamic color
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis, // Avoid overflow by truncating
              maxLines: 3, // Limit to 3 lines
            ),
          ),
        ],
      ),
    );
  }
}
