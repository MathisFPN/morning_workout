import 'package:flutter/material.dart';
import 'package:morning_workout/models/workout_models.dart';
import 'dart:async';
import 'package:vibration/vibration.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final Seance seance;
  final Future<void> Function(DateTime date)? onWorkoutCompleted;

  const WorkoutDetailScreen({super.key, required this.seance, this.onWorkoutCompleted});

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  int? _activeTimerIndex;
  int _timerSeconds = 0;
  Timer? _timer;
  // bool _isRestTimer = false; // supprimé car non utilisé
  // int? _checkedSeriesIndex; // supprimé car non utilisé
  final Map<int, List<bool>> _seriesChecked = {};

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer(int seconds, {bool isRest = false, int? cardIndex}) {
    _timer?.cancel();
    setState(() {
      _timerSeconds = seconds;
      _activeTimerIndex = cardIndex;
    });
    _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
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
            SnackBar(content: Text('Temps écoulé !')),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.seance.focus),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Stack(
        children: [
          ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: widget.seance.exercices.length,
            itemBuilder: (context, index) {
              final exercice = widget.seance.exercices[index];
              _seriesChecked.putIfAbsent(index, () => List.generate(int.tryParse(exercice.series) ?? 1, (_) => false));
              return _buildExerciceCard(context, exercice, index + 1, index);
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (widget.onWorkoutCompleted != null) {
            await widget.onWorkoutCompleted!(DateTime.now());
          }
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Séance terminée !')),
            );
            Navigator.pop(context, true);
          }
        },
        label: Text('Terminer la séance'),
        icon: Icon(Icons.check),
      ),
    );
  }

  Widget _buildExerciceCard(BuildContext context, Exercice exercice, int index, int cardIndex) {
    final isTimeBased = exercice.dureeEnSecondes != null;
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$index. ${exercice.nom}",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            if (exercice.description != null) ...[
              SizedBox(height: 6.0),
              Text(
                exercice.description!,
                style: TextStyle(fontSize: 15, color: Colors.grey[400]),
              ),
            ],
            SizedBox(height: 12.0),
            if (!isTimeBased)
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoChip("Séries", exercice.series),
                      _buildInfoChip("Reps", exercice.repetitions),
                      _buildInfoChip("Récup", exercice.recuperation),
                    ],
                  ),
                  SizedBox(height: 12.0),
                  // Suivi des séries (checkbox)
                  Column(
                    children: List.generate(_seriesChecked[cardIndex]?.length ?? 0, (serieIdx) {
                      return CheckboxListTile(
                        title: Text('Série ${serieIdx + 1}'),
                        value: _seriesChecked[cardIndex]![serieIdx],
                        onChanged: (val) {
                          setState(() {
                            _seriesChecked[cardIndex]![serieIdx] = val ?? false;
                          });
                        },
                      );
                    }),
                  ),
                  SizedBox(height: 8.0),
                  ElevatedButton.icon(
                    onPressed: _activeTimerIndex == cardIndex ? null : () {
                      // Parse la récupération (ex: "60s" ou "60-90s")
                      int seconds = 60;
                      final recup = exercice.recuperation.replaceAll('s', '');
                      if (recup.contains('-')) {
                        seconds = int.tryParse(recup.split('-').first) ?? 60;
                      } else {
                        seconds = int.tryParse(recup) ?? 60;
                      }
                      _startTimer(seconds, isRest: true, cardIndex: cardIndex);
                    },
                    icon: Icon(Icons.timer),
                    label: Text('Lancer le repos'),
                  ),
                ],
              ),
            if (isTimeBased)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoChip("Séries", exercice.series),
                      _buildInfoChip("Durée", "${exercice.dureeEnSecondes}s"),
                    ],
                  ),
                  SizedBox(height: 12.0),
                  ElevatedButton.icon(
                    onPressed: _activeTimerIndex == cardIndex ? null : () {
                      _startTimer(exercice.dureeEnSecondes!, isRest: false, cardIndex: cardIndex);
                    },
                    icon: Icon(Icons.play_arrow),
                    label: Text('Démarrer'),
                  ),
                ],
              ),
            SizedBox(height: 12.0),
            Chip(
              avatar: Icon(Icons.fitness_center, size: 18),
              label: Text(_getMaterielText(exercice.materiel)),
              backgroundColor: Theme.of(context).colorScheme.surface,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey[400]),
        ),
        SizedBox(height: 4.0),
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
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
            Icon(Icons.timer, color: Colors.white),
            SizedBox(width: 12),
            Text(
              _formatDuration(_timerSeconds),
              style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 24),
            IconButton(
              icon: Icon(Icons.close, color: Colors.redAccent),
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
}