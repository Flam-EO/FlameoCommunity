import 'package:checkbox_formfield/checkbox_formfield.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flameo/models/cart_models/cart.dart';
import 'package:flameo/models/client_user.dart';
import 'package:flameo/services/config_provider.dart';
import 'package:flameo/shared/utils.dart';
import 'package:flutter/material.dart';

class SettingsForm extends StatefulWidget {

  final ConfigProvider config;
  final CompanyPreferences companyPreferences;

  const SettingsForm({super.key, required this.config, required this.companyPreferences});

  @override
  State<SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends State<SettingsForm> {

  final formKey = GlobalKey<FormState>();
  TextEditingController addressController = TextEditingController(text: "");
  TextEditingController nameController = TextEditingController(text: "");
  TextEditingController descriptionController = TextEditingController(text: "");
  TextEditingController emailController = TextEditingController(text: "");
  TextEditingController phoneController = TextEditingController(text: "");
  TextEditingController mediaController = TextEditingController(text: "");
  TextEditingController minimumAmountController = TextEditingController(text: "");

  FocusNode addressFocusNode = FocusNode();
  FocusNode phoneFocusNode = FocusNode();
  FocusNode mediaFocusNode = FocusNode();
  FocusNode emailFocusNode = FocusNode();
  FocusNode descriptionFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    nameController.text = widget.companyPreferences.companyName;
    descriptionController.text = widget.companyPreferences.description ?? '';
    addressController.text = widget.companyPreferences.address ?? '';
    phoneController.text = widget.companyPreferences.phone ?? '';
    emailController.text = widget.companyPreferences.email ?? '';
    mediaController.text = widget.companyPreferences.media ?? '';
    minimumAmountController.text = widget.companyPreferences.minimumTransactionAmountStr;
  }

  String? _emailFieldValidator(String? value) {
    const maxNameLength = 256;
    if (value?.isEmpty ?? true) {
      return 'Introduce un email';
    } else if (!EmailValidator.validate(value!)) {
      return 'Introduce un email válido';
    } else if (value.length > maxNameLength) {
      return 'Email demasiado largo, el máximo número de caracteres es $maxNameLength';
    }
    return null;
  }

  String? _phoneFieldValidator(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Introduce un número de teléfono';
    }
    value = value!.replaceAll(' ', '');
    bool hasPlusPrefix = value.startsWith('+');
    bool isValidLength = value.length > (hasPlusPrefix ? 7 : 6) && value.length <= 15;
    bool isValidContent = value.substring(hasPlusPrefix ? 1 : 0).characters.every((c) => int.tryParse(c) != null);
    if (!isValidLength || !isValidContent) {
      return 'Introduce un número de teléfono válido';
    }
    return null;
  }

  String? _minimumAmountFieldValidator(String? value) {
    String? floatValidation = floatFieldValidator(value);
    if (floatValidation != null) return floatValidation;
    if (double.parse(value!) < 0.5) {
      return 'La cantidad mínima permitida es de 0.5 €';
    }
    return null;
  }

  late List<ShippingMethod> selectedMethods = widget.companyPreferences.shippingMethods;

  CheckboxListTileFormField checkboxListTile(ShippingMethod shippingMethod) => CheckboxListTileFormField(
    title: Text(shippingMethodName(shippingMethod)),
    validator: (_) => selectedMethods.isEmpty ? 'Selecciona al menos un método' : null,
    controlAffinity: ListTileControlAffinity.leading,
    initialValue: selectedMethods.contains(shippingMethod), 
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
    return Form(
      key: formKey,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextFormField(
              controller: nameController,
              decoration: inputDecoration("Nombre"),
              validator: (value) => (value?.trim().isEmpty ?? true) ? 'Introduce un nombre válido' : null,
              onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(descriptionFocusNode)
            ),
            const SizedBox(height: 20),
            TextFormField(
              focusNode: descriptionFocusNode,
              controller: descriptionController,
              decoration: inputDecoration("Descripción"),
              textCapitalization: TextCapitalization.sentences,
              maxLength: 500,
              maxLines: 5,
              minLines: 5,
              onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(mediaFocusNode)
            ),
            const SizedBox(height: 20),
            TextFormField(
              focusNode: mediaFocusNode,
              controller: mediaController,
              decoration: inputDecoration("Instagram"),
              validator: (value) => (value?.trim().isEmpty ?? true) ? 'Introduce tu nombre de usuario de instagram' : null,
              onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(addressFocusNode)
            ),
            const SizedBox(height: 20),
            TextFormField(
              focusNode: addressFocusNode,
              controller: addressController,
              decoration: inputDecoration("Dirección"),
              validator: (value) => (value?.trim().isEmpty ?? true) ? 'Introduce una dirección' : null,
              onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(emailFocusNode)
            ),
            const SizedBox(height: 20),
            TextFormField(
              focusNode: emailFocusNode,
              controller: emailController,
              decoration: inputDecoration("Correo electrónico"),
              validator: _emailFieldValidator,
              onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(phoneFocusNode)
            ),
            const SizedBox(height: 20),
            TextFormField(
              focusNode: phoneFocusNode,
              controller: phoneController,
              decoration: inputDecoration("Teléfono"),
              validator: _phoneFieldValidator
            ),
            const SizedBox(height: 20),
            const Text('Métodos de entrega'),
            const SizedBox(height: 20),
            checkboxListTile(ShippingMethod.pickUp),
            checkboxListTile(ShippingMethod.sellerShipping),
            // const CheckboxListTile(
            //   title: Text('Envío gestionado por Flameo'),
            //   subtitle: Text('*No disponible, lo estará pronto! (info@flameoapp.com)'),
            //   controlAffinity: ListTileControlAffinity.leading,
            //   value: false, 
            //   onChanged: null
            // ),
            const SizedBox(height: 20),
            TextFormField(
              controller: minimumAmountController,
              decoration: inputDecoration("Precio mínimo permitido por transacción"),
              validator: _minimumAmountFieldValidator
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.onBackground),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)
                  )
                )
              ),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  widget.companyPreferences.updateFields({
                    'companyName': nameController.text,
                    'description': descriptionController.text,
                    'address': addressController.text,
                    'email': emailController.text,
                    'phone': phoneController.text,
                    'media': mediaController.text,
                    'shippingMethods': selectedMethods.map((method) => method.name).toList(),
                    'minimumTransactionAmount': double.parse(minimumAmountController.text)
                  }, widget.config);
                  Navigator.pop(context);
                }
              },
              child: const Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  'Confirmar',
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.white
                  )
                )
              )
            )
          ]
        )
      )
    );
  }
}