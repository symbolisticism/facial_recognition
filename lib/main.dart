import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextStyle h2 = GoogleFonts.lato().copyWith(fontSize: 18);
ColorScheme colorScheme =
    ColorScheme.fromSeed(seedColor: const Color.fromARGB(0, 133, 20, 127));

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData.light(useMaterial3: true)
          .copyWith(colorScheme: colorScheme),
      debugShowCheckedModeBanner: false,
      home: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Facial Recognition Punch In/Out"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Welcome to work. Use the camera to clock in.",
                  style: h2,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
