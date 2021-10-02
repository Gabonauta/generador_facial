import 'package:flutter/material.dart';
import 'package:human_generator/home.dart';
import 'package:human_generator/splashscreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      debugShowCheckedModeBanner: false,
      initialRoute: 'splashscreen_page',
      routes: {
        'home_page': (_) => HomePage(),
        'splashscreen_page': (_) => MySplash(),
      },
    );
  }
}
