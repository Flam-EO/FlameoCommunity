import 'package:flameo/models/cart_models/cart.dart';
import 'package:flameo/models/photo.dart';

import 'package:flameo/models/userproduct.dart';
import 'package:flameo/services/config_provider.dart';

class CartItem {
  // Each item that can be added to a shopping cart (MyTransaction)

  UserProduct product;
  UserProductStatus productStatus;
  int quantity;

  CartItem({required this.product, required this.quantity, this.productStatus = UserProductStatus.ok});

  // Got the parent instance to use in logic
  late Cart parentCart;
  void setParentCart(Cart givenCart) => parentCart = givenCart;

  // Editing item methods
  void addOne() {
    if (product.stock > quantity){
      quantity++;
      parentCart.saveToCache();
    }
  }

  void removeOne() {
    if (quantity > 1) {
      quantity--;
    } else {
      removeMe();
    }

    parentCart.saveToCache();
  }

  void removeMe() => parentCart.removeCartItem(this);

  // Useful getters
  double get totalPrice => product.price * quantity;
  String get totalPriceEuro => '$totalPrice €';
  String get measureStr => quantity > 1 ? "${product.measure}s" : product.measure; 

  // Conversion methods
  Map<String, dynamic> toDict() {
    Map<String, dynamic> result = product.toDict();
    result.remove('description');
    result['productId'] = product.id;
    result['price'] = product.price;
    result['quantity'] = quantity;
    return result;
  }

  static CartItem fromDict(Map<String, dynamic> data, String companyID, ConfigProvider config) => CartItem(
    product: UserProduct(
      companyID: companyID,
      name: data['name'],
      measure: data['measure'],
      stock: data['stock'],
      price: data['price'],
      id: data['productId'],
      photos: data['photos']?.map((dynamic fileName) => Photo(name: fileName))?.toList().cast<Photo>(),
      config: config,
      active: data['active'] ?? true,
      size: data['size']
    ),
    quantity: data['quantity']
  );
}