import 'package:flameo/models/cart_models/cart.dart';
import 'package:flameo/models/client_user.dart';
import 'package:flameo/models/userproduct.dart';
import 'package:flameo/models_widgets/my_cart/my_cart_item.dart';
import 'package:flameo/services/config_provider.dart';
import 'package:flameo/shared/loading.dart';
import 'package:flameo/shared/platform.dart';
import 'package:flameo/shared/utils.dart';
import 'package:flameo/views/home/micro/price_panel/external/order_form/order_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyCart extends StatefulWidget {
  final ConfigProvider config;
  final Cart cart;
  final CompanyPreferences companyPreferences;
  final Function(UserProduct?) productSwitcher;
  const MyCart({super.key, required this.cart, required this.companyPreferences, required this.productSwitcher, required this.config});

  @override
  State<MyCart> createState() => _MyCartState();
}

class _MyCartState extends State<MyCart> {
  bool paying = false;
  DateTime _lastSnackbarTimestamp = DateTime.now();
  @override
  void initState() {
    widget.config.anonymousLog(LoggerAction.accessCart, {'companyID': widget.companyPreferences.companyID});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    
    ScreenSize screensize = ScreenSize(context);
    
    double minimumAmount = widget.companyPreferences.minimumTransactionAmount;

    List<MyCartItem> myItems = widget.cart.cartItems.map((e) {
      e.setParentCart(widget.cart);
      return MyCartItem(
        cartItem: e,
        parentUpdater: setState,
        key: UniqueKey(),
        productSwitcher: widget.productSwitcher
      );
    }).toList();

    TextStyle textStyle = TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.primary);

     Widget checkoutButton = TextButton.icon(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.disabled)) {
              return Theme.of(context).colorScheme.onPrimary;
            }
            return Theme.of(context).colorScheme.primary;
          }
        ),
        shape: MaterialStateProperty.all(RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ))
      ),
      // label is icon and icon is label because potato
      label: const Icon(Icons.arrow_forward, color: Colors.white, size: 12),
      onPressed: widget.cart.cartItems.isNotEmpty ? () async {
        if(widget.cart.subTotalAmount >= minimumAmount){
          await Navigator.of(context).push(MaterialPageRoute(builder: (context) => OrderForm(cart: widget.cart, config: widget.config, companyPreferences: widget.companyPreferences)));
          setState(() {});
        } else {
          if (elapsedTimeChecker(_lastSnackbarTimestamp, 200) && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Theme.of(context).colorScheme.error,
                content: Text('La compra mínima es de $minimumAmount euros', textAlign: TextAlign.center),
                duration: const Duration(seconds: 2),
              )
            );
            _lastSnackbarTimestamp = DateTime.now();
          }
        }

      } : null,
      icon: const Text(
        'Tramitar pedido',
        style: TextStyle(color: Colors.white),
      )
    );

    Widget total = SizedBox(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Column(
          children: [
            Divider(color: Theme.of(context).colorScheme.tertiary),
            Divider(color: Theme.of(context).colorScheme.tertiary),
           
            Padding(
              padding: const EdgeInsets.only(top: 5.0, bottom: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Subtotal",
                    style: textStyle,
                  ),
                  Text(
                    widget.cart.subTotalAmountEuro,
                    style: textStyle,
                  )
                ],
              ),
            ),
            Divider(color: Theme.of(context).colorScheme.tertiary),
          ],
        ),
      ),
    );

    return Scaffold(body: paying ? const Loading() : Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Container(
            height: 52,
            color: Theme.of(context).colorScheme.primary,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      )
                    ),
                    const Text(
                      "Tu compra",
                      style: TextStyle(color: Colors.white),
                    )
                  ]
                ),
                IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(
                      text: widget.cart.shareLink(widget.companyPreferences.panel.panelLink!, widget.config)
                    ));
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Link del carrito copiado al portapapeles!'))
                      );
                    }
                  },
                  icon: const Icon(Icons.share, color: Colors.white)
                )
              ]
            )
          )
        ),
        Expanded(child: ListView(children: myItems)),
        Container(
          padding: const EdgeInsets.only(bottom: 20),
          decoration: const BoxDecoration(
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Color.fromARGB(83, 0, 0, 0),
                blurRadius: 5.0
              )
            ],
            color: Colors.white
          ),
          child: Column(
            children: [
              total,
              SizedBox(
                width: screensize.width * 0.8,
                child: checkoutButton
              )
            ]
          )
        )
      ]
    ));
  }
}
