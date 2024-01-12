import 'package:flameo/models/photo.dart';
import 'package:logging/logging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flameo/models/userproduct.dart';

class CloudService {

  String? companyID;

  CloudService({this.companyID});

  // Logger for the CloudService Class
  final _log = Logger('CloudService');

  final cloudStorageRef = FirebaseStorage.instance.ref();

  void listenTask(
    UploadTask task,
    String uploadID,
    void Function(double progress, String fileName) uploadingProgressUpdater,
    void Function(UploadingStatus uploadingStatus, String filename) uploadStatusUpdater
  ) {
    task.snapshotEvents.listen((TaskSnapshot snapshot) {
      uploadingProgressUpdater(snapshot.bytesTransferred / snapshot.totalBytes, uploadID);
      if (snapshot.state == TaskState.success) {
        uploadStatusUpdater(UploadingStatus.success, uploadID);
      } else if (snapshot.state == TaskState.running) {
        uploadStatusUpdater(UploadingStatus.uploading, uploadID);
      } else {
        uploadStatusUpdater(UploadingStatus.error, uploadID);
      }
    }, 
    onError: (e) {
      _log.warning("Error en la subida de foto: $e");
      uploadStatusUpdater(UploadingStatus.error, uploadID);
    });
  }

  Future<void> addProductPhotos(
    String productId,
    List<Photo> photos,
    void Function(double progress, String fileName) uploadingProgressUpdater,
    void Function(UploadingStatus uploadingStatus, String fileName) uploadStatusUpdater
  ) async {
    Reference? companiesRef = cloudStorageRef.child("Companies").child("$companyID");
    List<UploadTask> tasks = [];
    for (Photo photo in photos) {
      UploadTask task = companiesRef.child("products/$productId/${photo.name}").putData(
        photo.data!,
        SettableMetadata(contentType: 'image/${photo.extension}')
      );
      UploadTask thumbnailTask = companiesRef.child("products/$productId/thumbnails/${photo.name}").putData(
        photo.thumbnailData!,
        SettableMetadata(contentType: 'image/${photo.extension}')
      );
      tasks.add(task);
      tasks.add(thumbnailTask);
      listenTask(task, photo.name, uploadingProgressUpdater, uploadStatusUpdater);
      listenTask(thumbnailTask, '${photo.name}.thumbnail', uploadingProgressUpdater, uploadStatusUpdater); 
    }
    for (UploadTask task in tasks) {
      await task;
    }
  }

  Future<void> downloadProductUrls(UserProduct product) async {
    for (Photo photo in product.photos!) {
      try {
        photo.link ??= await FirebaseStorage.instance
          .refFromURL("gs://flameoapp-pyme.appspot.com/Companies/$companyID/products/${product.id}/${photo.name}")
          .getDownloadURL();
        photo.thumbnailLink ??= await FirebaseStorage.instance
          .refFromURL("gs://flameoapp-pyme.appspot.com/Companies/$companyID/products/${product.id}/thumbnails/${photo.name}")
          .getDownloadURL();
      } on FirebaseException catch (e) {
        _log.warning("Failed with error '${e.code}': ${e.message}");
      }
    }
  }

  Future<Photo> landscapeUrl(String name) async {
    try {
      return Photo(
        name: name,
        link: await FirebaseStorage.instance.refFromURL(
          "gs://flameoapp-pyme.appspot.com/Companies/$companyID/$name"
        ).getDownloadURL()
      );
    } on FirebaseException catch (e) {
      _log.warning("Failed with error '${e.code}': ${e.message}");
      return Photo(name: name);
    }
  }

  Future<String?> backgroundLogo() async {
    try {
      return await FirebaseStorage.instance.refFromURL(
          "gs://flameoapp-pyme.appspot.com/gallery_background.gif"
        ).getDownloadURL();
    } on FirebaseException catch (e) {
      _log.warning("Failed with error '${e.code}': ${e.message}");
      return null;
    }
  }

  Future<void> addLandscapePhoto(
    Photo photo,
    void Function(double progress, String fileName) uploadingProgressUpdater,
    void Function(UploadingStatus uploadingStatus, String fileName) uploadStatusUpdater
  ) async {
    Reference? companiesRef = cloudStorageRef.child("Companies").child("$companyID");
    UploadTask task = companiesRef.child(photo.name).putData(
      photo.data!,
      SettableMetadata(contentType: 'image/${photo.extension}')
    );
     listenTask(task, photo.name, uploadingProgressUpdater, uploadStatusUpdater);
  }

}

enum UploadingStatus {
  uploading,
  success,
  error
}
