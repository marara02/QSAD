import 'package:flutter/material.dart';

class ProfileMenuWidget extends StatelessWidget {
  const ProfileMenuWidget(
      {super.key,
      required this.title,
      required this.icon,
      required this.onPress});

  final String title;
  final IconData icon;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onPress,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: const Color(0xFF65BEFF).withOpacity(0.1),
        ),
        child:  Icon(icon, color: const Color(0xFF65BEFF)),
      ),
      title: Text(title, style: Theme.of(context).textTheme.bodyMedium),
      trailing: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: Colors.grey.withOpacity(0.1),
        ),
        child: const Icon(Icons.arrow_circle_right,
            size: 18.0, color: Colors.grey),
      ),
    );
  }
}
