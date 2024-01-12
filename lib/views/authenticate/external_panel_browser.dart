import 'package:flameo/services/config_provider.dart';
import 'package:flameo/services/database.dart';
import 'package:flameo/shared/loading.dart';
import 'package:flameo/shared/utils.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class ExternalPanelBrowser extends StatefulWidget {
  final ConfigProvider config;
  const ExternalPanelBrowser({super.key, required this.config});

  @override
  State<ExternalPanelBrowser> createState() => _ExternalPanelBrowserState();
}

class _ExternalPanelBrowserState extends State<ExternalPanelBrowser> {

  final TextEditingController panelNameController = TextEditingController(text: '');
  DateTime _lastSnackbarTimestamp = DateTime.now();
  final _formKey = GlobalKey<FormState>();
  final _log = Logger('ExternalPanelBrowser');
  bool loading = false;
  String error = '';

  void onPressedBrowsePanelButton() async {
    setState(() => error = '');
    if(_formKey.currentState!.validate()) {
      setState(() => loading = true);
      String? foundPanelLink = await DatabaseService(config: widget.config).findPanelLink(panelNameController.text.trim());
      if(foundPanelLink == null) {
        setState(() {
          error = 'No se ha encontrado ningún panel con ese nombre.';
          loading = false;
          if (elapsedTimeChecker(_lastSnackbarTimestamp, 2000)) {
            _lastSnackbarTimestamp = DateTime.now();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Theme.of(context).colorScheme.error,
                content: Text(error, textAlign: TextAlign.center),
                duration: const Duration(seconds: 2),
              )
            );
            _lastSnackbarTimestamp = DateTime.now();
          }
        });
        
      } else {
        setState(() {
          loading = false;
          Uri panelUrl = Uri.parse('https://${widget.config.get('base_link')}/panel?name=$foundPanelLink');
          openUrl(panelUrl, _log, '_self');
          panelNameController.text = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading ? const Loading() : Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: TextFormField(
                onFieldSubmitted: (_) => onPressedBrowsePanelButton(),
                controller: panelNameController,
                validator: (value) => (value?.trim().isEmpty ?? true) ? 'Introduce un nombre' : null,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'Busca tu panel',
                  border:  OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)))
                )
              )
            ),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.primary),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)
                    )
                  )
                ),
                onPressed: onPressedBrowsePanelButton,
                child: const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    'Buscar panel',
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.white
                    )
                  )
                )
              ),
            )
          ]
        )
      )
    );
  }
}