import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flameo/models/cart_models/cart.dart';
import 'package:flameo/models/cart_models/cart_item.dart';
import 'package:flameo/models/client_contact.dart';
import 'package:flameo/services/config_provider.dart';
import 'package:flameo/services/database.dart';
import 'package:flameo/shared/utils.dart';
import 'package:intl/intl.dart';

class MyTransaction {
  // The transaction submited by a buyer

  final List<CartItem> cartItems;
  final Timestamp date;
  final ClientContact clientContact;
  final String transactionID;
  final String companyID;
  TransactionStatus status;
  final ConfigProvider config;
  final ShippingMethod shippingMethod;
  final bool closed;
  final double fee;
  final int shippingCostCents;

  MyTransaction({
    required this.transactionID,
    required this.date,
    required this.clientContact,
    required this.cartItems,
    required this.status,
    required this.companyID,
    required this.config,
    required this.shippingMethod,
    required this.closed,
    required this.fee,
    required this.shippingCostCents
  });

  // Editing transaction methods
  void submitStatus(TransactionStatus status) {
    DatabaseService(companyID: companyID, config: config).updateStatus(this, status).then((value) {
      if (value is! TransactionError) {
        this.status = status;
      }
    }
    );
  }

  void statusForward() {
    List<TransactionStatus> orderedStatus = TransactionStatus.values;
    if (status != TransactionStatus.pickedup && status != TransactionStatus.delivered) {
      switch (shippingMethod) {
        case ShippingMethod.pickUp: {
          if (status == TransactionStatus.prepared) {
            submitStatus(orderedStatus[orderedStatus.indexOf(status) + 2]);
          } else {
            submitStatus(orderedStatus[orderedStatus.indexOf(status) + 1]);
          }
          break;
        }
        case ShippingMethod.sellerShipping || ShippingMethod.flameoShipping: {
          if (status == TransactionStatus.pending || status == TransactionStatus.sent) {
            submitStatus(orderedStatus[orderedStatus.indexOf(status) + 2]);
          } else {
            submitStatus(orderedStatus[orderedStatus.indexOf(status) + 1]);
          }
          break;
        }
      }
    }
  }

  void statusBackward() {
    List<TransactionStatus> orderedStatus = TransactionStatus.values;
    if (status != orderedStatus.first) {
      switch (shippingMethod) {
        case ShippingMethod.pickUp: {
          if (status == TransactionStatus.pickedup) {
            submitStatus(orderedStatus[orderedStatus.indexOf(status) - 2]);
          } else {
            submitStatus(orderedStatus[orderedStatus.indexOf(status) - 1]);
          }
          break;
        }
        case ShippingMethod.sellerShipping || ShippingMethod.flameoShipping: {
          if (status == TransactionStatus.delivered || status == TransactionStatus.sent) {
            submitStatus(orderedStatus[orderedStatus.indexOf(status) - 2]);
          } else {
            submitStatus(orderedStatus[orderedStatus.indexOf(status) - 1]);
          }
          break;
        }
      }
    }
  }

  // Useful getters
  double get amount => cartItems.map((e) => e.totalPrice).reduce((a, b) => a + b);
  String get amountEuro => "${amount.toStringAsFixed(2)} €";
  String get dateStr => DateFormat('dd/MM/yyyy').format(date.toDate());

  // CompanyPreferences companyPreferences(ConfigProvider config) {
  //   CompanyPreferences companyPreferences;
  //   DatabaseService(companyID: this.companyID, config: config).companyPreferences.then((value) {
  //     companyPreferences = value;
      
  //   });
  //   return companyPreferences;
  // }

  String get feeStr {
    double feeEuro = this.fee/100;
    return "${feeEuro.toStringAsFixed(2)} €";
  }

  // Conversion methods
  static MyTransaction fromDict(Map<String, dynamic> data, String companyId, ConfigProvider config) => MyTransaction(
    companyID: data['companyId'],
    fee: data['fee'] ?? 0,
    shippingCostCents: data['shippingCostCents'] ?? 0,
    transactionID: data['transactionId'],
    date: data['timestamp'],
    status: TransactionStatus.values.byName(data['status']),
    clientContact: ClientContact.fromDict(data['clientContact']),
    closed: data['closed'] ?? false,
    shippingMethod: ShippingMethod.values.byName(data['shippingMethod'] ?? 'pickUp'), //TODO Fut eliminar cuando todas las transacciones sean nuevas
    cartItems: data['cartItems']?.map((e) => CartItem.fromDict(e, companyId, config))?.toList().cast<CartItem>(),
    config: config
  );

  factory MyTransaction.fromFirestore(DocumentSnapshot doc, String companyId, ConfigProvider config) {
    Map<String, dynamic> data = downloadDocSnapshot(doc);
    data['transactionId'] = doc.id;
    data['companyId'] = companyId;
    return fromDict(data, companyId, config);
  }
}

// Stripe link waiter used to listen to the coming link before set it in the cart
class StripeLinkWaiter {
  DocumentReference transactionReference;
  DocumentReference? checkoutSessionReference;
  String? link;

  StripeLinkWaiter({required this.transactionReference});
}

// Status enums
enum TransactionStatus {
  pending,
  prepared,  // Only for pickup shipping method
  sent,  // Only for seller shipping
  pickedup,  // Only for pickup shipping method
  delivered,  // Only for seller shipping
  cancelled
}

// Errors enums
enum TransactionError {
  databaseAdd,
  updateStatus
}

  // Function that returns the next value in the transaction status enum
  TransactionStatus getNextStatus(ShippingMethod shippingMethod, TransactionStatus status) {
    switch (shippingMethod) {
      case ShippingMethod.pickUp: {
        switch (status) {
          case TransactionStatus.pending:
            return TransactionStatus.prepared;
          case TransactionStatus.prepared:
            return TransactionStatus.pickedup;
          default:
            return status;
        }
      }
      case ShippingMethod.sellerShipping || ShippingMethod.flameoShipping: {
        switch(status) {
          case TransactionStatus.pending:
            return TransactionStatus.sent;
          case TransactionStatus.sent:
            return TransactionStatus.delivered;
          default:
            return status;
        }
      }
    }
  }

  // Function that returns the previous value in the transaction status enum
  TransactionStatus getPreviousStatus(ShippingMethod shippingMethod, TransactionStatus status) {
    switch (shippingMethod) {
      case ShippingMethod.pickUp: {
        switch (status) {
          case TransactionStatus.pickedup:
            return TransactionStatus.prepared;
          case TransactionStatus.prepared:
            return TransactionStatus.pending;
          default:
            return status;
        }
      }
      case ShippingMethod.sellerShipping || ShippingMethod.flameoShipping: {
        switch(status) {
          case TransactionStatus.delivered:
            return TransactionStatus.sent;
          case TransactionStatus.sent:
            return TransactionStatus.pending;
          default:
            return status;
        }
      }
    }
  }