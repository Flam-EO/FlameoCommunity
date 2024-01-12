import 'dart:html';

import 'package:flameo/models_widgets/individual_transaction.dart';
import 'package:flameo/models_widgets/transaction_page.dart';
import 'package:flameo/services/config_provider.dart';
import 'package:flameo/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:flameo/models/client_user.dart';
import 'package:flameo/shared/platform.dart';
import 'package:flameo/models/transaction.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:qrcode_reader_web/qrcode_reader_web.dart';

class TransactionDashboard extends StatefulWidget {

  final ClientUser user;
  final ConfigProvider config;
  final CompanyPreferences companyPreferences;
  final void Function(bool) setLoading;

  const TransactionDashboard({super.key, required this.user, required this.companyPreferences, required this.config, required this.setLoading});

  @override
  State<TransactionDashboard> createState() => _TransactionDashboardState();
}

class _TransactionDashboardState extends State<TransactionDashboard> {

  bool scanningQR = false;

 
  // late int elapsedTime;
  // late Timer _timer;

  // @override
  // void initState() {
  //    elapsedTime= 0;
  //   if (!widget.companyPreferences.stripeEnabled){

  //   _timer =  Timer.periodic(const Duration(seconds: 1), (timer) {
  //   if(mounted){setState(() {
  //     elapsedTime +=1;  
  //     });}
  //   });
  //   if (elapsedTime > 200){
  //     _timer.cancel();
  //   }
  //   }  
  // super.initState();
  // }

  void analyzeQR(String data, List<MyTransaction> transactions) {
    if ('/'.allMatches(data).length != 1) {
      Get.defaultDialog(
        title: 'Error',
        middleText: 'El QR no corresponde a una transacción de Flameo',
        textCancel: 'Volver',
        cancelTextColor: Colors.black
      );
    } else {
      List<String> parts = data.split('/');
      String dataCompanyID = parts[0];
      String dataTransactionID = parts[1];
      if (dataCompanyID != widget.companyPreferences.companyID) {
        Get.defaultDialog(
          title: 'Error',
          middleText: 'El QR no corresponde a ${widget.companyPreferences.companyName}',
          textCancel: 'Volver',
          cancelTextColor: Colors.black
        );
      } else {
        transactions = transactions.where((transaction) => transaction.transactionID == dataTransactionID).toList();
        if (transactions.isEmpty) {
          Get.defaultDialog(
            title: 'Error',
            middleText: 'No se encuentra la transacción, el QR podría ser inválido',
            textCancel: 'Volver',
            cancelTextColor: Colors.black
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TransactionPage(transaction: transactions[0])
            )
          );
        }
      }
    }
  }

  void registerStripe() async {
    widget.setLoading(true);
    String? result = await widget.companyPreferences.registerConnectedAccount(widget.config);
    if (result != null) {
      window.open(result, '_self');
    } else {
      if (mounted) {
        widget.setLoading(false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ha ocurrido un error, contacta con el equipo de Flameo'),
            backgroundColor: Colors.red
          )
        );
      }
    }
  }

  late Widget welcomeToTransactions = Card( //HTML is not a programming language
    color: widget.companyPreferences.stripeEnabled ? Theme.of(context).colorScheme.onSecondary : Theme.of(context).colorScheme.onTertiary,
    elevation: 5,
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium,
          children: [
            TextSpan(
              text: "Bienvenido a FlameoApp!!\n",
              style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 18)
            ),
            TextSpan(
              text: "Has completado tu registro con éxito. Enhorabuena! En cuanto el equipo de FlameoApp haya verificado tu cuenta tendrás tu panel público disponible para quien quieras. ",
              style: TextStyle(color: Theme.of(context).colorScheme.primary)
            ),
            TextSpan(
              text: "Ahora mismo te encuentras en ",
              style: TextStyle(color: Theme.of(context).colorScheme.primary)
            ),
            TextSpan(
              text: "la pestaña de transacciones. ",
              style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)
            ),
            if (!widget.companyPreferences.stripeEnabled) TextSpan(
              text: "En ella podrás ver (en cuanto configures Stripe) las ventas que realices en tu página web con toda su información. Así de fácil! ",
              style: TextStyle(color: Theme.of(context).colorScheme.primary)
            ),
            if (widget.companyPreferences.stripeEnabled) TextSpan(
              text: "En ella podrás ver las ventas que realices en tu página web con toda su información. Tu primera venta está a la vuelta de la esquina! ",
              style: TextStyle(color: Theme.of(context).colorScheme.primary)
            ),
            TextSpan(
              text: "Ahora pasa a la pestaña de productos para que te expliquemos como subir los artículos a tu web. Tardarás 2 minutos.",
              style: TextStyle(fontWeight: FontWeight.w300, color: Theme.of(context).colorScheme.primary)
            ), 
          ]
        )
      )
    )
  );


  late Widget mastersApproved = Card(
      //HTML is not a programming language
      color: Theme.of(context).colorScheme.onSecondary,
      elevation: 5,
      child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
              text: TextSpan(
                  style: Theme.of(context).textTheme.bodyMedium,
                  children: [
                const TextSpan(
                    text: "Enhorabuena!!\n",
                    style: TextStyle(
                        color: Colors.green,
                        fontSize: 18)),
                TextSpan(
                    text:
                        "Ya tienes tu cuenta aprobada. Desde ahora ya puedes compartir tu web con el mundo!\n",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.primary)),
                TextSpan(
                    text: "Ahora mismo te encuentras en ",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.primary)),
                TextSpan(
                    text: "la pestaña de transacciones. ",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary)),
                if (!widget.companyPreferences.stripeEnabled)
                  TextSpan(
                      text:
                          "En ella podrás ver (en cuanto configures Stripe, si es que todavía lo tienes pendiente!) las ventas que realices en tu página web con toda su información. Así de fácil! ",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary)),
                if (widget.companyPreferences.stripeEnabled)
                  TextSpan(
                      text:
                          "En ella podrás ver las ventas que realices en tu página web con toda su información. Tu primera venta está a la vuelta de la esquina! ",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary)),
                TextSpan(
                    text:
                        "Ahora pasa a la pestaña de productos para que te expliquemos como subir los artículos a tu web. Tardarás 2 minutos.",
                    style: TextStyle(
                        fontWeight: FontWeight.w300,
                        color: Theme.of(context).colorScheme.primary)),
              ]))));

  late Widget noStripeYet = Card(
    color: widget.companyPreferences.stripeEnabled ? Theme.of(context).colorScheme.onSecondary : Theme.of(context).colorScheme.onTertiary,
    elevation: 5,
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Aún no has configurado Stripe para poder recibir pagos en tu cuenta de forma segura (Cuando termines el registro en Stripe, es posible que esta ventana tarde un minuto en actualizarse). Para hacerlo, haz click aquí: ",
            style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.primary),
          ),
          if ((DateTime.now().millisecondsSinceEpoch/1000  - widget.companyPreferences.lastStripeRequest/1000) > 15) Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.primary)
              ),
              onPressed: registerStripe,
              child: Text(
                "Configura Stripe",
                style: TextStyle(color: Theme.of(context).colorScheme.tertiary)
              )
            )
          )
        ]
      )
    )
  );

  @override
  Widget build(BuildContext context) {
    List<MyTransaction>? transactions = Provider.of<List<MyTransaction>?>(context);
    ScreenSize screenSize = ScreenSize(context);

    bool showTransactions = widget.companyPreferences.mastersApprove
      && widget.companyPreferences.stripeEnabled
      && transactions != null
      && transactions.isNotEmpty;

    Widget mainContent = showTransactions ? ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, int index) => IndividualTransaction(transaction: transactions[index])
    ) 
    : transactions == null ? const Loading()
    : SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!widget.companyPreferences.stripeEnabled) noStripeYet,
          if (!widget.companyPreferences.mastersApprove || transactions.isEmpty) welcomeToTransactions,
          if (widget.companyPreferences.mastersApprove ) mastersApproved
          //Text("$elapsedTime")
        ]
      ),
    );

    // Choose the final layout of the page based on the size of the window in pixels
    Widget thinLayout = Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0, left: 10, right: 10),
        child: mainContent
      )
    );
    Widget wideLayout = Center(
      child: SizedBox(
        width: screenSize.width * 0.45,
        child: mainContent,
      )
    );
    return Stack(
      children: [
        scanningQR ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Escanea el QR del email de confirmación del comprador'),
            const SizedBox(height: 10),
            QRCodeReaderSquareWidget(
              onDetect: (QRCodeCapture capture) => setState(() {
                scanningQR = false;
                analyzeQR(capture.raw, transactions ?? []);
              }),
              size: 250,
            ),
          ],
        ) : screenSize.aspectRatio > 1.2 ? wideLayout : thinLayout,
        Positioned(
          bottom: 10,
          right: 10,
          child: FloatingActionButton(
            onPressed: () => setState(() => scanningQR = !scanningQR),
            child: Icon(
              scanningQR ? Icons.cancel : Icons.qr_code_scanner_rounded,
              color: Colors.white
            )
          )
        )
      ]
    );
  }
}
