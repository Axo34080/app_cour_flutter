import 'package:flutter/material.dart';
import '../models/message.dart';
import '../theme/app_theme.dart';
import '../utils/api.dart';
import '../utils/time_format.dart';

class CyberMessageBubble extends StatelessWidget {
  const CyberMessageBubble({
    super.key,
    required this.message,
    required this.isMine,
  });

  final Message message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        child: Container(
          margin: EdgeInsets.only(
            top: 3,
            bottom: 3,
            left: isMine ? 48 : 0,
            right: isMine ? 0 : 48,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isMine
                ? AppColors.neonCyan.withValues(alpha: 0.12)
                : AppColors.surface,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isMine ? 16 : 4),
              bottomRight: Radius.circular(isMine ? 4 : 16),
            ),
            border: Border.all(
              color: isMine
                  ? AppColors.neonCyan.withValues(alpha: 0.35)
                  : AppColors.neonPink.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: isMine
                ? [
                    BoxShadow(
                      color: AppColors.neonCyan.withValues(alpha: 0.08),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment:
                isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (message.type == 'file')
                _FileContent(fileUrl: message.content, fileName: message.fileName)
              else
                Text(
                  message.content ?? '',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    TimeFormat.message(message.createdAt),
                    style: TextStyle(
                      color: AppColors.textPrimary.withValues(alpha: 0.4),
                      fontSize: 10,
                    ),
                  ),
                  if (isMine) ...[
                    const SizedBox(width: 4),
                    Icon(
                      message.isRead ? Icons.done_all : Icons.done,
                      size: 12,
                      color: message.isRead
                          ? AppColors.neonCyan
                          : AppColors.textPrimary.withValues(alpha: 0.4),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FileContent extends StatelessWidget {
  const _FileContent({this.fileUrl, this.fileName});
  final String? fileUrl;
  final String? fileName;

  static const _imageExtensions = {'.jpg', '.jpeg', '.png', '.gif', '.webp'};

  bool get _isImage {
    final name = fileName ?? fileUrl ?? '';
    final lower = name.toLowerCase();
    return _imageExtensions.any((ext) => lower.endsWith(ext));
  }

  String? get _imageUrl {
    if (fileUrl != null) return '${Api.baseUrl}$fileUrl';
    if (fileName != null) return '${Api.baseUrl}/uploads/$fileName';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_isImage && _imageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          _imageUrl!,
          width: 200,
          fit: BoxFit.cover,
          loadingBuilder: (_, child, progress) => progress == null
              ? child
              : SizedBox(
                  width: 200,
                  height: 120,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.neonCyan,
                      value: progress.expectedTotalBytes != null
                          ? progress.cumulativeBytesLoaded /
                              progress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                ),
          errorBuilder: (_, _, _) => _FallbackFile(fileName: fileName ?? fileUrl),
        ),
      );
    }

    return _FallbackFile(fileName: fileName);
  }
}

class _FallbackFile extends StatelessWidget {
  const _FallbackFile({this.fileName});
  final String? fileName;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.attach_file,
          size: 16,
          color: AppColors.neonCyan.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            fileName ?? 'Fichier',
            style: TextStyle(
              color: AppColors.textPrimary.withValues(alpha: 0.8),
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
