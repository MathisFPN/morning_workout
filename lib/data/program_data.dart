// C'est ici que ton programme est codé en dur pour gagner du temps
import 'package:morning_workout/models/workout_models.dart';

class ProgramData {
  
  static List<Seance> getSeances() {
    return [
      // SÉANCE MARDI
      Seance(
        jour: "Mardi",
        focus: "PUSH (Pecs & Épaules)",
        description: "Focus sur la poussée : pectoraux, épaules et triceps.",
        exercices: [
          Exercice(
            nom: "Pompes (avec poignées)",
            series: "4",
            repetitions: "8 à 15",
            recuperation: "60-90s",
            materiel: Materiel.poignees,
          ),
          Exercice(
            nom: "Développé Haltères au sol",
            series: "4",
            repetitions: "10 à 15",
            recuperation: "60-90s",
            materiel: Materiel.halteres10kg,
          ),
          Exercice(
            nom: "Développé Militaire (haltères)",
            series: "3",
            repetitions: "8 à 12",
            recuperation: "60s",
            materiel: Materiel.halteres10kg,
          ),
          Exercice(
            nom: "Écarté Pectoraux (élastique)",
            series: "3",
            repetitions: "15 à 20",
            recuperation: "45s",
            materiel: Materiel.elastique,
          ),
          Exercice(
            nom: "Extensions Triceps (1 haltère)",
            series: "3",
            repetitions: "10 à 15",
            recuperation: "45s",
            materiel: Materiel.haltere20kg, // Ou 1x 10kg
          ),
        ],
      ),

      // SÉANCE MERCREDI
      Seance(
        jour: "Mercredi",
        focus: "PULL (Dos & Biceps)",
        description: "Focus sur le tirage : dos, biceps et avant-bras.",
        exercices: [
          Exercice(
            nom: "Rowing 1 bras (haltère)",
            series: "4",
            repetitions: "8 à 12 (par côté)",
            recuperation: "60-90s",
            materiel: Materiel.haltere20kg,
          ),
          Exercice(
            nom: "Tirage horizontal (élastique)",
            series: "3",
            repetitions: "15 à 20",
            recuperation: "60s",
            materiel: Materiel.elastique,
          ),
          Exercice(
            nom: "Curl Biceps (haltères)",
            series: "3",
            repetitions: "10 à 15",
            recuperation: "45s",
            materiel: Materiel.halteres10kg,
          ),
          Exercice(
            nom: "Curl Marteau (haltères)",
            series: "3",
            repetitions: "10 à 15",
            recuperation: "45s",
            materiel: Materiel.halteres10kg,
          ),
          Exercice(
            nom: "Curl Poignets (haltères)",
            series: "2",
            repetitions: "15 à 20",
            recuperation: "30s",
            materiel: Materiel.halteres10kg,
          ),
        ],
      ),

      // SÉANCE VENDREDI
      Seance(
        jour: "Vendredi",
        focus: "PECS & CORE",
        description: "Rappel pectoraux et focus sur la sangle abdominale.",
        exercices: [
          Exercice(
            nom: "Pompes Déclinées",
            series: "3",
            repetitions: "Max de reps",
            recuperation: "60-90s",
            materiel: Materiel.poignees,
          ),
           Exercice(
            nom: "Écarté Haltères au sol",
            series: "3",
            repetitions: "12 à 15",
            recuperation: "60s",
            materiel: Materiel.halteres10kg,
          ),
          Exercice(
            nom: "Serré Pectoraux (Crush Press)",
            series: "2",
            repetitions: "15 à 20",
            recuperation: "45s",
            materiel: Materiel.halteres10kg, // 1 ou 2 haltères
          ),
          Exercice(
            nom: "Circuit Abdominaux",
            description: "Planche, Relevés de jambes, Crunch Vélo",
            series: "3",
            repetitions: "Planche (45-60s) > Relevés de jambes (15-20) > Crunch Vélo (20-30)",
            recuperation: "60s",
            materiel: Materiel.poidsDuCorps,
            dureeEnSecondes: 45, // Ajout de la durée pour la planche
          ),
        ],
      ),
    ];
  }
}