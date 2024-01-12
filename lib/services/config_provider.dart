import 'dart:convert';
import 'package:dart_ipify/dart_ipify.dart';
import 'package:flameo/models/client_user.dart';
import 'package:flameo/services/management_database.dart';
import 'package:flameo/shared/utils.dart';
import 'package:flutter/services.dart';

class ConfigProvider {
  final String configFileName;
  late Map<String, dynamic> _config;

  String? logedVisitor;
  Environment? environment;

  ConfigProvider({required this.configFileName});

  Future<void> loadConfig() async {
    final configString = await rootBundle.loadString('config/$configFileName');
    _config = jsonDecode(configString);
    this.environment = Environment.values.byName(_config['environment']);
  }

  dynamic get(String key) {
    return _config[key];
  }

  bool get seoEnabled => [Environment.pro, Environment.art].contains(this.environment);

  String shareBaseLink(CompanyPreferences companyPreferences) {
    if (companyPreferences.flameoExtension == FlameoExtension.art) return _config['art_link'];
    return _config['app_link'];
  }

  void anonymousLog(LoggerAction action, [Map<String, dynamic>? metadata]) {
    if (this.get('logging')) {
      Ipify.ipv4().then((ip) {
        if (action == LoggerAction.openApp) {
          ManagementDatabaseService(config: this).saveIP(ip);
        }
        ManagementDatabaseService(config: this).log({
          'ip': ip,
          'action': action.name,
          'metadata': metadata
        }, ip);
      });
    }
  }

  void log(LoggerAction action, [Map<String, dynamic>? metadata]) {
    Ipify.ipv4().then((ip) {
      ManagementDatabaseService(config: this).log({
        'ip': ip,
        'action': action.name,
        'metadata': metadata
      }, this.logedVisitor ?? 'visitorError');
    });
  }
}

enum LoggerAction {
  // Actions to log
  openApp,
  thankYouPage,
  access,
  register,
  landingPage,
  openLogIn,
  openSignIn,
  openContact,
  openCodeReg,
  openRecoverPassword,
  companyDataPanelLink,
  linkTry,
  companyDataLandscape,
  companyDataDescription,
  companyDataReferral,
  companyDataAddress,
  companyDataShipping,
  companyDataPhone,
  companyDataPrePayment,
  completeStripeNow,
  completeStripeLater,
  acessExternalPanelDashboard,
  accessCart,
  accessCartFromLink,
  accessProductFromLink,
  orderFormAccess,
  orderContactDone,
  orderShippingDone,
  orderResumeDone,
  orderPanelOpen,
  linkChangeTry
}

enum Environment {
  local,
  dev,
  test,
  pro,
  art,
  devart
}