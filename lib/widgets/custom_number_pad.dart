import 'package:flutter/material.dart';

class CustomNumberPad extends StatelessWidget {
  final void Function(String value) onValueSelected;

  CustomNumberPad({Key? key, required this.onValueSelected}) : super(key: key);

  final List<String> buttons = [
    '1', '2', '3',
    '4', '5', '6',
    '7', '8', '9',
    '.', '0', '<-',
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: buttons.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio:
            2.0, 
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemBuilder: (BuildContext context, int index) {
        return ElevatedButton(
          onPressed: () {
            if (buttons[index] == '<-') {
              onValueSelected('backspace');
            } else {
              onValueSelected(buttons[index]);
            }
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black,
            backgroundColor: Colors.grey[300],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ), 
          ),
          child: buttons[index] == '<-'
              ? const Icon(Icons.backspace,
                  color: Colors.black) // Use backspace icon
              : Text(buttons[index], style: const TextStyle(fontSize: 20)),
        );
      },
    );
  }
}
