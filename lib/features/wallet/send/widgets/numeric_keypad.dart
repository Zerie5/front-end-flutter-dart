import 'package:flutter/material.dart';
import 'package:lul/utils/constants/colors.dart';
import 'package:lul/utils/constants/sizes.dart';

class NumericKeypad extends StatelessWidget {
  final Function(String) onNumberTap;
  final VoidCallback onBackspace;

  const NumericKeypad({
    super.key,
    required this.onNumberTap,
    required this.onBackspace,
  });

  Widget _buildKeypadButton(String value, {bool isBackspace = false}) {
    return InkWell(
      onTap: () {
        if (isBackspace) {
          onBackspace();
        } else {
          onNumberTap(value);
        }
      },
      child: Container(
        width: 60,
        height: 60,
        alignment: Alignment.center,
        child: Text(
          value,
          style: const TextStyle(
            color: TColors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          _buildKeypadRow(['1', '2', '3']),
          const SizedBox(height: TSizes.spaceBtwItems),
          _buildKeypadRow(['4', '5', '6']),
          const SizedBox(height: TSizes.spaceBtwItems),
          _buildKeypadRow(['7', '8', '9']),
          const SizedBox(height: TSizes.spaceBtwItems),
          _buildKeypadRow(['.', '0', '⌫'], hasBackspace: true),
        ],
      ),
    );
  }

  Widget _buildKeypadRow(List<String> values, {bool hasBackspace = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: values
          .map((value) => _buildKeypadButton(value,
              isBackspace: hasBackspace && value == '⌫'))
          .toList(),
    );
  }
}
