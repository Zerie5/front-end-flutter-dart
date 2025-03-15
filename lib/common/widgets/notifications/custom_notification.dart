import 'package:flutter/material.dart';

class CustomMessageWidget extends StatelessWidget {
  final String title;
  final String message;
  final Color backgroundColor;

  const CustomMessageWidget({
    super.key,
    required this.title,
    required this.message,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title,
              style: const TextStyle(color: Colors.white, fontSize: 18)),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
