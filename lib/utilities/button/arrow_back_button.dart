import 'package:flutter/material.dart';

class ArrowBackButton extends StatelessWidget {
  ArrowBackButton(
      {super.key, this.color = const Color.fromRGBO(214, 214, 214, 1)});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: Icon(
          Icons.arrow_back_ios_new,
          size: 30,
          color: color,
        ),
      ),
    );
  }
}
