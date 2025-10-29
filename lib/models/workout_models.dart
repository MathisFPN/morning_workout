enum Materiel {
  halteres10kg,
  haltere20kg,
  elastique,
  poignees,
  poidsDuCorps,
}

class Exercice {
  final String nom;
  final String? description;
  final String series;
  final String repetitions;
  final String recuperation;
  final Materiel materiel;
  /// Durée en secondes pour les exercices au temps (ex: gainage)
  final int? dureeEnSecondes;

  Exercice({
    required this.nom,
    this.description,
    required this.series,
    required this.repetitions,
    required this.recuperation,
    required this.materiel,
    this.dureeEnSecondes,
  });
}

class Seance {
  final String jour;
  final String focus;
  final String description;
  final List<Exercice> exercices;

  Seance({
    required this.jour,
    required this.focus,
    required this.description,
    required this.exercices,
  });
}