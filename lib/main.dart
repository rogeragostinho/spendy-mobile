import 'package:flutter/material.dart';
import 'package:spendy_mobile/screens/login_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env.development");

  /*
  await dotenv.load(
  fileName: kReleaseMode
      ? ".env.production"
      : ".env.development",
  );
*/

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: LoginScreen()
    );
  }
}
