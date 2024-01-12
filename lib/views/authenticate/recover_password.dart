import 'package:flameo/services/auth.dart';
import 'package:flameo/services/config_provider.dart';
import 'package:flameo/shared/utils.dart';
import 'package:flutter/material.dart';

class RecoverPassword extends StatefulWidget {

  final ConfigProvider config;
  final String email;
  final String? route;
  final void Function() goBack;
  
  const RecoverPassword({super.key, required this.config, required this.email, required this.goBack, required this.route});

  @override
  State<RecoverPassword> createState() => _RecoverPasswordState();
}

class _RecoverPasswordState extends State<RecoverPassword> {

  late final AuthService _auth = AuthService(config: widget.config);

  final GlobalKey<FormState> _formKey = GlobalKey();
  late TextEditingController emailController = TextEditingController(text: widget.email);
  TextEditingController passwordController = TextEditingController(text: '');
  TextEditingController verifyPasswordController = TextEditingController(text: '');

  FocusNode secondPasswordTextFieldFocusNode = FocusNode();

  final RegExp regExp = RegExp(r'^.{6,}$');
  String error = '';

  String? oobCode;
  @override
  void initState() {
    if (widget.route != null) {
      Uri url = Uri.parse("https://${widget.config.get('base_link')}${widget.route}");
      oobCode = url.queryParameters['oobCode'];
    }
    super.initState();
  }

  DateTime lastSnackbarTimestamp = DateTime.now();

  void onSubmitEmail() {
    if (_formKey.currentState!.validate()) {
      AuthService(config: widget.config).recoverPassword(emailController.text);
      if (elapsedTimeChecker(lastSnackbarTimestamp, 2000)) {
        lastSnackbarTimestamp = DateTime.now();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.error,
            content: const Text(
              'Si tu email está registrado te llegará un correo!',
              textAlign: TextAlign.center
            ),
            duration: const Duration(seconds: 2)
          )
        );
        widget.goBack();
      }
    }
  }

  
  bool loading = false;
  void onSubmitPassword() async {
    setState(() => error = '');
    if (_formKey.currentState!.validate()) {
      setState(() => loading = true);

      dynamic result = await _auth.resetPassword(oobCode!, passwordController.text);

      if (result is String) {
        setState(() {
          error = result;
          loading = false;
          if (elapsedTimeChecker(lastSnackbarTimestamp, 2000) && mounted) {
            lastSnackbarTimestamp = DateTime.now();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Theme.of(context).colorScheme.error,
                content: Text(
                  error,
                  textAlign: TextAlign.center
                ),
                duration: const Duration(seconds: 2)
              )
            );
            widget.goBack();
          }
        });
      } else {
        emailController.text = '';
        passwordController.text = '';
        verifyPasswordController.text = '';
        if (elapsedTimeChecker(lastSnackbarTimestamp, 2000) && mounted) {
            lastSnackbarTimestamp = DateTime.now();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Theme.of(context).colorScheme.error,
                content: const Text(
                  'Contraseña modificada, inicia sesión con tu nueva contraseña',
                  textAlign: TextAlign.center
                ),
                duration: const Duration(seconds: 2)
              )
            );
            widget.goBack();
          }
        widget.goBack();
      }
    }
  }

  bool passwordVisibility = false;
  bool verifyPasswordVisibility = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton.icon(
              onPressed: widget.goBack,
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white),
              label: const Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  "Volver a acceso",
                  style: TextStyle(color: Colors.white)
                )
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.primary),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)
                  )
                )
              )
            )
          ),
          const SizedBox(height: 20),
          if (oobCode == null) TextFormField(
            controller: emailController,
            validator: (value) => (value?.trim().isEmpty ?? true) ? 'Introduce tu email' : null,
            decoration: const InputDecoration(
              filled: true,
              fillColor: Colors.white,
              errorMaxLines: 2,
              labelText: 'Email',
              hintStyle: TextStyle(fontWeight: FontWeight.normal),
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
            )
          ),
          if (oobCode != null) TextFormField(
            controller: passwordController,
            validator: (value) => (value?.isEmpty ?? true) ? 'Introduce una nueva contraseña'
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
          if (oobCode != null) TextFormField(
            focusNode: secondPasswordTextFieldFocusNode,
            controller: verifyPasswordController,
            validator: (value) => (value?.isEmpty ?? true) ? 'Repite la contraseña'
              : passwordController.text.isNotEmpty && value != passwordController.text ? 'Las contraseñas no coinciden'
              : null,
            onFieldSubmitted: (_) => onSubmitPassword(),
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
          if (oobCode != null) const SizedBox(height: 20),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.primary),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                )
              )
            ),
            onPressed: oobCode == null ? onSubmitEmail : onSubmitPassword,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                oobCode == null ? 'Solicitar cambio de contraseña' : 'Cambiar contraseña',
                style: const TextStyle(
                  fontSize: 17,
                  color: Colors.white
                )
              )
            )
          )
        ]
      )
    );
  }
}