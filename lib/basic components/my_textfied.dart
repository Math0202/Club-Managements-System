// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';

class MyTextFied extends StatelessWidget {
  // ignore: prefer_typing_uninitialized_variables
  final controller;
  final String hintText;
  final bool obscureText;
  // ignore: prefer_typing_uninitialized_variables
  final TextInputType;

  const MyTextFied({
    super.key,
    required this.controller,
    required this.hintText,
     required this.obscureText, 
    this.TextInputType,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.8),
        child: TextField(
          keyboardType: TextInputType,
          maxLines: 1,
          controller: controller,
            obscureText: obscureText,
            decoration: InputDecoration(
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blueGrey),
              ),
              fillColor: Colors.grey.shade200,
              filled: true,
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey[500] ) 
            )
        ),
      ),
    );
  }
}
