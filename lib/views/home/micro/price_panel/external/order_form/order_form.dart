import 'dart:html';

import 'package:flameo/models/cart_models/cart.dart';
import 'package:flameo/models/client_user.dart';
import 'package:flameo/models/transaction.dart';
import 'package:flameo/models/userproduct.dart';
import 'package:flameo/services/config_provider.dart';
import 'package:flameo/services/stripe.dart';
import 'package:flameo/shared/loading.dart';
import 'package:flameo/shared/utils.dart';
import 'package:flutter/material.dart';
import 'package:flameo/views/home/micro/price_panel/external/order_form/contact_collector.dart';
import 'package:flameo/views/home/micro/price_panel/external/order_form/resume.dart';
import 'package:flameo/views/home/micro/price_panel/external/order_form/shipping/shipping.dart';

class OrderForm extends StatefulWidget {

  final CompanyPreferences companyPreferences;
  final ConfigProvider config;
  final Cart cart;

  const OrderForm({super.key, required this.companyPreferences, required this.cart, required this.config});

  @override
  State<OrderForm> createState() => _OrderFormState();
}

class _OrderFormState extends State<OrderForm> {

  OrderFormPanel openPanel = OrderFormPanel.contactCollector;
  final ChildController _contactCollectorController = ChildController();
  final ChildController _shippingController = ChildController();

  @override
  void initState() {
    super.initState();
    widget.config.anonymousLog(LoggerAction.orderFormAccess);
    widget.cart.stripeLinkWaiters.clear();
  }

  bool paying = false;
  void pay() async {
    setState(() => paying = true);
    
    dynamic result = await widget.cart.submit(widget.config);
    if (result is CartError) {
      debugPrint(result.name);
      setState(() => paying = false);
      return;
    }
    if (result is TransactionError) {
      debugPrint(result.name);
      setState(() => paying = false);
      return;
    }
    if (result is UserProductStatus) {
      debugPrint(result.name);
      setState(() => paying = false);
      if (mounted) {
        await showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            return StatefulBuilder(builder: (builderContext, setDialogState) {
              return AlertDialog(
                title: const Text(
                  'Los productos han cambiado',
                  textAlign: TextAlign.center,
                ),
                content: Text(
                  result == UserProductStatus.deleted ? 'Alguno de los productos en el carrito ya no está disponible'
                  : result == UserProductStatus.priceChanged ? 'Alguno de los productos en el carrito ha cambiado de precio'
                  : result == UserProductStatus.insufficientStock ? 'No hay suficiente stock de algún producto del carrito'
                  : 'Ha ocurrido un cambio en algún producto del carrito'
                ),
                titleTextStyle: const TextStyle(fontSize: 15),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(builderContext).pop(),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.secondary),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0))
                      )
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Volver al carrito',
                        style: TextStyle(fontSize: 12)
                      )
                    )
                  )
                ],
                elevation: 0.0
              );
            });
          }
        );
      }
      if(mounted) Navigator.pop(context);
      return;
    }
    while (widget.cart.stripeLinkWaiters.last.link == null) {
      await Future.delayed(const Duration(milliseconds: 200));
    }
    window.open(widget.cart.stripeLinkWaiters.last.link!, '_self');
  }

  void loadStripeLink() {
    StripeService(companyPreferences: widget.companyPreferences, config: widget.config).payCart(widget.cart).then((result) {
      if (result != null) {
        debugPrint(result.name);
      }
    });
  }

  Widget iAmPaying = const Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Padding(
        padding: EdgeInsets.all(10.0),
        child: Center(
          child: Text(
            "Espere mientras le redirigimos a la pasarela de pagos",
            style: TextStyle(fontSize: 28)
          )
        )
      ),
      Loading()
    ]
  );

  @override
  Widget build(BuildContext context) {

    return paying ? Scaffold(body: iAmPaying) :  Scaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        title: Text(
          widget.companyPreferences.companyName,
          style: const TextStyle(color: Colors.white)
        )
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: ExpansionPanelList(
            animationDuration: const Duration(seconds: 1),
            children: [
              ExpansionPanel(
                headerBuilder: (_, bool isOpen) {
                  return isOpen ? const Center(
                    child: Text(
                      'Información de contacto',
                      style: TextStyle(fontSize: 20)
                    ),
                  ) : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Text(
                          'Información de contacto',
                          style: TextStyle(fontSize: 15)
                        )
                      ),
                      widget.cart.clientContact != null ? Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            widget.cart.clientContact.toString(),
                            style: const TextStyle(color: Colors.grey),
                            overflow: TextOverflow.ellipsis
                          )
                        )
                      ) : const SizedBox()
                    ]
                  );
                },
                isExpanded: openPanel == OrderFormPanel.contactCollector,
                canTapOnHeader: true,
                body: ContactCollector(
                  controller: _contactCollectorController,
                  cart: widget.cart,
                  contactDone: () {
                    widget.config.anonymousLog(LoggerAction.orderContactDone);
                    setState(() => openPanel = OrderFormPanel.shipping);
                  }
                )
              ),
              ExpansionPanel(
                headerBuilder: (_, bool isOpen) {
                  return isOpen ? const Center(
                    child: Text(
                      'Método de envío',
                      style: TextStyle(fontSize: 20)
                    ),
                  ) : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Text(
                          'Método de envío',
                          style: TextStyle(fontSize: 15)
                        ),
                      ),
                      widget.cart.shippingMethod != null ? Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            widget.cart.shippingMethod == ShippingMethod.pickUp ? 'Recogida' : '',
                            style: const TextStyle(color: Colors.grey),
                            overflow: TextOverflow.ellipsis
                          ),
                        ),
                      ) : const SizedBox()
                    ]
                  );
                },
                isExpanded: openPanel == OrderFormPanel.shipping,
                canTapOnHeader: true,
                body: Shipping(
                  cart: widget.cart,
                  controller: _shippingController,
                  companyPreferences: widget.companyPreferences,
                  shippingDone: () => setState(() {
                    widget.config.anonymousLog(LoggerAction.orderShippingDone);
                    loadStripeLink();
                    openPanel = OrderFormPanel.resume;
                  })
                )
              ),
              ExpansionPanel(
                headerBuilder: (_, bool isOpen) {
                  return isOpen ? const Center(
                    child: Text(
                      'Resumen de la compra',
                      style: TextStyle(fontSize: 20)
                    ),
                  ) : const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Text(
                      'Resumen de la compra',
                      style: TextStyle(fontSize: 15)
                    ),
                  );
                },
                isExpanded: openPanel == OrderFormPanel.resume,
                canTapOnHeader: true,
                body: Resume(
                  cart: widget.cart,
                  companyPreferences: widget.companyPreferences,
                  pay: pay
                )
              )
            ],
            expansionCallback: (int i, bool isOpen) {
              if (i == 0 || i == 1) widget.cart.stripeLinkWaiters.clear();
              if (i != 0 && widget.cart.clientContact == null) return;
              if (i != 0 && !_contactCollectorController.callForward!()) return;
              if (i == 2 && widget.cart.shippingMethod == null) return;
              if (i == 2 && !_shippingController.callForward!()) return;
              if (i == 2 && widget.cart.stripeLinkWaiters.isEmpty) loadStripeLink();
              setState(() {
                widget.config.anonymousLog(LoggerAction.orderPanelOpen, {'panelNumber': i});
                openPanel = OrderFormPanel.values[i];
              });
            }
          )
        )
      )
    );
  }
}

enum OrderFormPanel {
  contactCollector,
  shipping,
  resume
}