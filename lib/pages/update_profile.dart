import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:safedriving/components/textfield.dart';
import 'package:intl/intl.dart';
import 'package:safedriving/pages/profile.dart';

const List<String> list = <String>['Female', 'Male', 'Other'];

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({super.key});

  @override
  State<UpdateProfile> createState() => _UpdateProfile();
}

class _UpdateProfile extends State<UpdateProfile> {
  final firstnameTextController = TextEditingController();
  final lastnameTextController = TextEditingController();
  final dateBirthController = TextEditingController();
  final citizenShipController = TextEditingController();
  final countryLiveController = TextEditingController();

  String dropdownValue = list.first;
  final currentUser = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back)),
          title: Text('Update Profile',
              style: Theme.of(context).textTheme.headlineMedium),
        ),
        body: SingleChildScrollView(
            child: Container(
                padding: const EdgeInsets.all(10.0),
                child: Column(children: [
                  const Stack(
                    children: [
                      Icon(
                        Icons.person,
                        size: 80,
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                  Form(
                      child: Column(children: [
                    MyTextField(
                        controller: firstnameTextController,
                        hintText: 'First name',
                        obscureText: false),
                    const SizedBox(height: 20),
                    MyTextField(
                        controller: lastnameTextController,
                        hintText: 'Last name',
                        obscureText: false),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: TextField(
                        controller: dateBirthController,
                        readOnly: true,
                        decoration: InputDecoration(
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          fillColor: Colors.grey[200],
                          filled: true,
                          hintText: 'Date of birth',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                        ),
                        onTap: () => onTapFunction(context: context),
                      ),
                    ),
                    const SizedBox(height: 20),
                    DropdownMenu<String>(
                      width: 330,
                      initialSelection: list.first,
                      onSelected: (String? value) {
                        // This is called when the user selects an item.
                        setState(() {
                          dropdownValue = value!;
                        });
                      },
                      dropdownMenuEntries:
                          list.map<DropdownMenuEntry<String>>((String value) {
                        return DropdownMenuEntry<String>(
                            value: value, label: value);
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    MyTextField(
                        controller: citizenShipController,
                        hintText: 'Citizenship',
                        obscureText: false),
                    const SizedBox(height: 20),
                    MyTextField(
                        controller: countryLiveController,
                        hintText: 'Birth Country',
                        obscureText: false),
                    const SizedBox(height: 30),
                    SizedBox(
                        width: 200,
                        child: ElevatedButton(
                            onPressed: () {
                              saveUserData();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF65BEFF),
                              side: BorderSide.none,
                              shape: const StadiumBorder(),
                            ),
                            child: const Text("Save",
                                style: TextStyle(color: Colors.white)))),
                  ]))
                ]))));
  }

  void _fetchUserData() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.email)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        // Populate the text controllers with the existing data
        firstnameTextController.text = userData['first_name'] ?? '';
        lastnameTextController.text = userData['last_name'] ?? '';
        dateBirthController.text = userData['date_of_birth'] ?? '';
        dropdownValue = userData['gender'] ?? list.first;
        citizenShipController.text = userData['citizenship'] ?? '';
        countryLiveController.text = userData['birth_country'] ?? '';

        // Call setState to update the UI
        setState(() {});
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  onTapFunction({required BuildContext context}) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      lastDate: DateTime.now(),
      firstDate: DateTime(1900),
      initialDate: DateTime.now(),
    );
    if (pickedDate == null) return;
    dateBirthController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
  }

  void saveUserData() async {
    Map<String, dynamic> updatedData = {
      "first_name": firstnameTextController.text,
      "last_name": lastnameTextController.text,
      "date_of_birth": dateBirthController.text,
      "gender": dropdownValue,
      "citizenship": citizenShipController.text,
      "birth_country": countryLiveController.text,
    };

    // Update the user data in FireStore
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser.email)
        .update(updatedData)
        .then((_) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Profile()),
      );
    }).catchError((error) {
      print("Failed to update user: $error");
    });
  }
}
