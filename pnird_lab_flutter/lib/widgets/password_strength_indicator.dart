import 'package:flutter/material.dart';

class PasswordStrength {
  final String text;
  final Color color;
  final double score;

  PasswordStrength(this.text, this.color, this.score);
}

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    final strength = _calculatePasswordStrength(password);
    
    return Column(
      children: [
        LinearProgressIndicator(
          value: strength.score / 4,
          backgroundColor: Colors.grey[800],
          valueColor: AlwaysStoppedAnimation<Color>(strength.color),
        ),
        const SizedBox(height: 4),
        Text(
          strength.text,
          style: TextStyle(
            color: strength.color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
  
  PasswordStrength _calculatePasswordStrength(String password) {
    if (password.isEmpty) {
      return PasswordStrength('', Colors.grey, 0);
    }
    
    int score = 0;
    if (password.length >= 8) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;
    
    if (score < 2) {
      return PasswordStrength('Weak password', Colors.red, score.toDouble());
    } else if (score < 4) {
      return PasswordStrength('Medium strength', Colors.orange, score.toDouble());
    } else {
      return PasswordStrength('Strong password', Colors.green, score.toDouble());
    }
  }
}

