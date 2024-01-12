import 'package:flameo/models/registration_values_setter.dart';
import 'package:flameo/models_widgets/company_data_screen.dart';
import 'package:flameo/services/config_provider.dart';
import 'package:flameo/shared/utils.dart';
import 'package:flameo/views/authenticate/company_data/phone_data.dart';
import 'package:flutter/material.dart';

class SocialMediaData extends StatefulWidget {

  final RegistrationValuesSetter values;
  final ConfigProvider config;

  const SocialMediaData({super.key, required this.values, required this.config});

  @override
  State<SocialMediaData> createState() => _SocialMediaDataState();
}

class _SocialMediaDataState extends State<SocialMediaData> {

  bool hasMedia = false;
  TextEditingController webController = TextEditingController(text: '');

  @override
  Widget build(BuildContext context) {
    return CompanyDataScreen(
      percentage: 3/9,
      title: 'Instagram',
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 20.0),
          child: Text(
            'Danos tu cuenta de Instagram y te seguimos! Si no tienes no pasa nada; pon "no tengo".',
            style: TextStyle(fontSize: 15, color: Colors.black),
            maxLines: 3),
        ),
        TextFormField(
          decoration: const InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border:  OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)))
          ),
          controller: webController,
          maxLines: 1,
          minLines: 1,
          keyboardType: TextInputType.name,
          onChanged: (_) => setState(() {})
        ),
        const SizedBox(height: 20),
        webController.text.isNotEmpty
        ? ElevatedButton(
            onPressed: () async {
              widget.values.setValue('media', webController.text);
              rightSlideTransition(
                context,
                PhoneData(
                  config: widget.config,
                  values:widget.values
                )
              );
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
            child: Text('Continuar', style: TextStyle(color: Colors.white, fontSize: 15)),
          )
          )
        : const SizedBox()
      ]
    ); 
  }
}