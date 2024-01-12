import 'package:flutter/material.dart';

class ElementLanding extends StatelessWidget {
  final String imagePath;
  const ElementLanding({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Column(children: [Image.asset(imagePath), ],);
  }
}