import 'package:flameo/models/cart_models/cart.dart';
import 'package:flameo/models/cart_models/cart_item.dart';
import 'package:flameo/models/client_user.dart';
import 'package:flameo/models/userproduct.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flameo/models/panel.dart';
import 'package:flameo/models/transaction.dart';
import 'package:flameo/services/config_provider.dart';
import 'package:flameo/shared/utils.dart';
import 'package:logging/logging.dart';

class DatabaseService {
  // Database service for general use

  String? companyID;
  String? uid;
  final ConfigProvider config;

  DatabaseService({this.companyID, this.uid, required this.config});

  // Logger for the DatabaseService class
  final _log = Logger('DatabaseService');

  // Collections ============================================================================================
  late CollectionReference users = FirebaseFirestore.instance.collection(config.get('users'));
  late CollectionReference companies = FirebaseFirestore.instance.collection(config.get('companies'));
  // ========================================================================================================

  // Panel tools ============================================================================================
  // Pause or not a public panel
  void pausePanelReference(bool pause) {
    companies.doc(companyID).update({'panelPaused': pause});
  }

  // Stream panel
  Stream<Panel> panelStatus(String panelLink) {
    return companies.where("panelLink", isEqualTo: panelLink).snapshots().map((querySnapshot) {
      return querySnapshot.docs.isNotEmpty ? Panel.fromFirestore(querySnapshot.docs.first, config) : Panel(error: PanelError.notFound, config: config);
    });
  }

    Stream<Panel> subdomainPanelStatus(String subdomain) {
    return companies.where("subdomain", isEqualTo: subdomain).snapshots().map((querySnapshot) {
      return querySnapshot.docs.isNotEmpty ? Panel.fromFirestore(querySnapshot.docs.first, config) : Panel(error: PanelError.notFound, config: config);
    });
  }

  // Getter of the panel with only a companyID
  Future<Panel> get companyPanel {
    return companies.doc(companyID).get().then((doc) {
      return Panel.fromDict(doc.data() as Map<String, dynamic>, config);
    });
  }

  // Getter for the company preferences
  Future<CompanyPreferences> get companyPreferences {
    return companies.doc(companyID).get().then((doc) {
      return CompanyPreferences.fromFirestore(doc, config);
    });
  }

  // Check if panel link already exists
  Future<bool> linkExists(String link) async {
    return (await findPanelLink(link, includeDeleting: true)) != null;
  }

  // Check if any of the panelLinks fits the browsed name. Null if fit is not found.
  Future<String?> findPanelLink(String link, {bool includeDeleting=false}) async {
    QuerySnapshot querySnapshot = await companies.get();

    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      if (!(data['is_deleted'] ?? false) || (includeDeleting && (data['deletion_date'] as Timestamp).seconds > Timestamp.now().seconds)) {
        if (data['panelLink'] != null) {
          String panelLink = (data['panelLink'] as String).toLowerCase();
          if (nonCsEqual(panelLink, link)) {
            return data['panelLink'] as String;
          }
        }
      }
    }
    return null; // Return null if no matching panel link is found
  }

  // ========================================================================================================

  // MyTransaction tools ====================================================================================
  // Returns a stream of all transactions AFTER a certain date
  Stream<List<MyTransaction>> getTransactions() {
    return companies.doc(companyID).collection('transactions')
      .where('paymentValidated', isEqualTo: true)
      .orderBy('timestamp', descending: true)
      .snapshots().map((QuerySnapshot snapshot) {
        return snapshot.docs.map((doc) => MyTransaction.fromFirestore(doc, companyID!, config)).toList();
      });
  }

  // Get transaction reference
  DocumentReference generateTransactionReference() {
    return companies.doc(companyID).collection('transactions').doc();
  }

  // Add transaction
  Future<TransactionError?> addTransaction(Cart cart) async {
    Map<String, dynamic> data = cart.toDict();
    data['status'] = TransactionStatus.pending.name;
    data['timestamp'] = Timestamp.now();
    data['paymentValidated'] = false;
    try {
      await cart.stripeLinkWaiters.last.transactionReference.set(data);
      return null;
    } catch (error) {
      _log.warning(error.toString());
      return TransactionError.databaseAdd;
    }
  }

  // Get n latest transactions
  Stream<List<MyTransaction>> getLatestTransactions(int n) {
    return companies.doc(companyID).collection('transactions')
      .orderBy("date", descending: true).limit(n).snapshots().map((QuerySnapshot snapshot) =>
        snapshot.docs.map((doc) => MyTransaction.fromFirestore(doc, companyID!, config)).toList()
    );
  }

  // Update transaction status
  Future<TransactionError?> updateStatus(MyTransaction transaction, TransactionStatus status) async {
    try {
      TransactionStatus oldStatus = transaction.status;
      await companies.doc(companyID).collection('transactions').doc(transaction.transactionID).update({
        'status': status.name,
        'closed': [TransactionStatus.cancelled, TransactionStatus.pickedup, TransactionStatus.delivered].contains(status)
      });
      notifyTransactionStatusChange(transaction.transactionID, oldStatus, status);
      return null;
    } catch (error) {
      _log.info(error.toString());
      return TransactionError.updateStatus;
    }
  }

  // Get transaction (used in the thankyou section after a client has purchased something)
  Future<MyTransaction> getTransaction(String transactionId) {
    return companies.doc(companyID).collection('transactions').doc(transactionId).get().then((doc) {
      return MyTransaction.fromFirestore(doc, companyID!, config);
    });
  }

  // Check if there are pending transactions
  Future<bool> pendingTransactions() async {
    return (await companies.doc(companyID).collection('transactions')
      .where('closed', isEqualTo: false).limit(1).get()).docs.isNotEmpty;
  }

  // ========================================================================================================

  // UserProducts tools =====================================================================================
  // Stream user products
  Stream<List<UserProduct>> get userProducts {
    return companies.doc(companyID).collection(config.get('products'))
      .where('is_deleted', isNotEqualTo: true)
      .snapshots().map((querySnapshot) => querySnapshot.docs.map((doc) => 
        UserProduct.fromFirestore(doc, companyID!, config)
      ).toList());
  }

  /// Stream of the list of products selected for the gallery
  Stream<List<UserProduct>?> get gallerySelectedProducts {
    return FirebaseFirestore.instance.collectionGroup(config.get('products'))
    .where('galleryPunctuation', isGreaterThan: 0)
    .orderBy('galleryPunctuation', descending: true)
    .snapshots()
    .map((querySnapshot) => querySnapshot.docs.map(
      (doc) {
        return UserProduct.fromFirestore(doc, doc.reference.path.split('/')[1], config);
      }
    ).toList());
  }

  Future<List<UserProduct>> latestUserProducts({int limit = 3}) async {
    return await companies
        .doc(companyID)
        .collection(config.get('products'))
        .where('is_deleted', isNotEqualTo: true)
        // .orderBy('creationTimestamp', descending: true)
        .limit(limit)
        .get()
        .then((query) {
      return query.docs
          .map((doc) => UserProduct.fromFirestore(doc, companyID!, config))
          .toList(); // Convert the iterable to a list and return it
    });
  }
  // Add new list of user products
  Future<UserProductError?> addUserProduct(UserProduct userProduct, CompanyPreferences? companyPreferences) async {
    Map<String, dynamic> data = userProduct.toDict();
    data['timestamp'] = Timestamp.now();
    try {
      await companies.doc(companyID).collection(config.get('products')).doc(userProduct.id).set(data);
      companyPreferences!.updateFields({'nProducts': companyPreferences.nProducts+1}, config);
      return null;
    } catch (error) {
      _log.warning(error.toString());
      return UserProductError.databaseAdd;
    }
  }

  // Delete a user product
  Future<dynamic> deleteUserProduct(UserProduct userProduct, CompanyPreferences? companyPreferences) async {
    Map<String, dynamic> data = userProduct.toDict();
    data['timestamp'] = Timestamp.now();
    try {
      await companies.doc(companyID).collection(config.get('products')).doc(userProduct.id).update({'is_deleted': true});
      companyPreferences!.updateFields({'nProducts': companyPreferences.nProducts-1}, config);
    } catch (error) {
      _log.info(error.toString());
      return UserProductError.userProductDelete;
    }
  }

  // Edit product field
  Future<UserProductError?> updateProductFields(String productID, Map<String, dynamic> fields) async {
    try {
      await companies.doc(companyID).collection(config.get('products')).doc(productID).update(fields);
      return null;
    } catch (error) {
      _log.warning(error.toString());
      return UserProductError.updateField;
    }
  }

  // Check product availability
  Future<UserProductStatus> productAvailable(CartItem cartItem) async {
    cartItem.productStatus = UserProductStatus.ok;
    double originalPrice = cartItem.product.price;
    cartItem.product = UserProduct.fromFirestore(
      await companies.doc(companyID).collection(config.get('products')).doc(cartItem.product.id).get(),
      companyID!,
      config
    );
    if (cartItem.product.isDeleted!) cartItem.productStatus = UserProductStatus.deleted;
    if (cartItem.product.stock < cartItem.quantity) cartItem.productStatus = UserProductStatus.insufficientStock;
    if (originalPrice != cartItem.product.price) cartItem.productStatus = UserProductStatus.priceChanged;
    return cartItem.productStatus;
  }

  // ========================================================================================================

  // Notification tools =====================================================================================
  // Add new list of user products
  Future notifyTransactionStatusChange(
    String transactionID, TransactionStatus oldStatus, TransactionStatus newStatus
  ) async {
    await companies.doc(companyID).collection('notifications').doc('status_tc_${generateCode(length: 15)}').set({
      'type': 'transaction_status_change',
      'transactionID': transactionID,
      'timestamp': Timestamp.now(),
      'oldStatus': oldStatus.name,
      'newStatus': newStatus.name
    });
  }

  // ========================================================================================================

  // CompanyPreferences tools =====================================================================================
  Stream<List<CompanyPreferences>> get streamArtCompanies {
    return companies
      .where('flameoExtension', isEqualTo: 'art',).where('nProducts', isGreaterThan: 1)
      //Filter.and(
      //  Filter('flameoExtension', isEqualTo: 'art'),
      //  Filter('mastersApprove', isEqualTo: true),
      //  Filter('panelLink', isNull: false),
      //  Filter('nProducts', isGreaterThan: 1),
      //  Filter('description', isNull: false)
      //)
    // .orderBy('creationTimestamp', descending: true)
      .snapshots().map((querySnapshot) => querySnapshot.docs.map((doc) => 
        CompanyPreferences.fromFirestore(doc, config)
    ).toList());
  }

  Stream<List<CompanyPreferences>> get streamFavoritesCompanies {
    return companies
      .where('flameoExtension', isEqualTo: 'art')
      .where('artistFans', arrayContains: companyID)
    .orderBy('creationTimestamp', descending: true)
      .snapshots().map((querySnapshot) => querySnapshot.docs.map((doc) => 
        CompanyPreferences.fromFirestore(doc, config)
    ).toList());
  }

  Future<CompanyPreferences> fanCompanyPreferences(String fanID) {
    return companies.doc(fanID).get().then((doc) => CompanyPreferences.fromFirestore(doc, config));
  }
}

  /// Downloads company data for a new product
  Future<CompanyPreferences> downloadCompanyPreferences(ConfigProvider config, String? companyId) async {
    return await DatabaseService(config: config, companyID: companyId).companyPreferences;
  }
