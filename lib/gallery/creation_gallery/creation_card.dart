import 'package:flameo/models/client_user.dart';
import 'package:flameo/models/userproduct.dart';
import 'package:flameo/models_widgets/photo_fit_contains.dart';
import 'package:flameo/services/config_provider.dart';
import 'package:flameo/services/database.dart';
import 'package:flameo/shared/loading.dart';
import 'package:flameo/shared/platform.dart';
import 'package:flameo/shared/utils.dart';
import 'package:flutter/material.dart';

class CreationCard extends StatefulWidget {

  final UserProduct product;
  final ConfigProvider config;
  final ScreenSize screenSize;

  const CreationCard({super.key, required this.product, required this.config, required this.screenSize});

  @override
  State<CreationCard> createState() => _CreationCardState();
}

class _CreationCardState extends State<CreationCard> {

  UserProduct? storedProduct;
  CompanyPreferences? storedCompanyPreferences;

  /// Downloads photolinks and company data for the product
  void downloadData() {
    downloadCompanyPreferences(widget.config, widget.product.companyID).then((value) {
        storedCompanyPreferences = value;
        widget.product.downloadPhotoLinks()
        .then((_) => Future.delayed(
            Duration.zero,
            (){
              if (widget.product.photos!.first.link == null) {
                downloadData();
              }
              if (mounted) {setState(() {storedProduct = widget.product; });}
            }
          )
        );
      }
    );
  }

  @override
  void initState() {
    downloadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    // Check if the photo has changed and download it
    if (storedProduct == null) {
      storedProduct = widget.product;
    } else {
      if (storedProduct!.photos!.first.name != widget.product.photos!.first.name ||
          storedProduct!.name != widget.product.name) {
        downloadData();
      }
    }

    return storedCompanyPreferences == null
    ? const Loading()
    : Column(
      children: [
        SizedBox(
          height: getWidthOfGridViewElement(widget.screenSize, 400, 10),
          width: getWidthOfGridViewElement(widget.screenSize, 400, 10),
          child: PhotoFitContains(
            photo: storedProduct!.photos!.first,
            boxFit: BoxFit.cover,
            thumbnail: true
          ),
        ),
        const SizedBox(height: 5),
        Text(storedProduct!.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(storedCompanyPreferences!.companyName)
      ],
    );
  }
}
