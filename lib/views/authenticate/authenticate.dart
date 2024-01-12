
import 'dart:math';

import 'package:flameo/services/config_provider.dart';
import 'package:flameo/shared/platform.dart';
import 'package:flameo/models/code.dart';
import 'package:flameo/shared/utils.dart';
import 'package:flameo/views/authenticate/background.dart';
import 'package:flameo/views/authenticate/code_reg.dart';
import 'package:flameo/views/authenticate/external_panel_browser.dart';
import 'package:flameo/views/authenticate/recover_password.dart';
import 'package:flutter/material.dart';
import 'package:flameo/views/authenticate/contact.dart';
import 'package:material_segmented_control/material_segmented_control.dart';
import 'package:flameo/views/authenticate/login_view.dart';
import 'package:flameo/views/authenticate/register_view.dart';

class Authenticate extends StatefulWidget {

  final ConfigProvider config;
  final String? route;  // True to navigate directly to register, false to navigate to login
  const Authenticate({super.key, required this.config, required this.route});

  @override
  State<Authenticate> createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {

  Code? toggleResult;
  late int _loginSelection = widget.route == '/registro' ? 1 : 0;
  late LoginScreen screen = widget.route == '/registro' ? LoginScreen.register
  : (widget.route?.startsWith('/recoverPassword') ?? false) ? LoginScreen.recoverPassword
  : LoginScreen.login;
  bool loginLoadingFlag = false;

  void setLoginLoadingFlag(bool flag) {
    setState(() => loginLoadingFlag = flag); 
  }

  void toggleView(LoginScreen which, [Code? result]) {
    setState(() {
      screen = which;
      toggleResult = result;
    });
  }

  String typedEmail = '';
  void openRecoverPassword(String email) => setState(() {
    screen = LoginScreen.recoverPassword;
    typedEmail = email;
    toggleResult = null;
  });

  Map<int, Widget> getSegmentedOptions() => {
    0: segmentedOption(context, 'Acceso', _loginSelection, 0), 
    1: segmentedOption(context, 'Registro', _loginSelection, 1), 
  };

  Map<int, LoginScreen> screenOptions = {
    0: LoginScreen.login,
    1: LoginScreen.register, //LoginScreen.codereg,
    2: LoginScreen.contact,
    3: LoginScreen.recoverPassword
  };

  late Widget contactButton = ElevatedButton.icon(
    icon: const Icon(
      Icons.email,
      color: Colors.white),
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.primary),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0)
        )
      )
    ),
    onPressed: () => setState(() {
      screen = screenOptions[2]!;
    }),
    label: const Padding(
      padding: EdgeInsets.all(10.0),
      child: Text(
        'Contáctanos',
        style: TextStyle(
          fontSize: 17,
          color: Colors.white
        )
      )
    )
  );

  /// Function to return the different login screens depending on the value of the screen selected 
  /// in the segmented control.
  Widget _getScreenWidget(LoginScreen screen) {
    switch (screen) {

      case LoginScreen.login:
        widget.config.anonymousLog(LoggerAction.openLogIn);
        return Column(
          children: [
            Login(config: widget.config, loginIsLoading: setLoginLoadingFlag, openRecoverPassword: openRecoverPassword),
            const SizedBox(height: 20),
            if (!loginLoadingFlag) ExternalPanelBrowser(config: widget.config),
            if (!loginLoadingFlag && mounted) Align(
              alignment: Alignment.center,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  contactButton
                ]
              )
            )
          ]
        );

      case LoginScreen.codereg:
        widget.config.anonymousLog(LoggerAction.openCodeReg);
        return CodeReg(toggleView: toggleView, config: widget.config);

      case LoginScreen.register:
        widget.config.anonymousLog(LoggerAction.openSignIn);
        return Register(code: toggleResult, config: widget.config);

      case LoginScreen.contact:
        widget.config.anonymousLog(LoggerAction.openContact);
        return Contact(config: widget.config);

      case LoginScreen.recoverPassword:
        widget.config.anonymousLog(LoggerAction.openRecoverPassword);
        return RecoverPassword(
          config: widget.config,
          route: widget.route,
          email: typedEmail,
          goBack: () => setState(() {
            this.screen = screenOptions[0]!;
          })
        );
    }
  }

  late Widget titles = Container(
    color: Theme.of(context).colorScheme.primary,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Flameo",
            style: TextStyle(
              fontSize: 58,
              color: Theme.of(context).colorScheme.onTertiary,
            )
          ),
          Text(
            "App",
            style: TextStyle(
              fontSize: 58,
              color: Theme.of(context).colorScheme.onTertiary,
              fontStyle: FontStyle.italic
            )
          )
        ]
      )
    ),
  );

  @override
  Widget build(BuildContext context) {

    ScreenSize screensize = ScreenSize(context);

    return Scaffold(
      body: Stack(
        children: [
          const Background(),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40, top: 120),
              child: Align(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Container(
                      width: min(500, screensize.width * 0.95),
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onSecondary,
                        borderRadius: const BorderRadius.all(Radius.circular(30.0))
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          if (screen != screenOptions[2]!)
                            MaterialSegmentedControl(
                              children: getSegmentedOptions(),
                              selectionIndex: _loginSelection,
                              borderColor: Theme.of(context).colorScheme.primary,
                              selectedColor: Theme.of(context).colorScheme.primary,
                              unselectedColor: Colors.white,
                              borderRadius: 6.0,
                              disabledChildren: null,
                              verticalOffset: 10.0,
                              onSegmentChosen: (index) {
                                setState(() {
                                  _loginSelection = index;
                                  screen = screenOptions[index]!;
                                });
                              },
                            ),
                          if (screen == screenOptions[2]!)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: ElevatedButton.icon(
                                onPressed: () => setState(() {
                                  screen = screenOptions[0]!;
                                }),
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
                                ),
                              ),
                            ),
                          const SizedBox(height: 50),
                          _getScreenWidget(screen)
                        ]
                      )
                    )
                  ]
                )
              )
            )
          ),
          titles
        ]
      )
    );
  }
}