import 'dart:html';
import 'dart:math';

import 'package:dart_ipify/dart_ipify.dart';
import 'package:flameo/models/client_user.dart';
import 'package:flameo/services/auth.dart';
import 'package:flameo/services/config_provider.dart';
import 'package:flameo/services/management_database.dart';
import 'package:flameo/shared/loading.dart';
import 'package:flameo/shared/platform.dart';
import 'package:flameo/views/home/micro/account/danger_zone.dart';
import 'package:flameo/views/home/micro/account/landscape_image.dart';
import 'package:flameo/views/home/micro/account/settings_form.dart';
import 'package:flutter/material.dart';

class AccountSettings extends StatefulWidget {

  final ConfigProvider config;
  final CompanyPreferences companyPreferences;

  const AccountSettings({super.key, required this.config, required this.companyPreferences});

  @override
  State<AccountSettings> createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {

  void logOut() async {
    bool logOut = await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(builder: (builderContext, setDialogState) => AlertDialog(
          title: const Text(
            'Cerrar sesión',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15)
          ),
          backgroundColor: Theme.of(context).colorScheme.onSecondary,
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  child: Text('Cancelar', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: Text('OK', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                  onPressed: () {
                    AuthService(config: widget.config).signOut();
                    Navigator.of(builderContext).pop(true);
                  }
                )
              ]
            )
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0) // Personaliza el radio de borde
          )
        ));
      }
    );
    if (logOut) {
      if (mounted) Navigator.pop(context);
    }
  }

  bool registering = false;
  void registerStripe() async {
    setState(() => registering = true);
    String? result = await widget.companyPreferences.registerConnectedAccount(widget.config);
    if (result != null) {
      window.open(result, '_self');
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ha ocurrido un error, contacta con el equipo de Flameo'),
            backgroundColor: Colors.red
          )
        );
      }
    }
  }

  bool temporaryRequested = false;
  void requestSubdomain() async {
    widget.companyPreferences.updateFields({'subdomainRequested': true}, widget.config);
    ManagementDatabaseService(config: widget.config).sendMessage(
      'system',
      'Company ${widget.companyPreferences.companyID} (${widget.companyPreferences.companyName} /${widget.companyPreferences.panel.panelLink}) has requested a subdomain.',
      await Ipify.ipv4()
    );
    setState(() => temporaryRequested = true);
  }

  @override
  Widget build(BuildContext context) {

    ScreenSize screenSize = ScreenSize(context);

    Widget accountStatus = Column(
      children: [
        Row(
          children: [
            Icon(
              Icons.circle,
              color: widget.companyPreferences.mastersApprove ? Colors.green : Colors.red
            ),
            Text(
              widget.companyPreferences.mastersApprove ? 'Aprobada por Flameo' : 'Pendiente de aprobación'
            )
          ]
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Icon(
              Icons.circle,
              color: widget.companyPreferences.stripeEnabled ? Colors.green : Colors.red
            ),
            Text(
              widget.companyPreferences.stripeEnabled ? 'Registrada en Stripe' : 'Pendiente de registro en Stripe'
            ),
            const SizedBox(width: 10),
            if (!widget.companyPreferences.stripeEnabled && !registering) ElevatedButton(
              onPressed: registerStripe,
              child: const Text('Registrar ahora')
            ),
            if (registering) const Loading()
          ]
        ),
        // const SizedBox(height: 5),
        // Row(
        //   children: [
        //     Icon(
        //       Icons.circle,
        //       color: widget.companyPreferences.subdomain != null ? Colors.green : Colors.orange
        //     ),
        //     Text(
        //       widget.companyPreferences.subdomain != null ? 'Subdominio activo: ${widget.companyPreferences.subdomain}' : 'Sin subdominio propio'
        //     ),
        //     const SizedBox(width: 10),
        //     if (widget.companyPreferences.subdomain == null) ElevatedButton(
        //       onPressed: !widget.companyPreferences.subdomainRequested && !temporaryRequested ? requestSubdomain : null,
        //       child: Text(!widget.companyPreferences.subdomainRequested && !temporaryRequested ? 'Solicitar subdominio' : 'Subdominio solicitado')
        //     ),
        //     if (registering) const Loading()
        //   ]
        // )
      ]
    );
  
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Mi cuenta', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          )
        )
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: 10,
              horizontal: screenSize.aspectRatio > 1.2 ? max(screenSize.width - 700, 5) / 2 : 5,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LandscapeImage(companyPreferences: widget.companyPreferences, config: widget.config),
                const SizedBox(height: 10),
                SelectableText('Id de Flameo: ${widget.companyPreferences.companyID}', style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 20),
                SettingsForm(config: widget.config, companyPreferences: widget.companyPreferences),
                const SizedBox(height: 20),
                const Row(children: [Text('Estado de la cuenta'), SizedBox(width: 10), Expanded(child: Divider())]),
                const SizedBox(height: 20),
                accountStatus,
                const SizedBox(height: 20),
                if (widget.companyPreferences.stripeEnabled ) Text("Comisión FlameoApp:   ${widget.companyPreferences.feeRate * 100}% + 25 cts por compra"),
                if (widget.companyPreferences.stripeEnabled ) const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 20),
                TextButton.icon(
                  label: const Text(
                    'Cerrar sesión',
                    style: TextStyle(color: Colors.black)
                  ),
                  onPressed: logOut,
                  icon: const Icon(
                    Icons.logout,
                    color: Colors.black,
                    weight: 3.0
                  )
                ),
                const SizedBox(height: 20),
                const Row(
                  children: [
                    Text('Zona peligrosa', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    SizedBox(width: 10),
                    Expanded(child: Divider(color: Colors.red))
                  ]
                ),
                const SizedBox(height: 20),
                DangerZone(companyPreferences: widget.companyPreferences, config: widget.config),
                const SizedBox(height: 50)
              ]
            )
          )
        )
      )
    );
  }
}