// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
// import 'package:safedriving/drowsinessDetect/utils/face_detecter_painter.dart';
// import 'package:tflite_flutter/tflite_flutter.dart';
//
// class EyeDetectionScreen extends StatefulWidget {
//   @override
//   _EyeDetectionScreenState createState() => _EyeDetectionScreenState();
// }
//
// class _EyeDetectionScreenState extends State<EyeDetectionScreen> {
//   late List<CameraDescription> cameras;
//   CameraController? _cameraController;
//   late FaceDetector _faceDetector;
//   late Interpreter _interpreter;
//   bool _isDetecting = false;
//   List<Face> _faces = [];
//   Size _imageSize = Size.zero;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//     _initializeTFLite();
//     _faceDetector = FaceDetector(
//       options: FaceDetectorOptions(
//         enableClassification: true,
//         enableLandmarks: true,
//         performanceMode: FaceDetectorMode.fast,
//         enableContours: true
//       ),
//     );
//   }
//
//   Future<void> _initializeTFLite() async {
//     _interpreter = await Interpreter.fromAsset('assets/model.tflite');
//   }
//
//   void _initializeCamera() async {
//     final cameras = await availableCameras();
//     _cameraController = CameraController(
//       cameras[0],
//       ResolutionPreset.high,
//       enableAudio: false,
//     );
//     await _cameraController?.initialize();
//     if (!mounted) return;
//     setState(() {});
//     _cameraController?.startImageStream((image) => _processCameraImage(image));
//   }
//
//   void _processCameraImage(CameraImage image) async {
//     if (_isDetecting) return;
//     _isDetecting = true;
//
//     final inputImage = _convertCameraImage(image);
//     final faces = await _faceDetector.processImage(inputImage);
//
//     setState(() {
//       _faces = faces;
//       _imageSize = Size(image.width.toDouble(), image.height.toDouble());
//     });
//
//     _isDetecting = false;
//   }
//
//   InputImage _convertCameraImage(CameraImage image) {
//     final WriteBuffer allBytes = WriteBuffer();
//     for (Plane plane in image.planes) {
//       allBytes.putUint8List(plane.bytes);
//     }
//     final bytes = allBytes.done().buffer.asUint8List();
//
//     final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());
//
//     final InputImageRotation imageRotation = InputImageRotation.rotation0deg;
//
//     final InputImageFormat inputImageFormat = InputImageFormatValue.fromRawValue(image.format.raw) ?? InputImageFormat.nv21;
//
//     final planeData = image.planes.map(
//           (Plane plane) {
//         return InputImagePlaneMetadata(
//           bytesPerRow: plane.bytesPerRow,
//           height: plane.height,
//           width: plane.width,
//         );
//       },
//     ).toList();
//
//     final inputImageData = InputImageData(
//       size: imageSize,
//       imageRotation: imageRotation,
//       inputImageFormat: inputImageFormat,
//       planeData: planeData,
//     );
//     return InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);
//   }
//
//   void _onEyeDetected(Uint8List eyeImageBytes, bool isLeftEye) async {
//     final input = _preprocess(eyeImageBytes); // Preprocess the eye image
//     final output = List<double>.filled(1, 0.0);
//     _interpreter.run(input, output);
//     print("Output check: $output");
//     final eyeState = output[0] > 0.5 ? 'Open' : 'Closed';
//     print('${isLeftEye ? 'Left' : 'Right'} eye is $eyeState');
//   }
//
//   List<double> _preprocess(Uint8List eyeImageBytes) {
//     // Preprocess the image bytes to match the input shape of your TFLite model
//     // This usually involves resizing and normalizing the image
//     return List<double>.filled(224 * 224, 0.0); // Example placeholder
//   }
//
//   @override
//   void dispose() {
//     _cameraController?.dispose();
//     _faceDetector.close();
//     _interpreter.close();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_cameraController == null || !_cameraController!.value.isInitialized) {
//       return Scaffold(
//         body: Center(
//           child: CircularProgressIndicator(),
//         ),
//       );
//     }
//
//     return Scaffold(
//       body: Stack(
//         children: [
//           CameraPreview(_cameraController!),
//           CustomPaint(
//             painter: FaceDetectorPainter(_faces, _imageSize, InputImageRotation.rotation0deg, _onEyeDetected),
//             size: Size.infinite,
//           ),
//         ],
//       ),
//     );
//   }
// }
