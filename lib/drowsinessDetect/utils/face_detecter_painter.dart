import 'dart:math';
import 'dart:typed_data';

import 'coordinates_painter.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceDetectorPainter extends CustomPainter {
  final List<Face> faces;
  final Size absoluteImageSize;
  final InputImageRotation rotation;
  final void Function(Uint8List, bool) onEyeDetected;

  FaceDetectorPainter(this.faces, this.absoluteImageSize, this.rotation, this.onEyeDetected);

  @override
  void paint(final Canvas canvas, final Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Colors.blue;

    for (final Face face in faces) {
      final leftEyeContour = face.contours[FaceContourType.leftEye];
      final rightEyeContour = face.contours[FaceContourType.rightEye];

      if (leftEyeContour != null && rightEyeContour != null) {
        _cropAndSendEyeImage(canvas, size, leftEyeContour.points, isLeftEye: true);
        _cropAndSendEyeImage(canvas, size, rightEyeContour.points, isLeftEye: false);
      }
    }
  }

  void _cropAndSendEyeImage(Canvas canvas, Size size, List<Point<int>> eyePoints, {required bool isLeftEye}) {
    // Calculate bounding box around the eye
    double minX = eyePoints.map((point) => translateX(point.x.toDouble(), rotation, size, absoluteImageSize)).reduce(min);
    double minY = eyePoints.map((point) => translateY(point.y.toDouble(), rotation, size, absoluteImageSize)).reduce(min);
    double maxX = eyePoints.map((point) => translateX(point.x.toDouble(), rotation, size, absoluteImageSize)).reduce(max);
    double maxY = eyePoints.map((point) => translateY(point.y.toDouble(), rotation, size, absoluteImageSize)).reduce(max);

    final Rect eyeRect = Rect.fromLTRB(minX, minY, maxX, maxY);
    // Assume you have a way to get the image bytes from the canvas (this can be complex in practice)
    final eyeImageBytes = _getBytesFromCanvas(eyeRect);

    // Send the cropped eye image to the callback
    onEyeDetected(eyeImageBytes, isLeftEye);
  }

  Uint8List _getBytesFromCanvas(Rect eyeRect) {
    return Uint8List(0); // Placeholder: Implement this according to your needs.
  }

  @override
  bool shouldRepaint(final FaceDetectorPainter oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize || oldDelegate.faces != faces;
  }
}
