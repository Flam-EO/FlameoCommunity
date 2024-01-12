import 'package:flameo/models/client_user.dart';
import 'package:flameo/models/panel.dart';
import 'package:flameo/models/userproduct.dart';
import 'package:flameo/services/auth_database.dart';
import 'package:flameo/services/config_provider.dart';
import 'package:flameo/services/database.dart';
import 'package:flameo/shared/loading.dart';
import 'package:flameo/shared/utils.dart';
import 'package:flameo/views/home/micro/price_panel/external/external_panel_dashboard.dart';
import 'package:flameo/views/home/micro/price_panel/external/panel_not_approved.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExternalPanelLoader extends StatefulWidget {

  final String panelName;
  final LinkOpener linkOpener;
  final ConfigProvider config;
  final String? scrollPosition;
  
  const ExternalPanelLoader({required this.panelName, super.key, required this.linkOpener, required this.config, this.scrollPosition});

  @override
  State<ExternalPanelLoader> createState() => _ExternalPanelLoaderState();
}

class _ExternalPanelLoaderState extends State<ExternalPanelLoader> {

  @override
  Widget build(BuildContext context) {

    Panel? panel = Provider.of<Panel?>(context);

    return panel == null
    ? const Center(child: Loading())
    : panel.error == PanelError.notFound
    ? Scaffold(
      body: Center(child: Text('Este panel no existe: ${widget.panelName}'))
    )
    : panel.isDeleted == true
    ? const Scaffold(
      body: Center(child: Text('Este panel ha sido eliminado'))
    )
    : panel.isPaused ?? false
    ? const Scaffold(
      body: Center(child: Text('Este panel está desactivado temporalmente, inténtalo de nuevo más tarde'))
    )
    : !(panel.mastersApprove ?? false)
    ? PanelNotApproved(companyName: panel.companyName!)
    : StreamProvider<CompanyPreferences?>.value(
      initialData: null,
      value: AuthDatabaseService(companyID: panel.companyID, config: widget.config).companyPreferences,
      child: StreamProvider<List<UserProduct>?>.value(
        initialData: null,
        value: DatabaseService(companyID: panel.companyID, config: widget.config).userProducts,
        child: ExternalPanelDashboard(
          companyID: panel.companyID!,
          isExternal: true,
          linkOpener: widget.linkOpener,
          config: widget.config,
          scrollPosition: widget.scrollPosition
        )
      )
    );
  }
}
