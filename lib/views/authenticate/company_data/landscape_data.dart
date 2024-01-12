import 'package:file_picker/file_picker.dart';
import 'package:flameo/models/photo.dart';
import 'package:flameo/models/registration_values_setter.dart';
import 'package:flameo/models_widgets/company_data_screen.dart';
import 'package:flameo/services/cloudstorage.dart';
import 'package:flameo/services/config_provider.dart';
import 'package:flameo/shared/loading.dart';
import 'package:flameo/shared/utils.dart';
import 'package:flameo/views/authenticate/company_data/panel_link_data.dart';
import 'package:flutter/material.dart';

class LandscapeData extends StatefulWidget {
  final ConfigProvider config;
  final RegistrationValuesSetter values;

  const LandscapeData({super.key, required this.values, required this.config});

  @override
  State<LandscapeData> createState() => _LandscapeDataState();
}

class _LandscapeDataState extends State<LandscapeData> {

  UploadingStatus? uploadingStatus;
  double? uploadingProgress;

  List<Photo> loadedPhotos = [];

  void uploadPressed() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      loadedPhotos.add(await Photo.fromFile(result.files.first, name: "portada_${generateCode(length: 10)}"));
      CloudService(companyID: widget.values.companyPreferences.companyID).addLandscapePhoto(
        loadedPhotos.first,
        (double progress, _) => setState(() => uploadingProgress = progress),
        (UploadingStatus status, _) => setState(() => uploadingStatus = status)
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompanyDataScreen(
      percentage: 7/9,
      title: 'Imagen de cabecera',
      amIFirst: false,
      children: [
        const Padding(
          padding: EdgeInsets.all(10),
          child: Text(
            'Elige la foto que será la presentación de tu web. La podrás cambiar más tarde!',
            style: TextStyle(fontSize: 15)
          )
        ),
        if (uploadingStatus == null || uploadingStatus == UploadingStatus.error) Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 20),
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.onBackground),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)
                )
              )
            ),
            onPressed: uploadPressed,
            child: const Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                "Pulsa aquí para subir tu imagen!",
                style: TextStyle(color: Colors.white),
              ),
            )
          )
        ), 
        if(uploadingStatus == UploadingStatus.uploading) const Loading(size: 12),
        if(uploadingStatus == UploadingStatus.success) const Text('Foto subida!', style: TextStyle(fontSize: 15)),
        if(uploadingStatus == UploadingStatus.success) Padding(
          padding: const EdgeInsets.all(10.0),
          child: ElevatedButton(
            onPressed: () async {
              widget.values.setValue('landscape', loadedPhotos.first.name);
              widget.config.log(LoggerAction.companyDataDescription);
              rightSlideTransition(context, PanelLinkData(values: widget.values, config: widget.config));
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.onBackground),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)
                )
              )
            ),
            child: const Padding(
              padding: EdgeInsets.all(10.0),
              child: Text('Continuar', style: TextStyle(fontSize: 15, color: Colors.white),),
            )
          )
        )
      ]
    );
  }
}
