import 'package:flutter/material.dart';

class BuildTableContainer extends StatelessWidget {
  const BuildTableContainer({
    super.key,
    required this.title,
    required this.container,
    this.check
  });

  final String title;
  final Container container;
  final bool? check;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:EdgeInsets.only(top: 16),
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        border: Border.all(
          color: Colors.grey.shade400,
        ),
        borderRadius: BorderRadius.circular(20)
      ),
      child: Column(
        children: [
           Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
             children: [
              check! ? Icon(Icons.check_box_outline_blank) : Container(),
               Text('$title',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
        
                ),
                textAlign: TextAlign.center,
              ),
              check! ?  Column(
                children: [
                  Icon(Icons.save),
                  Text('Submit Score')
                ],
              ) : Container(),
             ],
           ),
        Container(
          margin: EdgeInsetsDirectional.only(top: 8),
          decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20))
          ),
          child: container,
        ) 
        ],
      )
             
    );
    
  }
}