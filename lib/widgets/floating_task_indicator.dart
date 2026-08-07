import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/coze_colors.dart';
import '../theme/coze_theme.dart';

// ─────────────────────────────────────────────────────────────
// Global Task Progress Controller
// ─────────────────────────────────────────────────────────────

/// Global singleton to manage floating task indicator state.
class TaskProgressController extends ChangeNotifier {
  static final TaskProgressController instance = TaskProgressController._();
  TaskProgressController._();

  String? _taskName;
  String? _taskDescription;
  double _progress = 0.0;
  bool _isVisible = false;
  bool _isCompleted = false;

  String? get taskName => _taskName;
  String? get taskDescription => _taskDescription;
  double get progress => _progress;
  bool get isVisible => _isVisible;
  bool get isCompleted => _isCompleted;

  void startTask(String name, {String? description}) {
    _taskName = name;
    _taskDescription = description;
    _progress = 0.0;
    _isCompleted = false;
    _isVisible = true;
    notifyListeners();
  }

  void updateProgress(double value) {
    _progress = value.clamp(0.0, 1.0);
    notifyListeners();
  }

  void completeTask() {
    _progress = 1.0;
    _isCompleted = true;
    notifyListeners();
    Future.delayed(const Duration(seconds: 2), () {
      _isVisible = false;
      _isCompleted = false;
      notifyListeners();
    });
  }

  void hide() {
    _isVisible = false;
    _isCompleted = false;
    _progress = 0.0;
    notifyListeners();
  }

  bool get hasActiveTask => _isVisible && !_isCompleted;
}

// ─────────────────────────────────────────────────────────────
// Floating Task Indicator — Draggable + Edge Snap
// ─────────────────────────────────────────────────────────────
//
// Usage:
//   Wrap in a Stack or use Positioned.fill to give it full screen.
//   The widget renders itself as an absolutely-positioned element
//   inside the available area.
//
//   TaskProgressController.instance.startTask('编译中...');
//   TaskProgressController.instance.updateProgress(0.5);
//   TaskProgressController.instance.completeTask();
//

class FloatingTaskIndicator extends StatefulWidget {
  final double size;
  final double initialVerticalRatio;

  const FloatingTaskIndicator({
    super.key,
    this.size = 52,
    this.initialVerticalRatio = 0.35,
  });

  @override
  State<FloatingTaskIndicator> createState() => _FloatingTaskIndicatorState();
}

class _FloatingTaskIndicatorState extends State<FloatingTaskIndicator>
    with TickerProviderStateMixin {
  bool _isExpanded = false;
  bool _isDragging = false;
  bool _initialized = false;

  // Absolute center position of the ball
  double _centerX = 0;
  double _centerY = 0;
  bool _snappedRight = true;

  late AnimationController _expandController;
  late AnimationController _snapController;
  Animation<double>? _snapXAnim;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _snapController.addListener(() {
      if (_snapXAnim != null) {
        setState(() => _centerX = _snapXAnim!.value);
      }
    });
  }

  @override
  void dispose() {
    _expandController.dispose();
    _snapController.dispose();
    super.dispose();
  }

  void _initPosition(double w, double h) {
    if (_initialized) return;
    _initialized = true;
    _centerY = h * widget.initialVerticalRatio;
    _centerX = w - widget.size / 2 - 6;
  }

  void _toggleExpand() {
    if (_isDragging) return;
    setState(() => _isExpanded = !_isExpanded);
    if (_isExpanded) {
      _expandController.forward();
    } else {
      _expandController.reverse();
    }
  }

  void _onPanStart(DragStartDetails _) {
    _isDragging = true;
    if (_isExpanded) {
      _expandController.reverse();
      setState(() => _isExpanded = false);
    }
  }

  void _onPanUpdate(DragUpdateDetails d, double w, double h) {
    final half = widget.size / 2;
    setState(() {
      _centerY = (_centerY + d.delta.dy).clamp(half + 20, h - half - 20);
      _centerX = (_centerX + d.delta.dx).clamp(half, w - half);
    });
  }

  void _onPanEnd(DragEndDetails _, double w) {
    _isDragging = false;
    final half = widget.size / 2;
    final targetX = _centerX < w / 2 ? half + 4 : w - half - 6;
    _snappedRight = targetX > w / 2;

    _snapXAnim = Tween<double>(begin: _centerX, end: targetX).animate(
      CurvedAnimation(parent: _snapController, curve: Curves.easeOutBack),
    );
    _snapController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: TaskProgressController.instance,
      builder: (context, _) {
        final ctrl = TaskProgressController.instance;
        if (!ctrl.isVisible) {
          _initialized = false;
          return const SizedBox.shrink();
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;
            if (w == 0 || h == 0) return const SizedBox.shrink();
            _initPosition(w, h);
            return _render(ctrl, w, h);
          },
        );
      },
    );
  }

  Widget _render(TaskProgressController ctrl, double w, double h) {
    final half = widget.size / 2;
    final left = (_centerX - half).clamp(0.0, w - widget.size);
    final top = (_centerY - half).clamp(0.0, h - widget.size);
    final panelLeft = _snappedRight; // panel appears on left side of ball

    return Stack(
      children: [
        Positioned(
          left: left,
          top: top,
          child: GestureDetector(
            onPanStart: _onPanStart,
            onPanUpdate: (d) => _onPanUpdate(d, w, h),
            onPanEnd: (d) => _onPanEnd(d, w),
            onTap: _toggleExpand,
            child: AnimatedScale(
              scale: _isDragging ? 1.12 : 1.0,
              duration: const Duration(milliseconds: 120),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Panel on left side of ball (when ball is on right edge)
                  if (_isExpanded && !_isDragging && panelLeft)
                    _buildPanelFade(ctrl),
                  // The circle
                  _buildCircle(ctrl),
                  // Panel on right side of ball (when ball is on left edge)
                  if (_isExpanded && !_isDragging && !panelLeft)
                    _buildPanelFade(ctrl),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPanelFade(TaskProgressController ctrl) {
    return AnimatedBuilder(
      animation: _expandController,
      builder: (context, child) {
        final v = _expandController.value;
        if (v <= 0) return const SizedBox.shrink();
        final dx = _snappedRight ? -6.0 * v : 6.0 * v;
        return Transform.translate(
          offset: Offset(dx, 0),
          child: Opacity(opacity: v, child: child),
        );
      },
      child: _buildDetailPanel(ctrl),
    );
  }

  // ─── Circle ───
  Widget _buildCircle(TaskProgressController ctrl) {
    final size = widget.size;
    const sw = 3.0;
    final ringSize = size - sw * 4;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: CozeColors.bgMax,
        boxShadow: CozeShadow.defaultShadow,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // BG ring
          CustomPaint(
            size: Size(ringSize, ringSize),
            painter: _RingPainter(
                color: CozeColors.chipGray, strokeWidth: sw, progress: 1.0),
          ),
          // Progress ring
          CustomPaint(
            size: Size(ringSize, ringSize),
            painter: _RingPainter(
              color: ctrl.isCompleted ? CozeColors.success : CozeColors.brand5,
              strokeWidth: sw + 0.5,
              progress: ctrl.progress,
            ),
          ),
          // Icon
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: ctrl.isCompleted
                ? const Icon(Icons.check, size: 22, color: CozeColors.success,
                    key: ValueKey('done'))
                : _isExpanded
                    ? const Icon(Icons.close, size: 18, color: CozeColors.fgDim,
                        key: ValueKey('close'))
                    : Icon(_taskIcon(), size: 20, color: CozeColors.brand5,
                        key: const ValueKey('task')),
          ),
          // Drag hint dots
          if (!_isExpanded && !_isDragging)
            Positioned(
              bottom: 6,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  3,
                  (_) => Container(
                    width: 2.5,
                    height: 2.5,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: const BoxDecoration(
                        color: CozeColors.dimText, shape: BoxShape.circle),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─── Detail Panel ───
  Widget _buildDetailPanel(TaskProgressController ctrl) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 200, minWidth: 140),
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: CozeColors.bgMax,
        borderRadius: CozeRadius.xxlBorder,
        boxShadow: CozeShadow.defaultShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_taskIcon(), size: 16,
                  color:
                      ctrl.isCompleted ? CozeColors.success : CozeColors.brand5),
              const SizedBox(width: 6),
              Flexible(
                child: Text(ctrl.taskName ?? '任务进行中',
                    style: const TextStyle(
                        fontSize: CozeFontSize.s14,
                        fontWeight: FontWeight.w600,
                        color: CozeColors.fgPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          if (ctrl.taskDescription != null) ...[
            const SizedBox(height: 4),
            Text(ctrl.taskDescription!,
                style: const TextStyle(
                    fontSize: CozeFontSize.s12, color: CozeColors.fgDim),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],
          const SizedBox(height: 8),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: ctrl.progress,
              minHeight: 4,
              backgroundColor: CozeColors.chipGray,
              valueColor: AlwaysStoppedAnimation(
                  ctrl.isCompleted ? CozeColors.success : CozeColors.brand5),
            ),
          ),
          const SizedBox(height: 6),
          // Status row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(ctrl.isCompleted ? '已完成' : '进行中',
                  style: const TextStyle(
                      fontSize: 11, color: CozeColors.dimText)),
              Text('${(ctrl.progress * 100).toInt()}%',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: ctrl.isCompleted
                          ? CozeColors.success
                          : CozeColors.brand5)),
            ],
          ),
        ],
      ),
    );
  }

  IconData _taskIcon() {
    final n = (TaskProgressController.instance.taskName ?? '').toLowerCase();
    if (n.contains('编译') || n.contains('build')) return Icons.build;
    if (n.contains('下载') || n.contains('download')) return Icons.download;
    if (n.contains('上传') || n.contains('upload')) return Icons.upload;
    if (n.contains('同步') || n.contains('sync')) return Icons.sync;
    if (n.contains('部署') || n.contains('deploy')) return Icons.cloud_upload;
    if (n.contains('推送') || n.contains('push')) return Icons.send;
    return Icons.hourglass_top;
  }
}

// ─────────────────────────────────────────────────────────────
// Ring painter
// ─────────────────────────────────────────────────────────────

class _RingPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double progress;

  _RingPainter(
      {required this.color,
      required this.strokeWidth,
      required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final c = Offset(size.width / 2, size.height / 2);
    final r = (size.width - strokeWidth) / 2;
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress || old.color != color;
}
