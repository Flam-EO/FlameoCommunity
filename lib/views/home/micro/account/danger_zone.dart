import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flameo/models/client_user.dart';
import 'package:flameo/services/auth.dart';
import 'package:flameo/services/config_provider.dart';
import 'package:flameo/services/database.dart';
import 'package:flameo/shared/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class DangerZone extends StatefulWidget {

  final CompanyPreferences companyPreferences;
  final ConfigProvider config;

  const DangerZone({super.key, required this.companyPreferences, required this.config});

  @override
  State<DangerZone> createState() => _DangerZoneState();
}

class _DangerZoneState extends State<DangerZone> {

  late String currentLink = widget.companyPreferences.panel.panelLink!;

  late TextEditingController panelLinkController = TextEditingController(text: currentLink);
  String waitPanelLink = '';
  bool loading = false;
  bool? verified;
  String error = '';


  void checkLink(String tempLink) async {
    widget.config.log(LoggerAction.linkChangeTry, {'link': tempLink});
    if (removeDiacritics(tempLink.toLowerCase()) == removeDiacritics(currentLink.toLowerCase())) {
      setState(() {
        verified = null;
        loading = false;
        error = '';
      });
    } else if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(tempLink)) {
      setState(() {
        verified = false;
        loading = false;
        error = 'Solo se admiten caracteres alfanuméricos o barra baja';
      });
    } else if (await DatabaseService(config: widget.config).linkExists(tempLink)) {
      setState(() {
        verified = false;
        loading = false;
        error = 'Nombre no disponible';
      });
    } else {
      setState(() {
        verified = true;
        loading = false;
      });
    }
  }

  void fieldChanged(String newValue) => setState(() {
    loading = true;
    verified = null;
    error = '';
    if (newValue.isEmpty) loading = false;
    Future.delayed(const Duration(seconds: 1), () {
      if (newValue.isNotEmpty && newValue == panelLinkController.text) checkLink(newValue);
    });
  });

  Future<void> verifyChange() async {
    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder( builder: (builderContext, setDialogState) => AlertDialog(
          title: const Text(
            'Advertencia',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)
          ),
          content: const Text(
            'Si has publicado tu link o impreso el QR y tus clientes lo conocen, '
            'el link actual dejará de ser válido.\n'
            'Si otro usuario se registra con el link actual no podrás recuperarlo.'
          ),
          titleTextStyle: const TextStyle(fontSize: 15),
          actions: [
            dialogButton(context, 'Cancelar', () => Navigator.of(builderContext).pop()),
            dialogButton(context, 'Continuar', () async {
              await widget.companyPreferences.updateFields({'panelLink': panelLinkController.text}, widget.config);
              currentLink = panelLinkController.text;
              if(mounted) Navigator.of(builderContext).pop();
            })
          ],
          actionsAlignment: MainAxisAlignment.spaceAround,
          elevation: 0.0
        ));
      }
    );
  }

  Future<void> verifyDelete() async {
    bool pendingTransactions = await DatabaseService(
      config: widget.config,
      companyID: widget.companyPreferences.companyID
    ).pendingTransactions();
    if (mounted) {
      bool logOut = await showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return StatefulBuilder( builder: (builderContext, setDialogState) => AlertDialog(
            title: Text(
              pendingTransactions ? 'Transacciones pendientes' : 'Eliminar cuenta',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)
            ),
            content: Text(
              pendingTransactions ? 'No puedes eliminar la cuenta hasta que hayas completado todas las transacciones.\n'
              'Si crees que este mensaje es un error contacta con el equipo de Flameo (info@flameoapp.com)'
              : 'Se va a proceder a la eliminación de la cuenta, a partir de este momento tu panel será inaccesible.\n'
              'Si antes de 15 días accedes a tu cuenta podrás volver a reactivarla antes de su eliminación definitiva.'
            ),
            titleTextStyle: const TextStyle(fontSize: 15),
            actions: [
              dialogButton(context, 'Cancelar', () => Navigator.of(builderContext).pop(false)),
              dialogButton(context, 'Continuar', () async {
                if (!pendingTransactions) {
                  await widget.companyPreferences.updateFields({
                    'is_deleted': true,
                    'deletion_date': Timestamp.fromDate(DateTime.now().add(const Duration(days: 15)))
                  }, widget.config);
                  AuthService(config: widget.config).signOut();
                }
                if(mounted) Navigator.of(builderContext).pop(true);
              })
            ],
            actionsAlignment: MainAxisAlignment.spaceAround,
            elevation: 0.0
          ));
        }
      );
      if (logOut) {
        if (mounted) Navigator.of(context).pop();
      }
    }
  }

  void changePanelLink() async {
    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder( builder: (builderContext, setDialogState) => AlertDialog(
          title: const Text(
            'Cambiar link del panel',
            textAlign: TextAlign.center
          ),
          content: const Text('¿Quieres actualizar el link de tu panel público?'),
          titleTextStyle: const TextStyle(fontSize: 15),
          actions: [
            dialogButton(context, 'Cancelar', () => Navigator.of(builderContext).pop()),
            dialogButton(context, 'Continuar', () async {
              await verifyChange();
              if(mounted) Navigator.of(builderContext).pop();
            })
          ],
          actionsAlignment: MainAxisAlignment.spaceAround,
          elevation: 0.0
        ));
      }
    );
  }

  void deleteAccount() async {
    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder( builder: (builderContext, setDialogState) => AlertDialog(
          title: const Text(
            'Eliminar cuenta',
            textAlign: TextAlign.center
          ),
          content: const Text('¿Quieres eliminar definitivamente tu cuenta de FlameoApp?'),
          titleTextStyle: const TextStyle(fontSize: 15),
          actions: [
            dialogButton(context, 'Cancelar', () => Navigator.of(builderContext).pop()),
            dialogButton(context, 'Continuar', () async {
              await verifyDelete();
              if(mounted) Navigator.of(builderContext).pop();
            })
          ],
          actionsAlignment: MainAxisAlignment.spaceAround,
          elevation: 0.0
        ));
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text(
            'Link del panel: ',
            style: TextStyle(fontWeight: FontWeight.bold)
          )
        ),
        TextFormField(
          controller: panelLinkController,
          maxLength: 20,
          decoration: const InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(18)))),
          onChanged: fieldChanged
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: linkText('https://${widget.config.get('base_link')}/panel?name=${panelLinkController.text}', context),
            ), 
            if(loading) SpinKitCircle(
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            if (verified ?? false) Icon(Icons.check_circle, color: Colors.green[900]),
            if (!(verified ?? true))Icon(Icons.cancel, color: Colors.red[900])
          ]
        ),
        Text(error, style: TextStyle(color: Colors.red[900], fontWeight: FontWeight.bold)),
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.onBackground),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)
              )
            )
          ),
          onPressed: (verified ?? false) ? changePanelLink : null,
          child: const Text('Cambiar nombre del panel', style: TextStyle(color: Colors.white))
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)
              )
            )
          ),
          onPressed: deleteAccount,
          child: const Text('Eliminar cuenta')
        )
      ]
    );
  }
}