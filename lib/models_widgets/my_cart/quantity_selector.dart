import 'package:flameo/models/cart_models/cart_item.dart';
import 'package:flameo/models/userproduct.dart';
import 'package:flutter/material.dart';

class QuantitySelector extends StatefulWidget {
  
  final void Function(void Function()) parentUpdater;
  final CartItem cartItem;

  const QuantitySelector({super.key, required this.parentUpdater, required this.cartItem});

  @override
  State<QuantitySelector> createState() => _QuantitySelectorState();
}

class _QuantitySelectorState extends State<QuantitySelector> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.cartItem.productStatus != UserProductStatus.ok) Text(
            widget.cartItem.product.isDeleted! ? 'Producto no disponible'
            : widget.cartItem.productStatus == UserProductStatus.priceChanged ? 'El precio ha cambiado'
            : widget.cartItem.quantity > widget.cartItem.product.stock ? 'Stock insuficiente: ${widget.cartItem.product.stock}'
            : '',
            style: widget.cartItem.productStatus == UserProductStatus.priceChanged ?
              const TextStyle(color: Colors.orange)
              : const TextStyle(color: Colors.red)
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    widget.cartItem.removeOne();
                    widget.parentUpdater(() {});
                  });
                },
                icon: widget.cartItem.quantity > 1 ? 
                  const Icon(Icons.remove_outlined)
                  : const Icon(Icons.delete_outline_rounded, size: 15),
                iconSize: 12,
                color: Theme.of(context).colorScheme.primary
              ),
              Text(
                "${widget.cartItem.quantity}",
                style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.primary),
              ),
              if (widget.cartItem.product.stock > widget.cartItem.quantity) IconButton(
                onPressed: () {
                  setState(() {
                    widget.cartItem.addOne();
                      widget.parentUpdater(() {});
                  });
                },
                iconSize: 12,
                icon: Icon(
                  Icons.add_outlined,
                  color: Theme.of(context).colorScheme.primary
                )
              )
            ]
          ),
          TextButton(
            onPressed: () => setState(() {
              widget.cartItem.removeMe();
              widget.parentUpdater(() {});
            }),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.red)
            )
          )
        ]
      )
    );
  }
}