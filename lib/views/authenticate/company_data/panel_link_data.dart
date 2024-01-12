import 'package:flameo/models/registration_values_setter.dart';
import 'package:flameo/models_widgets/company_data_screen.dart';
import 'package:flameo/services/config_provider.dart';
import 'package:flameo/services/database.dart';
import 'package:flameo/shared/utils.dart';
import 'package:flameo/views/authenticate/company_data/pre_payment_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class PanelLinkData extends StatefulWidget {
  final RegistrationValuesSetter values;
  final ConfigProvider config;

  const PanelLinkData({super.key, required this.values, required this.config});

  @override
  State<PanelLinkData> createState() => _PanelLinkDataState();
}

class _PanelLinkDataState extends State<PanelLinkData> {
  TextEditingController panelLinkController = TextEditingController(text: '');
  String waitPanelLink = '';
  bool loading = false;
  bool? verified;
  String error = '';

  void checkLink(String tempLink) async {
    widget.config.log(LoggerAction.linkTry, {'link': tempLink});
    if (!RegExp(r'^[a-z0-9]+$').hasMatch(tempLink)) {
      setState(() {
        verified = false;
        loading = false;
        error = 'Solo se admiten caracteres alfanuméricos';
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
      // This is to change upper case letters automatically to lower case
      panelLinkController.text = panelLinkController.text.toLowerCase();
      final int textLength = panelLinkController.text.length;
      panelLinkController.selection = TextSelection.fromPosition(TextPosition(offset: textLength));
      if (newValue.isNotEmpty && newValue.toLowerCase() == panelLinkController.text) checkLink(newValue);
    });
  });

  @override
  Widget build(BuildContext context) {
    return CompanyDataScreen(
      percentage: 8/9,
      title: widget.config.environment == Environment.art ? 'Estás a tan solo 2 minutos de publicar tu galería' : 'Estás a tan solo 2 minutos de publicar tu web',
      amIFirst: true,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 20),
          child: TextFormField(
            controller: panelLinkController,
            inputFormatters: [
              TextInputFormatter.withFunction(
                (TextEditingValue oldValue, TextEditingValue newValue) {
                  return RegExp(r'^[a-z0-9]+$').hasMatch(newValue.text) ? newValue : oldValue;
                }
              )
            ],
            maxLength: 20,
            validator: (value) => (value?.trim().isEmpty ?? true) ? 'Introduce tu email' : null,
            onChanged: fieldChanged,
            decoration:  InputDecoration(
              filled: true,
              fillColor: Colors.white,
              labelText: widget.config.environment == Environment.art ? 'Introduce un nombre para tu galería pública' : 'Introduce un nombre para tu web pública', 
              border:  const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)))
            )
          )
        ),
        const Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Text(
            'Tu web será',
            style: TextStyle(color: Colors.black, fontSize: 15)
          )
        ),
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(10.0))
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: linkText(
                    'https://${widget.config.get('base_link')}/panel?name=${panelLinkController.text}',
                    context,
                    15
                  )
                )
              ), 
              if(loading) SpinKitCircle(
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              if (verified ?? false) Icon(Icons.check_circle, color: Colors.green[900]),
              if (!(verified ?? true))Icon(Icons.cancel, color: Colors.red[900])
            ]
          )
        ),
        Text(error, style: TextStyle(color: Colors.red[900], fontWeight: FontWeight.bold)),
        if (verified ?? false) ElevatedButton(
          onPressed: () async {
            widget.values.setValue('panelLink', panelLinkController.text);
            widget.config.log(LoggerAction.companyDataLandscape);
            rightSlideTransition(context, PrePaymentData(values: widget.values, config: widget.config));
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
            child: Text('Continuar', style: TextStyle(color: Colors.white))
          )
        )
      ]
    );
  }
}
