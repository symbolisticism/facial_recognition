import 'package:camera/camera.dart';
import 'package:facial_reg/widgets/widget_tree.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

ColorScheme colorScheme =
    ColorScheme.fromSeed(seedColor: const Color.fromARGB(0, 138, 77, 42), brightness: Brightness.dark);

Future<void> main() async {
  // ensure initialization before accessing cameras
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // get a list of available cameras
  final cameras = await availableCameras();

  // select a camera from the list
  final webcam = cameras.first;

  runApp(
      MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
        ).copyWith(
          colorScheme: colorScheme),
        debugShowCheckedModeBanner: false,
        home: WidgetTree(camera: webcam),
      ),
  );
}
