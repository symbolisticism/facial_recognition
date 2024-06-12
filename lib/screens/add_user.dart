import 'dart:io';

import 'package:camera/camera.dart';
import 'package:facial_reg/screens/take_picture_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:string_validator/string_validator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

var logger = Logger(printer: PrettyPrinter());

final db = FirebaseFirestore.instance;
final storage = FirebaseStorage.instance.ref();

class AddUser extends StatefulWidget {
  const AddUser({super.key, required this.camera});

  final CameraDescription camera;

  @override
  State<AddUser> createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  File? image;

  /// adds the user to the database
  void addUser(
    String employeeid,
    String firstname,
    String lastname,
    File? image,
  ) async {
    if (image == null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred with the image. Please try again.'),
        ),
      );
    }

    // add the user's name and ID to Firestore
    final fullname = {'firstname': firstname, 'lastname': lastname};

    // add the user's picture to Firebase Storage
    final images = storage.child('images');
    final userImageRef = images.child('$employeeid.$lastname.$firstname.jpg');
    final localFilePath = image!.path;
    final file = File(localFilePath);

    try {
      db.collection('users').doc(employeeid).set(fullname);
      await userImageRef.putFile(file);
    } catch (e) {
      logger.e(e);
    }
  }

  // destroy the TextEditingControllers when finished
  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _employeeIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Registration'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('New User'),
                const SizedBox(height: 32),
                TextFormField(
                  decoration: const InputDecoration(label: Text('First Name')),
                  autocorrect: false,
                  controller: _firstNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty || !isAlpha(value)) {
                      return 'Please enter a valid first name';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(label: Text('Last Name')),
                  autocorrect: false,
                  controller: _lastNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty || !isAlpha(value)) {
                      return 'Please enter a valid last name';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(label: Text('Employee ID')),
                  autocorrect: false,
                  controller: _employeeIdController,
                  validator: (value) {
                    if (value == null || value.isEmpty || !isNumeric(value)) {
                      return 'Please enter a valid employee ID.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 48),
                ElevatedButton(
                  child:
                      image == null ? const Text('Next') : const Text('Finish'),
                  onPressed: () async {
                    FocusManager.instance.primaryFocus?.unfocus();
                    if (_formKey.currentState!.validate()) {
                      if (image == null) {
                        image = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                TakePictureScreen(camera: widget.camera),
                          ),
                        );
                        setState(() {});
                      } else {
                        addUser(
                            _employeeIdController.text,
                            _firstNameController.text,
                            _lastNameController.text,
                            image);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('User and image were successfully added.'),
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
