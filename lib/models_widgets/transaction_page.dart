import 'package:flameo/models/transaction.dart';
import 'package:flameo/models_widgets/transaction_status_timeline.dart';
import 'package:flameo/models_widgets/transaction_synthesis.dart';
import 'package:flutter/material.dart';

class TransactionPage extends StatefulWidget {

  final MyTransaction transaction;
  const TransactionPage({super.key, required this.transaction});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {

  Widget exitButton() {
    return ElevatedButton(
      onPressed: () => Navigator.of(context).pop(),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.primary),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0)
          )
        )
      ),
      child: const Padding(
        padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.exit_to_app, color: Colors.white,),
            SizedBox(width: 5.0),
            Text(
              'Volver',
              style: TextStyle(
                color: Colors.white
              )
            ),
          ],
        )
      )
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSecondary,
                      borderRadius: const BorderRadius.all(Radius.circular(10.0))
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Align(alignment: Alignment.centerLeft,
                          child: exitButton()),
                        const Text(
                          'Resumen de la compra',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18)
                        ),
                        const SizedBox(height: 10),
                        TransactionSynthesis(transaction: widget.transaction),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSecondary,
                      borderRadius: const BorderRadius.all(Radius.circular(10.0))
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        const Text(
                          'Estado de la compra',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18)
                        ),
                        const SizedBox(height: 20),
                        TransactionStatusTimeline(transaction: widget.transaction),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 8.0)
          ],
        )
      ),
    );
  }
}