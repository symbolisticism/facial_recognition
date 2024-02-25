import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:facial_reg/screens/home.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// @@riverpod
// ThemeData appTheme(Ref ref) {
//   return ThemeData;
// }

TextStyle h2 = GoogleFonts.lato().copyWith(fontSize: 18);
ColorScheme colorScheme =
    ColorScheme.fromSeed(seedColor: const Color.fromARGB(0, 4, 95, 23));

void main() async {
  // ensure initialization before accessing cameras
  WidgetsFlutterBinding.ensureInitialized();

  // get a list of available cameras
  final cameras = await availableCameras();

  // select a camera from the list
  final webcam = cameras.first;

  runApp(
    ProviderScope(
      child: MaterialApp(
        theme: ThemeData.dark(useMaterial3: true)
            .copyWith(colorScheme: colorScheme),
        debugShowCheckedModeBanner: false,
        home: MyApp(camera: webcam),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key, required this.camera});

  CameraDescription camera;

  @override
  Widget build(BuildContext context) {
    return Home(camera: camera);
  }
}
