import 'package:email_validator/email_validator.dart';
import 'package:flameo/models/cart_models/cart.dart';
import 'package:flameo/models/client_contact.dart';
import 'package:flameo/shared/platform.dart';
import 'package:flameo/shared/utils.dart';
import 'package:flutter/material.dart';

class ContactCollector extends StatefulWidget {
  final Cart cart;
  final VoidCallback contactDone;
  final ChildController controller;
  const ContactCollector({super.key, required this.cart, required this.contactDone, required this.controller});

  @override
  State<ContactCollector> createState() => _ContactCollectorState();
}

class _ContactCollectorState extends State<ContactCollector> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController(text: "");
  final TextEditingController _surNameController = TextEditingController(text: "");
  final TextEditingController _emailController = TextEditingController(text: "");
  final TextEditingController _phoneController = TextEditingController(text: "");

  @override
  void initState() {
    widget.controller.callForward = submit;
    ClientContact.cache.then((ClientContact? clientContact) {
      if (clientContact != null) {
        Future.delayed(Duration.zero, () {
          if (mounted) {
            setState(() {
              _nameController.text = clientContact.name;
              _surNameController.text = clientContact.surname;
              _emailController.text = clientContact.email;
              _phoneController.text = clientContact.phoneNumber;
            });
          }
        });
      }
    });
    super.initState();
  }

  bool submit() {
    if (_formKey.currentState!.validate()) {
      ClientContact contact = ClientContact(
        name: _nameController.text,
        surname: _surNameController.text,
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim()
      );
      widget.cart.setClientContact(contact);
      widget.contactDone();
      return true;
    }
    return false;
  }

  String? _nameFieldValidator(String? value) {
    const maxNameLength = 30; // Maria Inmaculada Concepción
    if (value?.isEmpty ?? true) {
      return 'Introduce un nombre';
    } else if (value!.length > maxNameLength) {
      return 'Nombre demasiado largo, el máximo número de caracteres es $maxNameLength';
    }
    return null;
  }

  String? _surNameFieldValidator(String? value) {
    const maxNameLength = 50; // Arnaldo Garroguerricaechevarria Garroguerricaechevarria
    if (value?.isEmpty ?? true) {
      return 'Introduce tus apellidos';
    } else if (value!.length > maxNameLength) {
      return 'Apellidos demasiado largos, el máximo número de caracteres es $maxNameLength';
    }
    return null;
  }

  String? _emailFieldValidator(String? value) {
    const maxNameLength = 256;
    if (value?.isEmpty ?? true) {
      return 'Introduce un email';
    } else if (!EmailValidator.validate(value!.trim())) {
      return 'Introduce un email válido';
    } else if (value.trim().length > maxNameLength) {
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

  @override
  Widget build(BuildContext context) {
    ScreenSize screensize = ScreenSize(context);

    InputDecoration inputDecoration(String hintText) {
      return InputDecoration(
        errorMaxLines: 4,
        border: const OutlineInputBorder(
          borderSide: BorderSide(width: 1.5, style: BorderStyle.none),
          borderRadius: BorderRadius.all(Radius.circular(15.0))
        ),
        labelText: hintText
      );
    }

    Widget thinLayout =  Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10, top: 10),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              validator: _nameFieldValidator,
              decoration: inputDecoration("Nombre"),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: TextFormField(
                controller: _surNameController,
                validator: _surNameFieldValidator,
                decoration: inputDecoration("Apellidos"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: TextFormField(
                controller: _emailController,
                validator: _emailFieldValidator,
                decoration: inputDecoration("Email"),
              ),
            ),
            TextFormField(
              controller: _phoneController,
              validator: _phoneFieldValidator,
              decoration: inputDecoration("Número de teléfono"),
            ),
            SizedBox(
              width: screensize.width * 0.8,
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 10),
                child: TextButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.tertiary),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ))
                  ),
                  onPressed: submit,
                  child: const Text(
                    'Método de envío',
                    style: TextStyle(color: Colors.white),
                  )
                )
              )
            )
          ]
        )
      )
    );

    Widget rightSidecoloring = Container(
      width: screensize.width * 0.3,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [
            Theme.of(context).colorScheme.secondary,
            Theme.of(context).colorScheme.secondary,
          ]
        )
      )
    );

    Widget leftSidecoloring = Container(
      width: screensize.width * 0.3,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Theme.of(context).colorScheme.secondary,
            Theme.of(context).colorScheme.secondary,
          ]
        )
      )
    );

    Widget wideLayout = Row(
      children: [leftSidecoloring, Expanded(child: thinLayout), rightSidecoloring],
    );

    return screensize.aspectRatio < 1.2 ? thinLayout : wideLayout;
  }
}
