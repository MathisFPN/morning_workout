import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Résumé assiduité (placeholder)
            Card(
              color: Theme.of(context).colorScheme.surface,
              child: ListTile(
                leading: Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.primary),
                title: Text('Assiduité cette semaine', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                subtitle: const Text('3 séances complétées'),
                onTap: () {
                  // Navigue vers Statistiques
                  DefaultTabController.of(context)?.animateTo(2);
                },
              ),
            ),
            const SizedBox(height: 16),
            // Accès historique
            ElevatedButton.icon(
              icon: const Icon(Icons.history),
              label: const Text('Historique des séances'),
              onPressed: () => Navigator.pushNamed(context, '/historique'),
            ),
            const SizedBox(height: 8),
            // Accès personnalisation
            ElevatedButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text('Personnaliser mes séances'),
              onPressed: () => Navigator.pushNamed(context, '/personnalisation'),
            ),
            const SizedBox(height: 8),
            // Accès progression
            ElevatedButton.icon(
              icon: const Icon(Icons.show_chart),
              label: const Text('Voir ma progression'),
              onPressed: () => Navigator.pushNamed(context, '/progression'),
            ),
            const SizedBox(height: 32),
            // Autres infos importantes (placeholder)
            Card(
              color: Theme.of(context).colorScheme.surface,
              child: ListTile(
                leading: Icon(Icons.info, color: Theme.of(context).colorScheme.primary),
                title: Text('Prochaine séance prévue', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                subtitle: const Text('Vendredi - Pecs & Core'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
