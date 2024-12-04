import 'package:supabase_project/CommonWidgets/static_page_shared_widgets.dart';
import 'package:supabase_project/ConstantTexts/Theme.dart';
import '../../CommonWidgets/bottom-navigation-bar.dart';
import '../../CommonWidgets/appbar-widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FossilFuelsWidget extends StatelessWidget {
  const FossilFuelsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getAppTheme(),
      home: Scaffold(
        appBar: customAppBar1(
          title: 'Fossil Fuels',
          onBackPressed: () {
            Navigator.pop(context);
          },
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              firstParagraph(context,
                  'Fossil fuels,  including coal, oil, and natural gas, are energy sources formed from the remains of ancient plants and animals. They have been the primary sources of energy for centuries but have significant environmental impacts.'),
              firstParagraph(context,
                  'Fossil fuels  have powered progress but at a high environmental cost. Shifting to renewable energy is essential for sustainability. Every action towards reducing fossil fuel use contributes to a healthier planet.'),
              bigImageContainer(context, 'assets/image0.png'),
              header(context, 'Types of Fossil Fuels'),
              bottomDescription(
                context,
                'Coal',
                'Used mainly for electricity generation and industrial processes.',
                'Highly polluting and a major source of carbon emissions.',
                'assets/energy1.png',
                true,
              ),
              bottomDescription(
                context,
                'OIL',
                'Used primarily in transportation, heating, and the production of plastics and chemicals.',
                'Significant source of air pollution and greenhouse gases.',
                'assets/energy1.png',
                false,
              ),
              bottomDescription(
                context,
                'NATURAL GAS',
                'Used for electricity generation, heating, and as an industrial feed-stock.',
                'Burns cleaner than coal and oil but still emits greenhouse gases.',
                'assets/energy1.png',
                true,
              ),
              header(context, 'Alternative Energy Sources'),
              benefits(
                  context,
                  '1. Solar Energy. Harnessing sunlight to generate electricity.',
                  '2. Wind Energy. Using wind turbines to convert wind into electricity. ',
                  '3.Hydropower.   Generating power from moving water. Geothermal Energy. Utilizing heat from the Earth’s interior.',
                  '4. Biomass Energy. Converting organic materials into energy.'),
              header(context, 'How Can you help?'),
              benefits(
                context,
                'Reduce Energy Consumption. Use energy-efficient appliances and practices',
                'Support Renewable Energy. Advocate for and invest in renewable energy sources.',
                'Educate and Raise  Awareness. Inform others about the environmental impact of fossil fuels and the importance of transitioning to sustainable energy.',
                '',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
//   Widget _firstParagraph(String descriptions) {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
//       child: Text(
//         descriptions,
//         style: const TextStyle(color: Colors.black, fontSize: 12),
//       ),
//     );
//   }
//
//   Widget _imageContainer(String imagePath) {
//     return Container(
//       margin: const EdgeInsets.fromLTRB(20, 20, 0, 0),
//       child: Image.asset(
//         imagePath,
//         width: 329,
//         height: 167,
//       ),
//     );
//   }
//
//   Widget _header(String title) {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
//       child: Text(
//         title,
//         style: const TextStyle(
//           fontSize: 18,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }
//
//   Widget _bottomDescription(String title, String description, String details,
//       String imagePath, bool isFirst) {
//     return Container(
//       margin: EdgeInsets.symmetric(vertical: isFirst ? 20 : 10, horizontal: 20),
//       child: Row(
//         children: [
//           Image.asset(
//             imagePath,
//             width: 80,
//             height: 80,
//           ),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Text(description),
//                 if (details.isNotEmpty) Text(details),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
