import 'dart:io';

import 'package:flutter/material.dart';

class PictureTakenScreen extends StatelessWidget {
  const PictureTakenScreen({super.key, required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Analyzing picture..."),
      ),
      body: Image.network(imagePath),
    );
  }
}
