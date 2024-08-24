// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:google_mlkit_commons/google_mlkit_commons.dart';
//
// class CameraExample extends StatefulWidget {
//   final CameraDescription camera;
//   final Function(InputImage inputImage) onImageCaptured;
//   final CustomPaint? customPaint;
//
//   const CameraExample({
//     Key? key,
//     required this.camera,
//     required this.onImageCaptured,
//     this.customPaint,
//   }) : super(key: key);
//
//   @override
//   _CameraExampleState createState() => _CameraExampleState();
// }
//
// class _CameraExampleState extends State<CameraExample> {
//   late CameraController _controller;
//   late Future<void> _initializeControllerFuture;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = CameraController(
//       widget.camera,
//       ResolutionPreset.high,
//     );
//     _initializeControllerFuture = _controller.initialize();
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<void>(
//       future: _initializeControllerFuture,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.done) {
//           return Stack(
//             children: [
//               CameraPreview(_controller),
//               if (widget.customPaint != null) widget.customPaint!,
//               Positioned(
//                 bottom: 16.0,
//                 left: 16.0,
//                 child: FloatingActionButton(
//                   onPressed: _captureImage,
//                   child: Icon(Icons.camera),
//                 ),
//               ),
//             ],
//           );
//         } else {
//           return Center(child: CircularProgressIndicator());
//         }
//       },
//     );
//   }
//
//   void _captureImage() async {
//     try {
//       await _initializeControllerFuture;
//
//       // Capture the image
//       final image = await _controller.takePicture();
//
//       // Convert the captured image to InputImage for further processing
//       final inputImage = InputImage.fromFilePath(image.path);
//
//       // Pass the InputImage back to the DetectorView
//       widget.onImageCaptured(inputImage);
//     } catch (e) {
//       print(e);
//     }
//   }
// }
