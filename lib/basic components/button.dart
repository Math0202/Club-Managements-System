import 'package:flutter/material.dart';

class OutLinedButton1 extends StatelessWidget {
  final Icon icons;
  final String buttonName;

  const OutLinedButton1({
    Key? key,
    required this.buttonName,
    required this.icons,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: Colors.green, // Change the color here
          width: 1.5, // Change the thickness here
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0), // Change the roundness here
        ),
      ),
      onPressed: () {
        showDialog(context: context, builder: (BuildContext context){
        return AlertDialog(
          shadowColor: Colors.green.shade500,
          title: Text('Sorry'),
          backgroundColor: Colors.green.shade300,
          content: Text('Nothing to show yet.'),
          actions: [
            TextButton(onPressed: (){
            Navigator.pop(context);
            }, child: Text('Close'))
          ],
        );
        });
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 0),
        child: Row(
          
          children: [
            icons,
            Container(
              padding: EdgeInsets.only(left: 8),
              child: Text(
                buttonName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
