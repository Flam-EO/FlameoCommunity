import 'package:flameo/models/code.dart';
import 'package:flameo/services/auth.dart';
import 'package:flameo/services/config_provider.dart';
import 'package:flameo/shared/loading.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {

  final ConfigProvider config;
  final Code? code;

  const Register({required this.code, Key? key, required this.config}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  late final AuthService _auth = AuthService(config: widget.config);
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  bool passwordVisibility = false;
  bool verifyPasswordVisibility = false;

  // Focus nodes to move through the fields just pressing enter
  FocusNode companyNameTextFieldFocusNode = FocusNode();
  FocusNode firstPasswordTextFieldFocusNode = FocusNode();
  FocusNode secondPasswordTextFieldFocusNode = FocusNode();

  final RegExp regExp = RegExp(r'^.{6,}$');

  String error = '';

  TextEditingController emailController = TextEditingController(text: '');
  TextEditingController passwordController = TextEditingController(text: '');
  TextEditingController verifyPasswordController = TextEditingController(text: '');
  TextEditingController nameController = TextEditingController(text: '');

  void onPressedRegisterButton() async {
    setState(() => error = '');
    if (_formKey.currentState!.validate()) {
      setState(() => loading = true);

      dynamic result = await _auth.registerWithEmailAndPassword(
        emailController.text,
        passwordController.text,
        nameController.text,
        widget.code
      );

      if (result is String) {
        setState(() {
          error = result;
          loading = false;
        });
      } else {
        widget.code?.delete(widget.config);
        emailController.text = '';
        passwordController.text = '';
        verifyPasswordController.text = '';
        nameController.text = '';
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return loading ? const Loading() : Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            controller: emailController,
            validator: (value) => (value?.trim().isEmpty ?? true) ? 'Introduce tu email' : null,
            onFieldSubmitted: (_) {
              FocusScope.of(context).requestFocus(companyNameTextFieldFocusNode);
            },
            decoration: const InputDecoration(
              filled: true,
              fillColor: Colors.white,
              labelText: 'Email', 
              border:  OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)))
            )
          ),
          const SizedBox(height: 20),
          TextFormField(
            focusNode: companyNameTextFieldFocusNode,
            controller: nameController,
            validator: (value) => (value?.trim().isEmpty ?? true) ? 'Introduce un nombre válido' : null,
            onFieldSubmitted: (_) {
              FocusScope.of(context).requestFocus(firstPasswordTextFieldFocusNode);
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              labelText: widget.code?.companyID == null ? 'Nombre de tu empresa/proyecto' : 'Nombre',
              border:  const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)))
            )
          ),
          const SizedBox(height: 20),
          TextFormField(
            focusNode: firstPasswordTextFieldFocusNode,
            controller: passwordController,
            validator: (value) => (value?.isEmpty ?? true) ? 'Introduce una contraseña'
              : !regExp.hasMatch(value ?? '') ? 'La contraseña no es suficientemente segura'
              : verifyPasswordController.text.isNotEmpty && value != verifyPasswordController.text ? 'Las contraseñas no coinciden'
              : null,
            onFieldSubmitted: (_) {
              FocusScope.of(context).requestFocus(secondPasswordTextFieldFocusNode);
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              labelText: 'Contraseña',
              border:  const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
              suffixIcon: IconButton(
                icon: Icon(passwordVisibility ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => passwordVisibility = !passwordVisibility)
              )
            ),
            obscureText: !passwordVisibility
          ),
          const SizedBox(height: 20),
          TextFormField(
            focusNode: secondPasswordTextFieldFocusNode,
            controller: verifyPasswordController,
            validator: (value) => (value?.isEmpty ?? true) ? 'Repite la contraseña'
              : passwordController.text.isNotEmpty && value != passwordController.text ? 'Las contraseñas no coinciden'
              : null,
            onFieldSubmitted: (_) => onPressedRegisterButton(),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              labelText: 'Repite la contraseña',
              border:  const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
              suffixIcon: IconButton(
                icon: Icon(verifyPasswordVisibility ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => verifyPasswordVisibility = !verifyPasswordVisibility)
              )
            ),
            obscureText: !verifyPasswordVisibility
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.primary),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)
                    )
                  )
                ),
                onPressed: onPressedRegisterButton,
                child: const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    'Registro',
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.white
                    )
                  )
                )
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            error,
            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)
          )
        ]
      )
    );
  }
}
