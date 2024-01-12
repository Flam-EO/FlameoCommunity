import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flameo/models/cart_models/cart.dart';
import 'package:flameo/models/panel.dart';
import 'package:flameo/models/role.dart';
import 'package:flameo/models/userproduct.dart';
import 'package:flameo/services/auth_database.dart';
import 'package:flameo/services/config_provider.dart';
import 'package:flameo/services/database.dart';
import 'package:flameo/services/stripe.dart';
import 'package:flameo/shared/utils.dart';

class CompanyPreferences {
  // This object store the current company preferences

  final String companyName;
  final Panel panel;
  final bool dataCompleted;
  final String companyID;
  final bool stripeEnabled;
  final bool mastersApprove;
  final String? connectedAccountID;
  final double feeRate;
  final String? address;
  final String? businessType;
  final String? description;
  final String? media;
  final String? phone;
  final String? web;
  final String? landscape;
  final String? email;
  final List<ShippingMethod> shippingMethods;
  final bool isDeleted;
  final Timestamp? deletionDate;
  final double minimumTransactionAmount;
  final int shippingCostCents;
  final FlameoExtension flameoExtension;
  final List<String> categorySuggestions;
  final int lastStripeRequest;
  final bool triedStripe;
  final int nProducts;
  final String? subdomain;
  final bool subdomainRequested;
  final Timestamp creationTimestamp;
  final List<String> artistFans;
  final bool isPublic; // true if the company automatically publishes its products in the gallery upon creation

  CompanyPreferences({
    required this.companyName,
    required this.panel,
    required this.dataCompleted,
    required this.companyID,
    required this.connectedAccountID,
    required this.address,
    required this.businessType,
    required this.description,
    required this.media,
    required this.phone,
    required this.web,
    required this.stripeEnabled,
    required this.shippingMethods,
    required this.mastersApprove,
    required this.email,
    this.landscape,
    required this.isDeleted,
    required this.deletionDate,
    required this.feeRate,
    required this.minimumTransactionAmount,
    required this.shippingCostCents,
    required this.flameoExtension,
    required this.categorySuggestions,
    required this.lastStripeRequest, 
    required this.triedStripe,
    required this.nProducts,
    required this.subdomain,
    required this.subdomainRequested,
    required this.creationTimestamp,
    required this.artistFans,
    required this.isPublic
  });


  String get instagram{
    if (this.media == null || this.media!.isEmpty) return '';
    List<String> mediaParts = this.media!.split('?').first.split('/');
    if (mediaParts.last.isNotEmpty) return mediaParts.last.replaceAll("@", "");
    mediaParts.removeLast();
    if (mediaParts.isEmpty) return '';
    return mediaParts.last.replaceAll("@", "");
  }

  // Methods to submit information to firestore
  Future<void> updateFields(Map<String, dynamic> data, ConfigProvider config) async {
    await AuthDatabaseService(companyID: companyID, config: config).updateCompanyFields(data);
  }

  Future<void> like(String likerID, ConfigProvider config) async {
    await AuthDatabaseService(companyID: companyID, config: config).updateCompanyFields({
      'artistFans': this.artistFans + [likerID]
    });
  }
  Future<void> dislike(String likerID, ConfigProvider config) async {
    List<String> newFans = List<String>.from(this.artistFans);
    newFans.remove(likerID);
    await AuthDatabaseService(companyID: companyID, config: config).updateCompanyFields({
      'artistFans': newFans
    });
  }

  // Add new category suggestion
  Future<void> addCategory(String newCategory, ConfigProvider config) async {
    newCategory = newCategory.trim();
    if (newCategory.isNotEmpty 
      && !this.categorySuggestions.contains(newCategory)
    ) {
      this.updateFields({
        'categorySuggestions': this.categorySuggestions + [newCategory]
      }, config);
    }
  }

  Future<String?> registerConnectedAccount(ConfigProvider config) async {
    await AuthDatabaseService(companyID: companyID, config: config).updateCompanyFields({"url": FieldValue.delete()});
    String? link = await StripeService(companyPreferences: this, config: config)
        .registerConnectedAccount(this.panel.panelLink ?? '', connectedAccountID: this.connectedAccountID);
    if (link is String) {
      return link;
    } else {
      return null;
    }
  }

  // Useful methods
  String get shippingCostEuro => '${(shippingCostCents / 100).toStringAsFixed(2)} €';
  bool get isCommercial => ![FlameoExtension.art].contains(this.flameoExtension);
  Future<List<UserProduct>> latestProducts(ConfigProvider config) async{
    return await DatabaseService(config: config, companyID: this.companyID).latestUserProducts();
  }
  String get minimumTransactionAmountStr => this.minimumTransactionAmount.toStringAsFixed(2);

  // Conversion methods
  factory CompanyPreferences.fromFirestore(DocumentSnapshot doc, ConfigProvider config) {
    Map<String, dynamic> data = downloadDocSnapshot(doc);
    data['companyID'] = doc.id;
    return CompanyPreferences(
      companyName: data['companyName'],
      artistFans: ((data['artistFans'] ?? []).cast<String>() as List<String>),
      isDeleted: data['is_deleted'] ?? false,
      deletionDate: data['deletion_date'],
      connectedAccountID: data['connectedAccountID'],
      dataCompleted: data['dataCompleted'] ?? false,
      stripeEnabled: data['stripeEnabled'] ?? false,
      email: data['email'],
      panel: Panel.fromDict(data, config),
      companyID: doc.id,
      address: data['address'],
      businessType: data['businessType'],
      description: data['description'],
      media: data['media'],
      phone: data['phone'],
      web: data['web'],
      landscape: data['landscape'],
      mastersApprove: data['mastersApprove'] ?? false,
      feeRate: data['feeRate'] ?? 0.05, //TODO FUT: garantizar que la fee existe siempre para evitar quebraderos de cabeza,
      shippingMethods: 
        (data['shippingMethods']?.cast<String>() as List<String>?)?.map(ShippingMethod.values.byName).toList()
        ?? [ShippingMethod.pickUp],
      minimumTransactionAmount: data['minimumTransactionAmount'] ?? 5.0,
      shippingCostCents: data['shippingCostCents'] ?? 300,
      flameoExtension: FlameoExtension.values.byName(data['flameoExtension'] ?? 'main'),
      categorySuggestions: (data['categorySuggestions']?.cast<String>() as List<String>?) ?? [],
      lastStripeRequest: data['lastStripeRequest'] ?? 0,
      triedStripe: data['url'] != null,
      nProducts: data['nProducts'] ?? 0,
      subdomain: data['subdomain'],
      subdomainRequested: data['subdomainRequested'] ?? false,
      creationTimestamp: data['creationTimestamp'],
      isPublic: data['isPublic'] ?? true
    );
  }
}

// Upload to firestore error enums
enum CompanyPreferenceError { updateField }

class Preferences {
  // This object store the preferences of the user

  final String email;
  final String companyID;
  final Role role;
  final String name;
  final bool tutorialCompleted;

  Preferences({
    required this.email,
    required this.companyID,
    required this.role,
    required this.name,
    required this.tutorialCompleted
  });

  // Conversion methods
  static Preferences fromDict(Map<String, dynamic> data) {
    return Preferences(
      email: data['email'],
      companyID: data['companyID'],
      tutorialCompleted: data['tutorialCompleted'],
      name: data['name'],
      role: Role.fromDict(data)
    );
  }
}

// Upload to firestore error enums
enum PreferenceError {
  updateField,
  preferencesNotFound
}

class PreferencesWrapper {

  final Preferences? preferences;
  final PreferenceError? error;

  PreferencesWrapper({this.preferences, this.error});

}

class ClientUser {
  // This object is the client user which should contains preferences and anything useful related to the client

  final String uid;
  Preferences? preferences;

  ClientUser({required this.uid, this.preferences});

  // Methods to submit information to firestore
  void finishTutorial(ConfigProvider config) => AuthDatabaseService(uid: uid, config: config).updateUserFields({'tutorialCompleted': true});

  // Conversion methods
  static ClientUser? fromFirebaseUser(User? user) => user != null ? ClientUser(uid: user.uid) : null;
}
