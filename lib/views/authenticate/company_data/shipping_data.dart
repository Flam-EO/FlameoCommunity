import 'package:flameo/models/cart_models/cart.dart';
import 'package:flameo/models/registration_values_setter.dart';
import 'package:flameo/models_widgets/company_data_screen.dart';
import 'package:flameo/services/config_provider.dart';
import 'package:flameo/shared/utils.dart';
import 'package:flameo/views/authenticate/company_data/landscape_data.dart';
import 'package:flutter/material.dart';

class ShippingData extends StatefulWidget {

  final RegistrationValuesSetter values;
  final ConfigProvider config;

  const ShippingData({super.key, required this.values, required this.config});

  @override
  State<ShippingData> createState() => _ShippingDataState();
}

class _ShippingDataState extends State<ShippingData> {

  List<ShippingMethod> selectedMethods = [];

  CheckboxListTile checkboxListTile(ShippingMethod shippingMethod) => CheckboxListTile(
    title: Text(shippingMethodName(shippingMethod), style: const TextStyle(color: Colors.black)),
    controlAffinity: ListTileControlAffinity.leading,
    value: selectedMethods.contains(shippingMethod), 
    onChanged: (bool? selected) => setState(() {
      if (selected ?? false & !selectedMethods.contains(shippingMethod)) {
        selectedMethods.add(shippingMethod);
      } else if (selectedMethods.contains(shippingMethod)) {
        selectedMethods.remove(shippingMethod);
      }
    })
  );

  @override
  Widget build(BuildContext context) {
    return CompanyDataScreen(
      percentage: 6/9,
      title: 'Para tus ventas...',
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 20.0),
          child: Text(
            'Elige los métodos de entrega que aceptarás',
            style: TextStyle(fontSize: 15, color: Colors.black),
            maxLines: 3),
        ),
        checkboxListTile(ShippingMethod.pickUp),
        checkboxListTile(ShippingMethod.sellerShipping),
        const SizedBox(height: 20),
        if (selectedMethods.isNotEmpty) ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.onBackground),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)
              )
            )
          ),
          onPressed: () async {
            widget.values.setValue('shippingMethods', selectedMethods.map((method) => method.name).toList());
            widget.config.log(LoggerAction.companyDataPhone);
            rightSlideTransition(context, LandscapeData(values: widget.values, config: widget.config));
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