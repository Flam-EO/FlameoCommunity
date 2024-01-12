import 'package:flameo/master/master.dart';
import 'package:flameo/master/master_eye.dart';
import 'package:flameo/models/client_user.dart';
import 'package:flameo/models/userproduct.dart';
import 'package:flameo/services/auth.dart';
import 'package:flameo/services/auth_database.dart';
import 'package:flameo/services/config_provider.dart';
import 'package:flameo/services/database.dart';
import 'package:flameo/services/management_database.dart';
import 'package:flameo/shared/loading.dart';
import 'package:flameo/views/home/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CompanyLoader extends StatefulWidget {
  final ClientUser user;
  final String? route;
  final ConfigProvider config;

  const CompanyLoader({super.key, required this.user, this.route, required this.config});

  @override
  State<CompanyLoader> createState() => _CompanyLoaderState();
}

class _CompanyLoaderState extends State<CompanyLoader> {

  @override
  void initState() {
    //if (isMaster(widget.user)) {
    //  Future.delayed(Duration.zero, () => 
    //    masterPreferences(context, widget.config).then((value) => setState(() {
    //      widget.user.preferences = value;
    //    }))
    //  ); 
    //}
    super.initState();
  }

  bool preferencesTimeout = false;

  @override
  Widget build(BuildContext context) {
    
    if (!isMaster(widget.user)) {
      PreferencesWrapper? preferencesWrapper = Provider.of<PreferencesWrapper?>(context);
      if (preferencesWrapper?.error == PreferenceError.preferencesNotFound) {
        if (!preferencesTimeout) {
          Future.delayed(const Duration(seconds: 10), () {
            if (
              mounted && preferencesWrapper?.error == PreferenceError.preferencesNotFound
            ) setState(() => preferencesTimeout = true);
          });
        } else {
          return Scaffold(
            body: Center(
              child: Column(
                children: [
                  const Text('Este usuario pertenece a otro entorno, accede al entorno correcto'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: AuthService(config: widget.config).signOut,
                    child: const Text('Salir')
                  )
                ]
              )
            )
          );
        }
      }
      widget.user.preferences = preferencesWrapper?.preferences;
    }

    return isMaster(widget.user) ? StreamProvider<List<CompanyPreferences>>.value(
        initialData: const [],
        value: ManagementDatabaseService(config: widget.config).streamCompanies,
        child: MasterEye(config: widget.config)
    ) : widget.user.preferences == null ? const Loading() : StreamProvider<CompanyPreferences?>.value(
      initialData: null,
      value: AuthDatabaseService(companyID: widget.user.preferences!.companyID, config: widget.config).companyPreferences,
      child: StreamProvider<List<UserProduct>>.value(
        initialData: const [],
        value: DatabaseService(companyID: widget.user.preferences!.companyID, config: widget.config).userProducts,
        child: Home(user: widget.user, route: widget.route, config: widget.config)
      )
    );
  }
}
