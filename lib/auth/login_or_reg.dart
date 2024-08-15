import 'package:flutter/material.dart';
import 'package:safedriving/auth/login.dart';
import 'package:safedriving/auth/register.dart';

class LoginOrReg extends StatefulWidget{
  const LoginOrReg({super.key});

  @override
  State<LoginOrReg> createState() => _LoginOrRegState();
}

class _LoginOrRegState extends State<LoginOrReg>{
  bool isLoginPage = true;

  void switchPages(){
    setState(() {
      isLoginPage = !isLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(isLoginPage){
      return LoginPage(onTap: switchPages);
    }
    else{
      return RegisterPage(onTap: switchPages);
    }
  }

}