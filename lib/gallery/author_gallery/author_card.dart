import 'package:cached_network_image/cached_network_image.dart';
import 'package:flameo/models/client_user.dart';
import 'package:flameo/models/photo.dart';
import 'package:flameo/models/userproduct.dart';
import 'package:flameo/models_widgets/photo_fit_contains.dart';
import 'package:flameo/services/config_provider.dart';
import 'package:flutter/material.dart';
import 'package:seo/seo.dart';

class AuthorCard extends StatefulWidget {
  final CompanyPreferences companyPreferences;
  final ConfigProvider config;
  final Future<List<UserProduct>> Function(List<UserProduct>) asignProductsPhotoLinks;
  const AuthorCard({super.key, required this.companyPreferences, required this.asignProductsPhotoLinks,required this.config});

  @override
  State<AuthorCard> createState() => _AuthorCardState();
}

class _AuthorCardState extends State<AuthorCard> {

  Photo? photo;
  List<UserProduct> products = [];
  @override
  void initState() {
    super.initState();
    if (widget.companyPreferences.landscape != null) {
      widget.companyPreferences.latestProducts(widget.config).then((productsResult) {
      widget.asignProductsPhotoLinks(productsResult).then((value) {
        if (mounted) setState(() => products = value);
      });
    });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Wrap(
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.start,
            runAlignment: WrapAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 15, top: 5, right: 15),
                child: Text(
                  widget.companyPreferences.companyName,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 18
                  )
                ),
              ),
               Padding(
                padding: const EdgeInsets.only(left: 15, top: 5, right: 15, bottom: 15),
                child: VisitAuthorButton(companyPreferences: widget.companyPreferences,),
              ),
            ],
          ),
        ),
        if (photo?.link != null)
        CachedNetworkImage(
                imageUrl: photo!.link!,
                placeholder: (context, url) => Container(
                  color: Theme.of(context).colorScheme.secondary,
                ),
                imageBuilder: (context, imageProvider) => SizedBox(
                  // width: 50,
                  height: 200,
                  width: 600,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10), // You can adjust the radius as needed
                    child: Image(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),),
        if (widget.companyPreferences.description != null && widget.companyPreferences.description != '')
          Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 15),
            child: Text(widget.companyPreferences.description!,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 6,style: const TextStyle(fontSize: 12),),
          ),
          Wrap(
            alignment: WrapAlignment.start,
            spacing: 5,
            children:
              products.map((product) => SizedBox(
                width: 100,
                height: 100,
                child: GestureDetector(
                  child: PhotoFitContains(
                    photo: product.photos!.first,
                    boxFit: BoxFit.cover,
                    thumbnail: true
                  ),
                  onTap: () {
                    Navigator.pushNamed(context,
                        '/panel?name=${widget.companyPreferences.panel.panelLink}&product=${product.id}&scrollPosition=0');
                  },
                ),
              ))
              .toList()
          ),
      ],
    );
  }
}

class VisitAuthorButton extends StatelessWidget {
  final CompanyPreferences companyPreferences;
  const VisitAuthorButton({
    super.key,
    required this.companyPreferences
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ButtonStyle(
          elevation: MaterialStateProperty.all(0.0),
          backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.onBackground),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0.0)
            )
          )
        ),
        onPressed: () {
          Navigator.pushNamed(
                          context,
                          '/panel?name=${companyPreferences.panel.panelLink}&scrollPosition=0'
                        );
        },
        child:  Seo.text(
          text: "Galería online del artista. Online artist gallery",
          child: const Text(
            'Visitar galería del artista',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white
            )
          ),
        )
      );
  }
}