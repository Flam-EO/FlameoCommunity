import 'dart:html';

import 'package:file_picker/file_picker.dart';
import 'package:flameo/models/client_user.dart';
import 'package:flameo/models/photo.dart';
import 'package:flameo/services/cloudstorage.dart';
import 'package:flameo/services/config_provider.dart';
import 'package:flameo/shared/utils.dart';
import 'package:flutter/material.dart';

class LandscapeImage extends StatefulWidget {

  final CompanyPreferences companyPreferences;
  final ConfigProvider config;

  const LandscapeImage({super.key, required this.companyPreferences, required this.config});

  @override
  State<LandscapeImage> createState() => _LandscapeImageState();
}

class _LandscapeImageState extends State<LandscapeImage> {

  void loadLandscape(String photoName) {
    CloudService(companyID: widget.companyPreferences.companyID).landscapeUrl(photoName).then((value) =>
      Future.delayed(Duration.zero, () {
        if (mounted) setState(() => photo = value);
      })
    );
  }

  Photo? photo;
  @override
  void initState() {
    window.history.pushState(null, 'route', '/account');
    if (widget.companyPreferences.landscape != null) {
      loadLandscape(widget.companyPreferences.landscape!);
    }
    super.initState();
  }

  UploadingStatus? uploadingStatus;
  double? uploadingProgress;
  Photo? newPhoto;
  void changeLandscape() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      newPhoto = await Photo.fromFile(result.files.first, name: "portada_${generateCode(length: 10)}");
      CloudService(companyID: widget.companyPreferences.companyID).addLandscapePhoto(
        newPhoto!,
        (double progress, _) => setState(() => uploadingProgress = progress),
        (UploadingStatus status, _) => setState(() => uploadingStatus = status)
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {

    if (uploadingStatus == UploadingStatus.success) {
      uploadingStatus = null;
      widget.companyPreferences.updateFields({
        'landscape': newPhoto!.name
      }, widget.config);
      loadLandscape(newPhoto!.name);
    }

    if (uploadingStatus == UploadingStatus.error) {
      uploadingStatus = null;
      Future.delayed(Duration.zero, () => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: const Text('Ha ocurrido un error al actualizar la imagen', textAlign: TextAlign.center)
        )
      ));
    }

    Widget image = ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: Image.network(
        photo?.link ?? "",
        fit: BoxFit.cover,
        errorBuilder: (context, _, __) => Container(color: Theme.of(context).colorScheme.secondary)
      )
    );

    return Stack(
      children: [
        image,
        if (uploadingStatus == UploadingStatus.uploading) Positioned.fill(
          child: Center(
            child: Text(
              '${(uploadingProgress! * 100).round()} %',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 30
              )
            )
          )
        ),
        if (uploadingStatus != UploadingStatus.uploading) Positioned.fill(
          bottom: 10,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: ElevatedButton.icon(
              onPressed: changeLandscape,
              icon: const Icon(Icons.change_circle_outlined),
              label: const Text('Cambiar imagen de cabecera')
            )
          )
        )
      ]
    );
  }
}