import 'package:flameo/models/cart_models/cart.dart';
import 'package:flameo/models/client_user.dart';
import 'package:flameo/models/transaction.dart';
import 'package:flameo/services/config_provider.dart';
import 'package:flameo/services/database.dart';
import 'package:flameo/shared/loading.dart';
import 'package:flameo/shared/platform.dart';
import 'package:flameo/views/home/thank_you/product_tile.dart';
import 'package:flameo/views/home/thank_you/product_titles_row.dart';
import 'package:flameo/views/home/thank_you/return_to_panel_button.dart';
import 'package:flameo/views/home/thank_you/total_balance_row.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';


class ThankYou extends StatefulWidget {

  final String companyId;
  final String transactionId;
  final ConfigProvider config;

  ThankYou({super.key,
            required this.companyId,
            required this.transactionId,
            required this.config
           });

  final _log = Logger('ThankYou');

  @override
  State<ThankYou> createState() => _ThankYouState();
}

class _ThankYouState extends State<ThankYou> {
  MyTransaction? _transaction;
  CompanyPreferences? _companyPreferences;
  Uri? _panelUrl;
  bool loadError = false;

  @override
  void initState() {
    super.initState();
      DatabaseService(companyID: widget.companyId, config: widget.config).getTransaction(widget.transactionId).then((transactionValue) {
       Future.delayed(Duration.zero, () {if (mounted) setState(() {_transaction = transactionValue;});});
        DatabaseService(companyID: widget.companyId, config: widget.config).companyPreferences.then((companyPreferencesValue) {
          Future.delayed(Duration.zero, () {
            if (mounted) {
              setState(() {
                _companyPreferences = companyPreferencesValue;
                _panelUrl = Uri.parse('https://${widget.config.get('base_link')}/panel?name=${_companyPreferences!.panel.panelLink}');
              });
            }
          });
        }).catchError((error){
          widget._log.info('Error getting Company Preferences data from database: $error');
          loadError = true;
        });
      }).catchError((error) {
        widget._log.info('Error getting transaction data from database: $error');
        loadError = true;
      });
  }

  List<Widget>  _productTileList(bool layoutIsWide) {
    return _transaction!.cartItems.map((item) => ProductTile(cartItem: item, layoutIsWide: layoutIsWide)).toList();
  }

  Text get _firstText {
    return Text(
'''
Estimado/a ${_transaction!.clientContact.name},

¡Gracias por confiar en FlameoApp! Le informamos que su compra en ${_companyPreferences!.companyName} ha sido realizada con éxito.
La compra ha sido realizada el día ${_transaction!.date.toDate().day.toString().padLeft(2, '0')}/${_transaction!.date.toDate().month.toString().padLeft(2, '0')}/${_transaction!.date.toDate().year} a las ${_transaction!.date.toDate().hour.toString().padLeft(2, '0')}:${_transaction!.date.toDate().minute.toString().padLeft(2, '0')}.
Desglose de su compra:
''',
      style: Theme.of(context).textTheme.labelMedium,
    );
  }

  late final Text _shippingText = Text(
    _transaction!.shippingMethod == ShippingMethod.pickUp ? 
      'Te avisaremos cuando puedas pasarte a recoger tu pedido en:'
      : 'Dirección de entrega:',
    style: Theme.of(context).textTheme.labelMedium
  );
  late final Text _addressText = Text(
    _transaction!.shippingMethod == ShippingMethod.pickUp ? 
      _companyPreferences!.address!
      : _transaction!.clientContact.address.toString(),
    style: Theme.of(context).textTheme.labelMedium!.copyWith(fontWeight: FontWeight.bold)
  );

  Text get _lastText {
    return Text(
'''
Le enviaremos un correo electrónico con información detallada sobre el estado de su pedido y cualquier cambio que pueda haber en el mismo.
Esperamos que disfrute de sus nuevos productos y que su experiencia de compra haya sido satisfactoria. No dude en contactarnos si tiene alguna pregunta o problema con su pedido.
¡Gracias de nuevo por su compra!

Atentamente,
El equipo de FlameoApp
''',
      style: Theme.of(context).textTheme.labelMedium,
    );
  }

  Column _thankyouMessage(bool layoutIsWide) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _firstText,
        ProductTitlesRow(layoutIsWide: layoutIsWide),
        const SizedBox(height: 8),
        Column(children: _productTileList(layoutIsWide)),
        TotalBalanceRow(transaction: _transaction!, companyPreferences: _companyPreferences!,),
        const SizedBox(height: 8),
        _shippingText,
        _addressText,
        const SizedBox(height: 8),
        _lastText
      ],
    );
  }

  Widget _wideLayout(BuildContext context) {
    ScreenSize screenSize = ScreenSize(context);
    return Container(
        height: screenSize.height,
        width: screenSize.width,
        color: Theme.of(context).colorScheme.secondary,
        child: Row(
          children: [
            const Expanded(child: SizedBox()),
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  const Expanded(child: SizedBox()),
                  SizedBox(
                    height: screenSize.height * 0.9,
                    width: 700,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Column(
                          children: [
                            _thankyouMessage(true),
                            const SizedBox(height: 20,),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: ReturnToPanelButton(companyName: _companyPreferences!.companyName, panelUrl: _panelUrl!, log: widget._log)
                            ),
                          ],
                        )
                      ),
                    ),
                  ),
                  const Expanded(child: SizedBox()),
                ],
              ),
            ),
            const Expanded(child: SizedBox()),
          ],
        ),
      );
  }

  Widget _thinLayout() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            _thankyouMessage(false),
            const SizedBox(height: 20,),
            Align(
              alignment: Alignment.centerLeft,
              child: ReturnToPanelButton(companyName: _companyPreferences!.companyName, panelUrl: _panelUrl!, log: widget._log),
            ),
          ],
        )
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenSize screenSize = ScreenSize(context);
    return loadError ? 
    const Center(child: Text('Ha ocurrido un error cargando el resumen de la compra, contacta con info@flameoapp.com'))
    : _transaction == null || _companyPreferences == null || _panelUrl == null
    ? const Loading()
    : screenSize.width < 700
      ? _thinLayout()
      : _wideLayout(context);
  }
}