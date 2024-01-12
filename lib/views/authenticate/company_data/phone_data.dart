import 'package:flameo/models/registration_values_setter.dart';
import 'package:flameo/models_widgets/company_data_screen.dart';
import 'package:flameo/services/config_provider.dart';
import 'package:flameo/shared/utils.dart';
import 'package:flameo/views/authenticate/company_data/address_data.dart';
import 'package:flutter/material.dart';

class PhoneData extends StatefulWidget {

  final RegistrationValuesSetter values;
  final ConfigProvider config;

  const PhoneData({super.key, required this.values, required this.config});

  @override
  State<PhoneData> createState() => _PhoneDataState();
}

class _PhoneDataState extends State<PhoneData> {

  TextEditingController phoneController = TextEditingController(text: '');

  @override
  Widget build(BuildContext context) {
    return CompanyDataScreen(
      percentage: 4/9,
      title: 'Cuando necesitemos hablar...',
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 20.0),
          child: Text(
            'Introduce tu teléfono de contacto',
            style: TextStyle(fontSize: 15, color: Colors.black),
            maxLines: 3),
        ),
        TextFormField(
          decoration: const InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border:  OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)))
          ),
          keyboardType: TextInputType.phone,
          controller: phoneController,
          onChanged: (_) => setState(() {})
        ),
        const SizedBox(height: 30),
        if (phoneController.text.isNotEmpty) ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.onBackground),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)
              )
            )
          ),
          onPressed: () async {
            widget.values.setValue('phone', phoneController.text);
            rightSlideTransition(context, AddressData(values:widget.values, config: widget.config));
          },
          child: const Padding(
            padding: EdgeInsets.all(10.0),
            child: Text('Continuar', style: TextStyle(color: Colors.white, fontSize: 15)),
          )
        )
      ]
    );
  }
}