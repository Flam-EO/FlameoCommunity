import 'package:flameo/models/cart_models/cart.dart';
import 'package:flameo/models/cart_models/cart_item.dart';
import 'package:flameo/models/client_user.dart';
import 'package:flameo/shared/platform.dart';
import 'package:flutter/material.dart';

class Resume extends StatefulWidget {

  final Cart cart;
  final CompanyPreferences companyPreferences;
  final VoidCallback pay;
  
  const Resume({super.key, required this.cart, required this.companyPreferences, required this.pay});

  @override
  State<Resume> createState() => _ResumeState();
}

class _ResumeState extends State<Resume> {

  Widget buildInvoiceRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
        )
      ]
    );
  }

  Widget buildCartItem(CartItem cartItem) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          cartItem.product.name +
            (cartItem.quantity > 1 ?' (${cartItem.quantity} ${cartItem.measureStr} x ${cartItem.product.priceEuro})' : ''),
          style: const TextStyle(fontSize: 16),
        ),
        Text(
          cartItem.totalPriceEuro,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    ScreenSize screensize = ScreenSize(context);

    Widget thinLayout =  Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10, top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información de contacto',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline
            )
          ),
          Text(widget.cart.clientContact?.toStringStack() ?? ''),
          const SizedBox(height: 10),
          const Text(
            'Método de envío:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline
            )
          ),
          Text(widget.cart.shippingMethod == ShippingMethod.pickUp ? 
            'Recogida en (${widget.companyPreferences.address ?? ''})'
            : ''
          ),
          const SizedBox(height: 10),
          const Text(
            'Compra',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline
            )
          ),
          ...widget.cart.cartItems.map((cartItem) => buildCartItem(cartItem)).toList(),
          const Divider(thickness: 0.5,),
          buildInvoiceRow('Subtotal', widget.cart.subTotalAmountEuro),
          //buildInvoiceRow('Gestión', widget.cart.feeEuro),
          //buildInvoiceRow('Gestión', widget.cart.feeEuro),
          const Divider(thickness: 0.5),
          if(
            widget.cart.shippingMethod == ShippingMethod.sellerShipping
            || widget.cart.shippingMethod == ShippingMethod.flameoShipping
          ) buildInvoiceRow("Envío a domicilio", widget.companyPreferences.shippingCostEuro),
          const Divider(thickness: 0.5),
          //buildInvoiceRow('Total', '${(widget.cart.amount + widget.cart.fee / 100).toStringAsFixed(2)} €', isBold: true),
          buildInvoiceRow('Total', widget.cart.totalAmountEuro, isBold: true),
          Center(
            child: SizedBox(
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
                  onPressed: () => widget.pay(),
                  child: const Text(
                    'Continuar al pago',
                    style: TextStyle(color: Colors.white),
                  )
                )
              )
            ),
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