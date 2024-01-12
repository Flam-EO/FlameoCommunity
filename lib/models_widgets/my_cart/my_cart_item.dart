import 'package:flameo/models/cart_models/cart_item.dart';
import 'package:flameo/models/userproduct.dart';
import 'package:flameo/models_widgets/my_cart/cart_item_synthesis.dart';
import 'package:flameo/models_widgets/my_cart/quantity_selector.dart';
import 'package:flutter/material.dart';

class MyCartItem extends StatefulWidget {
  final void Function(void Function()) parentUpdater;
  final CartItem cartItem;
  final Function(UserProduct?) productSwitcher;

  const MyCartItem({super.key, required this.cartItem, required this.parentUpdater, required this.productSwitcher});

  @override
  State<MyCartItem> createState() => _MyCartItemState();
}

class _MyCartItemState extends State<MyCartItem> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.productSwitcher(widget.cartItem.product);
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10.0, left: 10),
        child: SizedBox(
          height: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CartItemSynthesis(cartItem: widget.cartItem),
              QuantitySelector(parentUpdater: widget.parentUpdater, cartItem: widget.cartItem)
            ]
          )
        )
      )
    );
  }
}
