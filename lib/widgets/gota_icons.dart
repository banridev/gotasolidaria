import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

/// Outlined blood drop icon matching Page 1 (`Tipo: O+`) and Page 4 preview circle.
class BloodDropIcon extends StatelessWidget {
  const BloodDropIcon({
    super.key,
    required this.size,
    required this.color,
    this.strokeWidth = 1.8,
  });

  final double size;
  final Color color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _BloodDropPainter(color: color, strokeWidth: strokeWidth),
    );
  }
}

class _BloodDropPainter extends CustomPainter {
  const _BloodDropPainter({
    required this.color,
    required this.strokeWidth,
  });

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w * 0.5, h * 0.1)
      ..cubicTo(w * 0.5, h * 0.1, w * 0.86, h * 0.50, w * 0.86, h * 0.66)
      ..arcToPoint(
        Offset(w * 0.14, h * 0.66),
        radius: Radius.circular(w * 0.36),
        clockwise: true,
      )
      ..cubicTo(w * 0.14, h * 0.50, w * 0.5, h * 0.1, w * 0.5, h * 0.1)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BloodDropPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}

/// Emergency beacon / siren icon with radiating rays matching Pages 1, 3, 4, 5.
class SirenIcon extends StatelessWidget {
  const SirenIcon({
    super.key,
    this.size = 24,
    required this.color,
    this.showRays = true,
  });

  final double size;
  final Color color;
  final bool showRays;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _SirenPainter(color: color, showRays: showRays),
    );
  }
}

class _SirenPainter extends CustomPainter {
  const _SirenPainter({required this.color, required this.showRays});

  final Color color;
  final bool showRays;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.075
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Base line
    canvas.drawLine(
      Offset(w * 0.18, h * 0.84),
      Offset(w * 0.82, h * 0.84),
      paint,
    );

    // Siren dome
    final dome = Path()
      ..moveTo(w * 0.27, h * 0.84)
      ..lineTo(w * 0.31, h * 0.50)
      ..arcToPoint(
        Offset(w * 0.69, h * 0.50),
        radius: Radius.circular(w * 0.19),
        clockwise: true,
      )
      ..lineTo(w * 0.73, h * 0.84);
    canvas.drawPath(dome, paint);

    // Center highlight line inside dome
    canvas.drawLine(
      Offset(w * 0.5, h * 0.44),
      Offset(w * 0.5, h * 0.68),
      paint..strokeWidth = size.width * 0.065,
    );

    if (showRays) {
      final rayPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.07
        ..strokeCap = StrokeCap.round;
      // Top ray
      canvas.drawLine(
        Offset(w * 0.50, h * 0.12),
        Offset(w * 0.50, h * 0.21),
        rayPaint,
      );
      // Top-left ray
      canvas.drawLine(
        Offset(w * 0.22, h * 0.24),
        Offset(w * 0.28, h * 0.30),
        rayPaint,
      );
      // Top-right ray
      canvas.drawLine(
        Offset(w * 0.78, h * 0.24),
        Offset(w * 0.72, h * 0.30),
        rayPaint,
      );
      // Left ray
      canvas.drawLine(
        Offset(w * 0.10, h * 0.52),
        Offset(w * 0.18, h * 0.52),
        rayPaint,
      );
      // Right ray
      canvas.drawLine(
        Offset(w * 0.82, h * 0.52),
        Offset(w * 0.90, h * 0.52),
        rayPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SirenPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.showRays != showRays;
}

/// Calendar icon with a small heart badge matching Page 1 and Page 5.
class CalendarHeartIcon extends StatelessWidget {
  const CalendarHeartIcon({
    super.key,
    this.size = 24,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: size * 0.9,
            color: color,
          ),
          Positioned(
            right: -1,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkSurface
                    : Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite,
                size: size * 0.42,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dashed circular border painter matching the WhatsApp `Status` button on Page 11.
class DashedCircleBorder extends StatelessWidget {
  const DashedCircleBorder({
    super.key,
    required this.size,
    required this.color,
    required this.child,
    this.strokeWidth = 2.2,
    this.dashCount = 12,
  });

  final double size;
  final Color color;
  final Widget child;
  final double strokeWidth;
  final int dashCount;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _DashedCirclePainter(
        color: color,
        strokeWidth: strokeWidth,
        dashCount: dashCount,
      ),
      child: SizedBox(
        width: size,
        height: size,
        child: Center(child: child),
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  const _DashedCirclePainter({
    required this.color,
    required this.strokeWidth,
    required this.dashCount,
  });

  final Color color;
  final double strokeWidth;
  final int dashCount;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: radius,
    );

    final sweepStep = (2 * math.pi) / dashCount;
    final dashSweep = sweepStep * 0.58;

    for (int i = 0; i < dashCount; i++) {
      canvas.drawArc(rect, i * sweepStep, dashSweep, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.dashCount != dashCount;
}

/// Custom pill toggle switch matching Page 5 (`Modo Escuro`, `Alertas`, `Lembrete`).
class GotaSwitch extends StatelessWidget {
  const GotaSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.gotaColors;
    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        width: 50,
        height: 28,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: value ? colors.success : AppColors.switchOffTrack,
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
