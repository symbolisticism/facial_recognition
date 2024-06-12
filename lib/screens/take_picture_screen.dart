import 'package:camera/camera.dart';
import 'package:facial_reg/widgets/image_input.dart';
import 'package:flutter/material.dart';

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    super.key,
    required this.camera,
  });

  final CameraDescription camera;

  @override
  State<TakePictureScreen> createState() => _TakePictureScreenState();
}

class _TakePictureScreenState extends State<TakePictureScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Take a Picture'),
      ),
      body: ImageInput(camera: widget.camera),
    );
  }
}
