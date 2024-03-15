import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  RoundedButton({super.key, this.title = '', this.color = Colors.lightBlueAccent, required this.onPressed});

  final String title;
  final Color color; // Changed type to Color
  final VoidCallback onPressed; // Changed to VoidCallback

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        elevation: 5.0,
        color: color, // Using the color parameter here
        borderRadius: BorderRadius.circular(30.0),
        child: MaterialButton(
          onPressed: onPressed, // Using the onPressed callback passed from outside
          minWidth: 200.0,
          height: 42.0,
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white,
            ),// Using the title parameter here
          ),
        ),
      ),
    );
  }
}