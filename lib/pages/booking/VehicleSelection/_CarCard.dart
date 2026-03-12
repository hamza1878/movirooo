import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

class CarOption {
  final String name;
  final String image;
  final int seats;
  final int bags;
  final String price;
  final String badge;
  final Color badgeColor;

  const CarOption({
    required this.name,
    required this.image,
    required this.seats,
    required this.bags,
    required this.price,
    required this.badge,
    required this.badgeColor,
  });
}

final List<CarOption> cars = [
  CarOption(name: 'Economy', image: 'images/bmw.png',
      seats: 3, bags: 3, price: '€107.57', badge: 'BEST VALUE', badgeColor: Colors.purple),
  CarOption(name: 'Business', image: 'images/bmw.png',
      seats: 4, bags: 4, price: '€149.00', badge: 'POPULAR', badgeColor: Colors.blue),
  CarOption(name: 'Premium', image: 'images/bmw.png',
      seats: 4, bags: 5, price: '€199.00', badge: 'TOP RATED', badgeColor: Colors.orange),
  CarOption(name: 'Van', image: 'images/bmw.png',
      seats: 7, bags: 7, price: '€220.00', badge: 'SPACIOUS', badgeColor: Colors.green),
];

class CarCard extends StatelessWidget {
  final CarOption car;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onInfoTap; // ✅ nouveau

  const CarCard({
    super.key,
    required this.car,
    required this.isSelected,
    required this.onTap,
    this.onInfoTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppColors.primaryPurple : AppColors.border(context),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(
                  color: AppColors.primaryPurple.withOpacity(0.28),
                  blurRadius: 24, spreadRadius: 2, offset: const Offset(0, 6))]
              : [],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 110, height: 70,
              child: Image.asset(car.image, fit: BoxFit.contain),
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
                      Text('${car.seats}', style: AppTextStyles.bodySmall(context)),
                      const SizedBox(width: 10),
                      Icon(Icons.work_outline_rounded,
                          color: AppColors.subtext(context), size: 14),
                      const SizedBox(width: 3),
                      Text('${car.bags}', style: AppTextStyles.bodySmall(context)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: car.badgeColor.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(car.badge,
                        style: TextStyle(
                          color: car.badgeColor, fontSize: 10,
                          fontWeight: FontWeight.w800, letterSpacing: 0.8,
                        )),
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
                Text('Total price', style: AppTextStyles.bodySmall(context)),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: onInfoTap,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.chevron_right_rounded,
                        color: AppColors.primaryPurple, size: 18),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}