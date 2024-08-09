import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late List<CameraDescription> cameras;
  CameraController? cameraController;
  CameraImage? cameraImage;
  String result = "";

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    try {
      cameras = await availableCameras();
      cameraController = CameraController(cameras[0], ResolutionPreset.medium);

      await cameraController!.initialize();

      if (!mounted) return;

      setState(() {
        cameraController!.startImageStream((imageStream) {
          cameraImage = imageStream;
          // runModel();
        });
      });
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Drowsiness detection"),
        ),
        body: cameraController == null || !cameraController!.value.isInitialized
            ? Center(child: CircularProgressIndicator())
            : Stack(
          children: [
            Center(
              child: Align(
                alignment: Alignment(0.0, -0.8),
                child: FractionallySizedBox(
                  widthFactor: 0.9,
                  heightFactor: 0.6,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: AspectRatio(
                      aspectRatio: cameraController!.value.aspectRatio,
                      child: CameraPreview(cameraController!),
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment(0.0, -0.8),
              child: FractionallySizedBox(
                widthFactor: 0.9,
                heightFactor: 0.6,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(
                      color: Colors.white,
                      width: 4.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {  },
              child: const Text("Stop"),
            ),
          ],
        ),
      ),
    );
  }
}
