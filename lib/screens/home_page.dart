import 'package:flutter/material.dart';
import 'package:morning_workout/data/program_data.dart';
import 'package:morning_workout/screens/exercice_detail_page.dart';
import 'package:morning_workout/models/workout_models.dart';
import 'package:vibration/vibration.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Set<DateTime> _completedWorkouts = {};
  late final List<Seance> seances;
  Map<int, List<bool>> _seriesChecked = {};
  int? _activeTimerIndex;
  int _timerSeconds = 0;
  Timer? _timer;

  Future<void> _saveWorkoutCompletion(DateTime date, Seance seance) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'completed_workouts';
    final dateStr = date.toIso8601String().substring(0, 10);
    final List<String> saved = prefs.getStringList(key) ?? [];
    if (!saved.contains(dateStr)) {
      Map<String, String> poidsMap = {};
      for (final ex in seance.exercices) {
        // On ne demande le poids QUE pour les exercices avec haltères (10kg ou 20kg)
        if (ex.materiel == Materiel.halteres10kg || ex.materiel == Materiel.haltere20kg) {
          final refKey = 'poids_ref_${ex.nom}';
          final refPoids = prefs.getString(refKey) ?? '';
          final controller = TextEditingController(text: refPoids);
          final poids = await showDialog<String>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Poids utilisé pour ${ex.nom}'),
              content: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Poids en kg'),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: const Text('Ignorer'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, controller.text),
                  child: const Text('Valider'),
                ),
              ],
            ),
          );
          if (poids != null && poids.isNotEmpty) {
            poidsMap[ex.nom] = poids;
          }
        }
        // Pour tout autre matériel (poidsDuCorps, poignees, elastique, etc), ne rien demander !
      }
      // Sauvegarde la date
      saved.add(dateStr);
      await prefs.setStringList(key, saved);
      // Sauvegarde les poids par exercice pour la date
      for (final entry in poidsMap.entries) {
        final poidsKey = 'poids_${entry.key}_$dateStr';
        await prefs.setString(poidsKey, entry.value);
      }
      setState(() {
        _completedWorkouts.add(DateTime.parse(dateStr));
      });
    }
  }

  Future<void> _loadCompletedWorkouts() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'completed_workouts';
    final List<String> saved = prefs.getStringList(key) ?? [];
    setState(() {
      _completedWorkouts = saved.map((e) => DateTime.parse(e)).toSet();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadCompletedWorkouts();
  }

  @override
  void initState() {
    super.initState();
    seances = ProgramData.getSeances();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer(int seconds, int cardIndex) {
    _timer?.cancel();
    setState(() {
      _timerSeconds = seconds;
      _activeTimerIndex = cardIndex;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_timerSeconds > 0) {
        setState(() {
          _timerSeconds--;
        });
      } else {
        timer.cancel();
        if (await Vibration.hasVibrator()) {
          Vibration.vibrate(duration: 500);
        }
        setState(() {
          _activeTimerIndex = null;
        });
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Temps écoulé !')),
          );
        }
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _activeTimerIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: seances.length,
          itemBuilder: (context, index) {
            final seance = seances[index];
            _seriesChecked.putIfAbsent(index, () => List.generate(int.tryParse(seance.exercices.first.series) ?? 1, (_) => false));
            return _buildSeanceCard(context, seance, index);
          },
        ),
        if (_activeTimerIndex != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 24,
            child: _buildTimerOverlay(),
          ),
      ],
    );
  }

  Widget _buildSeanceCard(BuildContext context, Seance seance, int cardIndex) {
  final now = DateTime.now();
  final isToday = seance.jour.toLowerCase() == _jourSemaineFr(now.weekday).toLowerCase();
  final isTodayCompleted = _completedWorkouts.any((d) => d.year == now.year && d.month == now.month && d.day == now.day && seance.jour.toLowerCase() == _jourSemaineFr(d.weekday).toLowerCase());
  return Card(
      elevation: 5.0,
      margin: const EdgeInsets.only(bottom: 32.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              seance.jour.toUpperCase(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 6.0),
            Text(
              seance.focus,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              seance.description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[300],
              ),
            ),
            const SizedBox(height: 18.0),
            ...seance.exercices.asMap().entries.map((entry) {
              final ex = entry.value;
              final isTimeBased = ex.dureeEnSecondes != null;
              return Card(
                color: Colors.grey[900],
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExerciceDetailPage(exercice: ex),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              ex.nom,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const Icon(Icons.info_outline, color: Colors.white54, size: 20),
                          ],
                        ),
                        if (!isTimeBased) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Séries: ${ex.series}', style: const TextStyle(color: Colors.white70)),
                              Text('Reps: ${ex.repetitions}', style: const TextStyle(color: Colors.white70)),
                              Text('Récup: ${ex.recuperation}', style: const TextStyle(color: Colors.white70)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Column(
                            children: List.generate(int.tryParse(ex.series) ?? 1, (serieIdx) {
                              _seriesChecked[cardIndex] ??= List.generate(int.tryParse(ex.series) ?? 1, (_) => false);
                              return CheckboxListTile(
                                title: Text('Série ${serieIdx + 1}', style: const TextStyle(color: Colors.white)),
                                value: _seriesChecked[cardIndex]![serieIdx],
                                onChanged: (val) {
                                  setState(() {
                                    _seriesChecked[cardIndex]![serieIdx] = val ?? false;
                                  });
                                },
                                activeColor: Theme.of(context).colorScheme.primary,
                                checkColor: Colors.white,
                              );
                            }),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: _activeTimerIndex == cardIndex ? null : () {
                              int seconds = 60;
                              final recup = ex.recuperation.replaceAll('s', '');
                              if (recup.contains('-')) {
                                seconds = int.tryParse(recup.split('-').first) ?? 60;
                              } else {
                                seconds = int.tryParse(recup) ?? 60;
                              }
                              _startTimer(seconds, cardIndex);
                            },
                            icon: const Icon(Icons.timer),
                            label: const Text('Lancer le repos'),
                          ),
                        ],
                        if (isTimeBased) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Séries: ${ex.series}', style: const TextStyle(color: Colors.white70)),
                              Text('Durée: ${ex.dureeEnSecondes}s', style: const TextStyle(color: Colors.white70)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: _activeTimerIndex == cardIndex ? null : () {
                              _startTimer(ex.dureeEnSecondes!, cardIndex);
                            },
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Démarrer'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isTodayCompleted ? Colors.green : (isToday ? Theme.of(context).colorScheme.primary : Colors.grey),
                  foregroundColor: Colors.white,
                ),
                icon: Icon(isTodayCompleted ? Icons.check : Icons.flag),
                label: Text(
                  isTodayCompleted
                      ? 'Séance du jour validée'
                      : (isToday ? 'Terminer la séance' : 'Disponible uniquement le ${seance.jour}'),
                ),
                onPressed: (isTodayCompleted || !isToday)
                    ? null
                    : () async {
                        await _saveWorkoutCompletion(DateTime.now(), seance);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Séance du jour validée !')),
                          );
                        }
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _jourSemaineFr(int weekday) {
    switch (weekday) {
      case 1:
        return 'Lundi';
      case 2:
        return 'Mardi';
      case 3:
        return 'Mercredi';
      case 4:
        return 'Jeudi';
      case 5:
        return 'Vendredi';
      case 6:
        return 'Samedi';
      case 7:
        return 'Dimanche';
      default:
        return '';
    }
  }

  Widget _buildTimerOverlay() {
    return Material(
      elevation: 8,
      color: Colors.black.withOpacity(0.85),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.timer, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              _formatDuration(_timerSeconds),
              style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 24),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.redAccent),
              onPressed: _stopTimer,
              tooltip: 'Arrêter',
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final min = (seconds ~/ 60).toString().padLeft(2, '0');
    final sec = (seconds % 60).toString().padLeft(2, '0');
    return "$min:$sec";
  }
}