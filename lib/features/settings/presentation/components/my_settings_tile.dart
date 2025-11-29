import 'package:flutter/material.dart';

/*

SETTINGS LIST TILE

This is a simple tile for each item in the settings page.

----------------------------------------------------------------

To use this widget, you need:

— title ( e.g. "Dark Mode" )
— action ( e.g. toggleTheme() )

*/

class MySettingsTile extends StatelessWidget {
  final String title;
  final Widget action;

  const MySettingsTile({super.key, required this.title, required this.action});

  // BUILD UI
  @override
  Widget build(BuildContext context) {
    // Container
    return Container(
      decoration: BoxDecoration(
        // Color
        color: Theme.of(context).colorScheme.secondary,

        // Curved corners
        borderRadius: BorderRadius.circular(12),
      ),

      // Padding outside
      margin: const EdgeInsets.only(left: 25, right: 25, top: 10),

      // Padding inside
      padding: const EdgeInsets.all(25),

      // Row
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // title
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),

          // action
          action,
        ],
      ),
    );
  }
}
