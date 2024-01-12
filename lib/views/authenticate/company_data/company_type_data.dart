//TODO FUT
// import 'package:flameo/models_widgets/company_data_screen.dart';
// import 'package:flameo/views/authenticate/company_data/description_data.dart';
// import 'package:flutter/material.dart';

// class CompanyTypeData extends StatefulWidget {

//   final Function(String, dynamic) setValue;
//   final VoidCallback saveData;

//   const CompanyTypeData({super.key, required this.setValue, required this.saveData});

//   @override
//   State<CompanyTypeData> createState() => _CompanyTypeDataState();
// }

// class _CompanyTypeDataState extends State<CompanyTypeData> {

//   String? businessType;
//   List<String> availableTypes = [
//     'Tienda de ropa',
//     'Frutería',
//     'Zapatería',
//     'Ferretería',
//     'Complementos',
//     'Electrónica',
//     'Artesanía'
//   ];

//   @override
//   Widget build(BuildContext context) {

//     availableTypes.sort((a, b) => a.compareTo(b));
//     // Para ponerlo el último
//     availableTypes.remove('Otros');
//     availableTypes.add('Otros');

//     return CompanyDataScreen(
//       title: 'Ya estamos creando tu página web, vamos a personalizarla',
//       subtitle: 'Indicanos el sector de tu negocio para adaptar la página web',
//       children: [
//         DropdownButton<String>(
//           value: businessType,
//           icon: const Icon(Icons.arrow_drop_down_sharp),
//           iconSize: 24,
//           elevation: 16,
//           onChanged: (String? newValue) {
//             setState(() {
//               businessType = newValue;
//             });
//           },
//           items: availableTypes.map<DropdownMenuItem<String>>((String value) =>
//             DropdownMenuItem<String>(
//               value: value,
//               child: Text(value),
//             )
//           ).toList(),
//         ),
//         const SizedBox(height: 30),
//         businessType != null ? ElevatedButton(
//           onPressed: () async {
//             widget.setValue('businessType', businessType);
//             rightSlideTransition(context, DescriptionData(
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