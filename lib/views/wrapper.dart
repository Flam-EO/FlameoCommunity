import 'package:flameo/models/client_user.dart';
// ignore: unused_import
import 'package:flameo/services/auth.dart';

import 'package:flameo/services/auth_database.dart';
import 'package:flameo/services/config_provider.dart';
import 'package:flameo/views/authenticate/authenticate.dart';
import 'package:flameo/views/home/company_loader.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {

  final String? route;
  final ConfigProvider config;

  const Wrapper({super.key, this.route, required this.config});

  @override
  Widget build(BuildContext context) {
    final ClientUser? user = Provider.of<ClientUser?>(context);
    return user == null ? Authenticate(config: config, route: route) : StreamProvider<PreferencesWrapper?>.value(
      initialData: null,
      value: AuthDatabaseService(uid: user.uid, config: config).userPreferences,
      child: CompanyLoader(user: user, route: route, config: config)
    );
  }
}
