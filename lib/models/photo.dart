import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flameo/shared/utils.dart';

class Photo {
  final String name;
  Uint8List? data;
  Uint8List? thumbnailData;
  String? link;
  String? thumbnailLink;
  String? extension;

  Photo({required this.name, this.data, this.link, this.thumbnailData, this.thumbnailLink, this.extension});

  // Conversion methods
  static Future<Photo> fromFile(PlatformFile file, {String? name}) async {
    String extension = file.name.split(".").last;
   
    return Photo(
      name: name == null ? '${generateCode(length: 20)}.$extension' : '$name.$extension',
      data: file.bytes,
      thumbnailData: await resizeImage(file.bytes, 500), // Thumbnail size 
      extension: extension
    );
  }
}
