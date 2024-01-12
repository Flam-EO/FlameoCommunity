import 'package:flameo/models/client_user.dart';
import 'package:flameo/models/photo.dart';
import 'package:flameo/models/userproduct.dart';
import 'package:flameo/services/config_provider.dart';
import 'package:flameo/shared/loading.dart';
import 'package:flameo/views/home/micro/artists/artist.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ArtistsList extends StatefulWidget {

  final CompanyPreferences companyPreferences;
  final ConfigProvider config;

  const ArtistsList({super.key, required this.companyPreferences, required this.config});

  @override
  State<ArtistsList> createState() => _ArtistsListState();
}

class _ArtistsListState extends State<ArtistsList> {

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

    List<CompanyPreferences>? companies = Provider.of<List<CompanyPreferences>?>(context);

    // Condtions to remove a company from the list
    bool removeCompany(CompanyPreferences company) =>
      company.companyID == widget.companyPreferences.companyID ||
      company.nProducts < 1 ||
      company.description == null ||
      company.panel.panelLink == null ||
      !company.mastersApprove ||
      company.isDeleted; 

    if (companies?.isNotEmpty ?? false) companies!.removeWhere(removeCompany);  // Remove own company from the list of art companies

    return companies == null ? const Loading() 
    : companies.isEmpty ? const Center(child: Text('Nada que mostrar por aquí todavía...'))
    : ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: companies.length,
      itemBuilder: (_, int index) => Artist(
        companyPreferences: companies[index],
        config: widget.config,
        viewerCompanyID: widget.companyPreferences.companyID,
        asignProductsPhotoLinks: asignProductsPhotoLinks
      )
    );
  }
}