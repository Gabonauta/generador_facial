import 'package:flutter/material.dart';
import 'package:human_generator/home.dart';
import 'package:splash_screen_view/SplashScreenView.dart';
import 'package:splash_screen_view/splash_screen_view.dart';

class MySplash extends StatefulWidget {
  @override
  _MySplashState createState() => _MySplashState();
}

class _MySplashState extends State<MySplash> {
  @override
  Widget build(BuildContext context) {
    return SplashScreenView(
      duration: 3000,
      //navigateAfteFuture: ,
      navigateRoute: HomePage(),
      text: 'Generador de rostros',
      textType: TextType.TyperAnimatedText,
      imageSize: 300,
      imageSrc:
          "https://cdn.pixabay.com/photo/2017/05/10/19/29/robot-2301646_960_720.jpg",
      textStyle: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 35,
        color: Colors.white,
      ),
      backgroundColor: Colors.black,
    );
  }
}
