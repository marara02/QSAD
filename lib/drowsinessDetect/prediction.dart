import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

class CameraView extends StatelessWidget {
  final List<dynamic> results;
  final int previewH;
  final int previewW;
  final double screenH;
  final double screenW;

  CameraView(
      this.results, this.previewH, this.previewW, this.screenH, this.screenW);

  @override
  Widget build(BuildContext context) {
    List<Widget> _renderStrings() {
      return results.map((re) {
        try {
          if (re["label"] == '0' && (re["confidence"] * 100 > 80)) {
            FlutterRingtonePlayer.play(
              android: AndroidSounds.notification,
              ios: IosSounds.glass,
            );
          } else {
            FlutterRingtonePlayer.stop();
          }
        } catch (err) {
          print(err);
        }

        return Stack(
          children: <Widget>[
            Positioned(
              left: screenW / 4,
              bottom: -(screenH - 80),
              width: screenW,
              height: screenH,
              child: Text(
                "${re["label"] == 'closed_eyes' ? "Eyes Closed" : "Eyes Open"} ${(re["confidence"] * 100).toStringAsFixed(0)}%",
                style: TextStyle(
                  color:
                      re["label"] == 'closed_eyes' ? Colors.red : Colors.green,
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        );
      }).toList();
    }

    return FractionallySizedBox(
      widthFactor: 1.0,
      child: Stack(
        children: _renderStrings(),
      ),
    );
  }
}
