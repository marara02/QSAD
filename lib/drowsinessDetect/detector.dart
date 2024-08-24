import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tflite_v2/tflite_v2.dart';

import 'face_detecter.dart';

class Detection extends StatefulWidget {
  @override
  _DetectionState createState() => _DetectionState();
}

class _DetectionState extends State<Detection> {
  late bool _loading;
  late List _outputs;
  late File _image;
  int count = 0;
  void initState() {
    super.initState();
    _loading = true;
    try {
      loadModel().then((value) {
        setState(() {
          _loading = false;
        });

        Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) {
              return DrowsinessDetectionLive();
            }));
      });
    } catch (err) {
      print("Error occured $err");
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/model.tflite",
      labels: "assets/label.txt",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _loading
            ? Container(
          alignment: Alignment.center,
          child: CircularProgressIndicator(),
        )
            : Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.center,
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _image == null
                  ? Container()
                  : Image.file(_image,
                  fit: BoxFit.cover,
                  height: MediaQuery.of(context).size.height * 0.6),
              const SizedBox(
                height: 10,
              ),
              _outputs != null
                  ? Column(
                children: <Widget>[
                  Text(
                    _outputs[0]["label"] == 'closed_eyes'
                        ? "Eyes closed"
                        : "Eyes Open",
                    style: TextStyle(
                      color: _outputs[0]["label"] == 'closed_eyes'
                          ? Colors.red
                          : Colors.green,
                      fontSize: 25.0,
                    ),
                  ),
                  Text(
                    "${(_outputs[0]["confidence"] * 100).toStringAsFixed(0)}%",
                    style: const TextStyle(
                        color: Colors.purpleAccent, fontSize: 20),
                  )
                ],
              )
                  : const Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    // here
                  ],
                ),
              )
            ],
          ),
        ));
  }
}