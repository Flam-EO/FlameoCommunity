import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flameo/models/client_contact.dart';
import 'package:flameo/models/client_user.dart';
import 'package:flameo/models/code.dart';
import 'package:flameo/services/auth.dart';
import 'package:flameo/services/config_provider.dart';
import 'package:flameo/shared/utils.dart';
import 'package:logging/logging.dart';

class AuthDatabaseService {
  // Database service for authentication

  String? companyID;
  String? uid;
  ConfigProvider config;

  AuthDatabaseService({this.companyID, this.uid, required this.config});

  final _log = Logger('AuthDatabaseService');

  late CollectionReference registrationCodes = FirebaseFirestore.instance.collection(config.get('registrationCodes'));
  late CollectionReference users = FirebaseFirestore.instance.collection(config.get('users'));
  late CollectionReference companies = FirebaseFirestore.instance.collection(config.get('companies'));
  late CollectionReference stripeCustomers = FirebaseFirestore.instance.collection(config.get('stripeCustomers'));

  // Create user entry
  Future<void> createUser(Map<String, dynamic> user) async {
    await users.doc(uid).set(user);
  }

  // Delete user
  void deleteUser() {
    users.doc(uid).update({'is_deleted': true});
  }

  // Stream of preferences
  Stream<PreferencesWrapper> get userPreferences {
    return users.doc(uid).snapshots().map((doc) {
      if (!doc.exists) {
        return PreferencesWrapper(error: PreferenceError.preferencesNotFound);
      }
      Map<String, dynamic> preferences = downloadDocSnapshot(doc);
      // The preferences of the user in Firestore can force an account delete
      // User just need to update their preferences setting is_deleted to true using the function deleteUser from this file
      if (preferences['is_deleted'] ?? false) {
        AuthService(config: config).deleteAccount();
        AuthService(config: config).signOut();
      }
      return PreferencesWrapper(preferences: Preferences.fromDict(preferences));
    });
  }

  // Stream of company preferences
  Stream<CompanyPreferences> get companyPreferences {
    return companies.doc(companyID).snapshots().map((doc) {
      return CompanyPreferences.fromFirestore(doc, config);
    });
  }
  
  // Get registration code
  Future<dynamic> getRegistrationCode(String code) async {
    return Code.fromFirestore(registrationCodes.doc(code));
  }

  // Delete registration code
  void deleteRegistrationCode(String code) {
    // registrationCodes.doc(code).delete();
  }

  // Create new company
  Future<String> createCompany(Map<String, dynamic> companyData) async {
    companyData['creationTimestamp'] = Timestamp.now();
    return (await companies.add(companyData)).id;
  }

  // Update user preferences fields
  Future<PreferenceError?> updateUserFields(Map<String, dynamic> fields) async {
    try {
      await users.doc(uid).update(fields);
      return null;
    } catch (error) {
      _log.warning(error.toString());
      return PreferenceError.updateField;
    }
  }

  // Update company preferences fields
  Future<CompanyPreferenceError?> updateCompanyFields(Map<String, dynamic> fields) async {
    try {
      await companies.doc(companyID).update(fields);
      return null;
    } catch (error) {
      _log.warning(error.toString());
      return CompanyPreferenceError.updateField;
    }
  }

  // Register or update a customer if email already exists in collection
  Future<dynamic> registerOrUpdateCustomer(ClientContact clientContact) async {
    List<String> uidQuery = (await stripeCustomers.where("email", isEqualTo: clientContact.email).get())
      .docs.map((QueryDocumentSnapshot docSnap) => docSnap.id).toList();
    String uid;
    DocumentReference doc;
    if (uidQuery.isNotEmpty) {
      uid = uidQuery.first;
      doc = stripeCustomers.doc(uid);
    } else {
      uid = clientContact.email + generateCode(length: 10);
      doc = stripeCustomers.doc(uid);
      // doc = customersStripe.doc();
      // uid = doc.id;
    }
    doc.set(clientContact.toDict(), SetOptions(merge: true));
    return uid;
  }
}
