import 'package:flutter/material.dart';
import 'package:moviroo/pages/search/RecentSearchItem.dart';
import 'package:moviroo/pages/search/_TopBar.dart';
import 'package:moviroo/pages/search/LocationCard.dart';

import 'package:moviroo/pages/search/MapPreview.dart';

import 'package:moviroo/pages/search/DateTimeRow.dart';
import 'package:moviroo/pages/search/SectionLabel.dart';
import 'package:moviroo/pages/tabs%20%5Bpassenger%5D/profile/edit_profile/personal_data_widgets.dart';
import 'package:moviroo/pages/search/ConfirmButton.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
class RecentSearch {
  final String title;
  final String subtitle;

  const RecentSearch({
    required this.title,
    required this.subtitle,
  });
}
const List<RecentSearch> recentSearchData = [
  RecentSearch(
    title: 'Golden Gate Bridge',
    subtitle: 'San Francisco, CA 94129',
  ),
  RecentSearch(
    title: 'The Ferry Building',
    subtitle: '1 Ferry Building, San Francisco',
  ),
  RecentSearch(
    title: 'Central Park',
    subtitle: 'New York, NY',
  ),
    RecentSearch(
    title: 'Golden Gate Bridge',
    subtitle: 'San Francisco, CA 94129',
  ),
  RecentSearch(
    title: 'The Ferry Building',
    subtitle: '1 Ferry Building, San Francisco',
  ),
  RecentSearch(
    title: 'Central Park',
    subtitle: 'New York, NY',
  ),
];
class NextDestinationSearch extends StatelessWidget {
  const NextDestinationSearch({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: Column(
          children: [
            TopBar(),

          Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20), 
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: const [
      SizedBox(height: 20),
      LocationCard(),
      SizedBox(height: 16),
      DateTimeRow(),
      SizedBox(height: 28),
      SectionLabel('RECENT SEARCHES'),
      SizedBox(height: 10),
    ],
  ),
),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: recentSearchData.length,
                itemBuilder: (context, index) {
                  final item = recentSearchData[index];
                  return RecentSearchItem(
                    title: item.title,
                    subtitle: item.subtitle,
                  );
                        
                },
              ),
            ),
            SizedBox(height: 10),
             Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20),
          child: MapPreview()   )

                 
          ],
        ),
      ),

      bottomNavigationBar: ConfirmButton(),
    );
  }
}
