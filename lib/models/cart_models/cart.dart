import 'dart:convert';

import 'package:collection/collection.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flameo/models/cart_models/cart_item.dart';
import 'package:flameo/models/client_contact.dart';
import 'package:flameo/models/client_user.dart';
import 'package:flameo/models/transaction.dart';
import 'package:flameo/models/userproduct.dart';
import 'package:flameo/services/config_provider.dart';

import 'package:flameo/services/database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Cart {
  final CompanyPreferences companyPreferences;

  List<CartItem> cartItems = [];
  ClientContact? clientContact;
  ShippingMethod? shippingMethod;
  List<StripeLinkWaiter> stripeLinkWaiters = [];

  Cart({required this.companyPreferences});

  // Cache constructor
  static Future<Cart> cache(CompanyPreferences companyPreferences, ConfigProvider config) async {
    return await SharedPreferences.getInstance().then((SharedPreferences prefs) {
      Cart cart = Cart(companyPreferences: companyPreferences);
      String? cartCache = prefs.getString(companyPreferences.companyID);
      if (cartCache != null) {
        Map<String, dynamic> cartCacheData = jsonDecode(cartCache) as Map<String, dynamic>;
        if (Timestamp.now().seconds - cartCacheData['timestamp'] < 24 * 3600) {
          if (cartCacheData['clientContact'] != null) {
            cart.clientContact = ClientContact.fromDict(cartCacheData['clientContact']);
          }
          cart.cartItems = (cartCacheData['cartItems'] as List).map((cartItemData) => 
            CartItem.fromDict(cartItemData, companyPreferences.companyID, config)
          ).toList();
        }
      }
      return cart;
    });
  }

  // Cache methods
  void saveToCache() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> cartCacheData = {
      'timestamp': Timestamp.now().seconds,
      'clientContact': this.clientContact?.toDict(),
      'cartItems': this.cartItemsDict
    };
    prefs.setString(companyPreferences.companyID, jsonEncode(cartCacheData));
  }

  void clearCache() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(companyPreferences.companyID);
  }

  // Cart link methods
  String shareLink(String panelName, ConfigProvider config) {
    if (companyPreferences.subdomain != null) {
      return 'https://${config.get(companyPreferences.subdomain!)}.${config.get('base_link')}/?cart=${base64.encode(utf8.encode(jsonEncode(this.cartItemsDict)))}';
    } else {
      return 'https://${config.get('base_link')}/panel?name=$panelName&cart=${base64.encode(utf8.encode(jsonEncode(this.cartItemsDict)))}';
    }
  }
  
  static Cart fromLinkReference(CompanyPreferences companyPreferences, String linkReference, ConfigProvider config) {
    Cart cart = Cart(companyPreferences: companyPreferences);
    cart.cartItems = (jsonDecode(utf8.decode(base64.decode(linkReference))) as List).map((cartItemData) => 
      CartItem.fromDict(cartItemData, companyPreferences.companyID, config)
    ).toList();
    return cart;
  }

  // Editing cart methods
  void removeCartItem(CartItem cartItem) {
    this.cartItems.remove(cartItem);
    saveToCache();
  }

  void addCartItem(CartItem cartItem) {
    if (this.cartItems.map((e) => e.product.id).contains(cartItem.product.id)) {
      this.cartItems.firstWhere((e) => e.product.id == cartItem.product.id).quantity += cartItem.quantity;
    } else {
      cartItem.setParentCart(this);
      this.cartItems.add(cartItem);
    }
    saveToCache();
  }

  void emptyCart() {
    this.cartItems = [];
    saveToCache();
  }

  void setClientContact(ClientContact newClientContact) {
    this.clientContact = newClientContact;
    this.clientContact!.saveToCache();
    saveToCache();
  }

  void setAdress(Address address) {
    this.clientContact!.setAddress(address);
    saveToCache();
  }

  // Useful getters
  double get subTotalAmount {
    if (cartItems.isNotEmpty) {
      return cartItems.map((e) => e.totalPrice).reduce((a, b) => a + b);
    } else {
      return 0;
    }
  }

  String get subTotalAmountEuro => '${subTotalAmount.toStringAsFixed(2)} €';

  double get totalAmount => subTotalAmount + shippingCostCents / 100;

  String get totalAmountEuro => '${totalAmount.toStringAsFixed(2)} €';

  int get fee {
    if (shippingMethod == ShippingMethod.flameoShipping) {
      return ((this.subTotalAmount * 100) * this.companyPreferences.feeRate + 25 + shippingCostCents).toInt();
    } else {
      return (this.subTotalAmount * this.companyPreferences.feeRate * 100 + 25).toInt();
    }
  }

  int get shippingCostCents {
    if (shippingMethod == ShippingMethod.sellerShipping) {
      return companyPreferences.shippingCostCents;
    } else {
      return 0;
    }
  }
  
  String get feeEuro {
    return '${(this.fee / 100).toStringAsFixed(2)} €';
  }

  CartItem? cartItemOfProduct(UserProduct product) {
    return this.cartItems.firstWhereOrNull((cartItem) => cartItem.product.id == product.id);
  }

  // Submit method to upload this to firebase
  Future<dynamic> submit(ConfigProvider config) async {
    if (this.clientContact == null) return CartError.clientContactNeeded;
    if (this.cartItems.isEmpty) return CartError.cartEmtpy;
    for (CartItem cartItem in this.cartItems) {
      UserProductStatus currentStatus = await DatabaseService(companyID: this.companyPreferences.companyID, config: config).productAvailable(cartItem);
      if (currentStatus != UserProductStatus.ok) {
        return currentStatus;
      }
    }
    for (CartItem cartItem in this.cartItems) {
      UserProductError? result = await DatabaseService(companyID: companyPreferences.companyID, config: config).updateProductFields(
        cartItem.product.id!,
        {'stock': cartItem.product.stock - cartItem.quantity}
      );
      if (result != null) {
        return CartError.submitError;
      }
    }
    TransactionError? transactionResult = await DatabaseService(companyID: companyPreferences.companyID, config: config).addTransaction(this);
    if (transactionResult != null) {
      return transactionResult;
    }
    clearCache();
    return null;
  }

  // Conversion methods
  List<Map<String, dynamic>> get cartItemsDict =>
    this.cartItems.map((CartItem cartItem) => cartItem.toDict()).toList();

  Map<String, dynamic> toDict() => {
    'clientContact': this.clientContact?.toDict(),
    'fee': this.fee,
    'shippingCostCents': this.shippingCostCents,
    'cartItems': this.cartItems.map((e) => e.toDict()).toList(),
    'shippingMethod': (shippingMethod ?? ShippingMethod.pickUp).name
  };

  static Cart fromDict(Map<String, dynamic> data, CompanyPreferences companyPreferences, ConfigProvider config) {
    Cart result = Cart(companyPreferences: companyPreferences);
    result.clientContact = ClientContact.fromDict(data['clientContact']);
    result.cartItems = data['cartItems'].map((e) => CartItem.fromDict(e, companyPreferences.companyID, config));
    return result;
  }
}

// Validation cart enums
enum CartError {
  clientContactNeeded,
  cartEmtpy,
  submitError
}

// Shipping methods
enum ShippingMethod {
  pickUp,
  sellerShipping,
  flameoShipping
}
