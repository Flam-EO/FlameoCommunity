import 'package:flutter/material.dart';

class ArtConversationElement extends StatelessWidget {

  const ArtConversationElement({
    super.key,
    required this.position,
    required this.isLeft,
    required this.conversation,
  });

  final int position;
  final bool isLeft;
  final List<String> conversation;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 7.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 350),
              child: Container(
                decoration: BoxDecoration(
                  color: isLeft ? Theme.of(context).colorScheme.primary : Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(10.0))
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    conversation[position],
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: isLeft ? Colors.white : Colors.black,
                      fontSize: 15
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
