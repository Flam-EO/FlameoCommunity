import 'package:animations/animations.dart';
import 'package:flameo/models/client_user.dart';
import 'package:flameo/services/config_provider.dart';
import 'package:flameo/shared/loading.dart';
import 'package:flameo/shared/utils.dart';
import 'package:flameo/views/home/micro/account/account_settings.dart';
import 'package:flameo/views/home/micro/artists/artists.dart';

import 'package:flameo/views/home/micro/price_panel/internal/price_panel.dart';
import 'package:flameo/views/home/micro/sales/sales.dart';
import 'package:flutter/material.dart';
import 'dart:html';

class Micro extends StatefulWidget {
  final ClientUser user;
  final ConfigProvider config;
  final CompanyPreferences companyPreferences;
  final String? route;

  const Micro({super.key, required this.user, this.route, required this.companyPreferences, required this.config});

  @override
  State<Micro> createState() => _MicroState();
}

class _MicroState extends State<Micro> {

  bool get isArtist => widget.companyPreferences.flameoExtension == FlameoExtension.art;

  late List<String> titles = [
    'Ventas',
    isArtist ? 'Tus obras' : 'Tus productos',
    if (isArtist)
      'Artistas'
  ];
  late List<String> routes = [
    '/ventas',
    '/panel',
    if (isArtist)
      '/artistas'
  ];
  late List<IconData> icons = [
    Icons.storefront,
    Icons.grid_on,
    if (isArtist)
      Icons.people
  ];

  int currentScreen = 0;
  late String defaultPage = routes.first;

  bool loading = false;
  void setLoading(bool loading) => setState(() => this.loading = loading);

  @override
  void initState() {
    if ((widget.route ?? '').startsWith('/registrationsuccess')) {
      widget.companyPreferences.updateFields({
        "lastStripeRequest": DateTime.now().millisecondsSinceEpoch
      }, widget.config);
    }
    if (widget.route == '/acceso') {
      window.history.pushState(null, 'Default Page', defaultPage);
    }
    if (widget.route == '/account') {
      Future.delayed(Duration.zero, () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AccountSettings(config: widget.config, companyPreferences: widget.companyPreferences))
      ).then((_) => setState(() => window.history.pushState(null, 'Previous Page', lastSeenPathName ?? defaultPage))));
    }
    if (routes.contains(widget.route)) {
      currentScreen = routes.indexOf(widget.route!);
    }
    super.initState();
  }

  void toggleScreen(int index, List titles, List routes) => setState(() {
    currentScreen = index;
    window.history.pushState(null, titles[currentScreen], routes[currentScreen]);
  });

  String? lastSeenPathName;

  @override
  Widget build(BuildContext context) {

    List<Widget> screens = [
      Sales(user: widget.user, companyPreferences: widget.companyPreferences, config: widget.config, setLoading: setLoading),
      PricePanel(user: widget.user, config: widget.config, companyPreferences: widget.companyPreferences),
      if (isArtist) Artists(companyPreferences: widget.companyPreferences, config: widget.config)
    ];

    return loading ? const Scaffold(body: Loading()) : Scaffold(
      appBar: AppBar(
        centerTitle: false,
        leading: Icon(icons[currentScreen], color: Colors.white),
        elevation: 0,
        title: Text(
          titles[currentScreen],
          style: const TextStyle(color: Colors.white, fontSize: 25)
        ),
        backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        actions: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: OpenContainer(
              clipBehavior: Clip.none,
              closedElevation:0,
              closedColor: Theme.of(context).colorScheme.onTertiaryContainer,
              closedShape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(0.0))),
              transitionDuration: const Duration(milliseconds: 400),
              transitionType: ContainerTransitionType.fadeThrough,
              closedBuilder: (context, action) => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.person,
                      color: Colors.white,
                      weight: 3.0,
                    ),
                    Text(
                      'Mi cuenta',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14
                      )
                    )
                  ]
                )
              ),
              openBuilder: (context, action) {
                if(window.location.pathname != '/account') {
                  lastSeenPathName = window.location.pathname;
                }
                return AccountSettings(config: widget.config, companyPreferences: widget.companyPreferences);
              }, 
              onClosed: (_) {
                setState(() => window.history.pushState(null, 'Previous Page', lastSeenPathName ?? defaultPage));
              }
            )
          )
        ]
      ),
      bottomNavigationBar: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        height: 70,
        onDestinationSelected: (index) => toggleScreen(index, titles, routes),
        selectedIndex: currentScreen,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.storefront, size: 15),
            label: 'Ventas'
          ),
          const NavigationDestination(
            icon: Icon(Icons.grid_on, size: 15),
            label: 'Mis productos'
          ),
          if (isArtist)
            const NavigationDestination(
              icon: Icon(Icons.people, size: 15),
              label: 'Artistas'
            )
        ],
        backgroundColor: Theme.of(context).colorScheme.secondary
      ),
      body: screens[currentScreen]
    );
  }
}
