import 'package:facial_reg/screens/summary_screen.dart';
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
  bool isLoggingIn = true;

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
              Text(isLoggingIn ? 'Sign In' : 'Sign Up'),
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
                    emailController.clear();
                    passwordController.clear();
                    if (isLoggingIn) {
                      try {
                        final credential = await FirebaseAuth.instance
                            .signInWithEmailAndPassword(
                                email: emailController.text,
                                password: passwordController.text);
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'user-not-found') {
                          if (!context.mounted) {
                            logger.e('CONTEXT NOT MOUTNED');
                            return;
                          }
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('No user found for that email.'),
                            ),
                          );
                          logger.e('No user found for that email.');
                        } else if (e.code == 'wrong-password') {
                          if (!context.mounted) {
                            logger.e('CONTEXT NOT MOUTNED');
                            return;
                          }
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Wrong password provided for that user.'),
                            ),
                          );
                          logger.e('Wrong password provided for that user.');
                        }
                      }

                      if (!context.mounted) return;
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SummaryScreen(),
                        ),
                      );
                    } else {
                      try {
                        // attempt to add their credentials to Firebase
                        final credential = await FirebaseAuth.instance
                            .createUserWithEmailAndPassword(
                          email: emailController.text,
                          password: passwordController.text,
                        );

                        if (!context.mounted) {
                          logger.e('CONTEXT NOT MOUNTED');
                          return;
                        }

                        emailController.clear();
                        passwordController.clear();

                        setState(() {
                          isLoggingIn = true;
                        });

                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('User successfully created.'),
                          ),
                        );
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'weak-password') {
                          if (!context.mounted) {
                            logger.e('CONTEXT NOT MOUTNED');
                            return;
                          }
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('The password provided is too weak.'),
                            ),
                          );
                          logger.e('The password provided is too weak.');
                        } else if (e.code == 'email-already-in-use') {
                          if (!context.mounted) {
                            logger.e('CONTEXT NOT MOUTNED');
                            return;
                          }
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('This account already exists.'),
                            ),
                          );
                          logger.e('This account already exists.');
                        }
                      } catch (e) {
                        logger.e(e);
                      }
                    }
                  }
                },
                child: Text(isLoggingIn ? 'Sign In' : 'Create Account'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    isLoggingIn = !isLoggingIn;
                  });
                },
                child: Text(
                  isLoggingIn
                      ? 'Don\'t have an account? Sign Up'
                      : 'Already have an account? Sign In',
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
