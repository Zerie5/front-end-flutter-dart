import 'package:flutter/material.dart';

class NumericKeypad2 extends StatelessWidget {
  final void Function(String) onDigitPressed;
  final VoidCallback onBackspacePressed;

  const NumericKeypad2({
    super.key,
    required this.onDigitPressed,
    required this.onBackspacePressed,
  });

  @override
  Widget build(BuildContext context) {
    // Layout with 12 items: digits 1-9, an empty placeholder, 0 and a backspace button.
    final List<String> keypadItems = [
      "1",
      "2",
      "3",
      "4",
      "5",
      "6",
      "7",
      "8",
      "9",
      "",
      "0",
      "backspace"
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: keypadItems.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.0,
      ),
      itemBuilder: (context, index) {
        final item = keypadItems[index];
        if (item == "") {
          // Empty placeholder for layout purposes.
          return const SizedBox();
        } else if (item == "backspace") {
          return IconButton(
            icon: const Icon(Icons.backspace, color: Colors.white),
            onPressed: onBackspacePressed,
          );
        } else {
          return TextButton(
            onPressed: () => onDigitPressed(item),
            child: Text(
              item,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }
      },
    );
  }
}
