import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:facial_reg/screens/home.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

ColorScheme colorScheme =
    ColorScheme.fromSeed(seedColor: const Color.fromARGB(0, 138, 77, 42), brightness: Brightness.dark);

void main() async {
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
    ProviderScope(
      child: MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
        ).copyWith(
          colorScheme: colorScheme),
        debugShowCheckedModeBanner: false,
        home: MyApp(camera: webcam),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.camera});

  final CameraDescription camera;

  @override
  Widget build(BuildContext context) {
    return Home(camera: camera);
  }
}
