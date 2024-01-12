import 'dart:html';
import 'package:flameo/models/client_user.dart';
import 'package:flameo/services/config_provider.dart';
import 'package:flameo/shared/loading.dart';
import 'package:flameo/views/authenticate/company_data/company_data.dart';
import 'package:flameo/views/home/deleted_account.dart';
import 'package:flameo/views/home/micro/micro.dart';
import 'package:flameo/views/home/tutorial/tutorial.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  final ConfigProvider config;
  final ClientUser user;
  final String? route;

  const Home({required this.user, super.key, this.route, required this.config});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  void dashboardUpdater(f) => setState(f);

  late String? route = widget.route;

  void goToDrawer(String pushRoute) => setState(() {
    window.history.pushState(null, 'route', '/$pushRoute');
    route = '/$pushRoute';
  });

  @override
  Widget build(BuildContext context) {

    CompanyPreferences? companyPreferences = Provider.of<CompanyPreferences?>(context);
    widget.config.logedVisitor = widget.user.uid;

    //Get.put(companyPreferences);

    return Scaffold(
      body: companyPreferences == null ? const Loading()
      : companyPreferences.isDeleted ? DeletedAccount(companyPreferences: companyPreferences, configProvider: widget.config)
      : widget.user.preferences?.tutorialCompleted ?? false || true ? //TODO Fut tutorial anulado 
        companyPreferences.dataCompleted ? Micro(user: widget.user, route: widget.route, companyPreferences: companyPreferences, config: widget.config)
        : CompanyData(companyPreferences: companyPreferences, config: widget.config)
      : Stack(
        children: [
          Micro(key: Key(route ?? ''), user: widget.user, route: route, companyPreferences: companyPreferences, config: widget.config),
          Tutorial(user: widget.user, goToDrawer: goToDrawer, config: widget.config)
        ]
      )
    );
  }
}
