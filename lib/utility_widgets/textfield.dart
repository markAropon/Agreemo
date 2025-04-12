// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class Textfield extends StatefulWidget {
  final TextEditingController Controller;
  final bool obscureText;
  final String hintText;
  final String label;
  final bool isPasswordField;

  const Textfield({
    super.key,
    required this.Controller,
    required this.obscureText,
    required this.hintText,
    required this.label,
    required this.isPasswordField,
    FocusNode? focusNode,
  });

  @override
  _TextfieldState createState() => _TextfieldState();
}

class _TextfieldState extends State<Textfield> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  void clear() {
    widget.Controller.clear();
  }

  void togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText; // Toggle visibility state
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        children: [
          TextField(
            controller: widget.Controller,
            obscureText: _obscureText,
            decoration: InputDecoration(
              hintText: widget.hintText,
              suffix: widget.isPasswordField
                  ? GestureDetector(
                      onTap: togglePasswordVisibility,
                      child: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                      ),
                    )
                  : GestureDetector(
                      onTap: clear,
                      child: const Icon(Icons.clear),
                    ),
              fillColor: Colors.white,
              filled: true,
              hintStyle: const TextStyle(color: Colors.grey),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 20.0,
                horizontal: 15.0,
              ),
            ),
          ),
          Positioned(
            top: 5.0,
            left: 3.0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 3.0),
              color: Colors.white,
              child: Text(
                widget.label,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
