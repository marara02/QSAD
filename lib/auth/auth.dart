import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:safedriving/pages/mainPage.dart';
import '../components/navBar.dart';
import '../pages/homePage.dart';
import 'login_or_reg.dart';

class AuthPage extends StatelessWidget{
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot){
          if(snapshot.hasData){
            return const NavigationExample();
          }
          else{
            return const LoginOrReg();
          }
        },
      ),
    );
  }
}