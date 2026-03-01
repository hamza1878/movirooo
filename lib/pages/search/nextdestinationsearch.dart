import 'package:flutter/material.dart';
import 'package:moviroo/pages/search/_TopBar.dart';
import 'package:moviroo/pages/search/LocationCard.dart';


import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
class NextDestinationSearch extends StatelessWidget {
  const NextDestinationSearch({super.key});
  // ignore: non_constant_identifier_names

  @override
  Widget build (BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: Column(
          children: [
           TopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                     LocationCard(),
                    const SizedBox(height: 16),
                    // _DateTimeRow(),
                    const SizedBox(height: 28),
                    // _SeectionLabel('RECENT SEARCHEES'),
                    const SizedBox(height: 10),
                    // const _RecentSearchItem(
                    //   title: 'Golden Gate Bridge',
                    //   subtitle: 'San Francisco, CA 94129',
                    // ),
                    // const _RecentSearchItem(
                    //   title: 'The Ferry Building',
                    //   subtitle: '1 Ferry Building, San Francisco',
                    // ),
                    // const SizedBox(height: 28),
                    // _SectionLabel('NEARBY LANDMARKS'),
                    // const SizedBox(height: 10),
                    // const _LandmarkItem(
                    //   title: 'Salesforce Tower',
                    //   subtitle: '415 Mission St, San Francisco',
                    //   distance: '0.8 mi',
                    // ),


                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // bottomNavigationBar: _ConfirmButton(),
    );
  }


}

