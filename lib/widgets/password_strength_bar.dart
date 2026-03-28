import 'package:flutter/material.dart';
import 'package:mynote/utilities/password_strength.dart';

class PasswordStrengthBar extends StatelessWidget {
  final PasswordStrength strength;
  const PasswordStrengthBar({super.key, required this.strength});

  Color get _color => switch (strength) {
    PasswordStrength.weak => Colors.red,
    PasswordStrength.fair => Colors.orange,
    PasswordStrength.medium => Colors.amber,
    PasswordStrength.strong => Colors.green,
  };

  double get _widthFraction => switch (strength) {
    PasswordStrength.weak => 0.25,
    PasswordStrength.fair => 0.50,
    PasswordStrength.medium => 0.75,
    PasswordStrength.strong => 1.0,
  };

  String get _label => switch (strength) {
    PasswordStrength.weak => 'Weak',
    PasswordStrength.fair => 'Fair',
    PasswordStrength.medium => 'Medium',
    PasswordStrength.strong => 'Strong',
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    Container(
                      width: constraints.maxWidth,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      width: constraints.maxWidth * _widthFraction,
                      height: 4,
                      decoration: BoxDecoration(
                        color: _color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _label,
            style: TextStyle(
              color: _color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
