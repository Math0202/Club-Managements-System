import 'package:flutter/material.dart';

class buildDropdownContainer extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final Function(String?) onChanged;
  const buildDropdownContainer({super.key,
 required this.label, 
 required this.value, 
 required this.items, 
 required this.onChanged,});

  @override
  Widget build(BuildContext context) {
  return Container(
   
    decoration: BoxDecoration(
      color: Colors.grey.shade200,
    ),
    child: Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[500],
              fontWeight: FontWeight.bold,
            ),
          ),
          DropdownButton<String>(
            value: value,
            onChanged: onChanged,
            items: items.map<DropdownMenuItem<String>>((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item.toString()),
              );
            }).toList(),
          ),
        ],
      ),
    ),
  );
}
  }
