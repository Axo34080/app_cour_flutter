abstract final class TimeFormat {
  static String message(DateTime date) {
    final now = DateTime.now();
    final local = date.toLocal();
    final diff = now.difference(local);

    if (diff.inDays == 0 && now.day == local.day) {
      return '${_pad(local.hour)}:${_pad(local.minute)}';
    }
    if (diff.inDays < 7) {
      const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
      return days[local.weekday - 1];
    }
    return '${_pad(local.day)}/${_pad(local.month)}';
  }

  static String relative(DateTime date) {
    final diff = DateTime.now().difference(date.toLocal());
    if (diff.inMinutes < 1) return "À l'instant";
    if (diff.inHours < 1) return 'Il y a ${diff.inMinutes} min';
    if (diff.inDays < 1) return 'Il y a ${diff.inHours} h';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays} j';
    final d = date.toLocal();
    return '${_pad(d.day)}/${_pad(d.month)}/${d.year}';
  }

  static String _pad(int n) => n.toString().padLeft(2, '0');
}
