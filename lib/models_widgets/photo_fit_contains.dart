import 'dart:ui';
import 'package:flameo/models/photo.dart';
import 'package:flameo/models_widgets/photo_builder.dart';
import 'package:flutter/material.dart';

class PhotoFitContains extends StatelessWidget {
  final Photo photo;
  final BoxFit boxFit;
  final Widget Function(BuildContext context, String url, dynamic error)? errorWidget;
  final bool thumbnail;

  const PhotoFitContains({super.key, required this.photo, required this.boxFit, this.errorWidget, this.thumbnail=false});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        PhotoBuilder(photo: photo, boxFit: BoxFit.cover, thumbnail: true),
        ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
              ),
              alignment: Alignment.center,
              child: PhotoBuilder(photo: photo, boxFit: boxFit, thumbnail: thumbnail),
            )
          ),
        )
      ]
    );
  }
}
