import 'dart:math';

import 'package:flameo/models/transaction.dart';
import 'package:flameo/models_widgets/adress.dart';
import 'package:flameo/models_widgets/cart_item_transaction_synthesis.dart';
import 'package:flameo/shared/platform.dart';
import 'package:flameo/shared/utils.dart';
import 'package:flutter/material.dart';

class TransactionSynthesis extends StatefulWidget {

  final MyTransaction transaction;

  const TransactionSynthesis({super.key, required this.transaction});

  @override
  State<TransactionSynthesis> createState() => _TransactionSynthesisState();
}

class _TransactionSynthesisState extends State<TransactionSynthesis> {
  @override
  Widget build(BuildContext context) {
    ScreenSize screenSize = ScreenSize(context);
    return SizedBox(
      height: 500,
      width: min(800, screenSize.width - 16.0),
      child: ListView.builder(
        itemCount: widget.transaction.cartItems.length + 1,
        itemBuilder: (context, int index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10, left: 8.0, right: 8.0),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10.0))
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Text(
                          "${widget.transaction.clientContact.name} ${widget.transaction.clientContact.surname}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.primary)
                        )
                      ),
                      Text(widget.transaction.clientContact.email),
                      Text(widget.transaction.clientContact.phoneNumber),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text("Total: ${widget.transaction.amountEuro}")
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(
                            "Comisión FlameoApp: ${widget.transaction.feeStr}",
                            style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 11)
                          )
                        )
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(
                            "Método de entrega: ${shippingMethodName(widget.transaction.shippingMethod)}",
                            style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 11)
                          )
                        )
                      ),
                      if (widget.transaction.clientContact.address != null) Align(
                        alignment: Alignment.centerLeft,
                        child: MyAddress(address: widget.transaction.clientContact.address!)
                      )
                    ]
                  )
                ),
              )
            );
          } else {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10.0, left: 8.0, right: 8.0),
              child: SizedBox(
                height: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CartItemTransactionSynthesis(cartItem: widget.transaction.cartItems[index - 1]),
                    Text(
                      '${widget.transaction.cartItems[index - 1].quantity} ${widget.transaction.cartItems[index - 1].product.measureStr}',
                      style: const TextStyle(fontSize: 11),
                    )
                  ]
                )
              )
            );
          }
        }
      )
    );
  }
}
