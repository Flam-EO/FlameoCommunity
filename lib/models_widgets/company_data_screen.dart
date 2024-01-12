import 'package:flameo/shared/platform.dart';
import 'package:flutter/material.dart';

class CompanyDataScreen extends StatelessWidget {

  final String title;
  final bool amIFirst;
  final List<Widget> children;
  final double percentage;

  const CompanyDataScreen({super.key, required this.title, this.amIFirst = false, required this.children, required this.percentage});

  @override
  Widget build(BuildContext context) {

    ScreenSize screenSize = ScreenSize(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: !amIFirst ? IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black
          )
        ) : null
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom:10.0),
                child: Image.asset(
                  'imgs/new_logo.JPG',
                  width: screenSize.aspectRatio < 1.2 ? screenSize.width * 0.55 : 400
                )
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Stack(
                  children: [
                    Container(
                      height: 3,
                      width: screenSize.width * 0.8,
                      color: Theme.of(context).colorScheme.secondary
                    ),
                    Container(
                      height: 3,
                      width: screenSize.width * 0.8 * percentage,
                      color: Theme.of(context).colorScheme.primary
                    )
                  ]
                )
              ),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.primary
                )
              ),
              const SizedBox(height: 30),
              Container(
                width: screenSize.width < 500 ? screenSize.width : 500,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSecondary,
                  borderRadius: const BorderRadius.all(Radius.circular(10.0))
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[...children]
                )
              )
            ]
          )
        )
      )
    );
  }
}
