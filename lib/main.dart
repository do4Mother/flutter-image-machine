import 'package:flutter/material.dart';
import 'package:image_machine/pages/home.dart';
import 'package:image_machine/provider/machine_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MachineProvider(),
      child: MaterialApp(
        title: "Image Machine",
        color: Colors.white,
        home: HomePage(),
        theme: ThemeData(
          fontFamily: 'Sf'
        ),
      ),
    );
  }
}