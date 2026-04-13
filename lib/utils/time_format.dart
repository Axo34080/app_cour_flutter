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

  static String _pad(int n) => n.toString().padLeft(2, '0');
}
