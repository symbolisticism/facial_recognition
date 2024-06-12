import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

var logger = Logger(printer: PrettyPrinter());

class ImageInput extends StatefulWidget {
  const ImageInput({super.key, required this.camera});

  final CameraDescription camera;

  @override
  State<ImageInput> createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  File? imageFile;

  @override
  void initState() {
    super.initState();

    _controller = CameraController(
      widget.camera,
      ResolutionPreset.veryHigh,
    );

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return imageFile == null
                  ? CameraPreview(_controller)
                  : Image.file(imageFile!);

              // if (imagePath == null) {
              //   return CameraPreview(_controller);
              // } else {
              //   Image.network(imagePath);
              // }
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
        ElevatedButton(
          onPressed: () async {
            try {
              await _initializeControllerFuture;
              final image = await _controller.takePicture();

              if (!context.mounted) return;

              Navigator.pop(context, File(image.path));

              // logger.e(image.path);

              setState(() {
                imageFile = File(image.path);
              });
            } catch (e) {
              logger.d(e);
            }
          },
          child: const Text('Take Picture'),
        ),
      ],
    );
  }
}
