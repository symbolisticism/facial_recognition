import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:facial_reg/screens/home.dart';
import 'package:facial_reg/screens/sign_in.dart';

final auth = FirebaseAuth.instance;

class WidgetTree extends StatefulWidget {
  const WidgetTree({
    super.key,
    required this.camera,
  });

  final CameraDescription camera;

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: auth.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Home(camera: widget.camera);
          } else {
            return const SignIn();
          }
        });
  }
}
