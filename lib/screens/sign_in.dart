import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

var logger = Logger(printer: PrettyPrinter());

final auth = FirebaseAuth.instance;

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  bool loggingIn = true;

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(36),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(loggingIn ? 'Sign In' : 'Sign Up'),
              const SizedBox(height: 48),
              Container(
                child: Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        label: Text('Username'),
                      ),
                      controller: emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Username or password was incorrect';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      obscureText: true,
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
                  ],
                ),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () async {
                  FocusManager.instance.primaryFocus?.unfocus();
                  if (formKey.currentState!.validate()) {
                    if (loggingIn) {
                      try {
                        final credential = await FirebaseAuth.instance
                            .signInWithEmailAndPassword(
                                email: emailController.text,
                                password: passwordController.text);

                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'user-not-found') {
                          logger.e('No user found for that email.');
                        } else if (e.code == 'wrong-password') {
                          logger.e('Wrong password provided for that user.');
                        }
                      }
                    } else {
                      try {
                        // attempt to add their credentials to Firebase
                        final credential = await FirebaseAuth.instance
                            .createUserWithEmailAndPassword(
                          email: emailController.text,
                          password: passwordController.text,
                        );
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'weak-password') {
                          logger.e('The password provided is too weak.');
                        } else if (e.code == 'email-already-in-use') {
                          logger
                              .e('The account already exists.');
                        }
                      } catch (e) {
                        logger.e(e);
                      }
                    }
                  }
                },
                child: Text(loggingIn ? 'Sign In' : 'Create Account'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    loggingIn = !loggingIn;
                  });
                },
                child: Text(loggingIn
                    ? 'Don\'t have an account? Sign Up'
                    : 'Already have an account? Sign In'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
