import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:safedriving/components/profile_list.dart';
import 'package:safedriving/pages/update_profile.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFF1FAFF),
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Users')
              .doc(currentUser.email)
              .snapshots(),
          builder: (context, snapshot){
            if(snapshot.hasData){
              final userData = snapshot.data!.data() as Map<String, dynamic>;
              return Center(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      // Margin from the screen edges
                      child: ListView(
                        children: [
                          const SizedBox(height: 50),
                          const Icon(
                            Icons.person,
                            size: 90,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            userData['first_name'] + ' ' + userData['last_name'],
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black),
                          ),
                          Text(
                            currentUser.email!,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                              width: 80,
                              child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                          const UpdateProfile()),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF65BEFF),
                                    side: BorderSide.none,
                                    shape: const StadiumBorder(),
                                  ),
                                  child: const Text("Edit",
                                      style: TextStyle(color: Colors.white)))),
                          const SizedBox(height: 40),
                          Container(
                              margin: EdgeInsets.symmetric(horizontal: 10.0),
                              // Margin of 8 from left and right
                              padding: EdgeInsets.all(16.0),
                              // Optional: Padding inside the container
                              decoration: BoxDecoration(
                                color: Colors.white,
                                // Background color of the container
                                borderRadius: BorderRadius.circular(
                                    12.0), // Rounded corners with radius of 12
                              ),
                              child: Column(
                                children: [
                                  ProfileMenuWidget(
                                      title: 'Settings',
                                      icon: Icons.settings,
                                      textColor: Colors.black,
                                      onPress: () {}),
                                  ProfileMenuWidget(
                                      title: 'Download analytics',
                                      icon: Icons.data_saver_on,
                                      textColor: Colors.black,
                                      onPress: () {}),
                                  const SizedBox(height: 80),
                                  ProfileMenuWidget(
                                      title: 'Logout',
                                      icon: Icons.logout,
                                      textColor: Colors.red,
                                      onPress: signOut),
                                ],
                              )),
                        ],
                      )));
            }
            else if(snapshot.hasError){
              return Center(
                child: Text('Error ${snapshot.error}'),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ));
  }
}
