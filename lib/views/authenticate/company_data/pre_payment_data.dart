import 'dart:html';

import 'package:flameo/models/registration_values_setter.dart';
import 'package:flameo/models_widgets/company_data_screen.dart';
import 'package:flameo/services/config_provider.dart';
import 'package:flameo/shared/loading.dart';
import 'package:flameo/shared/platform.dart';
import 'package:flutter/material.dart';

class PrePaymentData extends StatefulWidget {
  final ConfigProvider config;
  final RegistrationValuesSetter values;

  const PrePaymentData({super.key, required this.values, required this.config});

  @override
  State<PrePaymentData> createState() => _PrePaymentDataState();
}

class _PrePaymentDataState extends State<PrePaymentData> {

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () => widget.values.saveData(ScreenSize(context)));
    widget.config.log(LoggerAction.companyDataPrePayment);
  }

  bool paying = false;
  void stripePressed() async {
    setState(() => paying = true);
    widget.config.log(LoggerAction.completeStripeNow);
    String? result = await widget.values.registerConnectedAccount();
    if(result != null) window.open(result, '_self');
  }

  @override
  Widget build(BuildContext context) {

    return paying ? const Loading() : CompanyDataScreen(
      percentage: 1,
      title: 'Para poder pagarte...',
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child:  RichText(text:  TextSpan( style: Theme.of(context).textTheme.bodyMedium,
                           children: const [TextSpan(text:"Cuando realices una venta, necesitamos un número de cuenta en el que poder pagarte su importe (menos una comisión de un 5% sobre el valor de venta). Para ello utilizamos Stripe, uno de los proveedores de pagos más utilizados del mundo. ",style: TextStyle(color: Colors.black, fontSize: 15)),
                                           TextSpan(text:"Nunca",style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold)),
                                           TextSpan(text:" utilizaremos esta información para cobrarte nada. El uso de nuestra plataforma es gratuito.\n\n",style: TextStyle(color: Colors.black, fontSize: 15, )),
                                           TextSpan(text:"A continuación te redirigiremos a Stripe para que puedas rellenar estos datos. Lo puedes terminar más tarde si quieres pero mientras tanto, nadie podrá comprar tus obras en Flameoart! (No podríamos pagártelas)",style: TextStyle(color: Colors.black, fontSize: 15, ))
                                           ]))
        ),
        Wrap(
          runSpacing: 10,
          spacing: 10,
          alignment: WrapAlignment.center,
          runAlignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.onBackground),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)
                  )
                )
              ),
              onPressed: stripePressed,
              child: const Padding(
                padding: EdgeInsets.all(10.0),
                child: Text('Continuar a Stripe', style: TextStyle(color: Colors.white, fontSize: 15)),
              )
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.onBackground),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)
                  )
                )
              ),
              onPressed: () {
                widget.config.log(LoggerAction.completeStripeLater);
                window.open('https://${widget.config.get('base_link')}/acceso', '_self');
              },
              child: const Padding(
                padding: EdgeInsets.all(10.0),
                child: Text('Terminar más tarde', style: TextStyle(color: Colors.white, fontSize: 15)),
              )
            )
          ]
        )
      ]
    );
  }
}
