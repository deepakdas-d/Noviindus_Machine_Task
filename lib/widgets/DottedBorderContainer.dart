import 'package:flutter/material.dart';

class DottedBorderContainer extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  final Color borderColor;
  final Widget child;
  final double strokeWidth;
  final double dashLength;
  final double dashGap;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  const DottedBorderContainer({
    super.key,
    required this.width,
    required this.height,
    required this.child,
    this.radius = 12,
    this.borderColor = Colors.grey,
    this.strokeWidth = 1,
    this.dashLength = 6,
    this.dashGap = 3,
    this.onTap,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    Widget container = CustomPaint(
      painter: _DottedBorderPainter(
        color: borderColor,
        strokeWidth: strokeWidth,
        radius: radius,
        dashLength: dashLength,
        dashGap: dashGap,
      ),
      child: Container(
        width: width,
        height: height,
        padding: padding,
        child: child,
      ),
    );

    // Wrap with GestureDetector if onTap is provided
    if (onTap != null) {
      container = GestureDetector(onTap: onTap, child: container);
    }

    return container;
  }
}

class _DottedBorderPainter extends CustomPainter {
  final double radius;
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double dashGap;

  _DottedBorderPainter({
    required this.radius,
    required this.color,
    required this.strokeWidth,
    required this.dashLength,
    required this.dashGap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final path = Path()..addRRect(rrect);
    final dashPath = Path();

    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashLength;
        dashPath.addPath(
          metric.extractPath(distance, next.clamp(0.0, metric.length)),
          Offset.zero,
        );
        distance = next + dashGap;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
