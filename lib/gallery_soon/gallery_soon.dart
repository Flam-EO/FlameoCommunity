// ignore_for_file: unnecessary_const

import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flameo/gallery_soon/timer.dart';
import 'package:flameo/services/cloudstorage.dart';
import 'package:flameo/services/config_provider.dart';
import 'package:flameo/services/management_database.dart';
import 'package:flameo/shared/platform.dart';
import 'package:flameo/shared/utils.dart';
import 'package:flutter/material.dart';

class GallerySoon extends StatefulWidget {

  final ConfigProvider config;
  const GallerySoon({super.key, required this.config});

  @override
  State<GallerySoon> createState() => _GallerySoonState();
}

class _GallerySoonState extends State<GallerySoon> {

  final GlobalKey<FormState> _formKey = GlobalKey();
  late TextEditingController emailController = TextEditingController(text: '');

  DateTime lastSnackbarTimestamp = DateTime.now();
  void onSubmitEmail() {
    if (_formKey.currentState!.validate()) {
      ManagementDatabaseService(config: widget.config).galleryInterestedEmail(emailController.text);
      if (elapsedTimeChecker(lastSnackbarTimestamp, 2000)) {
        lastSnackbarTimestamp = DateTime.now();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            content: const Text(
              'Te avisaremos en la fecha de apertura de la galería!',
              textAlign: TextAlign.center
            ),
            duration: const Duration(seconds: 2)
          )
        );
        setState(() => emailController.clear());
      }
    }
  }

  String? photoLink;
  @override
  void initState() {
    CloudService().backgroundLogo().then((value) => setState(() => photoLink = value));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    ScreenSize screensize = ScreenSize(context);
    bool wideScreen = screensize.aspectRatio > 1;

    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: CachedNetworkImage(
              imageUrl: photoLink ?? '',
              fit: BoxFit.cover,
              placeholder: (_, __) => Image.asset('imgs/screen logo.JPG'),
              errorWidget: (_, __, ___) => Image.asset('imgs/screen logo.JPG')
            )
          ),
          Positioned(
            bottom: 10,
            right: 10,
            width: screensize.width - 30,
            child: const Text(
              'Créditos: Maxim Mavrichev, Fabian Mohr, Minneapolis Institute of Art, filththemutt, jvanko, Nikkip, 3DWP, TheSpacePunk',
              textAlign: TextAlign.end,
              style: TextStyle(color: Colors.white)
            )
          ),
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withOpacity(0.6)
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyMedium,
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Flameo', style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: wideScreen ? 65: 25)
                        ),
                        TextSpan(
                          text: 'Art',
                          style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontStyle: FontStyle.italic, fontSize: wideScreen ? 65: 25)
                        ),
                        TextSpan(
                          text: ' Online Gallery', style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: wideScreen ? 65: 25)
                        )
                      ]
                    )
                  ),
                  Text(
                    'Vive el mundo del arte como nunca antes a través de artistas emergentes',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onTertiary,
                      fontSize: 20
                    )
                  ),
                  Text(
                    '3 de diciembre',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 25
                    )
                  ),
                  Timer(start: Timestamp.fromDate(DateTime(2023, 12, 3))),
                  const SizedBox(height: 30),
                  const Text(
                    'Déjanos tu email para que te avisemos',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                  ),
                  SizedBox(
                    width: min(screensize.width, 500),
                    child: Form(
                      key: _formKey,
                      child: TextFormField(
                        controller: emailController,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        validator: (value) => (value?.trim().isEmpty ?? true) ? 'Introduce tu email!' : null,
                        onFieldSubmitted: (_) => onSubmitEmail(),
                        decoration: InputDecoration(
                          filled: true,
                          errorMaxLines: 2,
                          fillColor: Colors.transparent,
                          enabledBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(color: Colors.white)
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(color: Colors.white)
                          ),
                          suffixIcon: IconButton(
                            onPressed: onSubmitEmail,
                            icon: const Icon(Icons.arrow_forward, color: Colors.white)
                          )
                        )
                      )
                    )
                  )
                ]
              )
            )
          ),
          Positioned(
            top: 20,
            left: 20,
            child: IconButton(
              onPressed: () => Navigator.pushNamed(context, '/fg'),
              icon: const Icon(Icons.arrow_back, color: Colors.white)
            )
          )
        ]
      )
    );
  }
}