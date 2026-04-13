import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CyberMessageInput extends StatefulWidget {
  const CyberMessageInput({
    super.key,
    required this.onSend,
    this.onAttach,
    this.enabled = true,
  });

  final ValueChanged<String> onSend;
  final VoidCallback? onAttach;
  final bool enabled;

  @override
  State<CyberMessageInput> createState() => _CyberMessageInputState();
}

class _CyberMessageInputState extends State<CyberMessageInput> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() {
      final has = _ctrl.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _ctrl.clear();
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.neonCyan.withValues(alpha: 0.15)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (widget.onAttach != null)
              IconButton(
                onPressed: widget.onAttach,
                icon: Icon(
                  Icons.attach_file,
                  color: AppColors.textPrimary.withValues(alpha: 0.5),
                  size: 22,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
            Expanded(
              child: TextField(
                controller: _ctrl,
                focusNode: _focus,
                enabled: widget.enabled,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Message…',
                  hintStyle: TextStyle(
                    color: AppColors.textPrimary.withValues(alpha: 0.3),
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: AppColors.neonCyan.withValues(alpha: 0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: AppColors.neonCyan, width: 1.2),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedScale(
              scale: _hasText ? 1.0 : 0.7,
              duration: const Duration(milliseconds: 150),
              child: AnimatedOpacity(
                opacity: _hasText ? 1.0 : 0.3,
                duration: const Duration(milliseconds: 150),
                child: GestureDetector(
                  onTap: _hasText ? _send : null,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.neonCyan.withValues(alpha: 0.15),
                      border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.5)),
                      boxShadow: _hasText
                          ? [BoxShadow(color: AppColors.neonCyan.withValues(alpha: 0.2), blurRadius: 10)]
                          : null,
                    ),
                    child: const Icon(Icons.send_rounded, color: AppColors.neonCyan, size: 18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
