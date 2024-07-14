import 'package:camera/camera.dart';
import 'package:facial_reg/widgets/widget_tree.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:logger/logger.dart';

var logger = Logger(printer: PrettyPrinter());

ColorScheme colorScheme = ColorScheme.fromSeed(
    seedColor: const Color.fromARGB(0, 138, 77, 42),
    brightness: Brightness.dark);

Future<void> main() async {
  // ensure initialization before accessing cameras
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // get a list of available cameras
  final camerasList = await availableCameras();

  CameraDescription camera = camerasList.first;

  // select a camera from the list
  // if (camerasList.first.lensDirection == CameraLensDirection.front) {
  //   camera = camerasList.first;
  // } else {
  //   camera = camerasList[1];
  // }

  runApp(
    MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
      ).copyWith(colorScheme: colorScheme),
      debugShowCheckedModeBanner: false,
      home: WidgetTree(camera: camera),
    ),
  );
}
