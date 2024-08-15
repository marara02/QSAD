import 'package:flutter/material.dart';
import 'package:safedriving/components/button.dart';
import 'package:safedriving/components/textfield.dart';

class LoginPage extends StatefulWidget{
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<LoginPage>{
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
        body: SafeArea(
          child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.lock,
                      size: 100,
                    ),
                    const SizedBox(height: 50),

                    Text(
                      "Log in to start drive",
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),

                    const SizedBox(height: 25),

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

                    const SizedBox(height: 25),

                    MyButton(
                      onTap: (){},
                      text: 'Login',
                    ),

                    const SizedBox(height: 50),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Not have account yet?',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: widget.onTap,
                              child: const Text(
                                  'Register',
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