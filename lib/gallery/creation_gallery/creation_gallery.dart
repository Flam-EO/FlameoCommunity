import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flameo/gallery/creation_gallery/creation_card.dart';
import 'package:flameo/gallery/creation_gallery/gallery_orderer.dart';
import 'package:flameo/models/userproduct.dart';
import 'package:flameo/services/config_provider.dart';
import 'package:flameo/services/database.dart';
import 'package:flameo/shared/platform.dart';
import 'package:flameo/shared/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreationGallery extends StatefulWidget {

  final ScreenSize screenSize;
  final ConfigProvider config;
  final String? scrollPosition;

  const CreationGallery({super.key, required this.screenSize, required this.config, required this.scrollPosition});

  @override
  State<CreationGallery> createState() => _CreationGalleryState();
}

class _CreationGalleryState extends State<CreationGallery> {

  GalleryCreationsOrder orderCriteria = GalleryCreationsOrder.relevance;

  void setOrderCriteria(GalleryCreationsOrder criteria) {
    setState(() => orderCriteria = criteria);
  }

  void reorderGalleryCreations(GalleryCreationsOrder criteria, List<UserProduct>? galleryProducts) {
    switch (criteria) {
      case GalleryCreationsOrder.relevance:
        galleryProducts?.sort((b, a) => a.galleryPunctuation!.compareTo(b.galleryPunctuation!));
        break;
      case GalleryCreationsOrder.priceAscending:
        galleryProducts?.sort((a, b) => a.price.compareTo(b.price));
        break;
      case GalleryCreationsOrder.priceDescending:
        galleryProducts?.sort((b, a) => a.price.compareTo(b.price));
        break;
      case GalleryCreationsOrder.newer:
        galleryProducts?.sort((b, a) =>(a.timestamp??Timestamp.now()).compareTo(b.timestamp??Timestamp.now()));
        break;
      case GalleryCreationsOrder.older:
        galleryProducts?.sort((a, b) =>(a.timestamp??Timestamp.now()).compareTo(b.timestamp??Timestamp.now()));
        break;
    }
  }

  late ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {

    List<UserProduct>? galleryProducts = Provider.of<List<UserProduct>?>(context);
    reorderGalleryCreations(orderCriteria, galleryProducts);

    // TODO: check if the scroll controller can be fixed
    // if (widget.scrollPosition != null) {
    //   Future.delayed(Duration.zero, () => scrollController.jumpTo(double.parse(widget.scrollPosition!)));
    // }
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: CustomScrollView(
        // controller: scrollController,
        slivers: [
          if (galleryProducts != null && galleryProducts.isNotEmpty)
            SliverToBoxAdapter(
              child: GalleryOrderer(orderCreations: setOrderCriteria),
            ),
          if (galleryProducts != null && galleryProducts.isNotEmpty)
            SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: getNumElementsInGridView(widget.screenSize, 400),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: getChildAspectRatio(widget.screenSize, 400, 10)
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => galleryProducts.map(
                  (product) => GestureDetector(
                    onTap: () {
                      downloadCompanyPreferences(widget.config, product.companyID).then((value) {
                        Navigator.pushNamed(
                          context,
                          '/panel?name=${value.panel.panelLink}&product=${product.id}&scrollPosition=0'
                        );
                      });
                    },
                    child: CreationCard(
                      product: product,
                      config: widget.config,
                      screenSize: widget.screenSize
                    ),
                  )
                ).toList()[index],
                childCount: galleryProducts.length
              )
          ),
        ],
      ),
    );
  }
}
