import 'package:flutter/material.dart';
import 'package:lul/utils/constants/colors.dart';

class BuildQuickActionButton extends StatelessWidget {
  const BuildQuickActionButton({
    super.key,
    required this.context,
    required this.icon,
    required this.label,
    required this.buttonSize,
    required this.onPressed,
  });

  final BuildContext context;
  final IconData icon;
  final String label;
  final double buttonSize;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(buttonSize),
              splashColor: TColors.secondary.withOpacity(0.3),
              highlightColor: TColors.secondary.withOpacity(0.2),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: TColors.accent.withOpacity(0.3),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onPressed,
                    borderRadius: BorderRadius.circular(buttonSize),
                    splashColor: TColors.secondary.withOpacity(0.3),
                    highlightColor: BoxShadow(
                      color: TColors.secondary.withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ).color,
                    child: Container(
                      padding: EdgeInsets.all(buttonSize / 3),
                      child: Icon(
                        icon,
                        color: TColors.textWhite,
                        size: 26,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Roboto',
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
