import 'package:flameo/models/registration_values_setter.dart';
import 'package:flameo/models_widgets/company_data_screen.dart';
import 'package:flameo/services/config_provider.dart';
import 'package:flameo/shared/utils.dart';
import 'package:flameo/views/authenticate/company_data/referral_data.dart';
import 'package:flutter/material.dart';

class DescriptionData extends StatefulWidget {
  final ConfigProvider config;
  final RegistrationValuesSetter values;

  const DescriptionData({super.key, required this.values, required this.config});

  @override
  State<DescriptionData> createState() => _DescriptionDataState();
}

class _DescriptionDataState extends State<DescriptionData> {
  TextEditingController descriptionController = TextEditingController(text: '');

  @override
  Widget build(BuildContext context) {
    return CompanyDataScreen(
      percentage: 1/9,
      title: 'Bienvenido! Cuéntanos un poco sobre ti. ',
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 20.0),
          child: Text(
            'Qué tipo de obras creas, cuantos años llevas en la profesión... Algo que haga a tu público conocerte un poco más.',
            style: TextStyle(fontSize: 15, color: Colors.black),
            maxLines: 3),
        ),
        TextField(
          decoration: const InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border:  OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)))
          ),
          controller: descriptionController,
          textCapitalization: TextCapitalization.sentences,
          maxLength: 500,
          maxLines: 5,
          minLines: 5
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () {
            widget.values.setValue('description', descriptionController.text);
            widget.config.log(LoggerAction.companyDataAddress);
            rightSlideTransition(context, ReferralData(values: widget.values, config: widget.config));
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
