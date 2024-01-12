import 'package:flameo/models/cart_models/cart_item.dart';
import 'package:flameo/models_widgets/photo_fit_contains.dart';
import 'package:flutter/material.dart';

class ProductTile extends StatefulWidget {

  final CartItem cartItem;
  final bool layoutIsWide;

  const ProductTile({super.key,
                             required this.cartItem,
                             required this.layoutIsWide});


  @override
  State<ProductTile> createState() => _ProductTileState();
}

class _ProductTileState extends State<ProductTile> {

  @override
  void initState() {
    super.initState();
    widget.cartItem.product.downloadPhotoLinks().then((_) => Future.delayed(Duration.zero, () {if (mounted) setState(() {});}));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
              padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      width: 1,
                    ),
                    bottom: BorderSide(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      width: 1,
                    ),
                  ),
                ),
                height: 80,
                child: Material(
                  child: ListTile(
                    tileColor: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                    visualDensity: const VisualDensity(vertical: 4),
                    contentPadding:const EdgeInsets.all(3),
                    leading: AspectRatio(
                      aspectRatio: 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0), // Adjust the radius value as needed
                        child: PhotoFitContains(
                          photo: widget.cartItem.product.photos!.first,
                          boxFit: BoxFit.contain,
                          thumbnail: true,
                        ),
                      )
                    ),
                    title: widget.layoutIsWide
                    ? Row(
                        children: [
                          SizedBox(
                            width: 300,
                            child: Text(widget.cartItem.product.name,
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                          ),
                          const Expanded(child: SizedBox()),
                          SizedBox(
                            width: 50,
                            child: Text('${widget.cartItem.quantity} ${widget.cartItem.product.measure}',
                              style: Theme.of(context).textTheme.labelMedium,
                              textAlign: TextAlign.right,
                            ),
                          ),
                          const Expanded(child: SizedBox()),
                          SizedBox(
                            width: 80,
                            child: Text('${widget.cartItem.product.price.toStringAsFixed(2)} €/${widget.cartItem.product.measure}',
                              style: Theme.of(context).textTheme.labelMedium,
                              textAlign: TextAlign.right,
                            ),
                          ),
                          const Expanded(child: SizedBox()),
                        ],
                      )
                      : Text('${widget.cartItem.product.name} (${widget.cartItem.product.price.toStringAsFixed(2)} €/${widget.cartItem.product.measure}) x ${widget.cartItem.quantity} ${widget.cartItem.product.measure}',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                    trailing: SizedBox(
                      width: 60,
                      child: Text('${(widget.cartItem.product.price * widget.cartItem.quantity).toStringAsFixed(2)} €',
                        style: Theme.of(context).textTheme.labelMedium,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                ),
              ),
            );
  }
}