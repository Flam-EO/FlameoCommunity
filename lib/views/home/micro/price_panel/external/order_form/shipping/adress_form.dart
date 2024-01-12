import 'package:flameo/models/cart_models/cart.dart';
import 'package:flameo/models/client_contact.dart';
import 'package:flameo/shared/utils.dart';
import 'package:flutter/material.dart';

class AddressForm extends StatefulWidget {
  final Cart cart;
  final ChildController controller;

  const AddressForm({super.key, required this.cart, required this.controller});

  @override
  State<AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends State<AddressForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _provinceController = TextEditingController(text: "");
  final TextEditingController _cityController = TextEditingController(text: "");
  final TextEditingController _zipCodeController = TextEditingController(text: "");
  final TextEditingController _streetController = TextEditingController(text: "");
  final TextEditingController _numberController = TextEditingController(text: "");
  final TextEditingController _floorController = TextEditingController(text: "");
  final TextEditingController _doorController = TextEditingController(text: "");
  final TextEditingController _detailsController = TextEditingController(text: "");

  @override
  void initState() {
    widget.controller.callForward = submit;
    ClientContact.cache.then((ClientContact? clientContact) {
      if (clientContact != null) {
        Future.delayed(Duration.zero, () {
          if (mounted) {
            setState(() {
              _provinceController.text = clientContact.address?.province ?? '';
              _cityController.text = clientContact.address?.city ?? '';
              _zipCodeController.text = clientContact.address?.zipCode ?? '';
              _streetController.text = clientContact.address?.street ?? '';
              _numberController.text = clientContact.address?.number ?? '';
              _floorController.text = clientContact.address?.floor ?? '';
              _doorController.text = clientContact.address?.door ?? '';
              _detailsController.text = clientContact.address?.details ?? '';
            });
          }
        });
      }
    });
    super.initState();
  }

  bool submit() {
    if (_formKey.currentState!.validate()) {
      widget.cart.setAdress(Address(
        province: _provinceController.text,
        city: _cityController.text,
        zipCode: _zipCodeController.text,
        street: _streetController.text,
        number: _numberController.text,
        floor: _floorController.text,
        door: _doorController.text,
        details: _detailsController.text)
      );
      return true;
    }
    return false;
  }

  String? _provinceFieldValidator(String? value) {
     // 22 santa cruz de tenerife
    if (value?.isEmpty ?? true) {
      return 'Introduce la provincia';
    }
    return null;
  }

  String? _cityFieldValidator(String? value) {
    const maxNameLength = 50; // 44 Gargantilla del Lozoya y Pinilla de Buitrago
    if (value?.isEmpty ?? true) {
      return 'Introduce el nombre de la ciudad';
    } else if (value!.length > maxNameLength) {
      return 'Nombre demasiado largo';
    }
    return null;
  }

  String? _streetFieldValidator(String? value) {
    const maxNameLength = 50; // 44 Avenida de los Poblados del Real Sitio y Villa de Aranjuez
    if (value?.isEmpty ?? true) {
      return 'Introduce el nombre de la calle';
    } else if (value!.length > maxNameLength) {
      return 'Nombre demasiado largo';
    }
    return null;
  }

  String? _numberFieldValidator(String? value) {
    const maxNameLength = 6;
    if (value?.isEmpty ?? true) {
      return 'Introduce el número de la vivienda';
    } else if (value!.length > maxNameLength) {
      return 'Número demasiado largo';
    }
    return null;
  }

  String? _zipCodeFieldValidator(String? value) {
    const maxNameLength = 5;
    if (value?.isEmpty ?? true) {
      return 'Introduce el código postal';
    } else if (value!.length > maxNameLength) {
      return 'Código postal demasiado largo';
    } else if (value.length < maxNameLength) {
      return 'Código postal demasiado corto';
    } else if (
      double.tryParse(value.substring(0, 2)) == null
      || double.parse(value.substring(0, 2)) > 52
      || double.parse(value.substring(0, 2)) < 1
      ) {
      return 'Código postal inválido';
    } else if (['07', '35', '38', '51', '52'].contains(value.substring(0, 2))) {
      return 'Solo envíos a península';
    }
    return null;
  }

  String? _floorFieldValidator(String? value) {
    const maxNameLength = 6;
    if (value!.length > maxNameLength) {
      return 'Piso demasiado largo';
    }
    return null;
  }

  String? _doorFieldValidator(String? value) {
    const maxNameLength = 6;
    if (value!.length > maxNameLength) {
      return 'Puerta demasiado larga';
    }
    return null;
  }

  String? _detailsFieldValidator(String? value) {
    const maxNameLength = 100;
    if (value!.length > maxNameLength) {
      return 'Demasiados detalles';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    InputDecoration inputDecoration(String hintText) => InputDecoration(
      errorMaxLines: 4,
      border: const OutlineInputBorder(
        borderSide: BorderSide(width: 1.5, style: BorderStyle.none),
        borderRadius: BorderRadius.all(Radius.circular(15.0))
      ),
      labelText: hintText
    );

    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10, top: 10),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _streetController,
              validator: _streetFieldValidator,
              decoration: inputDecoration("Calle")
            ),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0, right: 4.0),
                    child: TextFormField(
                      controller: _numberController,
                      validator: _numberFieldValidator,
                      decoration: inputDecoration("Número")
                    )
                  )
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 4.0, right: 4.0),
                    child: TextFormField(
                      controller: _floorController,
                      validator: _floorFieldValidator,
                      decoration: inputDecoration("Piso")
                    )
                  )
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                    child: TextFormField(
                      controller: _doorController,
                      validator: _doorFieldValidator,
                      decoration: inputDecoration("Puerta")
                    )
                  )
                )
              ]
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: TextFormField(
                controller: _detailsController,
                validator: _detailsFieldValidator,
                decoration: inputDecoration("Otros detalles de la dirección")
              )
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: TextFormField(
                controller: _cityController,
                validator: _cityFieldValidator,
                decoration: inputDecoration("Ciudad")
              )
            ),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, right: 4.0),
                    child: TextFormField(
                      controller: _zipCodeController,
                      validator: _zipCodeFieldValidator,
                      decoration: inputDecoration("Código postal")
                    )
                  )
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 4.0),
                    child: TextFormField(
                      controller: _provinceController,
                      validator: _provinceFieldValidator,
                      decoration: inputDecoration("Provincia")
                    )
                  ),
                )
              ]
            )
          ]
        )
      )
    );
  }
}
