import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: Scaffold(
        appBar: AppBar(title: Text("Hello Flutter")),
        body: Center(child: Text("Welcome Zack!")),
      ),
    );
  }
}
void main() {
  runApp(MyApp());
}