import 'package:dart_ipify/dart_ipify.dart';
import 'package:flameo/services/config_provider.dart';
import 'package:flameo/services/management_database.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Contact extends StatefulWidget {
  final ConfigProvider config;
  const Contact({super.key, required this.config});

  @override
  State<Contact> createState() => _ContactState();
}

class _ContactState extends State<Contact> {

  final GlobalKey<FormState> _formKey = GlobalKey();
  TextEditingController senderController = TextEditingController(text: '');
  TextEditingController messageController = TextEditingController(text: '');

  // Focus node to move between textfields
  FocusNode messageTextFieldFocusNode = FocusNode();

  void onPressedSendMessage() async {
    if (_formKey.currentState!.validate()) {
      if (
        await ManagementDatabaseService(config: widget.config).sendMessage(
          senderController.text,
          messageController.text,
          await Ipify.ipv4()
        )
      ) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mensaje enviado!')));
          setState(() {
            senderController.text = '';
            messageController.text = '';
          });
          Navigator.of(context).pop();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(
            'Ha ocurrido un error, por favor, usa la información de contacto mostrada arriba'
          )));
        }
      } 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: senderController,
            validator: (value) => (value?.trim().isEmpty ?? true) ? 'Introduce un email o teléfono' : null,
            onFieldSubmitted: (_) {
              FocusScope.of(context).requestFocus(messageTextFieldFocusNode);
            },
            decoration: const InputDecoration(
              filled: true,
              fillColor: Colors.white,
              errorMaxLines: 2,
              labelText: 'Email o teléfono',
              hintStyle: TextStyle(fontWeight: FontWeight.normal),
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
            )
          ),
          const SizedBox(height: 20),
          TextFormField(
            focusNode: messageTextFieldFocusNode,
            controller: messageController,
            maxLines: 10,
            decoration: const InputDecoration(
              filled: true,
              fillColor: Colors.white,
              errorMaxLines: 2,
              labelText: 'Mensaje',
              hintStyle: TextStyle(fontWeight: FontWeight.normal),
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
            )
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.primary),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  )
                )
              ),
              onPressed: onPressedSendMessage,
              child: const Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  'Enviar',
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.white
                  )
                )
              )
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            'Respondemos en menos de 24 h\nO mándanos un correo a:',
            style: TextStyle(fontSize: 15),
            textAlign: TextAlign.center
          ),
          InkWell(
            onTap: () => launchUrl(Uri.parse('mailto:info@flameoapp.com')),
            child: const Text(
              "info@flameoapp.com",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold
              )
            ),
          )
        ]
      )
    );
  }
}
