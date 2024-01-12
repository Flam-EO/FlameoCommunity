import 'dart:math';

import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flameo/models/photo.dart';
import 'package:flameo/shared/image_shower.dart';
import 'package:flutter/material.dart';
import 'package:reorderables/reorderables.dart';

class NewPhotos extends StatefulWidget {

  final List<Photo> preLoadedPhotos;
  final bool enabled;

  const NewPhotos({super.key, required this.preLoadedPhotos, required this.enabled});

  @override
  State<NewPhotos> createState() => _NewPhotosState();
}

class _NewPhotosState extends State<NewPhotos> {

  List<Widget> loadings = [];
  late Widget loading = Container(
    width: 100,
    height: 100,
    decoration: BoxDecoration(
      border: Border.all(width: 2),
      borderRadius: BorderRadius.circular(10)
    ),
    child: const Center(
      child: Text('Cargando foto...', textAlign: TextAlign.center)
    )
  );

  void addPhotos() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true, type: FileType.image);
    setState(() => loadings.add(loading));
    if (result != null) {
      int numberPhotos = result.files.length;
      int totalNumberPhotos = widget.preLoadedPhotos.length + numberPhotos;
      int allowedNumberPhotos = 10 - widget.preLoadedPhotos.length;
      if (totalNumberPhotos > 10 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No puedes subir más de 10 fotos, tomando las 10 primeras'))
        );
      }
      List<Photo> photos = await Future.wait(result.files.sublist(0, min(allowedNumberPhotos, numberPhotos)).map((file) => Photo.fromFile(file)));
      widget.preLoadedPhotos.addAll(photos);
    }
    setState(() => loadings.removeLast());
  }

  late Widget addPhotoButton = InkWell(
    onTap: addPhotos,
    child: DottedBorder(
      borderType: BorderType.RRect,
      strokeWidth: 2,
      dashPattern: const [
        5,
        5
      ],
      radius: const Radius.circular(10),
      child: const SizedBox(
        width: 96,
        height: 96,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_camera_outlined),
            Text('Añadir foto')
          ]
        )
      )
    )
  );

  late Widget deletePhotoButton = DragTarget(
    onWillAccept: (_) => true,
    onLeave: (_) => deleteItem = false,
    onAccept: (_) => deleteItem = true,
    builder: (_, __, ___) => DottedBorder(
      color: Theme.of(context).colorScheme.error,
      borderType: BorderType.RRect,
      strokeWidth: 2,
      dashPattern: const [
        5,
        5
      ],
      radius: const Radius.circular(10),
      child: Container(
        color: Theme.of(context).colorScheme.error.withOpacity(0.5),
        width: 96,
        height: 96,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline_rounded),
            Text('Eliminar')
          ]
        )
      )
    )
  );

  Widget photoPreview(Photo photo) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageShower(
            title: 'Imagen ${(widget.preLoadedPhotos.indexOf(photo) + 1)}',
            image: photo.link,
            imageData: photo.data
          )
        )
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10)
          ),
          child: photo.thumbnailData != null ? Image.memory(
            photo.thumbnailData!,
            fit: BoxFit.cover
          )
          : Image.network(
            photo.thumbnailLink ?? '',
            fit: BoxFit.cover,
            errorBuilder: (context, _, __) {
              return SizedBox(
                height: 90,
                width: 90,
                child: Container(color: Theme.of(context).colorScheme.secondary)
              );
            }
          )
        )
      ),
    );
  }

  void reorderImageList(int startIndex, int endIndex) {
    reordering = false;
    if (deleteItem) {
      setState(() {
        widget.preLoadedPhotos.removeAt(startIndex);
        deleteItem = false;
      });
    } else {
      if (startIndex != widget.preLoadedPhotos.length && endIndex != widget.preLoadedPhotos.length) {
        setState(() {
          Photo imageToMove = widget.preLoadedPhotos.removeAt(startIndex);
          widget.preLoadedPhotos.insert(endIndex, imageToMove);
        });
      }
    }
  }

  void reorderStarted(int index) {
    if (index != widget.preLoadedPhotos.length) {
      setState(() {
        reordering = true;
      });
    }
  }

  void reorderCancel(int index) {
    if (deleteItem) {
      setState(() {
        widget.preLoadedPhotos.removeAt(index);
        deleteItem = false;
      });
    }
    setState(() {
      reordering = false;
    });
  }

  bool reordering = false;
  bool deleteItem = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          ReorderableWrap(
            enableReorder: widget.enabled,
            runAlignment: WrapAlignment.center,
            needsLongPressDraggable: false,
            runSpacing: 10,
            spacing: 10,
            onReorder: reorderImageList,
            onReorderStarted: reorderStarted,
            onNoReorder: reorderCancel,
            children: [
              ...widget.preLoadedPhotos.map(photoPreview).toList(),
              ...loadings,
              if (!reordering && widget.enabled && widget.preLoadedPhotos.length + loadings.length < 10) GestureDetector(
                onHorizontalDragStart: (_) {},
                onVerticalDragStart: (_) {},
                child: addPhotoButton
              )
            ]
          ),
          if (reordering) const SizedBox(height: 20),
          if (reordering) deletePhotoButton
        ]
      )
    );
  }
}