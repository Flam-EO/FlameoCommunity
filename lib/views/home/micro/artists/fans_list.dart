import 'package:flameo/models/client_user.dart';
import 'package:flameo/models/photo.dart';
import 'package:flameo/models/userproduct.dart';
import 'package:flameo/services/config_provider.dart';
import 'package:flameo/services/database.dart';
import 'package:flameo/shared/loading.dart';
import 'package:flameo/views/home/micro/artists/artist.dart';
import 'package:flutter/material.dart';

class FansList extends StatefulWidget {

  final CompanyPreferences companyPreferences;
  final ConfigProvider config;

  const FansList({super.key, required this.companyPreferences, required this.config});

  @override
  State<FansList> createState() => _FansListState();
}

class _FansListState extends State<FansList> {

  Map<String, CompanyPreferences> loadedCompanies = {};
  void loadCompany(String companyID) {
    if (loadedCompanies[companyID] == null) {
      DatabaseService(config: widget.config).fanCompanyPreferences(companyID).then((value) => 
        setState(() => loadedCompanies[companyID] = value)
      );
    }
  }

  List<UserProduct> products = [];
  Future<List<UserProduct>> asignProductsPhotoLinks(List<UserProduct> newProducts) async {
    for (UserProduct newProduct in newProducts) {
      List<UserProduct> productsCandidates = products.where((oldProduct) => oldProduct.id == newProduct.id).toList();
      if (productsCandidates.isNotEmpty) {
        UserProduct oldProduct = productsCandidates.first;
        for (Photo newPhoto in newProduct.photos!) {
          List<Photo> photoCandidates = oldProduct.photos!.where((oldPhoto) => oldPhoto.name == newPhoto.name).toList();
          if (photoCandidates.isNotEmpty) {
            Photo oldPhoto = photoCandidates.first;
            newPhoto.link = oldPhoto.link;
            newPhoto.thumbnailLink = oldPhoto.thumbnailLink;
          }
        }
      } else {
        await newProduct.downloadPhotoLinks();
        products.add(newProduct);
      }
    }
    return newProducts;
  }
  
  @override
  Widget build(BuildContext context) {
    return widget.companyPreferences.artistFans.isEmpty ? const Center(child: Text('Nada que mostrar por aquí todavía...'))
    : ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: widget.companyPreferences.artistFans.length,
      itemBuilder: (_, int index) {
        CompanyPreferences? fanPreferences = loadedCompanies[widget.companyPreferences.artistFans[index]];
        if (fanPreferences == null) {
          loadCompany(widget.companyPreferences.artistFans[index]);
          return const Loading();
        } else {
          return Artist(
            companyPreferences: fanPreferences,
            config: widget.config,
            viewerCompanyID: widget.companyPreferences.companyID,
            asignProductsPhotoLinks: asignProductsPhotoLinks
          );
        }
      }
    );
  }
}