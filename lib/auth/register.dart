import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:safedriving/components/button.dart';
import 'package:safedriving/components/textfield.dart';
import 'package:intl/intl.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final firstnameTextController = TextEditingController();
  final lastnameTextController = TextEditingController();
  final dateBirthController = TextEditingController();

  Future<void> signUp() async {
    showDialog(
        context: context,
        builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ));
    if (passwordTextController.text != confirmPasswordController.text) {
      Navigator.pop(context);
      displayMessage("Passwords don't match");
      return;
    }
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailTextController.text,
              password: passwordTextController.text);

      // Creating User's collection
      FirebaseFirestore.instance
          .collection("Users")
          .doc(userCredential.user?.email)
          .set({
        'first_name': firstnameTextController.text,
        'last_name': lastnameTextController.text,
        'username': emailTextController.text.split('@'),
        'date_birth': dateBirthController.text,
        'gender': 'Other',
        'citizenship': 'United Kingdom',
        'home_country': 'United Kingdom'
      });
      if (context.mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      displayMessage(e.code);
    }
  }

  void displayMessage(String message) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(message),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFE1F7F5),
        body: ListView(children: [
          Center(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.app_registration,
                  size: 100,
                ),
                const SizedBox(height: 40),
                Text(
                  "Welcome, register your driver account",
                  style: TextStyle(color: Colors.grey[700], fontSize: 20),
                ),
                const SizedBox(height: 25),
                MyTextField(
                    controller: firstnameTextController,
                    hintText: 'First name',
                    obscureText: false),
                const SizedBox(height: 10),
                MyTextField(
                    controller: lastnameTextController,
                    hintText: 'Last name',
                    obscureText: false),
                const SizedBox(height: 10),
                MyTextField(
                    controller: emailTextController,
                    hintText: 'Email',
                    obscureText: false),
                const SizedBox(height: 10),
                MyTextField(
                    controller: passwordTextController,
                    hintText: 'Set Password',
                    obscureText: true),
                const SizedBox(height: 10),
                MyTextField(
                    controller: confirmPasswordController,
                    hintText: 'Confirm Password',
                    obscureText: true),
                const SizedBox(height: 10),
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
                      fillColor: Colors.white,
                      filled: true,
                      hintText: 'Date of birth',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                    ),
                    onTap: () => onTapFunction(context: context),
                  ),
                ),
                const SizedBox(height: 25),
                MyButton(
                  onTap: signUp,
                  text: 'Register',
                ),
                const SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already has account?',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: widget.onTap,
                          child: const Text('Login',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              )),
                        )
                      ]),
                )
              ],
            ),
          )),
        ]));
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
}
