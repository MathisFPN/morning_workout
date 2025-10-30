import 'package:flutter/material.dart';
import 'package:morning_workout/models/workout_models.dart';

class ExerciceDetailPage extends StatelessWidget {
  final Exercice exercice;
  const ExerciceDetailPage({super.key, required this.exercice});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(exercice.nom),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exercice.nom,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (exercice.description != null)
              Text(
                exercice.description!,
                style: const TextStyle(fontSize: 16, color: Colors.white70),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Chip(label: Text('Séries: ${exercice.series}')),
                const SizedBox(width: 8),
                Chip(label: Text('Reps: ${exercice.repetitions}')),
                if (exercice.dureeEnSecondes != null) ...[
                  const SizedBox(width: 8),
                  Chip(label: Text('Durée: ${exercice.dureeEnSecondes}s')),
                ],
              ],
            ),
            const SizedBox(height: 16),
            Chip(
              avatar: const Icon(Icons.fitness_center, size: 18),
              label: Text(_getMaterielText(exercice.materiel)),
            ),
            const SizedBox(height: 24),
            const Text('Conseils d\'exécution :', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_getConseil(exercice)),
          ],
        ),
      ),
    );
  }

  String _getMaterielText(Materiel materiel) {
    switch (materiel) {
      case Materiel.halteres10kg:
        return "2x Haltères 10kg";
      case Materiel.haltere20kg:
        return "1x Haltère ~20kg";
      case Materiel.elastique:
        return "Élastique";
      case Materiel.poignees:
        return "Poignées (Pompes)";
      case Materiel.poidsDuCorps:
        return "Poids du corps";
    }
  }

  String _getConseil(Exercice ex) {
    if (ex.nom.toLowerCase().contains('pompe')) {
      return "Garde le dos droit, abdos gainés, descends poitrine proche du sol.";
    }
    if (ex.nom.toLowerCase().contains('curl')) {
      return "Contrôle la montée et la descente, ne balance pas le dos.";
    }
    if (ex.nom.toLowerCase().contains('gainage') || ex.nom.toLowerCase().contains('planche')) {
      return "Reste bien aligné, ne creuse pas le bas du dos.";
    }
    return "Exécute le mouvement lentement et avec contrôle.";
  }
}
