import 'package:flameo/models/cart_models/cart.dart';
import 'package:flameo/models/client_user.dart';
import 'package:flameo/shared/platform.dart';
import 'package:flameo/shared/utils.dart';
import 'package:flameo/views/home/micro/price_panel/external/order_form/shipping/adress_form.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class Shipping extends StatefulWidget {

  final Cart cart;
  final CompanyPreferences companyPreferences;
  final ChildController controller;
  final VoidCallback shippingDone;

  const Shipping({super.key, required this.shippingDone, required this.cart, required this.companyPreferences, required this.controller});

  @override
  State<Shipping> createState() => _ShippingState();
}

class _ShippingState extends State<Shipping> {

  @override
  void initState() {
    widget.cart.shippingMethod = widget.companyPreferences.shippingMethods.first;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    ScreenSize screensize = ScreenSize(context);

    Logger logger = Logger('Shipping');

    if (widget.cart.shippingMethod == ShippingMethod.pickUp) {
      widget.controller.callForward = () => true;
    }

    Widget thinLayout =  Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10, top: 10),
      child: Column(
        children: [
          if (widget.companyPreferences.shippingMethods.contains(ShippingMethod.pickUp)) RadioListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text('Recógelo aquí!', style: TextStyle(fontSize: 12)),
                Flexible(
                  child: TextButton.icon(
                    onPressed: () {
                      String encodedAddress = Uri.encodeComponent(widget.companyPreferences.address ?? '');
                      if (encodedAddress != '') {
                        final Uri url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encodedAddress}');
                        openUrl(url, logger);
                      }
                    },
                    icon: const Icon(
                      Icons.map,
                      color: Colors.blue,
                      size: 15,
                    ),
                    label: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        widget.companyPreferences.address ?? '',
                        style: const TextStyle(
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.blue,
                          color: Colors.blue,
                        ),
                        overflow: TextOverflow.clip
                      )
                    )
                  )
                )
              ]
            ),
            value: ShippingMethod.pickUp,
            groupValue: widget.cart.shippingMethod,
            onChanged: (value) => setState(() => widget.cart.shippingMethod = value)
          ),
          if (
            widget.companyPreferences.shippingMethods.contains(ShippingMethod.sellerShipping)
            || widget.companyPreferences.shippingMethods.contains(ShippingMethod.flameoShipping)
          ) RadioListTile(
            title: const Text('Envío a domicilio', style: TextStyle(fontSize: 12)),
            value: ShippingMethod.sellerShipping,
            groupValue: widget.cart.shippingMethod,
            onChanged: (value) => setState(() => widget.cart.shippingMethod = value)
          ),
          if (widget.cart.shippingMethod == ShippingMethod.sellerShipping) AddressForm(
            cart: widget.cart,
            controller: widget.controller
          ),
          SizedBox(
            width: screensize.width * 0.8,
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 10),
              child: TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.tertiary),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ))
                ),
                onPressed: () {
                  if (widget.controller.callForward!()) {
                    widget.shippingDone();
                  }
                },
                child: const Text(
                  'Confirmar',
                  style: TextStyle(color: Colors.white),
                )
              )
            )
          )
        ]
      )
    );

    Widget rightSidecoloring = Container(
      width: screensize.width * 0.3,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [
            Theme.of(context).colorScheme.secondary,
            Theme.of(context).colorScheme.secondary,
          ]
        )
      )
    );

    Widget leftSidecoloring = Container(
      width: screensize.width * 0.3,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Theme.of(context).colorScheme.secondary,
            Theme.of(context).colorScheme.secondary,
          ]
        )
      )
    );

    Widget wideLayout = Row(
      children: [leftSidecoloring, Expanded(child: thinLayout), rightSidecoloring],
    );

    return screensize.aspectRatio < 1.2 ? thinLayout : wideLayout;
  }
}