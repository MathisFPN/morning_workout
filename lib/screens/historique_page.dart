import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:morning_workout/models/workout_models.dart';
import 'package:morning_workout/data/program_data.dart';

class HistoriquePage extends StatefulWidget {
  const HistoriquePage({super.key});

  @override
  State<HistoriquePage> createState() => _HistoriquePageState();
}

class _HistoriquePageState extends State<HistoriquePage> {
  List<DateTime> _completedDates = [];
  List<Seance> _seances = [];

  @override
  void initState() {
    super.initState();
    _loadHistorique();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadHistorique();
  }

  Future<void> _loadHistorique() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'completed_workouts';
    final List<String> saved = prefs.getStringList(key) ?? [];
    setState(() {
      _completedDates = saved.map((e) => DateTime.parse(e)).toList()..sort((a, b) => b.compareTo(a));
      _seances = ProgramData.getSeances();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des séances'),
        centerTitle: true,
      ),
      body: _completedDates.isEmpty
          ? const Center(child: Text('Aucune séance terminée pour le moment.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _completedDates.length,
              itemBuilder: (context, index) {
                final date = _completedDates[index];
                final seance = _seances[index % _seances.length];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ListTile(
                    leading: const Icon(Icons.check_circle, color: Colors.green),
                    title: Text('${seance.focus}'),
                    subtitle: Text('Complétée le ${_formatDate(date)}'),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).colorScheme.secondary),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(seance.focus),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Jour : ${seance.jour}'),
                              Text('Description : ${seance.description}'),
                              const SizedBox(height: 8),
                              Text('Exercices :'),
                              ...seance.exercices.map((e) => Text('- ${e.nom}')).toList(),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Fermer'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
