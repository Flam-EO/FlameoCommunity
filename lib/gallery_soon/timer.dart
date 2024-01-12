import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flameo/shared/platform.dart';
import 'package:flutter/material.dart';

class Timer extends StatefulWidget {

  final Timestamp start;

  const Timer({ required this.start, Key? key }) : super(key: key);

  @override
  State<Timer> createState() => _TimerState();
}

class _TimerState extends State<Timer> {


  void startRefreshing() async {
    while(mounted) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    startRefreshing();
  }

  @override
  Widget build(BuildContext context) {
    
    Duration duration = widget.start.toDate().difference(Timestamp.now().toDate());

    ScreenSize screensize = ScreenSize(context);
    bool wideScreen = screensize.aspectRatio > 1;

    int days = duration.inDays;
    int hours = duration.inHours - days * 24;
    int minutes = duration.inMinutes - duration.inHours * 60;
    int seconds = duration.inSeconds - duration.inMinutes * 60;

    return Text(
      '$days dias, $hours horas, $minutes minutos y $seconds segundos',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.white,
        fontSize: wideScreen ? 25 : 15
      )
    );
  }
}