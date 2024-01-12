import 'package:flameo/models/registration_values_setter.dart';
import 'package:flameo/models_widgets/company_data_screen.dart';
import 'package:flameo/services/config_provider.dart';
import 'package:flameo/shared/utils.dart';
import 'package:flameo/views/authenticate/company_data/social_media_data.dart';
import 'package:flutter/material.dart';

class ReferralData extends StatefulWidget {
  final ConfigProvider config;
  final RegistrationValuesSetter values;

  const ReferralData({super.key, required this.values, required this.config});

  @override
  State<ReferralData> createState() => _ReferralDataState();
}

class _ReferralDataState extends State<ReferralData> {
  TextEditingController referralController = TextEditingController(text: '');

  @override
  Widget build(BuildContext context) {
    return CompanyDataScreen(
      percentage: 2/9,
      title: 'Cómo descubriste Flameo',
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 20.0),
          child: Text(
            'Algún artista te habló de nosotros? Déjanos aquí su nombre de Flameo, o el lugar donde oíste hablar de nosotros',
            style: TextStyle(fontSize: 15, color: Colors.black),
            maxLines: 3),
        ),
        TextField(
          decoration: const InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border:  OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)))
          ),
          controller: referralController,
          textCapitalization: TextCapitalization.sentences
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () {
            widget.values.setValue('referral', referralController.text);
            widget.config.log(LoggerAction.companyDataReferral);
            rightSlideTransition(context, SocialMediaData(values: widget.values, config: widget.config));
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
      ]
    );
  }
}
