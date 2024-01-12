//TODO Fut
// import 'package:flameo/models_widgets/company_data_screen.dart';
// import 'package:flameo/views/authenticate/company_data/social_media_data.dart';
// import 'package:flutter/material.dart';
// import 'package:material_segmented_control/material_segmented_control.dart';

// class WebData extends StatefulWidget {

//   final Function(String, dynamic) setValue;
//   final VoidCallback saveData;

//   const WebData({super.key, required this.setValue, required this.saveData});

//   @override
//   State<WebData> createState() => _WebDataState();
// }

// class _WebDataState extends State<WebData> {

//   bool hasWeb = false;
//   TextEditingController webController = TextEditingController(text: '');

//   @override
//   Widget build(BuildContext context) {

//     Map<Object, Widget> options = {
//       0: segmentedOption(context, 'Sí'),
//       1: segmentedOption(context, 'No')
//     };

//     return !hasWeb ? CompanyDataScreen(
//       title: 'Presencia en internet',
//       subtitle: '¿Tienes ya una web del negocio?',
//       children: [
//         const SizedBox(height: 10),
//         MaterialSegmentedControl(
//           children: options,
//           borderColor: Theme.of(context).colorScheme.onPrimaryContainer,
//           selectedColor: Theme.of(context).colorScheme.onPrimaryContainer,
//           unselectedColor: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.3),
//           borderRadius: 6.0,
//           disabledChildren: null,
//           verticalOffset: 10.0,
//           onSegmentChosen: (index) {
//             switch (index) {
//               case 0:
//                 setState(() => hasWeb = true);
//                 break;
//               case 1:
//                 widget.setValue('web', null);
//                 rightSlideTransition(context, SocialMediaData(
//                   setValue: widget.setValue,
//                   saveData: widget.saveData
//                 ));
//                 break;
//               default:
//             }
//           },
//         )
//       ]
//     ) : CompanyDataScreen(
//       title: 'Presencia en internet',
//       subtitle: 'Introduce la web actual de tu negocio',
//       children: [
//         TextFormField(
//           controller: webController,
//           onChanged: (_) => setState(() {})
//         ),
//         const SizedBox(height: 30),
//         webController.text.isNotEmpty ? ElevatedButton(
//           onPressed: () async {
//             widget.setValue('web', webController.text);
//             rightSlideTransition(context, SocialMediaData(
//               setValue: widget.setValue,
//               saveData: widget.saveData
//             ));
//           },
//           child: const Text('Continuar')
//         ) : const SizedBox()
//       ]
//     );
//   }
// }