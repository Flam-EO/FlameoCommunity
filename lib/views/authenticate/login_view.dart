import 'package:flameo/services/auth.dart';
import 'package:flameo/services/config_provider.dart';
import 'package:flameo/shared/loading.dart';
import 'package:flameo/shared/utils.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {

  final ConfigProvider config;
  final void Function(bool) loginIsLoading;
  final Function openRecoverPassword;

  const Login({ Key? key, required this.config, required this.loginIsLoading, required this.openRecoverPassword }) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with WidgetsBindingObserver {

  late final AuthService _auth = AuthService(config: widget.config);
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  bool passwordVisibility = false;
  String error = '';

  TextEditingController emailController = TextEditingController(text: '');
  TextEditingController passwordController = TextEditingController(text: '');

  // Focus nodes for moving between the textfields in the login when enter is pressed
  FocusNode passwordTextFieldFocusNode = FocusNode();

  DateTime lastSnackbarTimestamp = DateTime.now();
  void onPressedSignInButton() async {
    setState(() => error = '');
    if(_formKey.currentState!.validate()) {
      setState(() {
        loading = true;
        widget.loginIsLoading(true);
      });
      dynamic result = await _auth.signInWithEmailAndPassword(emailController.text, passwordController.text);
      if(result is String) {
        setState(() {
          error = result;
          loading = false;
          widget.loginIsLoading(false);
          if (elapsedTimeChecker(lastSnackbarTimestamp, 2000)) {
            lastSnackbarTimestamp = DateTime.now();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Theme.of(context).colorScheme.error,
                content: Text(error, textAlign: TextAlign.center),
                duration: const Duration(seconds: 2)
              )
            );
          }
        });
      } else {
        setState(() {
          emailController.text = '';
          passwordController.text = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading ? const Loading() : Form(
      key: _formKey,
      child: AutofillGroup(
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              validator: (value) => (value?.trim().isEmpty ?? true) ? 'Introduce tu email' : null,
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(passwordTextFieldFocusNode);
              },
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
                labelText: 'Email',
                hintStyle: TextStyle(
                  fontWeight: FontWeight.normal,
                  color: Colors.white),
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)))
              )
            ),
            const SizedBox(height: 20),
            TextFormField(
              focusNode: passwordTextFieldFocusNode,
              controller: passwordController,
              autofillHints: const [AutofillHints.password],
              validator: (value) => (value?.trim().isEmpty ?? true) ? 'Introduce tu contraseña' : null,
              onFieldSubmitted: (_) => onPressedSignInButton(),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                labelText: 'Contraseña',
                hintStyle: const TextStyle(fontWeight: FontWeight.normal),
                border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                suffixIcon: IconButton(
                  icon: Icon(passwordVisibility ? Icons.visibility_off : Icons.visibility),
                  onPressed: (() {
                    setState(() => passwordVisibility = !passwordVisibility);
                  })
                )
              ),
              obscureText: !passwordVisibility
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => widget.openRecoverPassword(emailController.text),
              child: const Text('He olvidado mi contraseña')
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.primary),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)
                    )
                  )
                ),
                onPressed: onPressedSignInButton,
                child: const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    'Acceder',
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.white
                    )
                  )
                )
              ),
            )
          ]
        ),
      )
    );
  }
}