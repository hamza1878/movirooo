import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
final cars = [
  _CarOption(
    name: 'Economy',
    image: 'images/bmw.png',
    seats: 3,
    bags: 3,
    price: '€107.57',
    badge: 'BEST VALUE',
    badgeColor: Colors.purple,
  ),
    _CarOption(
    name: 'Economy',
    image: 'images/bmw.png',
    seats: 3,
    bags: 3,
    price: '€107.57',
    badge: 'BEST VALUE',
    badgeColor: Colors.purple,
  ),
];
class _CarOption {
  final String name;
  final String image;
  final int seats;
  final int bags;
  final String price;
  final String badge;
  final Color badgeColor;

  const _CarOption({
    required this.name,
    required this.image,
    required this.seats,
    required this.bags,
    required this.price,
    required this.badge,
    required this.badgeColor,
  });
}

class CarCard extends StatelessWidget {
  final _CarOption car;
  final bool isSelected;
  final VoidCallback onTap;
  const CarCard({super.key, 
    required this.car,
    required this.isSelected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:onTap ,
      child: AnimatedContainer(
       duration:const Duration(milliseconds:200),
  margin:   const EdgeInsets.symmetric(horizontal: 20,vertical: 6) ,
  padding:const EdgeInsets.all(14),
        decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(18),
         border: Border.all(
          color:isSelected?AppColors.primaryPurple:AppColors.border(context),
          width: isSelected?2:1,





         ),
        boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryPurple.withOpacity(0.18),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],



        ), child: Row(
          children: [
            // Car image
            SizedBox(
              width: 110,
              height: 70,
              child: Image.asset(
                'images/bmw.png',
                fit: BoxFit.contain,
                
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(car.name,
                      style: AppTextStyles.bodyLarge(context)
                          .copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.person_outline_rounded,
                          color: AppColors.subtext(context), size: 14),
                      const SizedBox(width: 3),
                      Text('${car.seats}',
                          style: AppTextStyles.bodySmall(context)),
                      const SizedBox(width: 10),
                      Icon(Icons.work_outline_rounded,
                          color: AppColors.subtext(context), size: 14),
                      const SizedBox(width: 3),
                      Text('${car.bags}',
                          style: AppTextStyles.bodySmall(context)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: car.badgeColor.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      car.badge,
                      style: TextStyle(
                        color: car.badgeColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(car.price,
                    style: AppTextStyles.bodyLarge(context).copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.text(context),
                    )),
                const SizedBox(height: 2),
                Text('Total price',
                    style: AppTextStyles.bodySmall(context)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
       






