import 'package:cached_network_image/cached_network_image.dart';
import 'package:flameo/models/client_user.dart';
import 'package:flameo/models/userproduct.dart';
import 'package:flameo/services/config_provider.dart';
import 'package:flameo/shared/utils.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:like_button/like_button.dart';

class Artist extends StatefulWidget {
  final CompanyPreferences companyPreferences;
  final String viewerCompanyID;
  final ConfigProvider config;
  final Future<List<UserProduct>> Function(List<UserProduct>) asignProductsPhotoLinks;
  const Artist({super.key, required this.companyPreferences, required this.config, required this.viewerCompanyID, required this.asignProductsPhotoLinks});

  @override
  State<Artist> createState() => _ArtistState();
}

class _ArtistState extends State<Artist> {

  List<UserProduct> products = [];
  @override
  void initState() {
    widget.companyPreferences.latestProducts(widget.config).then((productsResult) {
      widget.asignProductsPhotoLinks(productsResult).then((value) {
        if (mounted) setState(() => products = value);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSecondary,
          borderRadius: const BorderRadius.all(Radius.circular(10.0))
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.companyPreferences.companyName,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 22
                    )
                  ),
                  LikeButton(
                    likeCount: widget.companyPreferences.artistFans.length,
                    isLiked: widget.companyPreferences.artistFans.contains(widget.viewerCompanyID),
                    onTap: (value) async {
                      if (!value) { //!value = like
                        widget.companyPreferences.like(widget.viewerCompanyID, widget.config);
                      } else {
                        widget.companyPreferences.dislike(widget.viewerCompanyID, widget.config);
                      }
                      return !value;
                    }
                  )
                ]
              ),
              if (widget.companyPreferences.media != null) Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5)
                  ),
                  child: TextButton.icon(
                    onPressed: () => openUrl(
                      Uri.parse('https://www.instagram.com/${widget.companyPreferences.instagram}'),
                      null
                    ),
                    icon: Icon(
                      FontAwesomeIcons.instagram,
                      color: Theme.of(context).colorScheme.primary
                    ),
                    label: Text("@${widget.companyPreferences.instagram}")
                  )
                )
              ),
              Text(widget.companyPreferences.description!),
              ScrollConfiguration(
                behavior: MyCustomScrollBehavior(),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Row(
                      children: products.map((product) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: SizedBox(
                          width: 160,
                          height: 160,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                            child: CachedNetworkImage(
                              imageUrl: product.photos!.first.thumbnailLink ?? "",
                              fit: BoxFit.cover
                            )
                          )
                        )
                      )).toList()
                    )
                  )
                )
              ),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ButtonStyle(
                    elevation: MaterialStateProperty.all(0.0),
                    backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.onBackground),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0))
                    )
                  ),
                  onPressed: () => Navigator.pushNamed(context, '/panel?name=${widget.companyPreferences.panel.panelLink}'),
                  child: const Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Text(
                      'Visitar autor',
                      style: TextStyle(fontSize: 15, color: Colors.white)
                    )
                  )
                )
              )
            ]
          )
        )
      )
    );
  }
}
