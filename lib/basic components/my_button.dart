import 'package:flutter/material.dart';
class MyButton extends StatelessWidget {
  final Function()? onTap;
  final String text;
  
   MyButton({
    Key? key, 
    required this.onTap,
    required this.text
    }):super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        width: 220,
        decoration: BoxDecoration(color: Colors.green,
        borderRadius: BorderRadius.circular(8.9)
        ),
        child: Center(
          child: Text(
            text,
          style: TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.bold, 
            fontSize: 17),
          )
           ),
      ),
    );
  }
}