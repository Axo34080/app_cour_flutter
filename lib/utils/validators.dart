abstract final class Validators {
  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email requis';
    final regex = RegExp(r'^[\w.+\-]+@[\w\-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(v.trim())) return 'Email invalide';
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Mot de passe requis';
    if (v.length < 6) return '6 caractères minimum';
    return null;
  }

  static String? username(String? v) {
    if (v == null || v.trim().isEmpty) return "Nom d'utilisateur requis";
    if (v.trim().length < 3) return '3 caractères minimum';
    if (v.trim().length > 20) return '20 caractères maximum';
    final regex = RegExp(r'^[\w._]+$');
    if (!regex.hasMatch(v.trim())) return 'Lettres, chiffres, _ et . uniquement';
    return null;
  }

  static String? Function(String?) confirmPassword(String? password) {
    return (String? v) {
      if (v == null || v.isEmpty) return 'Confirmation requise';
      if (v != password) return 'Les mots de passe ne correspondent pas';
      return null;
    };
  }
}
