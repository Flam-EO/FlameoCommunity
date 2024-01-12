import 'dart:async';

import 'package:flameo/landing_page/landing_elements/art_conversation_element.dart';
import 'package:flutter/material.dart';

class ArtConversation extends StatefulWidget {
  const ArtConversation({
    super.key,
  });

  @override
  State<ArtConversation> createState() => _ArtConversationState();
}

class _ArtConversationState extends State<ArtConversation> with SingleTickerProviderStateMixin {

    static List<String> conversation = const [
    "Ganarse la vida como artista no es fácil...",
    "¿Por qué?",
    "Los clientes que mejor saben valorar tus obras son difíciles de encontrar y normalmente sin la ayuda de intermediarios es muy difícil vender.",
    "Entiendo.. ¿A qué intermediarios te refieres?",
    "Las galerías de arte por ejemplo... Es complicadísimo que acepten tus obras y si lo hacen te suelen cobrar comisiones de hasta el 50% sobre el precio de la obra.",
    "¡Que barbaridad! Ojalá pudieses montar tu propia galería de arte en la que promocionar tus obras..."
  ];

  late Timer _timer;

  List<Widget> chatList = [];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (chatList.length < conversation.length) {
        if (mounted) {
          setState(() {
            chatList.add(
              ArtConversationElement(
                position: chatList.length,
                isLeft: chatList.length % 2 == 0 ? true : false,
                conversation: conversation
              )
            );
          });
        }
      } else if (chatList.length >= conversation.length) {
        _timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: SizedBox(
        width: 400,
        child: Column(
          children: chatList,
        ),
      ),
    );
  }
}
