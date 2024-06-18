import 'package:facial_reg/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

var logger = Logger(printer: PrettyPrinter());

final auth = FirebaseAuth.instance;

class SignIn extends StatelessWidget {
  const SignIn({super.key});

  @override
  Widget build(BuildContext context) {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('Sign In'),
              const SizedBox(height: 48),
              TextFormField(
                decoration: const InputDecoration(
                  label: Text('Username'),
                ),
                controller: usernameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Username or password was incorrect';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  label: Text('Password'),
                ),
                controller: passwordController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Username or password was incorrect';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    // auth.authStateChanges().listen((User? user) {
                    //   if (user == null) {
                    //     logger.d('User is currently signed out');
                    //   } else {
                    //     logger.d('User is signed in!');
                    //   }
                    // });


                    // Navigator.of(context).push(
                    //   MaterialPageRoute(
                    //     builder: (context) => Home(camera: camera),
                    //   ),
                    // );

                    
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('You were successfully logged in!'),
                      ),
                    );
                  }
                },
                child: const Text('Sign In'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
