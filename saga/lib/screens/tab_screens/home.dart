// lib/screens/tab_screens/home_tab.dart
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Contenu de l\'accueil',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}