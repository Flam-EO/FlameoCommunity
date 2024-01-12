

import 'package:flameo/gallery/punctuation_selector.dart';
import 'package:flameo/models/cart_models/cart.dart';
import 'package:flameo/models/client_user.dart';
import 'package:flameo/models/userproduct.dart';
import 'package:flameo/models_widgets/photo_fit_contains.dart';
import 'package:flameo/models_widgets/style_widgets.dart';
import 'package:flameo/services/auth.dart';
import 'package:flameo/services/config_provider.dart';

import 'package:flameo/shared/utils.dart';
import 'package:flutter/material.dart';

/// PanelElement: This widget renders each of the cards in the panel
class PanelProductElement extends StatefulWidget {
  final bool openFromPanelHome;
  final UserProduct product;
  final CompanyPreferences companyPreferences;
  final bool isExternal;
  final Cart cart;
  final Function(UserProduct?) productSwitcher;
  final ConfigProvider config;

  const PanelProductElement({
    super.key,
    required this.product,
    required this.isExternal,
    required this.cart,
    required this.openFromPanelHome,
    required this.companyPreferences,
    required this.productSwitcher,
    required this.config
  });

  @override
  State<PanelProductElement> createState() => _PanelProductElementState();
}

class _PanelProductElementState extends State<PanelProductElement> {

  @override
  void initState() {
    widget.product.downloadPhotoLinks().then((_) => Future.delayed(Duration.zero, () {
      if (mounted) {
        setState(() {});
      }
    }));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => widget.productSwitcher(widget.product),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: PhotoFitContains(
              photo: widget.product.photos!.first,
              boxFit: BoxFit.contain,
              thumbnail: true
            )
          ),
          if (widget.product.pinnedTimestamp != null) const Icon(Icons.push_pin, color: Colors.white),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 50,
              decoration:  BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.transparent
                  ]
                )
              )
            )
          ),
          Positioned(
            left: 10,
            bottom: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text(
                    //   widget.product.name,
                    //   style: const TextStyle(
                    //     color: Colors.white,
                    //     fontSize: 12,
                    //     fontWeight: FontWeight.bold
                    //   )
                    // ),
                    if(widget.product.stock > 0 && widget.companyPreferences.isCommercial) Text(
                      widget.product.priceEuro,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11
                      )
                    ),
                    if (widget.product.stock == 0) Text(
                      widget.companyPreferences.isCommercial ? "Agotado" : 'Adquirido',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11
                      )
                    )
                  ]
                )
              ]
            )
          ),
          if (AuthService(config: widget.config).userIsMaster &&
              widget.companyPreferences.flameoExtension == FlameoExtension.art)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Material(
                        color: Colors.white,
                        child: PunctuationSelector(
                          product: widget.product,
                        )
                      )
                    )
                  );
                },
                style: whiteButtonStyle(context),
                child: widget.product.galleryPunctuation == null
                ?  Text("***",style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold))
                : Text("${widget.product.galleryPunctuation}", style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),)
              )
            )
        ]
      )
    );
  }
}
