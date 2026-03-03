import 'package:flutter/material.dart';
import 'package:moviroo/routing/router.dart';
import 'package:moviroo/theme/app_colors.dart';
import 'package:moviroo/theme/app_text_styles.dart';

class ConfirmButton extends StatelessWidget {
  const ConfirmButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bg(context),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child:SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
                
            
                  onPressed: () => AppRouter.clearAndGo(context, AppRouter.vehicleSelectionPage),

          style:ElevatedButton.styleFrom(
            backgroundColor:AppColors.primaryPurple,
            shape:RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),

            ),
elevation: 0,
          ), child: const Row(mainAxisAlignment: MainAxisAlignment.center , 
            children:[
              Text(
                   'Confirm Destination',
                style: AppTextStyles.buttonPrimary,
              ),

 SizedBox(width: 8),
              Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),



          ],) ,
          
          ),
      
      
      
      
      
      
      
      )




    );
  }
}
