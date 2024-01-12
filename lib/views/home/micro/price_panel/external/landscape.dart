import 'package:cached_network_image/cached_network_image.dart';
import 'package:flameo/models/client_user.dart';
import 'package:flameo/models/photo.dart';
import 'package:flameo/services/cloudstorage.dart';
import 'package:flameo/shared/platform.dart';
import 'package:flutter/material.dart';

class Landscape extends StatefulWidget {
  final CompanyPreferences companyPreferences;
  const Landscape({super.key, required this.companyPreferences});

  @override
  State<Landscape> createState() => _LandscapeState();
}

class _LandscapeState extends State<Landscape> {
  Photo? photo;
  @override
  void initState() {
    super.initState();
    if (widget.companyPreferences.landscape != null) {
      CloudService(companyID: widget.companyPreferences.companyID)
        .landscapeUrl(widget.companyPreferences.landscape!).then((value) =>
          Future.delayed(Duration.zero, () {if (mounted) setState(() => photo = value);})
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenSize screensize = ScreenSize(context);
    return SizedBox(
      width: screensize.width,
      child: CachedNetworkImage(
        imageUrl: photo?.link ?? "",
        fit: BoxFit.cover,
        fadeInDuration: const Duration(milliseconds: 100),
        progressIndicatorBuilder: (context, url, error) => Container(
          color: Theme.of(context).colorScheme.secondary,
        ),
        errorWidget: (_, __, ___) => Container(
          color: Theme.of(context).colorScheme.secondary,
        )
      )
    );
  }
}
