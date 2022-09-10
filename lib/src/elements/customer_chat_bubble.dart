
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomChatBubble extends CustomPainter {
  CustomChatBubble({this.color, @required this.isOwn});

  final Color color;
  final bool isOwn;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color ?? Colors.blue;

    Path paintBubbleTail() {
      Path path;
      if (!isOwn) {
        path = Path()
          ..moveTo(5, size.height - 5)
          ..quadraticBezierTo(-5, size.height, -16, size.height - 14)
          ..quadraticBezierTo(-5, size.height - 5, 0, size.height + 17);
      }
      if (isOwn) {
        path = Path()
          ..moveTo(size.width - 6, size.height - 4)
          ..quadraticBezierTo(
              size.width + 5, size.height, size.width + 16, size.height - 14)
          ..quadraticBezierTo(
              size.width + 5, size.height - 5, size.width, size.height - 17);
      }
      return path;
    }

    final RRect bubbleBody = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height), Radius.circular(16));
    final Path bubbleTail = paintBubbleTail();

    canvas.drawRRect(bubbleBody, paint);
    canvas.drawPath(bubbleTail, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}