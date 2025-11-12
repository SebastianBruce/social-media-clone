import 'package:flutter/material.dart';
import 'package:social_media_clone/features/home/presentation/components/my_drawer.dart';
import 'package:social_media_clone/features/post/presentation/pages/upload_post_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // BUILD UI
  @override
  Widget build(BuildContext context) {
    // SCAFFOLD
    return Scaffold(
      // APP BAR
      appBar: AppBar(
        title: const Text("Home"),
        foregroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
        actions: [
          // upload new post button
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UploadPostPage()),
            ),
            icon: const Icon(Icons.add),
          ),
        ],
      ),

      // DRAWER
      drawer: MyDrawer(),
    );
  }
}
