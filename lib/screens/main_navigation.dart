import 'package:flutter/material.dart';
// import 'dashboard_page.dart';
import 'stats_page.dart';
import 'historique_page.dart';
import 'personnalisation_page.dart';
import 'progression_page.dart';
import 'home_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  final List<Widget> _pages = const [
    HomePage(), // Affichage interactif des séances (ancien affichage)
    StatsPage(),
    HistoriquePage(),
    PersonnalisationPage(),
    ProgressionPage(),
  ];
  final List<String> _titles = const [
    'Séances',
    'Statistiques',
    'Historique',
    'Personnalisation',
    'Progression',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        centerTitle: true,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey[400],
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Séances'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historique'),
          BottomNavigationBarItem(icon: Icon(Icons.edit), label: 'Perso'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Progression'),
        ],
      ),
    );
  }
}
