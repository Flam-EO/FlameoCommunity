import 'dart:math';

import 'package:flameo/models/client_user.dart';
import 'package:flameo/models/photo.dart';
import 'package:flameo/models/userproduct.dart';
import 'package:flameo/services/cloudstorage.dart';
import 'package:flameo/shared/loading.dart';
import 'package:flameo/shared/platform.dart';
import 'package:flameo/shared/utils.dart';
import 'package:flameo/views/home/micro/price_panel/internal/new_photos.dart';
import 'package:flameo/views/home/micro/price_panel/internal/size_selector.dart';
import 'package:flutter/material.dart';
import 'package:searchfield/searchfield.dart';

/// EditablePanelElement: This widget renders each of the cards in the panel
class EditablePanelElement extends StatefulWidget {

  final UserProduct product;
  final CompanyPreferences companyPreferences;

  const EditablePanelElement({super.key, required this.product, required this.companyPreferences});

  @override
  State<EditablePanelElement> createState() => _EditablePanelElementState();
}

class _EditablePanelElementState extends State<EditablePanelElement> {

  final formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController(text: "");
  TextEditingController categoryController = TextEditingController(text: "");
  TextEditingController descriptionController = TextEditingController(text: "");
  TextEditingController stockController = TextEditingController(text: "");
  TextEditingController priceController = TextEditingController(text: "");
  final TextEditingController _widthController = TextEditingController(text: "");
  final TextEditingController _heightController = TextEditingController(text: "");

  FocusNode priceFocusNode = FocusNode();
  FocusNode stockFocusNode = FocusNode();
  FocusNode descriptionFocusNode = FocusNode();

  DateTime _lastSnackbarTimestamp = DateTime.now();

  Map<String, double> uploadPhotosProgress = {};
  Map<String, UploadingStatus> uploadPhotosStatus = {};

  List<Photo>? currentPhotos;
  @override
  void initState() {
    super.initState();
    currentPhotos = null;
    widget.product.downloadPhotoLinks().then((_) => Future.delayed(Duration.zero, () {
      if (mounted) setState(() {currentPhotos = List<Photo>.from(widget.product.photos!);});
    }));
    nameController.text = widget.product.name;
    descriptionController.text = widget.product.description ?? '';
    priceController.text = "${widget.product.price}";
    stockController.text = "${widget.product.stock}";
    categoryController.text = widget.product.category ?? '';
    List<String> splittedSize = widget.product.size?.split(' x ') ?? [''];
    if (splittedSize.length == 2) {
      _widthController.text = splittedSize.first;
      _heightController.text = splittedSize.last;
    } else if (splittedSize.length > 2) {
      _widthController.text = splittedSize.join(' x ');
    } else {
      _widthController.text = splittedSize.first;
    }
  }

  void updateProduct() {
    widget.product.setEditables(
      editedName: nameController.text.trim(),
      editedDescription: descriptionController.text.trim(),
      editedStock: double.parse(stockController.text),
      editedPrice: double.parse(double.parse(priceController.text.replaceAll(',', '.')).toStringAsFixed(2)),
      editedPhotos: currentPhotos!.map((photo) => photo.name).toList(),
      editedCategory: categoryController.text,
      editedSize: _heightController.text.isEmpty ? 
      _widthController.text.isEmpty ? null : _widthController.text
    : '${_widthController.text} x ${_heightController.text}'
    );
    widget.companyPreferences.addCategory(categoryController.text, widget.product.config);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Producto actualizado'),
      backgroundColor: Theme.of(context).colorScheme.primary,
      elevation: 10
    ));
  }

  Widget productAttributesForm(double height, double width) {
    return Form(
      key: formKey,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSecondary,
          borderRadius: const BorderRadius.all(Radius.circular(10.0))
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextFormField(
                enabled: uploadPhotosProgress.isEmpty,
                controller: nameController,
                decoration: inputDecoration("Nombre"),
                validator: nameFieldValidator,
                onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(priceFocusNode)
              ),
              const SizedBox(height: 20),
              SearchField<String>(
                textCapitalization: TextCapitalization.sentences,
                onSuggestionTap: (_) => FocusScope.of(context).requestFocus(FocusNode()),
                controller: categoryController,
                validator: (value) => ((value?.trim().length ?? 0) > 30) ? 'Nombre demasiado largo' : null,
                searchInputDecoration: inputDecoration('Categoria (opcional)'),
                suggestions: widget.companyPreferences.categorySuggestions.map(
                  (categorySuggestion) => SearchFieldListItem<String>(
                    categorySuggestion,
                    item: categorySuggestion,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(categorySuggestion)
                    )
                  )
                ).toList()
              ),
              const SizedBox(height: 20),
              SizeSelector(
                enabled: uploadPhotosProgress.isEmpty,
                widthController: _widthController,
                heightController: _heightController
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      enabled: uploadPhotosProgress.isEmpty,
                      focusNode: priceFocusNode,
                      controller: priceController,
                      decoration: inputDecoration("Precio"),
                      validator: priceFieldValidator,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(stockFocusNode)
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: TextFormField(
                      enabled: uploadPhotosProgress.isEmpty,
                      focusNode: stockFocusNode,
                      controller: stockController,
                      decoration: inputDecoration("Stock"),
                      validator: integerFieldValidator,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(descriptionFocusNode)
                    )
                  )
                ]
              ),
              const SizedBox(height: 20),
              TextFormField(
                enabled: uploadPhotosProgress.isEmpty,
                focusNode: descriptionFocusNode,
                controller: descriptionController,
                maxLines: 6,
                decoration: inputDecoration("Descripción"),
                validator: descriptionFieldValidator
              ),
              const Expanded(child: SizedBox()),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (uploadPhotosProgress.isNotEmpty) Text(
                    'Subiendo fotos ${100 * uploadPhotosProgress.values.toList().fold(0.0, (a,b) => a+b) ~/ uploadPhotosProgress.length} %'
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.onBackground),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)
                        )
                      )
                    ),
                    onPressed: uploadPhotosProgress.isNotEmpty ? null : () {
                      if (formKey.currentState!.validate()) {
                        if (currentPhotos?.isEmpty ?? true) {
                          if (elapsedTimeChecker(_lastSnackbarTimestamp, 2000) && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Theme.of(context).colorScheme.error,
                                content: const Text('Necesitas subir al menos una foto del producto', textAlign: TextAlign.center),
                                duration: const Duration(seconds: 2),
                              )
                            );
                            _lastSnackbarTimestamp = DateTime.now();
                          }
                          return;
                        }
                        List<Photo> photosToUpload = currentPhotos?.where((photo) => photo.link == null).toList() ?? [];
                        if (photosToUpload.isNotEmpty) {
                          CloudService(companyID: widget.product.companyID).addProductPhotos(
                            widget.product.id!,
                            photosToUpload,
                            (double progress, String fileName) {
                              if (mounted) setState(() => uploadPhotosProgress[fileName] = progress);
                            },
                            (UploadingStatus uploadingStatus, String fileName) {
                              uploadPhotosStatus[fileName] = uploadingStatus;
                              if (mounted && uploadPhotosStatus.values.every((uploadingStatus) => uploadingStatus == UploadingStatus.success) ) { 
                                updateProduct();
                              }
                            }
                          );
                        } else {
                          updateProduct();
                        }
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text(
                        'Confirmar',
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.white
                        )
                      )
                    )
                  ),
                ],
              )
            ]
          )
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
  
    ScreenSize screensize = ScreenSize(context);

    Widget wideLayout = SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: 450,
                height: 500,
                child: currentPhotos != null ? NewPhotos(
                  preLoadedPhotos: currentPhotos!,
                  enabled: uploadPhotosProgress.isEmpty
                ) : const Loading()
              ),
              productAttributesForm(750, 500)
            ]
          ),
        )
      ),
    );

    Widget thinLayout = SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            SizedBox(
              width: min(500, screensize.width - 10 * 2),
              child: currentPhotos != null ? NewPhotos(
                preLoadedPhotos: currentPhotos!,
                enabled: uploadPhotosProgress.isEmpty
              ) : const Loading()
            ),
            const SizedBox(height: 50),
            productAttributesForm(750, screensize.width - 20)
          ]
        )
      )
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text(
          "Editar Producto",
          style: TextStyle(color: Colors.white, fontSize: 25)
        ),
        backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          )
        ),
      ),
      body: screensize.aspectRatio > 1.2 ? wideLayout : thinLayout
    );
  }
}
