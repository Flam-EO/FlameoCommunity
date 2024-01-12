import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flameo/models/cart_models/cart.dart';
import 'package:flameo/models/client_user.dart';
import 'package:flameo/models/transaction.dart';
import 'package:flameo/services/auth_database.dart';
import 'package:flameo/services/config_provider.dart';
import 'package:flameo/services/database.dart';
import 'package:flutter/foundation.dart';

class StripeService {

  final CompanyPreferences companyPreferences;
  final ConfigProvider config;

  StripeService({required this.companyPreferences, required this.config});

  late CollectionReference connectedAccounts = FirebaseFirestore.instance.collection(config.get('connectedAccounts'));
  late CollectionReference companies = FirebaseFirestore.instance.collection(config.get('companies'));
  late CollectionReference stripeCustomers = FirebaseFirestore.instance.collection(config.get('stripeCustomers'));

  Future<String?> registerConnectedAccount(String panelLink, {String? connectedAccountID}) async {
    await connectedAccounts.doc(companyPreferences.companyID).set({
      "companyID": companyPreferences.companyID,
      "email": companyPreferences.email,
      "panelLink": panelLink,
      "connectedAccountID":connectedAccountID, //May be null!!! Logic implemented in the cloud  function
      "return_url": "https://${config.get('base_link')}/registrationsuccess?name=${companyPreferences.companyID}",
      "refresh_url": "https://${config.get('base_link')}/acceso",
      "time": DateTime.now()
    }, SetOptions(merge: true));

    // Wait until stripe replies and return stripe link
    StreamSubscription<DocumentSnapshot>? subscription;
    DocumentReference doc = companies.doc(companyPreferences.companyID);
    Completer<String?> completer = Completer<String?>();

    subscription = doc.snapshots().listen((DocumentSnapshot snapshot) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

      if (data.containsKey('url')) {
        completer.complete(data['url']);
        subscription?.cancel();
      }
    });

    return completer.future;
  }

  Future<dynamic> generateStripeLink(Cart cart) async {
    dynamic registerResult = await AuthDatabaseService(config: config).registerOrUpdateCustomer(cart.clientContact!);
    if (registerResult is PayCartError) {
      return registerResult;
    }
    String uid = registerResult as String;

    DocumentReference transactionReference = DatabaseService(companyID: cart.companyPreferences.companyID, config: config).generateTransactionReference();
    StripeLinkWaiter stripeLinkWaiter = StripeLinkWaiter(transactionReference: transactionReference);
    cart.stripeLinkWaiters.add(stripeLinkWaiter);

    // Submit the checkout session
    DocumentReference doc = await stripeCustomers.doc(uid).collection("checkout_sessions").add({
      'customer_email': cart.clientContact!.email,
      'metadata': {
        'transactionID': transactionReference.id,
        'companyID': companyPreferences.companyID
      },
      'mode': "payment",
      "expires_at": Timestamp.now().seconds + 1801,
      "payment_method_types": ["card"],
      'line_items': cart.cartItems.map((cartItem) => {
        'price_data': {
          'currency': 'EUR',
          'unit_amount': (cartItem.product.price * 100).toInt(),
          'product_data': {
            'name': cartItem.product.name,
            'images': cartItem.product.photos?.map((photo) => photo.thumbnailLink)
              .where((link) => link != null).toList() ?? []
          }
        },
        'quantity': cartItem.quantity
      }).toList(),
      "payment_intent_data": {
        "application_fee_amount": cart.fee,
        "transfer_data": {"destination": companyPreferences.connectedAccountID},
      },
      'shipping_options': [{
        "shipping_rate_data": {
          "display_name": "A domicilio",
          "type": "fixed_amount",
          "fixed_amount": {
            "amount": cart.shippingCostCents,
            "currency": "EUR"
          }
        }
      }],
      'success_url': 'https://${config.get('base_link')}/thankyou?c=${companyPreferences.companyID}&t=${transactionReference.id}',
      'cancel_url': companyPreferences.subdomain != null ? 
        'https://${companyPreferences.subdomain}.${config.shareBaseLink(companyPreferences)}'
        : 'https://${config.shareBaseLink(companyPreferences)}/panel?name=${companyPreferences.panel.panelLink}'
    });
    stripeLinkWaiter.checkoutSessionReference = doc;
    return stripeLinkWaiter;
  }

  Future<PayCartError?> payCart(Cart cart) async {
    Completer<PayCartError?> completer = Completer<PayCartError?>();

    // Get the customer id, registering if needed
    dynamic result = await generateStripeLink(cart);
    if (result is PayCartError) return result;
    StripeLinkWaiter stripeLinkWaiter = result;

    // Wait until stripe replies and return stripe link
    StreamSubscription<DocumentSnapshot>? subscription;

    subscription = stripeLinkWaiter.checkoutSessionReference!.snapshots().listen((DocumentSnapshot snapshot) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      if (data.containsKey('error')) {
        debugPrint(data['error']);
        completer.complete(PayCartError.stripeError);
        subscription?.cancel();
      }
      if (data.containsKey('url')) {
        stripeLinkWaiter.link = data['url'];
        completer.complete(null);
        subscription?.cancel();
      }
    });
    return completer.future;
  }
}

// enum for paying error
enum PayCartError {
  clientContactNeeded,
  cartEmtpy,
  uploadTransactionFailed,
  stripeError,
  registerUserError,
  cartNotSubmitted
}
