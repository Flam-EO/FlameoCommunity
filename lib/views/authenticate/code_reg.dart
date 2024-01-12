import 'package:flameo/models/code.dart';
import 'package:flameo/services/auth_database.dart';
import 'package:flameo/services/config_provider.dart';
import 'package:flameo/shared/loading.dart';
import 'package:flameo/shared/utils.dart';
import 'package:flutter/material.dart';

class CodeReg extends StatefulWidget {

  final Function toggleView;
  final ConfigProvider config;
  const CodeReg({required this.toggleView, Key? key, required this.config}) : super(key: key);

  @override
  State<CodeReg> createState() => _CodeRegState();
}

class _CodeRegState extends State<CodeReg> {

  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  late AuthDatabaseService database = AuthDatabaseService(config: widget.config);
  String error = '';
  final TextEditingController codeController = TextEditingController(text: '');
  DateTime _lastSnackbarTimestamp = DateTime.now();

  void onPressedCheckCodeButton() async {
    setState(() => error = '');
    if(_formKey.currentState!.validate()) {
      setState(() {loading = true;});
      dynamic result = await database.getRegistrationCode(codeController.text.trim());
      if(result is RegistrationCodeError) {
        setState(() {
          error = result == RegistrationCodeError.notValid ?
            'El código no es válido'
          : result == RegistrationCodeError.expirated ?
            'El código ha expirado'
          : 'Error desconocido';
          loading = false;
          if (elapsedTimeChecker(_lastSnackbarTimestamp, 2000)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Theme.of(context).colorScheme.error,
                content: Text(error, textAlign: TextAlign.center),
                duration: const Duration(seconds: 2),
              )
            );
            _lastSnackbarTimestamp = DateTime.now();
          }
        });
      } else {
        setState(() {
          codeController.text = '';
        });
        widget.toggleView(LoginScreen.register, result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading ? const Loading() : Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: codeController,
            validator: (value) => (value?.trim().isEmpty ?? true) ? 'Introduce un código' : null,
            decoration: const InputDecoration(
              hintText: 'Código de registro',
              labelText: 'Código de registro',
              border:  OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(18)))
            )
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.onPrimaryContainer),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                )
              )
            ),
            onPressed: onPressedCheckCodeButton,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text('Enviar código',
                style: TextStyle(
                  fontSize: 17,
                  color: Theme.of(context).colorScheme.onTertiary
                )
              )
            )
          ),
          const SizedBox(height: 20)
        ]
      )
    );
  }
}