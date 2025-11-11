import 'package:flutter/material.dart';
import 'package:social_media_clone/features/home/components/my_drawer.dart';

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
      appBar: AppBar(title: const Text("Home"), centerTitle: true),

      // DRAWER
      drawer: MyDrawer(),
    );
  }
}
