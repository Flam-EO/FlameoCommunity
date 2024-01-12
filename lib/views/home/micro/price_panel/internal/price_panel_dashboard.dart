import 'dart:math';

import 'package:flameo/models/client_user.dart';
import 'package:flameo/models/photo.dart';
import 'package:flameo/models/userproduct.dart';
import 'package:flameo/models_widgets/panel_element.dart';
import 'package:flameo/shared/loading.dart';
import 'package:flameo/shared/platform.dart';
import 'package:flameo/shared/utils.dart';

import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class PricePanelDashboard extends StatefulWidget {

  final CompanyPreferences? companyPreferences;

  const PricePanelDashboard({super.key, required this.companyPreferences});

  @override
  State<PricePanelDashboard> createState() => _PricePanelDashboardState();
}

class _PricePanelDashboardState extends State<PricePanelDashboard> {

  List<UserProduct>? products;

  late Widget welcomeToProducts = Column(
    children: [
      Card(
        color: Theme.of(context).colorScheme.onSecondary,
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyMedium,
              children: [
                TextSpan(
                  text: "Bienvenido a tus productos en FlameoApp!!\n",
                  style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 18)
                ),
                TextSpan(
                  text: "Esta es la pestaña más importante en tu app. Algo más arriba ",
                  style: TextStyle(color: Theme.of(context).colorScheme.primary)
                ),
                TextSpan(
                  text: "encontrarás el código QR y el enlace de tu web para que la compartas. ",
                  style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)
                ),
                TextSpan(
                  text: "Importante! ",
                  style: TextStyle(color: Theme.of(context).colorScheme.primary)
                ),
                TextSpan(
                  text: "Todos los productos que añadas en esta página estarán disponible en la web para su venta. Podrás editar su ",
                  style: TextStyle(color: Theme.of(context).colorScheme.primary)
                ),
                TextSpan(
                  text: "stock, precio, nombre fotos... lo que quieras! ",
                  style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)
                ),
                TextSpan(
                  text: "Nos hemos preocupado de todo lo demás. Recibirás un email con cada venta para que estés informado de todo.",
                  style: TextStyle(color: Theme.of(context).colorScheme.primary)
                ),
              ]
            )
          )
        )
      )
    ]
  );

  // Map<productID, List<Map<photoName, Map<thumbNailLink, link>>>>
  // Map<String, List<Map<String, Map<String, String>>>> productsLinks = {};
  List<UserProduct> asignProductsPhotoLinks(List<UserProduct> newProducts) {
    if (products == null) return newProducts;
    for (UserProduct newProduct in newProducts) {
      List<UserProduct> productsCandidates = products!.where((oldProduct) => oldProduct.id == newProduct.id).toList();
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
      }
    }
    return newProducts;
  }

  @override
  Widget build(BuildContext context) {

    ScreenSize screensize = ScreenSize(context);

    int rowSize = max((screensize.width / 300).floor(), 2);

    List<UserProduct>? newProducts = Provider.of<List<UserProduct>?>(context);
    
    if (newProducts != null) {
      products = asignProductsPhotoLinks(newProducts);
    }

    if (products != null) products = sortProducts(products!);

    bool pinnable = products != null && products!.where((product) => product.pinnedTimestamp != null).length < 3;

    late List<PanelElement> panelList = products!.map((e) => PanelElement(
      product: e,
      companyPreferences: widget.companyPreferences,
      pinnable: pinnable,
      key: UniqueKey()
    )).toList();

    late Widget productsGrid = GridView.count(
      crossAxisCount: rowSize,
      childAspectRatio: 1 / 1.6,
      crossAxisSpacing: 0,
      mainAxisSpacing: 0,
      children: panelList,
    );

    return products == null ? const Loading()
    : (products?.isEmpty ?? true) ? Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: SizedBox(
            width: min(screensize.width - 16, 700),
            child: welcomeToProducts
          )
        )
      ]
    ) : productsGrid;
  }
}
