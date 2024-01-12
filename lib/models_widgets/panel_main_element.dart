import 'package:flameo/models/cart_models/cart.dart';
import 'package:flameo/models/cart_models/cart_item.dart';
import 'package:flameo/models/client_user.dart';
import 'package:flameo/models/userproduct.dart';
import 'package:flameo/services/config_provider.dart';
import 'package:flameo/shared/photo_gallery.dart';
import 'package:flameo/views/home/micro/price_panel/external/order_form/order_form.dart';
import 'package:flutter/material.dart';

/// PanelMainElement: This widget renders each of the cards in the panel
class PanelMainElement extends StatefulWidget {
  final UserProduct product;
  final Cart cart;
  final CompanyPreferences companyPreferences;
  final VoidCallback updateParent;
  final ConfigProvider config;

  const PanelMainElement({super.key, required this.product, required this.cart, required this.updateParent, required this.companyPreferences, required this.config});

  @override
  State<PanelMainElement> createState() => _PanelMainElementState();
}

class _PanelMainElementState extends State<PanelMainElement> {
  @override
  void initState() {
    widget.product.downloadPhotoLinks().then((_) {
      Future.delayed(Duration.zero, () {if (mounted) setState(() {});});
    });
    // print(widget.product.iswrittenart);
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    CartItem? productCartItem = widget.cart.cartItemOfProduct(widget.product);

    RoundedRectangleBorder miniCardShape = RoundedRectangleBorder(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(0),
        topRight: Radius.circular(8),
        bottomLeft: Radius.circular(0),
        bottomRight: Radius.circular(0)
      ),
      side: BorderSide(
        width: 0.7,
        color: Theme.of(context).colorScheme.outline,
      )
    );

    return Container(
      color: Theme.of(context).colorScheme.onSecondary,
      child: Column(
        children: [
          Stack(
            children: [
              if (!widget.product.iswrittenart)
              Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child:
                      PhotoGallery(photos: widget.product.photos!, title: widget.product.name, config: widget.config)),
              if(widget.product.iswrittenart)
                  Padding(
                    padding: const EdgeInsets.only(top:18.0,bottom: 18, right: 8, left: 8),
                    child: RichText(
                    text: TextSpan(style: Theme.of(context).textTheme.bodyMedium, children:  [
                                    TextSpan(text: "${widget.product.name}\n\n", style:const  TextStyle(color: Colors.black, fontSize: 19, letterSpacing: 1.2)),
                                    TextSpan(
                      text: "${widget.product.description} ",
                      style: const TextStyle(color: Colors.black, fontSize: 16, wordSpacing: 3.5)),
                                  ])),
                  ),
              
              if(widget.companyPreferences.isCommercial || widget.product.stock == 0) Positioned(
                left: -10,
                bottom: 1,
                child: Card(
                  color: widget.product.stock > 0 ? 
                    Theme.of(context).colorScheme.primary
                    : Colors.red[900],
                  shape: miniCardShape,
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Text(
                      widget.product.stock > 0 ? 
                        "${widget.product.stock} ${widget.product.measureStr} disponibles"
                        : widget.companyPreferences.isCommercial ? "Agotado" : "Adquirido",
                      style: const TextStyle(color: Colors.white)
                    )
                  )
                )
              )
            ]
          ),
          if (!widget.product.iswrittenart) Text(
            widget.product.name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 19)
          ),
          if(widget.product.stock > 0 && widget.companyPreferences.isCommercial) Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.product.priceEuro,
                textAlign: TextAlign.center,
              )
            ]
          ),
          if ((widget.product.description?.isNotEmpty ?? false) && !widget.product.iswrittenart) Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Center(child: Text(widget.product.description!, textAlign: TextAlign.center)),
          ),
          if (widget.product.size?.isNotEmpty ?? false) Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Center(child: Text("${widget.product.size!} cm", textAlign: TextAlign.center)),
          ),
          if (widget.product.stock > 0 && !widget.product.iswrittenart) Padding(
            padding: const EdgeInsets.only(top: 1),
            child: SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                    if (!widget.companyPreferences.stripeEnabled) {
                      return Theme.of(context).colorScheme.onPrimary;
                    }
                    if (states.contains(MaterialState.disabled)) {
                      return Theme.of(context).colorScheme.tertiary;
                    }
                    return Theme.of(context).colorScheme.primary;
                  }),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0)
                  ))
                ),
                icon: Icon(
                  !widget.companyPreferences.isCommercial ? Icons.star
                  : productCartItem == null ? Icons.shopping_cart_checkout_outlined : Icons.check,
                  color: Colors.white,
                  size: 20,
                  weight: 100,
                ),
                onPressed: !widget.companyPreferences.stripeEnabled ? null
                : widget.companyPreferences.isCommercial && productCartItem == null && widget.product.stock > 0 ? () {
                  widget.cart.addCartItem(CartItem(product: widget.product, quantity: 1));
                  widget.updateParent();
                } 
                : !widget.companyPreferences.isCommercial && productCartItem == null && widget.product.stock > 0 ? () async {
                  widget.cart.emptyCart();
                  widget.cart.addCartItem(CartItem(product: widget.product, quantity: 1));
                  widget.updateParent();
                  await Navigator.of(context).push(MaterialPageRoute(builder: (context) => OrderForm(cart: widget.cart, config: widget.config, companyPreferences: widget.companyPreferences)));
                  widget.cart.emptyCart();
                  widget.updateParent();
                }
                : null,
                label: widget.companyPreferences.isCommercial ? Text(
                  productCartItem == null ? "Añadir al carrito" : "Añadido al carrito!",
                  style: const TextStyle(color: Colors.white)
                ) : Text(
                  "Adquirir a ${widget.companyPreferences.companyName} por (${widget.product.priceEuro})",
                  style: const TextStyle(color: Colors.white, fontSize: 13)
                )
              )
            )
          )
        ]
      )
    );
  }
}
