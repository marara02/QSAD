import 'package:flutter/material.dart';

class SwitchCamera extends StatefulWidget {
  const SwitchCamera({super.key, required Null Function(bool value) onChanged});

  @override
  State<SwitchCamera> createState() => _SwitchCameraState();
}

class _SwitchCameraState extends State<SwitchCamera> {
  bool light = true;

  @override
  Widget build(BuildContext context) {
    return Switch(
      // This bool value toggles the switch.
      value: light,
      activeColor: Colors.green,
      onChanged: (bool value) {
        // This is called when the user toggles the switch.
        setState(() {
          light = value;
        });
      },
    );
  }
}
