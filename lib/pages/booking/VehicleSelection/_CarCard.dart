import 'package:flutter/material.dart';
import 'package:moviroo/routing/router.dart';
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

class CarSelectionSection extends StatefulWidget {
  const CarSelectionSection({super.key});

  @override
  State<CarSelectionSection> createState() => _CarSelectionSectionState();
}

class _CarSelectionSectionState extends State<CarSelectionSection> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...List.generate(cars.length, (i) => CarCard(
          car: cars[i],
          isSelected: _selectedIndex == i,
          onTap: () => setState(() => _selectedIndex = i),
        )),

        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) => SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: FadeTransition(opacity: animation, child: child),
          ),
          child: _selectedIndex != null
              ? Padding(
                  key: const ValueKey('More Inforamtion'),
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                                        onPressed: () => AppRouter.clearAndGo(context, AppRouter.vehicleSelectionPage),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPurple,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                         shape:RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),

            ),
                      ).copyWith(
                        shadowColor: WidgetStateProperty.all(
                          AppColors.primaryPurple.withOpacity(0.25),
                        ),
                        elevation: WidgetStateProperty.all(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'More Inforamtion',
                            style: AppTextStyles.bodyLarge(context).copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('empty')),
        ),
      ],
    );
  }
}

class CarCard extends StatelessWidget {
  final _CarOption car;
  final bool isSelected;
  final VoidCallback onTap;

  const CarCard({
    super.key,
    required this.car,
    required this.isSelected,
    required this.onTap,
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
              ? [
                  BoxShadow(
                    color: AppColors.primaryPurple.withOpacity(0.28),
                    blurRadius: 24,
                    spreadRadius: 2,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 110,
              height: 70,
              child: Image.asset('images/bmw.png', fit: BoxFit.contain),
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
                Text('Total price', style: AppTextStyles.bodySmall(context)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}