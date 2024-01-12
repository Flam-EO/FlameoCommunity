import 'package:flameo/shared/utils.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class ReturnToPanelButton extends StatelessWidget {

  final String companyName;
  final Uri panelUrl;
  final Logger log;

  const ReturnToPanelButton({super.key,
                             required this.companyName,
                             required this.panelUrl,
                             required this.log});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.zero),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.arrow_back,
            size: 13,
            color: Colors.blue
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text('Volver al panel de $companyName',
              style: const TextStyle(
                fontSize: 12,
                // decoration: TextDecoration.underline,
                // decorationColor: Colors.blue,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
      onPressed: () {openUrl(panelUrl, log);}
    );
  }
}