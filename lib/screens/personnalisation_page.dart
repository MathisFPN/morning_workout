import 'package:flutter/material.dart';
import 'package:morning_workout/models/workout_models.dart';
import 'package:morning_workout/data/program_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PersonnalisationPage extends StatefulWidget {
  const PersonnalisationPage({super.key});

  @override
  State<PersonnalisationPage> createState() => _PersonnalisationPageState();
}

class _PersonnalisationPageState extends State<PersonnalisationPage> {
  Map<String, TextEditingController> _poidsControllers = {};
  List<Seance> _seances = [];

  @override
  void initState() {
    super.initState();
    _seances = ProgramData.getSeances();
    _initPoidsControllers();
  }

  Future<void> _initPoidsControllers() async {
    final prefs = await SharedPreferences.getInstance();
    for (final seance in _seances) {
      for (final ex in seance.exercices) {
        final key = 'poids_ref_${ex.nom}';
        final poids = prefs.getString(key) ?? '';
        _poidsControllers[ex.nom] = TextEditingController(text: poids);
      }
    }
    setState(() {});
  }

  Future<void> _savePoidsRef(String exName, String poids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('poids_ref_$exName', poids);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personnaliser mes séances'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _seances.length,
        itemBuilder: (context, index) {
          final seance = _seances[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12.0),
            child: ExpansionTile(
              title: Text(seance.focus),
              subtitle: Text(seance.jour),
              children: [
                ...seance.exercices.map((ex) => ListTile(
                      title: Row(
                        children: [
                          Expanded(child: Text(ex.nom)),
                          if (ex.materiel == Materiel.halteres10kg || ex.materiel == Materiel.haltere20kg)
                            SizedBox(
                              width: 90,
                              child: TextField(
                                controller: _poidsControllers[ex.nom],
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Poids (kg)',
                                  isDense: true,
                                ),
                                onChanged: (val) {
                                  _savePoidsRef(ex.nom, val);
                                },
                              ),
                            ),
                        ],
                      ),
                      subtitle: Text('Séries: ${ex.series}, Reps: ${ex.repetitions}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            seance.exercices.remove(ex);
                          });
                        },
                      ),
                    )),
                TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter un exercice'),
                  onPressed: () async {
                    final result = await showDialog<Exercice>(
                      context: context,
                      builder: (context) {
                        final nomController = TextEditingController();
                        final descController = TextEditingController();
                        final seriesController = TextEditingController(text: '3');
                        final repsController = TextEditingController(text: '10');
                        final recupController = TextEditingController(text: '60s');
                        Materiel selectedMateriel = Materiel.poidsDuCorps;
                        return AlertDialog(
                          title: const Text('Nouvel exercice'),
                          content: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  controller: nomController,
                                  decoration: const InputDecoration(labelText: 'Nom'),
                                ),
                                TextField(
                                  controller: descController,
                                  decoration: const InputDecoration(labelText: 'Description (optionnel)'),
                                ),
                                DropdownButtonFormField<Materiel>(
                                  value: selectedMateriel,
                                  decoration: const InputDecoration(labelText: 'Matériel'),
                                  items: [
                                    DropdownMenuItem(
                                      value: Materiel.poidsDuCorps,
                                      child: Text('Poids du corps'),
                                    ),
                                    DropdownMenuItem(
                                      value: Materiel.halteres10kg,
                                      child: Text('Haltères 10kg'),
                                    ),
                                    DropdownMenuItem(
                                      value: Materiel.haltere20kg,
                                      child: Text('Haltère 20kg'),
                                    ),
                                    DropdownMenuItem(
                                      value: Materiel.elastique,
                                      child: Text('Élastique'),
                                    ),
                                    DropdownMenuItem(
                                      value: Materiel.poignees,
                                      child: Text('Poignées'),
                                    ),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) selectedMateriel = val;
                                  },
                                ),
                                TextField(
                                  controller: seriesController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(labelText: 'Séries'),
                                ),
                                TextField(
                                  controller: repsController,
                                  decoration: const InputDecoration(labelText: 'Répétitions'),
                                ),
                                TextField(
                                  controller: recupController,
                                  decoration: const InputDecoration(labelText: 'Récupération'),
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, null),
                              child: const Text('Annuler'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                if (nomController.text.trim().isEmpty) return;
                                Navigator.pop(
                                  context,
                                  Exercice(
                                    nom: nomController.text.trim(),
                                    description: descController.text.trim().isEmpty ? null : descController.text.trim(),
                                    series: seriesController.text.trim(),
                                    repetitions: repsController.text.trim(),
                                    recuperation: recupController.text.trim(),
                                    materiel: selectedMateriel,
                                  ),
                                );
                              },
                              child: const Text('Ajouter'),
                            ),
                          ],
                        );
                      },
                    );
                    if (result != null) {
                      setState(() {
                        seance.exercices.add(result);
                      });
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
