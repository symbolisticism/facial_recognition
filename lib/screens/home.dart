import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

var logger = Logger(printer: PrettyPrinter());
var db = FirebaseFirestore.instance;

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
    /// Returns a dummy API response with dummy data
    /// This function assumes that the machine learning model is
    /// sending a response that looks something like the following:
    ///
    ///  ```dart
    /// {
    /// 'identified':true,
    /// 'firstname':'John',
    /// 'lastname':'Doe'
    /// }
    /// ```
    ///
    /// ...or...
    ///
    /// ```dart
    /// {
    /// 'identified':false
    /// }
    /// ```
    Future<String> mlModelResponse(XFile image) {
      // send the image

      const person = {
        'identified': true,
        'employeeid': '123',
        'firstname': 'Gabriele',
        'lastname': 'Peck'
      };

      // return Future<String>.value(jsonEncode(person));
      return Future.delayed(
          const Duration(seconds: 1), () => jsonEncode(person));
    }

    /// Checks whether the first value of the JSON response is true or false
    /// This makes the assumption that data returned from the machine
    ///   learning model looks like the following:
    ///
    /// ```dart
    /// {
    /// 'identified':true,
    /// 'firstname':'John',
    /// 'lastname':'Doe'
    /// }
    /// ```
    bool isPersonRecognized(dynamic jsonResponse) {
      if (jsonResponse['identified'] == true) {
        return true;
      }

      return false;
    }

    /// Returns a dummy response from a Firestore database
    Future<bool> firestoreDocExists(dynamic jsonResponse) {
      logger.d(jsonResponse['employeeid']);
      final usersRef = db.collection('users').doc(jsonResponse['employeeid']);
      logger.d('Hello Before');
      return usersRef.get().then((value) => value.exists ? true : false);
    }

    /// Returns a dummy response relating the success of the post operation
    /// to the database
    Future<bool> addUser() {
      return Future.delayed(const Duration(seconds: 1), () => true);
    }

    /// Returns the success of clocking the user in or out
    Future<bool> clockUser() {
      return Future.delayed(const Duration(seconds: 1), () => true);
    }

    /// Returns a JSON string converted to JSON, throws an error
    ///   if the returned object cannot be encoded as JSON
    dynamic convertToJson(String response) {
      try {
        return jsonDecode(response);
      } catch (e) {
        logger.e(e);
        return {'identified': false, 'error': 'JSON conversion'};
      }
    }

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

            var response = await mlModelResponse(image);
            var jsonResponse = convertToJson(response);

            // check that the user is recognized and that they have a record in
            //  the database

            // if the person was recognized by the ML model and their record was
            //  found in the database

            logger.d(isPersonRecognized(jsonResponse)); // true
            logger.d(await firestoreDocExists(jsonResponse)); // false

            if (isPersonRecognized(jsonResponse) &&
                await firestoreDocExists(jsonResponse)) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('The user was found.'),
                duration: Duration(seconds: 3),
              ));

              // if the person was either recognized by the ML model or a record
              //  was found in the database, but not both
            } else if (isPersonRecognized(jsonResponse) ||
                await firestoreDocExists(jsonResponse)) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text(
                    'The user is either recognized or recorded, but not both.'),
                duration: Duration(seconds: 3),
              ));

              // if neither the person was recognized by the ML model nor a record
              //  was found in the database for them
            } else {
              // show that the user could not be found
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text(
                    'The user could not be identified. Please register as a new user or try again.'),
                duration: Duration(seconds: 3),
              ));
            }
          } catch (e) {
            logger.e(e);
          }
        },
        child: const Icon(Icons.camera),
      ),
    );
  }
}
