import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite_v2/tflite_v2.dart';
import 'dart:math' as math;
import 'coordinates.dart';

// the problem is my code not returning probability, its returning predictions
class DrowsinessDetectionLive extends StatefulWidget {
  @override
  _DrowsinessDetectionLiveState createState() =>
      _DrowsinessDetectionLiveState();
}

class _DrowsinessDetectionLiveState
    extends State<DrowsinessDetectionLive> {
  List<CameraDescription> _availableCameras = [];
  CameraController? cameraController;
  bool isDetecting = false;
  List<dynamic> _recognitions = [];
  int _imageHeight = 0;
  int _imageWidth = 0;
  bool front = true;

  @override
  void initState() {
    super.initState();
    loadModel();
    _getAvailableCameras();
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  Future<void> _getAvailableCameras() async {
    WidgetsFlutterBinding.ensureInitialized();
    _availableCameras = await availableCameras();
    _initializeCamera(_availableCameras[0]);
  }

  void loadModel() async {
    await Tflite.loadModel(
      model: "assets/model.tflite",
      labels: "assets/label.txt",
    );
  }

  Future<void> _initializeCamera(CameraDescription description) async {
    cameraController = CameraController(description, ResolutionPreset.high);
    try {
      await cameraController?.initialize().then(
        (_) {
          if (!mounted) {
            return;
          }
          cameraController?.startImageStream(
            (CameraImage img) {
              if (!isDetecting) {
                isDetecting = true;
                Tflite.runModelOnFrame(
                  bytesList: img.planes.map(
                    (plane) {
                      return plane.bytes;
                    },
                  ).toList(),
                  threshold: 0.5,
                  rotation: 0,
                  imageHeight: img.height,
                  imageWidth: img.width,
                  numResults: 1,
                ).then(
                  (recognitions) {
                    setRecognitions(recognitions, img.height, img.width);
                    isDetecting = false;
                  },
                );
              }
            },
          );
        },
      );
    } catch (e) {
      print(e);
    }
  }

  void setRecognitions(recognitions, imageHeight, imageWidth) {
    if (mounted) {
      setState(() {
        _recognitions = recognitions;
        _imageHeight = imageHeight;
        _imageWidth = imageWidth;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Output $_recognitions');
    Size screen = MediaQuery.of(context).size;
    return Container(
        constraints: const BoxConstraints.expand(),
        child: cameraController!.value.isInitialized
            ? Scaffold(
                backgroundColor: Colors.white,
                body: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: 500,
                        child: AspectRatio(
                          aspectRatio: 1 / cameraController!.value.aspectRatio,
                          child: CameraPreview(cameraController!),
                        ),
                      ),
                    ),
                    CameraView(
                      _recognitions ?? [],
                      math.max(_imageHeight, _imageWidth),
                      math.min(_imageHeight, _imageWidth),
                      screen.height,
                      screen.width,
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              )
            : Container(
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
              ));
  }
}
