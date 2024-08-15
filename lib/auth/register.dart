import 'package:flutter/material.dart';
import 'package:safedriving/components/button.dart';
import 'package:safedriving/components/textfield.dart';

class RegisterPage extends StatefulWidget{
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>{
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final firstnameTextController = TextEditingController();
  final lastnameTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock,
                  size: 100,
                ),
                const SizedBox(height: 40),

                Text(
                  "Welcome, register your driver account",
                  style: TextStyle(
                    color: Colors.grey[700],
                  ),
                ),

                const SizedBox(height: 25),
                MyTextField(
                    controller: firstnameTextController,
                    hintText: 'First name',
                    obscureText: false
                ),

                const SizedBox(height: 10),
                MyTextField(
                    controller: lastnameTextController,
                    hintText: 'Last name',
                    obscureText: false
                ),

                const SizedBox(height: 10),
                MyTextField(
                    controller: emailTextController,
                    hintText: 'Email',
                    obscureText: false
                ),

                const SizedBox(height: 10),
                MyTextField(
                    controller: passwordTextController,
                    hintText: 'Set Password',
                    obscureText: true
                ),
                const SizedBox(height: 10),
                MyTextField(
                    controller: confirmPasswordController,
                    hintText: 'Confirm Password',
                    obscureText: true
                ),
                const SizedBox(height: 25),

                MyButton(
                    onTap: (){},
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
                          child: const Text(
                              'Login',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              )
                          ),
                        )
                      ]
                  ),
                )
              ],
            ),
          )
        ),
      )
    );
  }
}