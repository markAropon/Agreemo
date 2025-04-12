import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../pages/app_login.dart';
import '../pages/dashboard.dart';

Future<bool> GetUserEmail(String text) async {
  var headers = {
    'x-api-key': 'AgreemoCapstoneProject',
  };

  var url = Uri.parse('https://agreemo-api.onrender.com/stored-email');
  String responseData = '';

  try {
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200 || response.statusCode == 201) {
      var data = jsonDecode(response.body);

      if (data is List) {
        bool emailFound = false;

        for (var user in data) {
          String email = user['email'];
          if (email == text) {
            emailFound = true;
            print("Email $text found in the response.");
            return true;
          }
        }
        if (!emailFound) {
          print("Email $text does not match any email in the response.");
        }
      } else {
        print(data);
      }
    } else {
      responseData = 'Failed to load data: ${response.reasonPhrase}';
      print(responseData);
    }
  } catch (e) {
    responseData = 'Error: $e';
    print(responseData);
  }
  return false;
}

Future<bool> addUser({
  required BuildContext context,
  required String firstName,
  required String lastName,
  required String dateOfBirth,
  required String emailAddress,
  required String phoneNumber,
  required String addressText,
}) async {
  // Email validation
  final RegExp emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  if (!emailRegExp.hasMatch(emailAddress)) {
    showCustomDialog(
      context: context,
      title: "Invalid Email",
      message: "Please enter a valid email address.",
      icon: Icons.error,
      iconColor: Colors.red,
      backgroundColor: Colors.white,
    );
    return false;
  }

  // Validate dateOfBirth is not empty and is in the correct format (yyyy-MM-dd)
  if (dateOfBirth.isEmpty) {
    showCustomDialog(
      context: context,
      title: "Invalid Date of Birth",
      message: "Please enter a valid Date of Birth.",
      icon: Icons.error,
      iconColor: Colors.red,
      backgroundColor: Colors.white,
    );
    return false;
  }

  // Try parsing the date to ensure it's in the correct format (yyyy-MM-dd)
  DateTime? birthDate;
  try {
    birthDate = DateFormat("yyyy-MM-dd").parse(dateOfBirth);
  } catch (e) {
    showCustomDialog(
      context: context,
      title: "Invalid Date Format",
      message: "Please enter the Date of Birth in the format yyyy-MM-dd.",
      icon: Icons.error,
      iconColor: Colors.red,
      backgroundColor: Colors.white,
    );
    return false;
  }

  DateTime currentDate = DateTime.now();
  int age = currentDate.year - birthDate.year;

  if (currentDate.month < birthDate.month ||
      (currentDate.month == birthDate.month &&
          currentDate.day < birthDate.day)) {
    age--;
  }

  // Check if the user is above 18
  if (age < 18) {
    showCustomDialog(
      context: context,
      title: "Age Restriction",
      message: "You must be above 18 years old to register.",
      icon: Icons.error,
      iconColor: Colors.red,
      backgroundColor: Colors.white,
    );
    return false;
  }

  var headers = {
    'x-api-key': 'AgreemoCapstoneProject',
  };

  var request = http.Request(
    'POST',
    Uri.parse('https://agreemo-api.onrender.com/user'),
  );

  request.bodyFields = {
    'first_name': firstName,
    'last_name': lastName,
    'date_of_birth': dateOfBirth,
    'email': emailAddress,
    'phone_number': phoneNumber,
    'address': addressText,
  };

  request.headers.addAll(headers);

  try {
    var response = await request.send();

    if (response.statusCode == 200 || response.statusCode == 201) {
      showCustomDialog(
        context: context,
        title: "User Successfully Registered",
        message: "New user added. Check your Gmail for confirmation.",
        icon: Icons.check_circle_outlined,
        iconColor: const Color.fromARGB(255, 46, 181, 116),
        backgroundColor: const Color.fromARGB(255, 224, 249, 192),
      );
      return true;
    } else {
      String responseBody = await response.stream.bytesToString();
      print(
          'Request failed - URL: ${request.url}, Status Code: ${response.statusCode}, Reason Phrase: ${response.reasonPhrase}, Response Body: $responseBody, Request Body: ${request.bodyFields}');
      return false;
    }
  } catch (exception) {
    showCustomDialog(
      context: context,
      title: "Error",
      message: "Something went wrong.",
      icon: Icons.error,
      iconColor: Colors.red,
      backgroundColor: Colors.white,
    );
    print('Exception occurred: $exception');
    return false;
  }
}

Future<void> updatePassword(
    {required String email,
    required String newPassword,
    required BuildContext context}) async {
  var headers = {
    'x-api-key': 'AgreemoCapstoneProject',
  };

  var url =
      Uri.parse('https://agreemo-api.onrender.com/new-user/change-password');
  var body = {
    'email': email,
    'new_password': newPassword,
  };

  try {
    final response = await http.put(url, headers: headers, body: body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      showCustomDialog(
        context: context,
        title: 'Password Saved',
        message: 'New Password Recorded You can now use your account',
        icon: Icons.check_circle_outline,
        iconColor: Colors.white,
        backgroundColor: Colors.green,
        onConfirm: () => LoginScreen(),
      );
    } else {
      print(
          'Failed to update password: ${response.reasonPhrase}${response.body} ');
      showCustomDialog(
          context: context,
          title: 'Error',
          message: 'Something Went Wrong Try Again Later',
          icon: Icons.error_outline_outlined,
          iconColor: Colors.white,
          backgroundColor: Colors.red);
    }
  } catch (e) {
    print('Error: $e');
  }
}

Future<void> signinUser(
  BuildContext context, {
  required TextEditingController username,
  required TextEditingController pass,
  required Function setState,
}) async {
  if (username.text.isEmpty || pass.text.isEmpty) {
    showCustomDialog(
      context: context,
      title: 'Missing Credentials',
      message: 'Please enter both email and password.',
      icon: Icons.error,
      iconColor: const Color.fromARGB(255, 242, 100, 90),
      backgroundColor: Colors.red[50]!,
    );
    return;
  }

  try {
    var url = Uri.parse('https://agreemo-api.onrender.com/user/login');
    var headers = {
      'x-api-key': 'AgreemoCapstoneProject',
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    var body = {
      'email': username.text,
      'password': pass.text,
    };

    var response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      print('Login successful: ${response.body}');
      var responseData = jsonDecode(response.body);
      String fullname = responseData['full_name'] ?? 'User';
      String email = responseData['email'] ?? username.text;
      int loginId = responseData['login_id'] ?? 0;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('fullname', fullname);
      await prefs.setString('email', email);
      await prefs.setInt('loginId', loginId);

      showCustomDialog(
        context: context,
        title: 'Login Success',
        message: 'Welcome $fullname',
        icon: Icons.check_circle_outlined,
        iconColor: const Color.fromARGB(255, 46, 181, 116),
        backgroundColor: const Color.fromARGB(255, 224, 249, 192),
      );
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const Dashboard(),
          ),
          (Route<dynamic> route) => false,
        );
      });
    } else if (response.statusCode == HttpStatus.badRequest) {
      showCustomDialog(
        context: context,
        title: 'Login Failed',
        message: 'Account Does Not Exist',
        icon: Icons.error,
        iconColor: Colors.red,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      );
    } else if (response.statusCode == HttpStatus.unauthorized) {
      showCustomDialog(
        context: context,
        title: 'Login Failed',
        message:
            'Your Account has been deactivated by the admin, try contacting the admin if you think this is wrong',
        icon: Icons.error,
        iconColor: Colors.red,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      );
    } else if (response.statusCode == HttpStatus.forbidden) {
      try {
        // Using username.text instead of accessing an undefined emailController
        if (await checkIfActive(email: username.text)) {
          TextEditingController passwordController = TextEditingController();
          showCustomDialog(
            context: context,
            title: "Change Password",
            message: "Please enter your new password.",
            icon: Icons.lock,
            iconColor: Colors.blue,
            backgroundColor: Colors.white,
            changePasswordController: passwordController,
            onConfirm: () async {
              if (validatePassword(passwordController.text) != null) {
                await updatePassword(
                  email: username.text,
                  newPassword: passwordController.text.trim(),
                  context: context,
                );
                Navigator.of(context).pop();
              }
            },
          );
        } else {
          showCustomDialog(
            context: context,
            title: 'Error',
            message: 'Your Account Has been deactivated',
            icon: Icons.info,
            iconColor: Colors.blue,
            backgroundColor: Colors.white,
          );
        }
      } catch (e) {
        print('Error in forbidden status handling: ${e.toString()}');
        showCustomDialog(
          context: context,
          title: 'Error',
          message: 'An error occurred while processing your request',
          icon: Icons.error,
          iconColor: Colors.red,
          backgroundColor: Colors.white,
        );
      }
    } else {
      showCustomDialog(
        context: context,
        title: 'Login Failed',
        message:
            'Unable to login. Please check your credentials and try again.',
        icon: Icons.error,
        iconColor: Colors.red,
        backgroundColor: Colors.red[50]!,
      );
    }
  } catch (e) {
    print('Login error: ${e.toString()}');
    showCustomDialog(
      context: context,
      title: 'Connection Error',
      message:
          'Unable to connect to the server. Please check your internet connection and try again.',
      icon: Icons.wifi_off,
      iconColor: Colors.orange,
      backgroundColor: Colors.yellow[50]!,
    );
  }
}

Future<void> Userlogout(BuildContext context) async {
  String email = '';

  // Show the confirmation dialog before proceeding with logout
  bool? confirmLogout = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('Do you really want to log out?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Logout'),
          ),
        ],
      );
    },
  );

  if (confirmLogout == true) {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      email = prefs.getString('email') ?? '';

      var headers = {
        'x-api-key': 'AgreemoCapstoneProject',
      };

      var request = http.Request(
          'POST', Uri.parse('https://agreemo-api.onrender.com/user/logout'));
      request.bodyFields = {
        'email': email,
      };
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        print(
            'Logout successful: ${await response.stream.bytesToString()} $email');
        await prefs.clear();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      } else if (response.statusCode == 404) {
        print(
            'Logout successful but not saved in log: ${await response.stream.bytesToString()} $email');
        await prefs.clear();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      } else {
        print(
            'Error during logout: ${response.reasonPhrase} ${response.statusCode} ');
      }
    } catch (e) {
      print('An error occurred during the logout process: $e');
    }
  } else {
    print('Logout cancelled');
  }
}

Future<void> forceLogout(BuildContext context) async {
  String email = '';

  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    email = prefs.getString('email') ?? '';

    var headers = {
      'x-api-key': 'AgreemoCapstoneProject',
    };

    var request = http.Request(
        'POST', Uri.parse('https://agreemo-api.onrender.com/user/logout'));
    request.bodyFields = {
      'email': email,
    };
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200 || response.statusCode == 201) {
      print(
          'Logout successful: ${await response.stream.bytesToString()} $email');
      await prefs.clear();
    } else if (response.statusCode == 404) {
      print(
          'Logout successful but not saved in log: ${await response.stream.bytesToString()} $email');
      await prefs.clear();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    } else {
      print(
          'Error during logout: ${response.reasonPhrase} ${response.statusCode} ');
    }
  } catch (e) {
    print('An error occurred during the logout process: $e');
  }
}

void forgotpass(BuildContext context, String email) async {
  await sendVerificationCode(email);
  ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Verification code sent to $email')));
}

Future<String?> sendVerificationCode(String email) async {
  var headers = {'x-api-key': 'AgreemoCapstoneProject'};
  var request = http.Request('POST',
      Uri.parse('https://agreemo-api.onrender.com/send-verification-code'));

  request.bodyFields = {'email': email};
  request.headers.addAll(headers);

  try {
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Parse the response body to JSON
      String responseBody = await response.stream.bytesToString();
      Map<String, dynamic> responseJson = json.decode(responseBody);

      // Extract the token from the JSON response
      String? token = responseJson['token'];

      if (token != null) {
        print("Token received: $token");
        return token; // Return the token
      } else {
        print("Token not found in the response.");
        return null;
      }
    } else {
      print('Failed to send verification code: ${response.reasonPhrase}');
      return null;
    }
  } catch (e) {
    print('Error: $e');
    return null;
  }
}

Future<void> verifyCode(
    String email, String verificationCode, String token) async {
  var headers = {
    'x-api-key': 'AgreemoCapstoneProject',
  };

  var request = http.Request(
      'POST', Uri.parse('https://agreemo-api.onrender.com/verify-code'));
  request.bodyFields = {
    'email': email,
    'verification_code': verificationCode,
    'token': token,
  };

  request.headers.addAll(headers);

  try {
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200 || response.statusCode == 201) {
      String responseBody = await response.stream.bytesToString();
      print('Verification response: $responseBody');
    } else {
      String responsebody = await response.stream.bytesToString();
      print('Verification failed: ${response.reasonPhrase},${responsebody}');
    }
  } catch (e) {
    print('Error: $e');
  }
}

Future<void> changePass(String email, String newPassword, String token) async {
  var headers = {
    'x-api-key': 'AgreemoCapstoneProject',
  };

  var request = http.Request('POST',
      Uri.parse('https://agreemo-api.onrender.com/user-reset-password'));
  request.bodyFields = {
    'email': email,
    'new_password': newPassword,
    'token': token,
  };

  request.headers.addAll(headers);

  try {
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  } catch (e) {
    print('Error: $e');
  }
}

//getuserData
Future<void> getUserData() async {
  int loginId;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  loginId = prefs.getInt('loginId')!;
  var headers = {
    'x-api-key': 'AgreemoCapstoneProject',
  };

  // Create the GET request
  var request = http.Request(
      'GET', Uri.parse('https://agreemo-api.onrender.com/users/$loginId'));

  // Add the headers
  request.headers.addAll(headers);

  // Send the request
  http.StreamedResponse response = await request.send();
  if (response.statusCode == 200) {
    // Decode the response body
    var responseData = jsonDecode(await response.stream.bytesToString());

    // Debug: Print the API response
    print('API Response: $responseData');

    // Extract the necessary data
    String date_of_birth = responseData['date_of_birth'] ?? "Not available";
    String email = responseData['email'] ?? "Not available";
    String phone_number = responseData['phone_number'] ?? "Not available";
    String address = responseData['address'] ?? "Not available";

    // Save data to SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('date_of_birth', date_of_birth);
    await prefs.setString('email', email);
    await prefs.setString('phone_number', phone_number);
    await prefs.setString('address', address);
    print('Saved Data:');
    print('Date of Birth: $date_of_birth');
    print('Email: $email');
    print('Phone: $phone_number');
    print('Address: $address');
    print(response.stream.bytesToString());
  } else {
    print('Error: ${response.reasonPhrase}');
  }
}

Future<bool> checkIfActive({
  required String email,
}) async {
  var headers = {
    'x-api-key': 'AgreemoCapstoneProject',
  };

  // Create the GET request
  var request =
      http.Request('GET', Uri.parse('https://agreemo-api.onrender.com/users'));

  // Add the headers
  request.headers.addAll(headers);

  // Send the request
  http.StreamedResponse response = await request.send();
  if (response.statusCode == 200 || response.statusCode == 201) {
    var responseData = jsonDecode(await response.stream.bytesToString());

    // Debug: Print the API response
    print('API Response: $responseData');

    for (var user in responseData) {
      if (user['email'] == email) {
        bool isNewUser = user['isNewUser'] ?? false;

        if (!isNewUser) {
          return false;
        }
        return true;
      }
    }

    print('User not found with email: $email');
    return false;
  } else {
    print('Error: ${response.reasonPhrase}');
    return false;
  }
}

String? validatePassword(String? password) {
  if (password == null || password.isEmpty) {
    return 'Password is required';
  }
  if (password.length < 8) {
    return 'Password must be at least 8 characters long';
  }
  if (!password.contains(RegExp(r'[0-9]'))) {
    return 'Password must contain at least one digit';
  }
  return null; // Password is valid
}

//dialog
Future<void> showCustomDialog({
  required BuildContext context,
  required String title,
  required String message,
  required IconData icon,
  required Color iconColor,
  required Color backgroundColor,
  TextEditingController? changePasswordController,
  Widget? pinCodeTextField,
  List<TextEditingController>? additionalControllers,
  List<String>? labels,
  List<String>? hints,
  List<bool>? obscureTextList,
  Function()? onConfirm,
  Function()? reSend,
  int initialTimer = 180,
}) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      int timer = initialTimer;
      Timer? countdownTimer;
      countdownTimer = Timer.periodic(const Duration(seconds: 1), (timerTick) {
        if (timer > 0) {
          timer--;
        } else {
          countdownTimer?.cancel();
        }
      });

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Center(child: Text(title)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(
                        icon,
                        color: iconColor,
                        size: 40,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          message,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                  if (changePasswordController != null) ...[
                    const SizedBox(height: 20),
                    StatefulBuilder(
                      builder: (context, setState) {
                        bool obscureText = true;
                        return Stack(
                          children: [
                            TextField(
                              controller: changePasswordController,
                              obscureText: obscureText,
                              decoration: const InputDecoration(
                                labelText: 'New Password',
                                hintText: 'Enter new password',
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                  if (additionalControllers != null &&
                      labels != null &&
                      hints != null) ...[
                    for (int i = 0; i < additionalControllers.length; i++) ...[
                      const SizedBox(height: 20),
                      StatefulBuilder(
                        builder: (context, setState) {
                          bool obscureText = obscureTextList != null &&
                                  obscureTextList.length > i
                              ? obscureTextList[i]
                              : false;

                          return Stack(
                            children: [
                              TextField(
                                controller: additionalControllers[i],
                                obscureText: obscureText,
                                decoration: InputDecoration(
                                  labelText: labels[i],
                                  hintText: hints[i],
                                ),
                              ),
                              if (obscureText) ...[
                                Positioned(
                                  right: 0,
                                  top: 12,
                                  child: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        obscureText = !obscureText;
                                      });
                                    },
                                    icon: Icon(
                                      obscureText
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          );
                        },
                      ),
                    ],
                  ],
                  if (pinCodeTextField != null) ...[
                    const SizedBox(height: 20),
                    pinCodeTextField,
                  ],
                ],
              ),
            ),
            backgroundColor: backgroundColor,
            actions: [
              if (onConfirm != null) ...[
                TextButton(
                  onPressed: onConfirm,
                  child: const Text('Confirm'),
                ),
              ],
              if (reSend != null) ...[
                Row(
                  children: [
                    TextButton(
                      onPressed: reSend,
                      child: const Text('Resend'),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${timer}s',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ],
          );
        },
      );
    },
  );
}
