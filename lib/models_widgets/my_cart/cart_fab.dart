import 'package:animations/animations.dart';
import 'package:flameo/models/cart_models/cart.dart';
import 'package:flameo/models/client_user.dart';
import 'package:flameo/models/userproduct.dart';
import 'package:flameo/models_widgets/my_cart/my_cart.dart';
import 'package:flameo/services/config_provider.dart';
import 'package:flameo/shared/utils.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;

class CartAccess extends StatefulWidget {
  final Cart cart;
  final CompanyPreferences companyPreferences;
  final Function(UserProduct?) productSwitcher;
  final LinkOpener? linkOpener;
  final ConfigProvider config;

  const CartAccess({super.key,
    required this.cart, required this.companyPreferences,
    required this.productSwitcher, this.linkOpener, required this.config
  });

  @override
  State<CartAccess> createState() => _CartAccessState();
}

class _CartAccessState extends State<CartAccess> {

  @override
  void initState() {
    if (widget.linkOpener?.cartReference != null) {
      Future.delayed(Duration.zero, () async {
        widget.config.anonymousLog(LoggerAction.accessCartFromLink, {'companyID': widget.companyPreferences.companyID});
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyCart(
              cart: Cart.fromLinkReference(widget.companyPreferences, widget.linkOpener!.cartReference!, widget.config),
              companyPreferences: widget.companyPreferences,
              productSwitcher: widget.productSwitcher,
              config: widget.config
            )
          )
        );
      widget.linkOpener?.cartReference = null;
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if(widget.companyPreferences.stripeEnabled){
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: OpenContainer(
          clipBehavior: Clip.none,
          closedElevation:0,
          closedColor: Theme.of(context).colorScheme.onTertiaryContainer,
          closedShape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(0.0))),
          transitionDuration: const Duration(milliseconds: 400),
          transitionType: ContainerTransitionType.fadeThrough,
          closedBuilder: (context, action) => badges.Badge(
            showBadge: widget.cart.cartItems.isNotEmpty,
            badgeContent: Text(widget.cart.cartItems.length.toString()),
            child: Icon(
              Icons.shopping_cart_outlined,
              color: Theme.of(context).colorScheme.tertiary,
              size: 30
            )
          ),
          openBuilder: (context, action) => MyCart(
            cart: widget.cart,
            config: widget.config,
            companyPreferences: widget.companyPreferences,
            productSwitcher: widget.productSwitcher
          )
        )
      );
    } else {
      return const SizedBox();
    }
  }
}
