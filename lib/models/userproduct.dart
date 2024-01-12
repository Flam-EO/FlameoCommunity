import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flameo/models/client_user.dart';
import 'package:flameo/models/photo.dart';
import 'package:flameo/services/cloudstorage.dart';
import 'package:flameo/services/config_provider.dart';
import 'package:flameo/services/database.dart';
import 'package:flameo/shared/utils.dart';

class UserProduct {

  // A single product present in panel
  
  late String? id;
  final String? companyID;
  String name;
  String? description;
  String measure;
  Timestamp? timestamp;
  late List<Photo>? photos;
  double stock;
  double price;
  bool? isDeleted;
  final ConfigProvider config;
  String? category;
  Timestamp? pinnedTimestamp;
  final bool active;
  int? galleryPunctuation; // Luis Gutierrez: Punctuation to classify the products that will be displayed in the gallery. 
  String? size;
  final bool iswrittenart;

  UserProduct({
    required this.name,
    required this.companyID,
    required this.measure,
    required this.stock,
    required this.price,
    this.iswrittenart = false,
    this.photos,
    this.id,
    this.description,
    this.timestamp,
    this.category,
    this.isDeleted = false,
    this.pinnedTimestamp,
    required this.active,
    required this.config,
    this.galleryPunctuation,
    required this.size
  }) {
    this.id ??= generateCode(length: 20);
    this.photos ??= [];
  }

  // Editing product methods to firebase
  void deleteProduct(CompanyPreferences? companyPreferences) => DatabaseService(companyID: companyID, config: config).deleteUserProduct(this, companyPreferences);

  void addOneToStock() => DatabaseService(companyID: companyID, config: config).updateProductFields(id!, {'stock': stock + 1});
  void removeOneFromStock() => DatabaseService(companyID: companyID, config: config).updateProductFields(id!, {'stock': stock - 1});
  void editStock(double newStock) => DatabaseService(companyID: companyID, config: config).updateProductFields(id!, {'stock': newStock});
  void pin() => DatabaseService(companyID: companyID, config: config).updateProductFields(id!, {'pinnedTimestamp': Timestamp.now()});
  void unPin() => DatabaseService(companyID: companyID, config: config).updateProductFields(id!, {'pinnedTimestamp': null});

  void setPrice(double newPrice) => DatabaseService(companyID: companyID, config: config).updateProductFields(id!, {'price': newPrice});
  void changeActive(bool newActive) => DatabaseService(companyID: companyID, config: config).updateProductFields(id!, {'active': newActive});

  void setEditables({
    required String editedName,
    required String editedDescription,
    required double editedStock,
    required double editedPrice,
    required List<String> editedPhotos,
    required String editedCategory,
    required String? editedSize
  }) {
    DatabaseService(companyID: companyID, config: config).updateProductFields(id!, {
      if (editedPrice != price) 'price': editedPrice,
      if (editedStock != stock) 'stock': editedStock,
      if (editedName != name) 'name': editedName,
      if (editedDescription != description) 'description': editedDescription,
      if (editedPhotos != photos!.map((photo) => photo.name).toList()) 'photos': editedPhotos,
      if (editedCategory != category) 'category': editedCategory,
      if (editedSize != size) 'size': editedSize
    });
  }

  // Useful methods
  void addPhotos(List<Photo> photos) {
    this.photos = this.photos! + photos;
  }

  Future<void> downloadPhotoLinks() async {
    if (!photos!.every((photo) => photo.link != null)) {
      await CloudService(companyID: this.companyID).downloadProductUrls(this);
    }
  }

  // Useful getters
  String get priceEuro => '$price €';
  String get measureStr => (stock) > 1 ? "${measure}s" : measure; 

  // Conversion methods
  factory UserProduct.fromFirestore(DocumentSnapshot doc, String companyID, ConfigProvider config) {
    Map<String, dynamic> data = downloadDocSnapshot(doc);
    return UserProduct(
      id: doc.id,
      companyID: companyID,
      name: data["name"],
      photos: List<Photo>.from(data['photos'].map((dynamic fileName) => Photo(name: fileName))),
      description: data["description"],
      measure: data["measure"] ?? Measure.unit,
      stock: data["stock"],
      price: data["price"],
      timestamp: data["timestamp"],
      isDeleted: data["is_deleted"],
      config: config,
      category: data['category'],
      pinnedTimestamp: data['pinnedTimestamp'],
      active: data['active'] ?? true,
      galleryPunctuation: data['galleryPunctuation'],
      size: data['size'],
      iswrittenart: data['iswrittenart'] ?? false
    );
  }

  void toFirebase({
    required void Function(double progress, String fileName) uploadingProgressUpdater,
    required void Function(UploadingStatus uploadingStatus, String fileName) uploadStatusUpdater,
    required CompanyPreferences? companyPreferences
  }) async {
    await CloudService(companyID: companyID).addProductPhotos(this.id!, this.photos!, uploadingProgressUpdater, uploadStatusUpdater);
    DatabaseService(companyID: companyID, config: config).addUserProduct(this, companyPreferences);
  }

  Map<String, dynamic> toDict() => {
    'name': name,
    'measure': measure,
    'timestamp': timestamp,
    'stock': stock,
    'price': price,
    'description': description,
    'is_deleted': isDeleted,
    'photos': photos!.map((photo) => photo.name).toList(),
    'category': category,
    'pinnedTimestamp': pinnedTimestamp,
    'active': active,
    'galleryPunctuation': galleryPunctuation,
    'size': size,
    'iswrittenart':iswrittenart
  };

  /// Sets the new value of galleryPunctuation in the product uploaded in firebase
  Future<void> setGalleryPunctuation(int punctuation) async {
    galleryPunctuation = punctuation;
    await DatabaseService(companyID: companyID, config: config).updateProductFields(id!, {'galleryPunctuation': punctuation});
  }

  Future<void> removeGalleryPunctuation() async {
    galleryPunctuation = null;
    await DatabaseService(companyID: companyID, config: config).updateProductFields(id!, {'galleryPunctuation': null});
  }

}

// Measure enums
class Measure {
  static String unit = 'ud';
  static String kg = 'kg';
}

// Error enums
enum UserProductError {
  databaseAdd,
  updateField,
  userProductDelete
}

// Status enums
enum UserProductStatus {
  deleted,
  insufficientStock,
  priceChanged,
  ok
}
