import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImageShower extends StatelessWidget {

  final String? image;
  final Uint8List? imageData;
  final String title;
  const ImageShower({Key? key,  this.image, required this.title, this.imageData }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(title)
      ),
      body: image == null && imageData == null ? const Center(
        child: Text('No se puede cargar la imagen')
      ) : PhotoView(
        imageProvider: (image != null ? NetworkImage(image!) : MemoryImage(imageData!) as ImageProvider),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.contained * 4,
        loadingBuilder: (context, progress) => Center(
         child: SizedBox(
           width: 20.0,
           height: 20.0,
           child: CircularProgressIndicator(
             value: progress == null
              ? null
              : progress.cumulativeBytesLoaded /
                  progress.expectedTotalBytes!,
           ),
         ),
       ),
      ),
    );
  }
}