import 'package:flameo/models/photo.dart';
import 'package:flameo/models_widgets/photo_fit_contains.dart';
import 'package:flameo/services/auth.dart';
import 'package:flameo/services/config_provider.dart';
import 'package:flameo/shared/image_shower.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PhotoGallery extends StatefulWidget {

  final List<Photo> photos;
  final String title;
  final ConfigProvider config;

  const PhotoGallery({super.key, required this.photos, required this.title, required this.config});

  @override
  State<PhotoGallery> createState() => _PhotoGalleryState();
}

class _PhotoGalleryState extends State<PhotoGallery> {

  int _currentIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.photos.length,
            itemBuilder: (_, index) {
              return InkWell(
                onTap: () {
                  if (AuthService(config: widget.config).userIsMaster && widget.photos[index].link != null) {
                    launchUrl(Uri.parse(widget.photos[index].link!));
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImageShower(
                          title: widget.title,
                          image: widget.photos[index].link
                        )
                      )
                    );
                  }
                },
                child: PhotoFitContains(
                  photo: widget.photos[index],
                  boxFit: BoxFit.contain,
                ),
              );
            },
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ),
        Positioned(
          bottom: 10,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.photos.map((photo) {
              int index = widget.photos.indexOf(photo);
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentIndex == index ? Colors.grey[800] : Colors.grey[400]
                )
              );
            }).toList()
          )
        ),
        if (_currentIndex > 0)
          Positioned(
            left: 10,
            top: 0,
            bottom: 0,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              color: Colors.black.withOpacity(0.5),
              onPressed: () {
                setState(() {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                });
              }
            )
          ),
        if (_currentIndex < widget.photos.length - 1)
          Positioned(
            right: 10,
            top: 0,
            bottom: 0,
            child: IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              color: Colors.black.withOpacity(0.5),
              onPressed: () {
                setState(() {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                });
              }
            )
          )
      ]
    );
  }
}