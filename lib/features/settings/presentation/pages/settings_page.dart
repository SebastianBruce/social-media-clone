/*

SETTINGS PAGE

- Dark Mode
- Blocked Users
- Account Settings

*/

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_clone/features/settings/presentation/components/my_settings_tile.dart';
import 'package:social_media_clone/features/settings/presentation/pages/blocked_users_page.dart';
import 'package:social_media_clone/responsive/constrained_scaffold.dart';
import 'package:social_media_clone/themes/theme_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  // BUILD UI
  @override
  Widget build(BuildContext context) {
    // theme cubit
    final themeCubit = context.watch<ThemeCubit>();

    // is dark mode
    bool isDarkMode = themeCubit.isDarkMode;

    // SCAFFOLD
    return ConstrainedScaffold(
      appBar: AppBar(title: const Text("Settings"), centerTitle: true),
      body: Column(
        children: [
          // Dark mode tile
          MySettingsTile(
            title: "Dark Mode",
            action: CupertinoSwitch(
              value: isDarkMode,
              onChanged: (value) {
                themeCubit.toggleTheme();
              },
            ),
          ),

          // Block users tile
          MySettingsTile(
            title: "Blocked Users",
            action: IconButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BlockedUsersPage()),
              ),
              icon: Icon(
                Icons.arrow_forward,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
