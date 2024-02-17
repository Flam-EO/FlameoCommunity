import 'package:flameo/gallery/gallery.dart';
import 'package:flameo/landing_page/landing_page.dart';
import 'package:flameo/landing_page/landing_page_art.dart';
import 'package:flameo/models/client_user.dart';
import 'package:flameo/models/panel.dart';
import 'package:flameo/services/auth.dart';
import 'package:flameo/services/config_provider.dart';
import 'package:flameo/services/database.dart';
import 'package:flameo/shared/utils.dart';
import 'package:flameo/views/home/micro/price_panel/external/external_panel_loader.dart';
import 'package:flameo/views/home/thank_you/thank_you.dart';
import 'package:flameo/views/wrapper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meta_seo/meta_seo.dart';
import 'package:provider/provider.dart';
import 'package:seo/html/seo_controller.dart';
import 'package:seo/html/tree/widget_tree.dart';
import 'shared/color_schemes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:html' as html;
import 'package:get/get.dart';

class MyApp extends StatelessWidget {

  final ConfigProvider config;

  const MyApp(this.config, {Key? key}) : super(key: key);

  bool routeStart(RouteSettings settings, String name) {
    return settings.name?.startsWith(name) ?? false;
  }

  static List<String> reservedSubdomains = ['dev', 'stg', 'gallery', 'galeria'];

  dynamic checkSubdomain([RouteSettings? settings]) {
    // dummy comment
    String fullUrl = html.window.location.href;
    Uri fullUrlParsed = Uri.parse(fullUrl);
    List<String> parts = fullUrlParsed.host.split('.');
    Uri? url = settings != null ? Uri.parse("https://${config.get('base_link')}${settings.name}") : null;
    if (parts.length > 2) {

      String subdomain = parts[0];
      if (subdomain == 'gallery') {
        if (settings != null && routeStart(settings, '/panel')) {
          return StreamProvider<Panel?>.value(
            initialData: null,
            value: DatabaseService(config: config).panelStatus(url!.queryParameters["name"]!),
            child: ExternalPanelLoader(
              config: config,
              panelName: url.queryParameters["name"]!,
              linkOpener: LinkOpener(
                productID: url.queryParameters['product'],
                cartReference: url.queryParameters['cart']
              ),
              scrollPosition: url.queryParameters['scrollPosition'],
            )
          );
        }
        return StreamProvider<List<CompanyPreferences>>.value(
          initialData: const [],
          value: DatabaseService(config: config).streamArtCompanies,
          child: Gallery(config: config, scrollPosition: url?.queryParameters['scrollPosition'])
        );
      }
      if (reservedSubdomains.contains(subdomain)) return null;
      return StreamProvider<Panel?>.value(
        initialData: null,
        value: DatabaseService(config: config).subdomainPanelStatus(subdomain),
        child: ExternalPanelLoader(
          config: config,
          panelName: subdomain, // Esto solo está por el nombre cuando no existe.
          linkOpener: LinkOpener(
            productID: url?.queryParameters['product'],
            cartReference: url?.queryParameters['cart']
          )
        )
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {

    List<String> innerRoutes = ['/acceso', '/ventas', '/panel', '/account', '/registro', '/artistas'];

    if(kIsWeb && [Environment.pro, Environment.art].contains(config.environment)) {
      MetaSEO meta = MetaSEO();
      meta.author(author: 'GWP');
      if (config.environment == Environment.pro) {
        meta.ogTitle(ogTitle: 'Flameo App');
        meta.description(description: 'Cualquier persona, empresa con un proyecto puede llevarlo a internet.');
        meta.ogDescription(ogDescription: '¡Accede a Flameo App! Puedes llevar tu proyecto a internet en cuestión de minutos.');
        meta.keywords(keywords: 'Flameo, FlameoApp, e-commerce, ecommerce, Flameo App, Crear Ecommerce, Plataforma Ecommerce España, Crear Tienda Online, Vender por Internet, Emprendedor Digital, Negocios Online España, Plataforma Venta Online, Tienda Online Fácil, Proyectos Online, Empresa Digital, Solución Ecommerce, Vender Productos Online, Ecommerce Rápida, Simplicidad Ecommerce, Flameo España');
      } else if (config.environment == Environment.art) {
        meta.ogTitle(ogTitle: 'FlameoArt galería online');
        meta.description(description: 'Galería online para artistas emergentes. Cualquier artista puede subir sus obras y venderlas de forma gratuita');
        meta.ogDescription(ogDescription: 'Galería online para artistas emergentes. Cualquier artista puede subir sus obras y venderlas de forma gratuita');
        meta.keywords(keywords: 'galería,galería online,arte online, arte barato,arte,flameo, art, obras de arte, arte digital, arte pictórico');}
    }

    config.anonymousLog(LoggerAction.openApp);

    return StreamProvider<ClientUser?>.value(
      initialData: null,
      value: AuthService(config: config).user,
      child: SeoController(
        enabled: true,
        tree: WidgetTree(context: context),
        child: GetMaterialApp(
          title: 'Flameo',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: lightColorScheme,
            textSelectionTheme: const TextSelectionThemeData(selectionColor: Color.fromARGB(50, 0, 122, 255)),
            textTheme: GoogleFonts.loraTextTheme(),
            navigationBarTheme: NavigationBarThemeData(
              elevation: 0.0,
              indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              indicatorColor: const Color.fromARGB(100, 33, 96, 135),
              labelTextStyle: const MaterialStatePropertyAll(TextStyle(fontSize: 14)),
            ),
          ),
          initialRoute: '/',
          onGenerateRoute: (settings) => MaterialPageRoute<dynamic>(
            builder: (context) {
              StreamProvider? subdomainApp = checkSubdomain(settings);
              if (subdomainApp != null) {
                config.anonymousLog(LoggerAction.access, {'route': html.window.location.href, 'page': html.window.location.href});
                return subdomainApp;
              }
              // IpLogger.anonymousLog('Access route: ${settings.name}');
              // _log.info(settings.name);
              // _log.info(settings);
              Uri url = Uri.parse("https://${config.get('base_link')}${settings.name}");
        
              if (routeStart(settings, '/panel?') && url.queryParameters["name"] != null) {
                return StreamProvider<Panel?>.value(
                  initialData: null,
                  value: DatabaseService(config: config).panelStatus(url.queryParameters["name"]!),
                  child: ExternalPanelLoader(
                    config: config,
                    panelName: url.queryParameters["name"]!,
                    linkOpener: LinkOpener(
                      productID: url.queryParameters['product'],
                      cartReference: url.queryParameters['cart']
                    ),
                    scrollPosition: url.queryParameters['scrollPosition'],
                  )
                );
              } else if (
                routeStart(settings, '/thankyou?') &&
                url.queryParameters["c"] != null &&
                url.queryParameters["t"] != null
              ) {
                config.anonymousLog(LoggerAction.thankYouPage, {
                  'c': url.queryParameters["c"]!,
                  't': url.queryParameters["t"]
                });
                return ThankYou(
                  companyId: url.queryParameters["c"]!,
                  transactionId: url.queryParameters["t"]!,
                  config: config
                );
              } else if (routeStart(settings, '/gallery')) {
                return StreamProvider<List<CompanyPreferences>>.value(
                  initialData: const [],
                  value: DatabaseService(config: config).streamArtCompanies,
                  child: Gallery(config: config, scrollPosition: url.queryParameters['scrollPosition'])
                );
              } else if (
                innerRoutes.contains(settings.name)
                || routeStart(settings, '/registrationsuccess')
                || routeStart(settings, '/recoverPassword')
              ) {
                config.anonymousLog(LoggerAction.access, {'route': url.path, 'page': settings.name});
                return Wrapper(route: settings.name, config: config);
              } else if (routeStart(settings, '/sauron')) {
                return const Scaffold(body: Center(child: Text('Necesitarás cruzar las puertas de Mordor...')));
              } else {
                config.anonymousLog(LoggerAction.landingPage, {'route': url.path});
                return isArtEnvironment(config) ? LandingPageArt(config: config) : LandingPage(config: config);
              }
            },
            settings: settings
          ),
          home: checkSubdomain() ?? (isArtEnvironment(config) ? LandingPageArt(config: config) : LandingPage(config: config)),
          debugShowCheckedModeBanner: false
        ),
      )
    );
  }
}
