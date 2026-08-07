import 'package:flutter/material.dart';
import '../theme/coze_colors.dart';
import '../theme/coze_theme.dart';

/// Coze 风格弹窗 —— 统一替换默认 Material AlertDialog
class CozeDialog extends StatelessWidget {
  final String? title;
  final Widget content;
  final List<Widget> actions;

  const CozeDialog({
    super.key,
    this.title,
    required this.content,
    this.actions = const [],
  });

  /// 统一的输入弹窗
  static Future<String?> showInput(
    BuildContext context, {
    required String title,
    String? hintText,
    String initialValue = '',
    int maxLines = 1,
    String confirmText = '确定',
    String cancelText = '取消',
  }) {
    final controller = TextEditingController(text: initialValue);
    return showDialog<String>(
      context: context,
      builder: (ctx) => CozeDialog(
        title: title,
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: maxLines,
          style: const TextStyle(fontSize: CozeFontSize.s16, color: CozeColors.fgPrimary),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: CozeColors.fgDim),
            filled: true,
            fillColor: CozeColors.chipGray,
            border: OutlineInputBorder(
              borderRadius: CozeRadius.xlBorder,
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: CozeSpacing.lg, vertical: CozeSpacing.md),
          ),
        ),
        actions: [
          _DialogButton(
            label: cancelText,
            isPrimary: false,
            onTap: () => Navigator.pop(ctx),
          ),
          const SizedBox(width: CozeSpacing.sm),
          _DialogButton(
            label: confirmText,
            isPrimary: true,
            onTap: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                Navigator.pop(ctx, text);
              }
            },
          ),
        ],
      ),
    );
  }

  /// 统一的确认弹窗
  static Future<bool> showConfirm(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = '确定',
    String cancelText = '取消',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => CozeDialog(
        title: title,
        content: Text(content, style: const TextStyle(fontSize: CozeFontSize.s14, color: CozeColors.fgSecondary, height: 1.5)),
        actions: [
          _DialogButton(
            label: cancelText,
            isPrimary: false,
            onTap: () => Navigator.pop(ctx, false),
          ),
          const SizedBox(width: CozeSpacing.sm),
          _DialogButton(
            label: confirmText,
            isPrimary: true,
            isDestructive: isDestructive,
            onTap: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    ).then((v) => v ?? false);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: CozeSpacing.xl),
      child: Container(
        padding: const EdgeInsets.all(CozeSpacing.xl),
        decoration: BoxDecoration(
          color: CozeColors.bgMax,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null) ...[
              Text(title!, style: const TextStyle(fontSize: CozeFontSize.s18, fontWeight: FontWeight.w600, color: CozeColors.fgPrimary)),
              const SizedBox(height: CozeSpacing.lg),
            ],
            content,
            if (actions.isNotEmpty) ...[
              const SizedBox(height: CozeSpacing.xl),
              Row(children: actions.map((a) => Expanded(child: a)).toList()),
            ],
          ],
        ),
      ),
    );
  }
}

/// 弹窗内统一按钮样式
class _DialogButton extends StatelessWidget {
  final String label;
  final bool isPrimary;
  final bool isDestructive;
  final VoidCallback onTap;

  const _DialogButton({
    required this.label,
    required this.onTap,
    this.isPrimary = false,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isPrimary
        ? (isDestructive ? CozeColors.error : CozeColors.brand5)
        : CozeColors.chipGray;
    final fgColor = isPrimary ? Colors.white : CozeColors.fgSecondary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: CozeSpacing.md),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: CozeRadius.xlBorder,
        ),
        child: Center(
          child: Text(label, style: TextStyle(fontSize: CozeFontSize.s16, fontWeight: FontWeight.w500, color: fgColor)),
        ),
      ),
    );
  }
}

/// Coze 风格页面过渡动画
Route<T> cozeFadeRoute<T>(Widget Function(BuildContext) builder) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 250),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}
