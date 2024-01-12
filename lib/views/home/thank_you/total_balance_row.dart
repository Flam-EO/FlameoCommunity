import 'package:flameo/models/cart_models/cart.dart';
import 'package:flameo/models/client_user.dart';
import 'package:flameo/models/transaction.dart';
import 'package:flutter/material.dart';

class TotalBalanceRow extends StatelessWidget {

  final MyTransaction transaction;
  final CompanyPreferences companyPreferences;

  const TotalBalanceRow({super.key,
                         required this.companyPreferences,
                         required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
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
              color: Theme.of(context).colorScheme.secondary
            ),
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Column(
                children: [
                  if (
                    transaction.shippingMethod == ShippingMethod.sellerShipping
                    || transaction.shippingMethod == ShippingMethod.flameoShipping
                  )
                    Row(
                      children: [
                        const Expanded(child: SizedBox()),
                        SizedBox(
                          width: 200,
                          child: Text('Gastos de envío',
                            style: Theme.of(context).textTheme.labelMedium,
                            textAlign: TextAlign.right,
                          ),
                        ),
                        const SizedBox(width: 30),
                        SizedBox(
                          width: 80,
                          child: Text(companyPreferences.shippingCostEuro,
                            style: Theme.of(context).textTheme.labelMedium,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  if (
                    transaction.shippingMethod == ShippingMethod.sellerShipping
                    || transaction.shippingMethod == ShippingMethod.flameoShipping
                  )
                    const SizedBox(height: 5),
                  Row(
                    children: [
                      const Expanded(child: SizedBox()),
                      SizedBox(
                        width: 200,
                        child: Text('Importe total de la compra',
                          style: Theme.of(context).textTheme.labelMedium,
                          textAlign: TextAlign.right,
                        ),
                      ),
                      const SizedBox(width: 30),
                      SizedBox(
                        width: 80,
                        child: transaction.shippingMethod == ShippingMethod.sellerShipping 
                          || transaction.shippingMethod == ShippingMethod.flameoShipping
                        ? Text('${(transaction.amount + (companyPreferences.shippingCostCents / 100.0)).toStringAsFixed(2)} €',
                            style: Theme.of(context).textTheme.labelMedium,
                            textAlign: TextAlign.right,
                          )
                        : Text('${transaction.amount.toStringAsFixed(2)} €',
                            style: Theme.of(context).textTheme.labelMedium,
                            textAlign: TextAlign.right,
                          )
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }
}