import 'dart:math';

import 'package:flameo/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class Terms extends StatefulWidget {
  const Terms({super.key});

  @override
  State<Terms> createState() => _TermsState();
}

class _TermsState extends State<Terms> {

  Future<String> cargarTextoAssets(String ruta) async {
    return await rootBundle.loadString(ruta);
  }

  String? policyData;
  @override
  void initState() {
    super.initState();
    rootBundle.loadString('docs/terms.md').then((value) => setState(() => policyData = value));
  }

  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;
    bool isVertical = size.height > size.width;

    return Scaffold(
      appBar: AppBar(title: const Text('Términos y condiciones')),
      body: policyData == null ? const Center(child: Loading()) : isVertical ? Markdown(
        shrinkWrap: true,
        data: policyData!
      ) : Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: min(size.width * 0.95, 800),
          child: Markdown(
            shrinkWrap: true,
            data: policyData!
          )
        )
      )
    );
  }
}