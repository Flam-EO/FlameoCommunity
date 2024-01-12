import 'package:cached_network_image/cached_network_image.dart';
import 'package:flameo/models/photo.dart';
import 'package:flutter/material.dart';

class PhotoBuilder extends StatelessWidget {
  final Photo photo;
  final BoxFit boxFit;
  final Widget Function(BuildContext context, String url, dynamic error)? errorWidget;
  final bool thumbnail;

  const PhotoBuilder({super.key, required this.photo, required this.boxFit, this.errorWidget, this.thumbnail=false});

  @override
  Widget build(BuildContext context) {
    String link;
    if (thumbnail) {
      link = photo.thumbnailLink ?? photo.link ?? '';
    } else {
      link = photo.link ?? photo.thumbnailLink ?? '';
    }
    return CachedNetworkImage(
      imageUrl: link, 
      fit: boxFit,
      placeholder: (context, url) => !thumbnail
      ? PhotoBuilder(photo: photo, boxFit: boxFit, errorWidget: errorWidget, thumbnail: true)
      : Container(
          color: Theme.of(context).colorScheme.secondary,
        ),
      errorWidget: !thumbnail
      ? (_, __, ___) => PhotoBuilder(photo: photo, boxFit: boxFit, errorWidget: errorWidget, thumbnail: true)
      : errorWidget ?? (_, __, ___) => Container(
          color: Theme.of(context).colorScheme.secondary,
        )
    );
  }
}
