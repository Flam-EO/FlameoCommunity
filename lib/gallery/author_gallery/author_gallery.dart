import 'package:flameo/gallery/author_gallery/author_card.dart';
import 'package:flameo/models/client_user.dart';
import 'package:flameo/models/photo.dart';
import 'package:flameo/models/userproduct.dart';
import 'package:flameo/services/config_provider.dart';
import 'package:flameo/shared/platform.dart';
import 'package:flutter/material.dart';

class AuthorGallery extends StatefulWidget {
  
  final ScreenSize screenSize;
  final List<CompanyPreferences> companies;
  final ConfigProvider config;
  const AuthorGallery({
    super.key,
    required this.screenSize,
    required this.companies,
    required this.config
  });



  @override
  State<AuthorGallery> createState() => _AuthorGalleryState();
}

class _AuthorGalleryState extends State<AuthorGallery> {


      // Condtions to remove a company from the list
    bool removeCompany(CompanyPreferences company) =>

      company.nProducts < 1 ||
      company.description == null ||
      company.panel.panelLink == null ||
      !company.mastersApprove ||
      company.isDeleted; 

    
  
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

    if (widget.companies.isNotEmpty) widget.companies.removeWhere(removeCompany);


    // int crossAxisCount = (screenSize.width / 600).floor(); // number of elements in each row

    return Padding(
      padding: const EdgeInsets.only(left:15.0, right:15),
      child: CustomScrollView(
        slivers: [
             SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                childAspectRatio: 1.10,
                maxCrossAxisExtent: 550,
                mainAxisSpacing: 35,
                crossAxisSpacing: 35
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => widget.companies.map(//TODO eliminar las que no tienen productos
                  (company) => AuthorCard(companyPreferences: company,asignProductsPhotoLinks: asignProductsPhotoLinks,config: widget.config) //TODO Esta función hay que ponerla en algún sitio común 
                ).toList()[index],
                childCount: widget.companies.length
              )
            ),
          ]
      ),
    );
  }
}

