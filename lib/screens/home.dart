import 'package:camera/camera.dart';
import 'package:facial_reg/screens/recent_clocks.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:facial_reg/screens/add_user.dart';

var logger = Logger(printer: PrettyPrinter());
var db = FirebaseFirestore.instance;

// Home Screen
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
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const RecentClocks(),
                  ),
                );
              },
              child: const Text('Recent Clock History'),
            ),
          ],
        ),
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

            // if the person was recognized and they have a record in the database
            if (isPersonRecognized(jsonResponse) &&
                await firestoreDocExists(jsonResponse)) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('The user was found.'),
                duration: Duration(seconds: 3),
              ));

              // example of datetime output
              // 2024-06-30 22:37:07.392037
              Timestamp timestamp = Timestamp.now();
              final currentTime = timestamp.toDate();

              // break out datetime for granular control over formatting
              final year = currentTime.year;
              final month = currentTime.month;
              final day = currentTime.day;
              final hour = currentTime.hour;
              final minute = currentTime.minute;
              final second = currentTime.second;

              final macroTime = '$month:$day:$year';
              final microTime = '$hour:$minute:$second';
              final employeeid = jsonResponse['employeeid'];

              final primaryKey = '$employeeid-$macroTime-$microTime';

              bool? clockedIn;

              final clocksRef = db.collection('clocks');
              await clocksRef
                  .where('employeeid', isEqualTo: employeeid)
                  .orderBy('timestamp', descending: true)
                  .limit(1)
                  .get()
                  .then((querySnapshot) {
                if (querySnapshot.docs[0].get('clockedstatus') == false) {
                  clockedIn = true;
                } else {
                  clockedIn = false;
                }
              });

              if (!context.mounted) return;

              if (clockedIn == null) {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'There was an error determining clocked status. Please try again.'),
                  ),
                );
                return;
              }

              // construct database entry
              final clock = {
                'employeeid': jsonResponse['employeeid'],
                'firstname': jsonResponse['firstname'],
                'lastname': jsonResponse['lastname'],
                'month': month,
                'day': day,
                'year': year,
                'hour': hour,
                'minute': minute,
                'second': second,
                'clockedstatus': clockedIn,
                'timestamp': timestamp
              };

              try {
                db.collection('clocks').doc(primaryKey).set(clock);
              } catch (e) {
                logger.e(e);
              }

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
              // ScaffoldMessenger.of(context).clearSnackBars();
              // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              //   content: Text(
              //       'The user could not be identified. Please register as a new user or try again.'),
              //   duration: Duration(seconds: 3),
              // ));
              showDialog<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: const Text('User Not Found'),
                        content: const SingleChildScrollView(
                          child: ListBody(
                            children: <Widget>[
                              Text('It looks like you are not registered.'),
                              Text('Would you like to register yourself?')
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('No'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: const Text('Yes'),
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AddUser(camera: widget.camera),
                                ),
                              );
                            },
                          )
                        ],
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
      'employeeid': '234',
      'firstname': 'Gabriele',
      'lastname': 'Peck'
    };

    // return Future<String>.value(jsonEncode(person));
    return Future.delayed(const Duration(seconds: 1), () => jsonEncode(person));
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
    final usersRef = db.collection('users').doc(jsonResponse['employeeid']);
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
}
