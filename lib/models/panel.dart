import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flameo/services/config_provider.dart';
import 'package:flameo/services/database.dart';
import 'package:flameo/shared/utils.dart';

class Panel {

  // Panel basic information

  final String? companyID;
  final String? companyName;
  final bool? mastersApprove;
  final String? panelLink;
  final bool? isPaused;
  final PanelError? error;
  final ConfigProvider config;
  final bool? isDeleted;
  final String? subdomain;

  Panel({
    this.companyID, 
    this.companyName, 
    this.mastersApprove, 
    this.isPaused, 
    this.panelLink, 
    this.error, 
    required this.config,
    this.isDeleted,
    this.subdomain
  });

  // Methods to manage/edit panel
  void pause() => DatabaseService(companyID: companyID, config: config).pausePanelReference(true);
  void resume() => DatabaseService(companyID: companyID, config: config).pausePanelReference(false);
  void switchPause() =>DatabaseService(companyID: companyID, config: config).pausePanelReference(isPaused!);

  // Conversion methods
  static Panel fromDict(Map<String, dynamic> data, ConfigProvider config) => Panel(
    companyID: data['companyID'],
    panelLink: data['panelLink'],
    isPaused: data['panelPaused'],
    companyName: data['companyName'],
    isDeleted: data['is_deleted'] ?? false,
    mastersApprove: data['mastersApprove'] ?? false,
    subdomain: data['subdomain'] ?? "",
    config: config
  );

  factory Panel.fromFirestore(QueryDocumentSnapshot doc, ConfigProvider config) {
    Map<String, dynamic> data = downloadDocSnapshot(doc);
    data['companyID'] = doc.id;
    return fromDict(data, config);
  }
}

// Error enums
enum PanelError {
  notFound;
}
