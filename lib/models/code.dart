
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flameo/models/role.dart';
import 'package:flameo/services/auth_database.dart';
import 'package:flameo/services/config_provider.dart';
import 'package:flameo/shared/utils.dart';

class Code {

  // This object represent a authorization code to allow a client to register
  
  final String code;
  final Timestamp expiration;
  final String? companyID;
  final Permissions? permissions;

  Code({
    required this.code,
    required this.expiration,
    this.companyID,
    this.permissions
  });

  // Methods to submit information to firestore
  void delete(ConfigProvider config) => AuthDatabaseService(config: config).deleteRegistrationCode(code);

  // Useful getters
  bool get isNewCompany => companyID == null;

  // Conversion methods
  static Future<dynamic> fromFirestore(DocumentReference doc) async {
    Map<String, dynamic>? data = await downloadDoc(doc);
    if (data == null) {
      return RegistrationCodeError.notValid;
    } else if (data['expiration'].seconds < Timestamp.now().seconds) {
      return RegistrationCodeError.expirated;
    }
    return Code(
      code: doc.id,
      expiration: data['expiration'],
      companyID: data['companyID']
    );
  }
}

// Code validation enums
enum RegistrationCodeError {
  notValid,
  expirated
}