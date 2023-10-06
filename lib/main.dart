import 'package:flutter/material.dart';
import 'package:webproject/HomePage/home.dart';

void main() {
  runApp(const MyAapp());
}

class MyAapp extends StatelessWidget {
  const MyAapp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
