import 'package:flameo/models/registration_values_setter.dart';
import 'package:flameo/models_widgets/company_data_screen.dart';
import 'package:flameo/services/config_provider.dart';
import 'package:flameo/shared/utils.dart';
import 'package:flameo/views/authenticate/company_data/shipping_data.dart';
import 'package:flutter/material.dart';

class AddressData extends StatefulWidget {
  final RegistrationValuesSetter values;
  final ConfigProvider config;

  const AddressData({super.key, required this.values, required this.config});

  @override
  State<AddressData> createState() => _AddressDataState();
}

class _AddressDataState extends State<AddressData> {

  TextEditingController addressController = TextEditingController(text: '');

  @override
  Widget build(BuildContext context) {
    return CompanyDataScreen(
      percentage: 5/9,
      title: '¿Dónde estás?',
      children: [
        TextFormField(
          decoration: const InputDecoration(
            filled: true,
            fillColor: Colors.white,
            labelText: 'Introduce la ciudad en la que vives.',
            border:  OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)))
          ),
          controller: addressController,
          onChanged: (_) => setState(() {})
        ),
        const SizedBox(height: 30),
        if(addressController.text.isNotEmpty) ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.onBackground),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)
              )
            )
          ),
          onPressed: () async {
            widget.values.setValue('address', addressController.text);
            widget.config.log(LoggerAction.companyDataShipping);
            rightSlideTransition(context, ShippingData(values: widget.values, config: widget.config));
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