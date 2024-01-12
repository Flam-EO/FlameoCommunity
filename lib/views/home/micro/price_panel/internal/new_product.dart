import 'dart:math';

import 'package:flameo/models/client_user.dart';
import 'package:flameo/models/photo.dart';
import 'package:flameo/models/userproduct.dart';
import 'package:flameo/services/cloudstorage.dart';
import 'package:flameo/services/config_provider.dart';
import 'package:flameo/shared/platform.dart';
import 'package:flameo/shared/utils.dart';
import 'package:flameo/views/home/micro/price_panel/internal/new_photos.dart';
import 'package:flameo/views/home/micro/price_panel/internal/size_selector.dart';
import 'package:flutter/material.dart';
import 'package:searchfield/searchfield.dart';

class NewProduct extends StatefulWidget {

  final ConfigProvider config;
  final CompanyPreferences companyPreferences;

  const NewProduct(this.companyPreferences, {super.key, required this.config});

  @override
  State<NewProduct> createState() => _NewProductState();
}

class _NewProductState extends State<NewProduct> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController(text: "");
  final TextEditingController _categoryController = TextEditingController(text: "");
  final TextEditingController _descriptionController = TextEditingController(text: "");
  final TextEditingController _stockController = TextEditingController(text: "1");
  final TextEditingController _priceController = TextEditingController(text: "");
  final TextEditingController _widthController = TextEditingController(text: "");
  final TextEditingController _heightController = TextEditingController(text: "");
  bool isChecked = false;
  FocusNode priceFocusNode = FocusNode();
  FocusNode stockFocusNode = FocusNode();
  FocusNode descriptionFocusNode = FocusNode();

  Map<String, double> uploadPhotosProgress = {};
  Map<String, UploadingStatus> uploadPhotosStatus = {};

  DateTime _lastSnackbarTimestamp = DateTime.now();

  UserProduct buildUserProduct() => UserProduct(
    name: _nameController.text.trim(),
    config: widget.config,
    measure: Measure.unit,
    description: _descriptionController.text.trim(),
    stock: double.parse(_stockController.text),
    price: double.parse(double.parse(_priceController.text.replaceAll(',', '.')).toStringAsFixed(2)),
    companyID: widget.companyPreferences.companyID,
    category: _categoryController.text.isEmpty ? null : _categoryController.text,
    active: true,
    iswrittenart: isChecked,
    galleryPunctuation: widget.companyPreferences.isPublic ? 1 : 0,
    size: _heightController.text.isEmpty ? 
      _widthController.text.isEmpty ? null : _widthController.text
    : '${_widthController.text} x ${_heightController.text}'
  );

  List<Photo> preLoadedPhotos = [];

  void submitProduct() async {
    if (_formKey.currentState!.validate()) {
      UserProduct product = buildUserProduct();
      product.addPhotos(preLoadedPhotos);
      if (product.photos!.isEmpty) {
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
      product.toFirebase(
        uploadingProgressUpdater: (double progress, String fileName) {
          Future.delayed(Duration.zero, () {if (mounted) setState(() => uploadPhotosProgress[fileName] = progress);});
        },
        uploadStatusUpdater: (UploadingStatus uploadingStatus, String fileName) {
          uploadPhotosStatus[fileName] = uploadingStatus;
          if (mounted && uploadPhotosStatus.values.every((uploadingStatus) => uploadingStatus == UploadingStatus.success) ) { 
            _nameController.text = "";
            _descriptionController.text = "";
            _priceController.text = "";
            _stockController.text = "";
            _categoryController.text = "";
            _widthController.text = "";
            _heightController.text = "";
            uploadPhotosProgress = {};
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Text('Producto nuevo añadido'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              elevation: 10
            ));
          }
        },
        companyPreferences: widget.companyPreferences
      );
      widget.companyPreferences.addCategory(_categoryController.text, widget.config);
    }
  }
  
  Widget productAttributesContainer(double width) {
    return Form(
      key: _formKey,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSecondary,
          borderRadius: const BorderRadius.all(Radius.circular(10.0))
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              TextFormField(
                enabled: uploadPhotosProgress.isEmpty,
                controller: _nameController,
                decoration: inputDecoration("Nombre"),
                validator: nameFieldValidator,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(priceFocusNode);
                }
              ),
                const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 0.5),
                      color: Theme.of(context).colorScheme.onSecondary,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8, top: 8, bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          const Text('¿Es una obra literaria?', style: TextStyle(fontSize: 14),),
                          Checkbox(
                            value: isChecked,
                            onChanged: (newValue) {
                              setState(() {
                                isChecked = newValue!;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
              const SizedBox(height: 20),
              SearchField<String>(
                textCapitalization: TextCapitalization.sentences,
                onSuggestionTap: (_) => FocusScope.of(context).requestFocus(FocusNode()),
                controller: _categoryController,
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
                      controller: _priceController,
                      decoration: inputDecoration("Precio"),
                      validator: priceFieldValidator,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(stockFocusNode);
                      }
                    )
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: TextFormField(
                      enabled: uploadPhotosProgress.isEmpty,
                      focusNode: stockFocusNode,
                      controller: _stockController,
                      decoration: inputDecoration("Stock"),
                      validator: integerFieldValidator,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(descriptionFocusNode);
                      }
                    )
                  )
                ]
              ),
              const SizedBox(height: 20),
              if (!isChecked) TextFormField(
                enabled: uploadPhotosProgress.isEmpty,
                focusNode: descriptionFocusNode,
                controller: _descriptionController,
                maxLines: 6,
                decoration: inputDecoration("Descripción"),
                validator: descriptionFieldValidator
              ),
              if (isChecked) TextFormField(
                enabled: uploadPhotosProgress.isEmpty,
                focusNode: descriptionFocusNode,
                controller: _descriptionController,
                maxLines: 16,
                decoration: inputDecoration("Descripción"),
                
              ),

            ]
          )
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
  
    ScreenSize screensize = ScreenSize(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text(
          "Nuevo Producto",
          style: TextStyle(color: Colors.white, fontSize: 25),
        ),
        backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          )
        )
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Center(
            child: Column(
              children: [
                NewPhotos(preLoadedPhotos: preLoadedPhotos, enabled: uploadPhotosProgress.isEmpty),
                const SizedBox(height: 20),
                productAttributesContainer(min(screensize.width - 20, 500)),
                const SizedBox(height: 20),
                if (uploadPhotosProgress.isNotEmpty) Text(
                  'Subiendo fotos ${100 * uploadPhotosProgress.values.toList().fold(0.0, (a,b) => a+b) ~/ uploadPhotosProgress.length} %'
                )
              ]
            ),
          )
        )
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        onPressed: uploadPhotosProgress.isEmpty ? submitProduct : null,
        child: const Icon(
          fill: 0.1,
          Icons.upload,
          color: Colors.white
        )
      )
    );
  }
}
