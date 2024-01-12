import 'package:flameo/models/transaction.dart';
import 'package:flameo/models_widgets/transaction_page.dart';
import 'package:flameo/shared/utils.dart';
import 'package:flutter/material.dart';

class IndividualTransaction extends StatefulWidget {

  final MyTransaction transaction;

  const  IndividualTransaction({super.key, required this.transaction});

  @override
  State<IndividualTransaction> createState() => _IndividualTransactionState();
}

class _IndividualTransactionState extends State<IndividualTransaction> {

  void tapTransaction() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionPage(transaction: widget.transaction)
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(
          width: 0.7,
          color: Theme.of(context).colorScheme.outline,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(0)),
      ),
      elevation: 5,
      child: ListTile(
        title: Text("${widget.transaction.clientContact.name} ${widget.transaction.clientContact.surname}"),
        subtitle: Text("ID: ${widget.transaction.transactionID}"),
        leading: Text(widget.transaction.amountEuro),
        trailing: Text(
          transactionStatusName(widget.transaction.status),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: transactionStatusColor(widget.transaction.status)
          )
        ),
        onTap: tapTransaction
      )
    );
  }
}
