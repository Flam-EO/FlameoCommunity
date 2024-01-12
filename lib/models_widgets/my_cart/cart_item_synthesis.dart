import 'package:flameo/models/cart_models/cart_item.dart';
import 'package:flameo/shared/platform.dart';
import 'package:flutter/material.dart';

class CartItemSynthesis extends StatefulWidget {

  final CartItem cartItem;

  const CartItemSynthesis({super.key, required this.cartItem});

  @override
  State<CartItemSynthesis> createState() => _CartItemSynthesisState();
}

class _CartItemSynthesisState extends State<CartItemSynthesis> {

  @override
  void initState() {
    super.initState();
    widget.cartItem.product.downloadPhotoLinks().then((_) => Future.delayed(Duration.zero, () {
      if (mounted) setState(() {});
    }));
  }

  @override
  Widget build(BuildContext context) {

    ScreenSize screenSize = ScreenSize(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Image.network(
            this.widget.cartItem.product.photos!.first.thumbnailLink ?? "",
            fit: BoxFit.cover,
            errorBuilder: (context, _, __) {
              return SizedBox(
                height: 150,
                width: 150,
                child: Container(color: Theme.of(context).colorScheme.secondary)
              );
            }
          )
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: screenSize.width - 10 - 150 - 10 - 50,
                child: Text(
                  widget.cartItem.product.name,
                  style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.primary)
                )
              ),
              Text(
                widget.cartItem.product.priceEuro,
                style: TextStyle(fontSize: 14, color: Colors.grey[800])
              )
            ]
          )
        )
      ]
    );
  }
}