// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../functions/UserFunctions.dart';
import '../utility_widgets/buttons.dart';
import '../utility_widgets/textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final username = TextEditingController();
  final pass = TextEditingController();
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    username.addListener(() {
      if (username.text.isNotEmpty) {
        GetUserEmail(username.text);
      }
    });
  }

  @override
  void dispose() {
    username.dispose();
    pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Color.fromARGB(255, 19, 62, 135),
        ),
        backgroundColor: const Color.fromARGB(255, 220, 224, 230),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 220, 224, 230),
              Color.fromARGB(255, 97, 174, 236),
            ],
          ),
        ),
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                    height: 90,
                    width: 90,
                    child: Image.asset('assets/icons/leafIcon.png')),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height - 170,
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(19, 62, 135, 1),
                  border: Border.symmetric(
                      vertical: BorderSide(color: Colors.blue, width: 1),
                      horizontal: BorderSide(color: Colors.blue, width: 1)),
                  borderRadius:
                      BorderRadius.only(topLeft: Radius.circular(100)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                "Login",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900,
                                  wordSpacing: 4,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      Textfield(
                        Controller: username,
                        obscureText: false,
                        hintText: 'Juandelacruz@gmail.com',
                        label: 'Email',
                        isPasswordField: false,
                      ),
                      const SizedBox(height: 10),
                      Textfield(
                        Controller: pass,
                        obscureText: true,
                        hintText: '********',
                        label: 'Password',
                        isPasswordField: true,
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Container(
                        margin: const EdgeInsets.only(right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                // Trigger forgot password flow
                                forgotpass(context, username.text);

                                TextEditingController pinController =
                                    TextEditingController();

                                showCustomDialog(
                                  context: context,
                                  title: "Enter Pin",
                                  message:
                                      "A Pin has been sent to your Gmail. Please enter it below.",
                                  icon: Icons.lock,
                                  iconColor: Colors.redAccent,
                                  backgroundColor: Colors.white,
                                  labels: ['Enter Pin'],
                                  hints: ['Enter the pin sent to your email'],
                                  obscureTextList: [false],
                                  pinCodeTextField: PinCodeTextField(
                                    appContext: context,
                                    length: 6,
                                    cursorColor: Colors.black,
                                    animationDuration:
                                        const Duration(milliseconds: 300),
                                    enableActiveFill: true,
                                    controller: pinController,
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      // onChanged can still be used for intermediate actions, if needed.
                                    },
                                    onCompleted: (value) {
                                      // Generate a random token when pin input is completed
                                      String generateRandomToken(int length) =>
                                          List.generate(
                                              length,
                                              (index) => Random()
                                                  .nextInt(36)
                                                  .toRadixString(36)).join();
                                      String token = generateRandomToken(10);
                                      String pin = pinController.text;
                                      String email = username.text;

                                      verifyCode(email, pin, token);

                                      TextEditingController
                                          newPasswordController =
                                          TextEditingController();

                                      showCustomDialog(
                                        context: context,
                                        title: "Enter New Password",
                                        message: "Create Your New Password",
                                        icon: Icons.pending_actions,
                                        iconColor: Colors.blue,
                                        backgroundColor: Colors.white,
                                        labels: ['Enter Password'],
                                        hints: ['Enter your new password'],
                                        changePasswordController:
                                            newPasswordController,
                                        obscureTextList: [true],
                                        onConfirm: () {
                                          changePass(
                                              email,
                                              newPasswordController.text,
                                              token);
                                        },
                                      );
                                    },
                                  ),
                                  reSend: () {
                                    // Option to resend the pin if needed
                                    forgotpass(context, username.text);
                                  },
                                );
                              },
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Buttons(
                        onTap: () => signinUser(
                          context,
                          username: username,
                          pass: pass,
                          setState: setState,
                        ),
                        color: const Color.fromARGB(255, 13, 183, 101),
                        label: 'Login',
                        labelColor: Colors.white,
                        Borderradius: 5,
                      ),
                      if (_isLoading) const CircularProgressIndicator(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
