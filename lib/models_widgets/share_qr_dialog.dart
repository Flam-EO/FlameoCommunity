import 'package:flameo/models/client_user.dart';
import 'package:flameo/services/config_provider.dart';
import 'package:flameo/shared/loading.dart';
import 'package:flameo/shared/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui' as dart_ui;

class ShareQrDialog extends StatelessWidget {
  final BuildContext context;
  final BuildContext dialogContext;
  final ConfigProvider config;
  final CompanyPreferences companyPreferences;
  const ShareQrDialog({super.key, required this.dialogContext, required this.config, required this.companyPreferences, required this.context});

  @override
  Widget build(BuildContext context) {

    DateTime? lastSnackbarTimestamp;

    void downloadQR(String data) async {
      QrValidationResult qrValidationResult = QrValidator.validate(
        data: data,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.L,
      );
      if (qrValidationResult.status == QrValidationStatus.valid) {
        QrPainter painter = QrPainter.withQr(
          qr: qrValidationResult.qrCode!,
          emptyColor: Colors.white,
          color: Theme.of(context).colorScheme.primary
        );
        ByteData? picData = await painter.toImageData(2048, format: dart_ui.ImageByteFormat.png);
        if (picData != null) {
          List<int> bytesList = picData.buffer.asUint8List(picData.offsetInBytes, picData.lengthInBytes);
          imageCache.clear();
          saveFile('PanelQR_flameoapp.png', bytesList);
        }
      }
    }

    return AlertDialog(
      title: const Text(
        'Compartir link del panel',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18)
      ),
      backgroundColor: Theme.of(context).colorScheme.onSecondary,
      content: companyPreferences.panel.panelLink != null ? SizedBox(
        height: 300,
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10.0))
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 200,
                    width: 200,
                    child: QrImage(
                      data: companyPreferences.subdomain != null ? 
                      'https://${companyPreferences.subdomain}.${config.shareBaseLink(companyPreferences)}'
                      : 'https://${config.shareBaseLink(companyPreferences)}/panel?name=${companyPreferences.panel.panelLink}',
                      version: QrVersions.auto,
                      embeddedImage: const AssetImage('imgs/logo.png'),
                    )
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10.0))
              ),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: SelectableText(companyPreferences.subdomain != null ? 
                        'https://${companyPreferences.subdomain}.${config.shareBaseLink(companyPreferences)}'
                        : 'https://${config.shareBaseLink(companyPreferences)}/panel?name=${companyPreferences.panel.panelLink}'
                      )
                    )
                  ]
                )
              )
            ),
            const SizedBox(height: 15),
            
          ]
        ),
      ) : const Loading(),
      actions: [
        Align(
          alignment: Alignment.topLeft,
          child: TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(
                text: companyPreferences.subdomain != null ? 
                  'https://${companyPreferences.subdomain}.${config.shareBaseLink(companyPreferences)}'
                  : 'https://${config.shareBaseLink(companyPreferences)}/panel?name=${companyPreferences.panel.panelLink}'
              ));
              if (elapsedTimeChecker(lastSnackbarTimestamp, 2000)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Link copiado al portapapeles!'))
                );
                lastSnackbarTimestamp = DateTime.now();
              }
            },
            label: const Text('Copiar link', style: TextStyle(color: Colors.black)),
            icon: const Icon(Icons.copy, color: Colors.black)
          ),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: TextButton.icon(
            onPressed: () => downloadQR(companyPreferences.subdomain != null ? 
              'https://${companyPreferences.subdomain}.${config.shareBaseLink(companyPreferences)}'
              : 'https://${config.shareBaseLink(companyPreferences)}/panel?name=${companyPreferences.panel.panelLink}'
            ),
            label: const Text('Descargar imagen', style: TextStyle(color: Colors.black)),
            icon: const Icon(Icons.download, color: Colors.black)
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Cerrar', style: TextStyle(color: Colors.black))
        )
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0), // Personaliza el radio de borde
      ),
    );
  }
}