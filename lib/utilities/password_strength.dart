enum PasswordStrength { weak, fair, medium, strong }

PasswordStrength calculateStrength(String password) {
  int score = 0;
  if (password.length >= 8) {
    score += 1;
  }
  if (RegExp(r'[A-Z]').hasMatch(password)) {
    score += 1;
  }
  if (RegExp(r'[a-z]').hasMatch(password)) {
    score += 1;
  }
  if (RegExp(r'[0-9]').hasMatch(password)) {
    score += 1;
  }
  if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
    score += 1;
  }

  if (score <= 1) return PasswordStrength.weak;
  if (score <= 2) return PasswordStrength.fair;
  if (score <= 3) return PasswordStrength.medium;
  return PasswordStrength.strong;
}
