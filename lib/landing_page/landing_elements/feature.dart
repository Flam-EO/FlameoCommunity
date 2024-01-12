import 'package:flameo/shared/platform.dart';
import 'package:flutter/material.dart';

class Feature extends StatelessWidget {
  final String path;
  const Feature({super.key, required this.path});

  @override
  Widget build(BuildContext context) {
    ScreenSize screensize = ScreenSize(context);
    return Padding(
      padding: const EdgeInsets.only(left: 5.0, right: 5.0),
      child: AspectRatio(
        aspectRatio: screensize.aspectRatio > 1.2 ? 1.52 : 0.475,
        child: Image.asset(path, fit: BoxFit.cover)
      ),
    );
  }
}