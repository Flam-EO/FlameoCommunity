import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flameo/models/cart_models/cart.dart';
import 'package:flameo/models/transaction.dart';
import 'package:flameo/models/userproduct.dart';
import 'package:flameo/services/config_provider.dart';
import 'package:flameo/shared/platform.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;

import 'package:image/image.dart' as image_lib;
import 'package:logging/logging.dart';
import 'package:url_launcher/url_launcher.dart';

// Classes
class DateVars {

  // Useful datetime methods and getters

  final DateTime _now = DateTime.now();

  DateTime get today => DateTime(_now.year, _now.month, _now.day);
  DateTime get tomonth => DateTime(_now.year, _now.month);
  DateTime get toyear => DateTime(_now.year);

  int weekOfYear(Timestamp timestamp) {
    final from = DateTime(timestamp.toDate().year, 1, 1);
    return (timestamp.toDate().difference(from).inDays / 7).ceil();
  }
}

// Constant vars

// Name of months to show in spanish
List<String> monthNames = [
  'ENERO',
  'FEBRERO',
  'MARZO',
  'ABRIL',
  'MAYO',
  'JUNIO',
  'JULIO',
  'AGOSTO',
  'SEPTIEMBRE',
  'OCTUBRE',
  'NOVIEMBRE',
  'DICIEMBRE'
];

// Useful functions
void saveFile(String filename, List<int> bytes) {

// Function to save a file locally, download bytes using filename

  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.document.createElement('a') as html.AnchorElement
    ..href = url
    ..style.display = 'none'
    ..download = filename;
  html.document.body?.children.add(anchor);

  anchor.click();

  html.document.body?.children.remove(anchor);
  html.Url.revokeObjectUrl(url);
}

// Download a document reference to a Map
Future<Map<String, dynamic>?> downloadDoc(DocumentReference doc) async =>
  (await doc.get()).data() as Map<String, dynamic>?;

// Download a document snapshot to a Map
Map<String, dynamic> downloadDocSnapshot(DocumentSnapshot doc) => doc.data() as Map<String, dynamic>;

String generateCode( {int length = 20})  {
  // Generate random alphanumeric codes of length
  String pool = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  Random r = Random();
  String code = '';
  for (var j = 0; j < length; j++) {
    code += pool[r.nextInt(pool.length)];
  }
  return code;
}

// Convert Uint8List to type image.Image in a efficient way using JS
Future<image_lib.Image?> decodeUint8ListToImage(Uint8List uint8List) async {  
  Completer<image_lib.Image?> completer = Completer<image_lib.Image>();
  html.Blob blob = html.Blob([uint8List]);
  String url = html.Url.createObjectUrlFromBlob(blob);
  html.ImageElement img = html.ImageElement(src: url)..crossOrigin = 'Anonymous';

  img.onLoad.listen((event) {
    html.Url.revokeObjectUrl(url);
    html.CanvasElement canvas = html.CanvasElement(width: img.width, height: img.height);
    html.CanvasRenderingContext2D ctx = canvas.context2D..drawImageScaled(img, 0, 0, img.width!, img.height!);
    html.ImageData imageData = ctx.getImageData(0, 0, img.width!, img.height!);
    Uint8List imgBytes = Uint8List.fromList(imageData.data);
    image_lib.Image image = image_lib.Image.fromBytes(img.width!, img.height!, imgBytes);
    completer.complete(image);
  });

  img.onError.listen((event) {
    html.Url.revokeObjectUrl(url);
    completer.completeError('Error al cargar la imagen.');
  });

  return completer.future;
}

// Resize image
Future<Uint8List?> resizeImage(Uint8List? imageData, int width) async {
  image_lib.Image? image = imageData != null ? await decodeUint8ListToImage(imageData) : null;
  image_lib.Image? newImage = image != null ? image_lib.copyResize(image, width: width) : null;
  return newImage != null ? Uint8List.fromList(image_lib.encodeJpg(newImage, quality: 40)) : null;
}

// Function to open a url
Future<void> openUrl(Uri url, [Logger? logger, String target='_blank']) async {
  if (!await launchUrl(url, webOnlyWindowName: target)) {
    if (logger!= null){
       logger.warning('The URL link could not be loaded.');
    }
   
  }
}

/// Method to check that enough time has elapsed between the instant when the function is called 
/// and a timestamp given to the function as an argument.
bool elapsedTimeChecker(DateTime? timestamp, int elapsedMilliseconds) {
  if (timestamp == null) return true;
  DateTime now = DateTime.now();
  Duration elapsedTime = now.difference(timestamp);
  if (elapsedTime.inMilliseconds > elapsedMilliseconds) {
    return true;
  } else {
    return false;
  }
}

// Extend String to have capitalize method
extension StringCustomMethods on String {
  String capitalize() {
    if (this.isEmpty) {
      return this;
    }
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

// Build a widget of type Text that looks like a link
Text linkText(String text, context, [double? fontSize]) => Text(
  text,
  maxLines: 2,
  style: TextStyle(
    fontSize: fontSize,
    color: Theme.of(context).colorScheme.primaryContainer,
    decoration: TextDecoration.underline,
    decorationColor: Theme.of(context).colorScheme.primaryContainer,
    decorationThickness: 2,
    decorationStyle: TextDecorationStyle.solid,
    overflow: TextOverflow.ellipsis,
  )
);

// Slide transaction function for company register
Future<void> rightSlideTransition(BuildContext context, Widget destination, {bool mounted = true}) async {
  await Navigator.of(context).push(
    PageRouteBuilder(
      pageBuilder: (_, __, ___) => destination,
      transitionDuration: const Duration(milliseconds: 500),
      transitionsBuilder: (_, animation, __, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeInOut)
          ),
          child: child
        );
      }
    )
  );
}

// Segmented option widgets for segmetend widgets
Widget segmentedOption(BuildContext context, String title, int loginSelection, int selectedValue) => SizedBox(
  width: 160,
  child: Center(
    child: Text(
      title,
      style: TextStyle(
        fontSize: 17,
          color: loginSelection == selectedValue
            ? Colors.white
            : Colors.black
      )
    )
  )
);

// ChildController class to manage child functions
class ChildController {
  dynamic Function()? callForward;
}

// Object to carry a product to open it if someone access directly to it
class LinkOpener {
  String? productID;
  String? cartReference;
  LinkOpener({required this.productID, required this.cartReference});

  factory LinkOpener.none() => LinkOpener(productID: null, cartReference: null);
}

// Global Enums
enum LoginScreen {
  // Different screens for the login (normal sign in and user registration)
  login,
  codereg,
  register,
  contact,
  recoverPassword
}

enum PopScreenResult {
  // Types of result a screen can return when poping
  back,
  home
}

enum PriceFormat {
  // Types of prices format
  priceKg,
  priceUnit
}

enum FlameoExtension {
  // The different extensions of flameo, different webs with some few changes
  main,
  art
}

String? floatFieldValidator(String? value) {
  if (value?.isEmpty ?? true) {
    return 'Introduce un valor en el campo';
  }
  else if (double.tryParse(value!.replaceAll(',', '.')) == null) {
    return 'Introduce un número válido';
  }
  return null;
}


// Precio mínimo de productos 
String? priceFieldValidator(String? value) {
  if (value?.isEmpty ?? true) {
    return 'Introduce un valor en el campo';
  }
  else if (double.tryParse(value!.replaceAll(',', '.')) == null) {
    return 'Introduce un número válido';
  }
  //else if((double.tryParse(value.replaceAll(',', '.')) ?? 0 )  < 3){
  //  return 'Precio mínimo de 3 €';
  //}
  return null;
}
// Validators for the different fields of a product

String? integerFieldValidator(String? value) {
  RegExp regex = RegExp(r'^[0-9]\d*$');
  if (value?.isEmpty ?? true) {
    return 'Introduce un valor en el campo';
  }
  else if (!regex.hasMatch(value!.replaceAll(',', '.').trim())) {
    return 'Introduce un número válido';
  }
  return null;
}

String? nameFieldValidator(String? value) {
  const maxNameLength = 30;
  if (value?.isEmpty ?? true) {
    return 'Introduce un nombre';
  }
  else if (value!.trim().length > maxNameLength) {
    return 'Nombre demasiado largo, el máximo número de caracteres es $maxNameLength';
  }
  return null;
}

String? descriptionFieldValidator(String? value) {
  const maxDescriptionLength = 160;
  if (value!.trim().length > maxDescriptionLength) {
    return 'Descripción demasiado larga, el máximo número de caracteres es $maxDescriptionLength';
  }
  return null;
}

InputDecoration inputDecoration(String hintText) {
  return InputDecoration(
    filled: true,
    fillColor: Colors.white,
    errorMaxLines: 4,
    border: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10.0))
      ),
    labelText: hintText
  );
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => { 
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    // etc.
  };
}

TextButton dialogButton(context, String text, VoidCallback callback) => TextButton(
  onPressed: callback,
  style: ButtonStyle(
    backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.secondary),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0))
    )
  ),
  child: Padding(
    padding: const EdgeInsets.all(8.0),
    child: Text(
      text,
      style: const TextStyle(fontSize: 12)
    )
  )
);

String transactionStatusName(TransactionStatus transactionStatus) {
  switch (transactionStatus) {
    case TransactionStatus.pending:
      return 'Pendiente';
    case TransactionStatus.prepared:
      return 'Listo para recogida';
    case TransactionStatus.sent:
      return 'Enviado';
    case TransactionStatus.pickedup:
      return 'Recogido';
    case TransactionStatus.delivered:
      return 'Entregado';
    case TransactionStatus.cancelled:
      return 'Cancelado';
  }
}

Color transactionStatusColor(TransactionStatus transactionStatus) {
  switch (transactionStatus) {
    case TransactionStatus.pending:
      return Colors.orange;
    case TransactionStatus.prepared:
      return Colors.blue;
    case TransactionStatus.sent:
      return Colors.blue;
    case TransactionStatus.pickedup:
      return Colors.green;
    case TransactionStatus.delivered:
      return Colors.green;
    case TransactionStatus.cancelled:
      return Colors.red;
  }
}

String shippingMethodName(ShippingMethod shippingMethod) {
  switch (shippingMethod) {
    case ShippingMethod.pickUp:
      return 'Recogida';
    case ShippingMethod.sellerShipping:
      return 'Envío';
    case ShippingMethod.flameoShipping:
      return 'Envío gestionado por Flameo';
    default:
      return shippingMethod.name;
  }
}

bool isArtEnvironment(ConfigProvider config) => [Environment.local, Environment.art, Environment.devart].contains(config.environment);

List<UserProduct> sortProducts(List<UserProduct> products) {
  List<UserProduct> pinnedProducts = products.where((product) => product.pinnedTimestamp != null).toList();
  List<UserProduct> unPinnedProducts = products.where((product) => product.pinnedTimestamp == null).toList();
  pinnedProducts.sort((b, a) => a.pinnedTimestamp!.seconds.compareTo(b.pinnedTimestamp!.seconds));
  unPinnedProducts.sort((b, a) => a.timestamp!.seconds.compareTo(b.timestamp!.seconds));
  return pinnedProducts + unPinnedProducts;
}

/// Function tu return the number of elements in a gridview given the minimum width specified 
/// for the elements.
int getNumElementsInGridView(ScreenSize screenSize, double minElementWidth) {
  if (screenSize.width < 2 * minElementWidth) {
    return 2;
  }
  return (screenSize.width / minElementWidth).floor();
}

/// Function to return the width of each element of the gridview given the minimum element width 
/// and the grid spacing selected.
double getWidthOfGridViewElement(ScreenSize screenSize, double minElementWidth, double gridSpacing) {
  int numOfElements = getNumElementsInGridView(screenSize, minElementWidth);
  return screenSize.width /  numOfElements - (numOfElements + 1) * gridSpacing;
}

/// Returns the aspect ratio of the gridview element (the 50 is an estimate for the height of the image titles)
double getChildAspectRatio(ScreenSize screenSize, double minElementWidth, double gridSpacing) {

  double width = getWidthOfGridViewElement(screenSize, minElementWidth, gridSpacing);
  return width/(width + 50);
}

// Different criterias to order the creations exposed in the gallery
enum GalleryCreationsOrder {
  relevance,
  priceAscending,
  priceDescending,
  newer,
  older
}

/// Checks if a URL has subdomain
bool hasSubdomain(String url) {
  Uri uri = Uri.parse(url);
  List<String> parts = uri.host.split('.');
  return parts.length > 2 && parts[0] != 'www';
}

/// Searches the location given by the address in google maps
void findOnMaps(String? address, [Logger? logger]) {
  var encodedAddress = Uri.encodeComponent(address ?? '');
  if (encodedAddress != '') {
    final Uri url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encodedAddress');
    openUrl(url, logger);
  }
}
