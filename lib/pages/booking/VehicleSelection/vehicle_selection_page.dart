import 'package:flutter/material.dart';
import 'package:moviroo/pages/booking/VehicleSelection/RideBookingPage.dart';
import 'package:moviroo/pages/booking/VehicleSelection/_CarCard.dart';
import 'package:moviroo/pages/booking/VehicleSelection/_RouteInfoBar.dart';
import 'package:moviroo/pages/booking/VehicleSelection/_VatNote.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

class VehicleSelectionPage extends StatelessWidget {
  const VehicleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child:Column(
  children: [
   

 Expanded(
      child: RideBookingPage(),

    ),
           SizedBox(height: 20),

    RouteInfoBar(),
               SizedBox(height: 20),

VatNote(),
Expanded(
  child: ListView.builder(
    itemCount: cars.length,
    itemBuilder: (context, index) {
      return CarCard(
        car: cars[index],
        isSelected: false,
        onTap: () {},
      );
    },
  ),
),  ],
),

       

           

                 
      
        ),
    

    );
  }
}
