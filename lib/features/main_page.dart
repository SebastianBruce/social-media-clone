import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_clone/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_media_clone/features/home/presentation/components/my_drawer.dart';
import 'package:social_media_clone/features/home/presentation/pages/home_page.dart';
import 'package:social_media_clone/features/post/presentation/pages/upload_post_page.dart';
import 'package:social_media_clone/features/search/presentation/pages/search_page.dart';
import 'package:social_media_clone/features/profile/presentation/pages/profile_page.dart';
import 'package:social_media_clone/features/home/presentation/components/my_nav_bar.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthCubit>().currentUser!.uid;

    final List<Widget> pages = [
      const HomePage(), // no scaffold inside
      const SearchPage(),
      const Center(child: Text("Placeholder Page")),
      ProfilePage(uid: uid),
    ];

    return Scaffold(
      // ---------- DRAWER ALWAYS EXISTS HERE ----------
      drawer: const MyDrawer(),

      // ---------- APP BAR ONLY ON HOME ----------
      appBar: _selectedIndex == 0
          ? AppBar(
              title: const Text("Home"),
              centerTitle: true,
              foregroundColor: Theme.of(context).colorScheme.primary,
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const UploadPostPage()),
                    );
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            )
          : null,

      body: pages[_selectedIndex],

      bottomNavigationBar: MyCustomBottomNavBar(
        currentIndex: _selectedIndex,
        onItemSelected: (index) {
          setState(() => _selectedIndex = index);
        },
      ),
    );
  }
}
