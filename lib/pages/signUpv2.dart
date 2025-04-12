import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../functions/UserFunctions.dart';
import '../utility_widgets/buttons.dart';
import 'app_login.dart';

class Signupv2 extends StatefulWidget {
  const Signupv2({Key? key}) : super(key: key);

  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signupv2> {
  final _formKey = GlobalKey<FormState>();

  // Use TextEditingControllers with meaningful naming
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dobController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  // Email validation regex
  static final _emailRegExp =
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

  Future<void> _selectDate() async {
    final currentDate = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(1900),
      lastDate: currentDate,
    );

    if (selectedDate != null) {
      setState(() {
        _dobController.text = "${selectedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  void _submitForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final isEmailRegistered = await GetUserEmail(_emailController.text);
    if (!isEmailRegistered) {
      _showErrorDialog(
        title: "Access Denied!",
        message: "Please ensure your email is registered with the secretary.",
      );
      return;
    }

    final success = await addUser(
      context: context,
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      dateOfBirth: _dobController.text,
      emailAddress: _emailController.text,
      phoneNumber: _phoneController.text,
      addressText: _addressController.text,
    );

    print(
        success ? "User successfully registered!" : "Failed to register user.");
  }

  void _showErrorDialog({required String title, required String message}) {
    showCustomDialog(
      context: context,
      title: title,
      message: message,
      icon: Icons.error,
      iconColor: Colors.red,
      backgroundColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 220, 224, 230),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 19, 62, 135)),
        backgroundColor: const Color.fromARGB(255, 220, 224, 230),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: const Color.fromRGBO(19, 62, 135, 1),
              borderRadius:
                  const BorderRadius.only(topLeft: Radius.circular(100)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Text(
                      'Sign Up!',
                      style: TextStyle(
                        fontSize: 32,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Roboto",
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _firstNameController,
                      label: 'First Name',
                      icon: Icons.person,
                    ),
                    _buildTextField(
                      controller: _lastNameController,
                      label: 'Last Name',
                      icon: Icons.person,
                    ),
                    _buildEmailField(),
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(11),
                      ],
                    ),
                    _buildDatePickerField(),
                    _buildTextField(
                      controller: _addressController,
                      label: 'Address',
                      icon: Icons.home,
                    ),
                    const SizedBox(height: 30),
                    Buttons(
                      onTap: _submitForm,
                      color: const Color.fromARGB(255, 13, 183, 101),
                      label: 'Sign Up',
                      labelColor: Colors.white,
                      Borderradius: 10,
                    ),
                    const SizedBox(height: 20),
                    _buildLoginLink(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          suffixIcon: Icon(icon),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: _emailController,
        decoration: const InputDecoration(
          labelText: 'Email',
          filled: true,
          suffixIcon: Icon(Icons.email),
        ),
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (value == null || value.isEmpty) return 'Please enter an email';
          if (!_emailRegExp.hasMatch(value)) {
            _showErrorDialog(
              title: "Invalid Email",
              message: "Please use a valid email address",
            );
            return 'Invalid email';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDatePickerField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: GestureDetector(
        onTap: _selectDate,
        child: Container(
          decoration: const BoxDecoration(
            color: Color.fromARGB(217, 255, 255, 255),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _dobController.text.isNotEmpty
                    ? _dobController.text
                    : 'Select Date of Birth',
                style: const TextStyle(fontSize: 16),
              ),
              const Icon(Icons.calendar_today, color: Colors.black),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Already have an account? ',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          ),
          child: const Text(
            'Login',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
