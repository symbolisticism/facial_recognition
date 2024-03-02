import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:facial_reg/screens/picture_taken_screen.dart';
import 'package:logger/logger.dart';

var logger = Logger(printer: PrettyPrinter());

class Home extends StatefulWidget {
  const Home({super.key, required this.camera});

  final CameraDescription camera;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
        // Get a specific camera from the list of available cameras.
        widget.camera,
        // Define the resolution to use.
        ResolutionPreset.veryHigh);

    // initialize the controller, which returns a Future
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // dispose of the camera controller
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Facial Recognition Punch In/Out"),
        centerTitle: true,
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            // display loading indicator
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            await _initializeControllerFuture;
            final image = await _controller.takePicture();

            if (!context.mounted) return;

            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PictureTakenScreen(imagePath: image.path),
              ),
            );
          } catch (e) {
            logger.e(e);
          }
        },
        child: const Icon(Icons.camera),
      ),
    );
  }
}
