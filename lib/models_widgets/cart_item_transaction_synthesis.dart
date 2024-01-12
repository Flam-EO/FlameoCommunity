import 'dart:math';

import 'package:flameo/models/cart_models/cart_item.dart';
import 'package:flameo/shared/platform.dart';
import 'package:flutter/material.dart';

class CartItemTransactionSynthesis extends StatefulWidget {

  final CartItem cartItem;

  const CartItemTransactionSynthesis({super.key, required this.cartItem});

  @override
  State<CartItemTransactionSynthesis> createState() => _CartItemTransactionSynthesisState();
}

class _CartItemTransactionSynthesisState extends State<CartItemTransactionSynthesis> {

  @override
  void initState() {
    super.initState();
    widget.cartItem.product.downloadPhotoLinks().then((_) => Future.delayed(Duration.zero, () {
      if (mounted) setState(() {});
    }));
  }

  @override
  Widget build(BuildContext context) {
    ScreenSize screensize = ScreenSize(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              this.widget.cartItem.product.photos!.first.thumbnailLink ?? "",
              fit: BoxFit.cover,
              errorBuilder: (context, _, __) {
                return SizedBox(
                  height: 90,
                  width: 90,
                  child: Container(color: Theme.of(context).colorScheme.secondary)
                );
              }
            ),
          )
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: min(500, screensize.width * 0.55),
                child: Text(
                  this.widget.cartItem.product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              Text(
                this.widget.cartItem.product.priceEuro,
                style: TextStyle(fontSize: 11, color: Colors.grey[800]),
              )
            ]
          )
        )
      ]
    );
  }
}