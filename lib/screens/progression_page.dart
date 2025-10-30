import 'package:morning_workout/data/program_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ProgressionPage extends StatefulWidget {
  const ProgressionPage({super.key});

  @override
  State<ProgressionPage> createState() => _ProgressionPageState();
}

class _ProgressionPageState extends State<ProgressionPage> {

  String? _selectedExercice;
  List<String> _exercices = [];
  List<MapEntry<DateTime, double>> _poidsEvolution = [];
  List<DateTime> _completedDates = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    // Calcul réel du nombre de séances validées par jour de la semaine
    final weekDays = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    Map<String, int> weekStats = {for (var d in weekDays) d: 0};
    for (final date in _completedDates) {
      int weekday = date.weekday;
      String dayStr = weekDays[weekday - 1];
      weekStats[dayStr] = (weekStats[dayStr] ?? 0) + 1;
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Progression')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.black87,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${weekStats.keys.elementAt(group.x)}\n',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(
                              text: '${rod.toY.toInt()} séance(s)',
                              style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.normal),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (v) => FlLine(color: Colors.grey[800], strokeWidth: 1),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx > 6) return const SizedBox();
                          return Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(weekStats.keys.elementAt(idx), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          );
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(7, (i) {
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: weekStats.values.elementAt(i).toDouble(),
                          color: weekStats.values.elementAt(i) > 0 ? Colors.green : Colors.deepPurple,
                          width: 18,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ],
                    );
                  }),
                  minY: 0,
                  maxY: (weekStats.values.reduce((a, b) => a > b ? a : b) + 1).toDouble(),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text('Évolution du poids par exercice', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            DropdownButton<String>(
              value: _selectedExercice,
              hint: const Text('Choisir un exercice'),
              items: _exercices.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) async {
                setState(() { _selectedExercice = val; });
                await _loadData();
              },
            ),
            const SizedBox(height: 12),
            if (_selectedExercice != null && _poidsEvolution.isNotEmpty)
              SizedBox(
                height: 180,
                child: LineChart(
                  LineChartData(
                    lineBarsData: [
                      LineChartBarData(
                        spots: _poidsEvolution
                            .map((e) => FlSpot(e.key.millisecondsSinceEpoch.toDouble(), e.value))
                            .toList(),
                        isCurved: true,
                        color: Colors.orange,
                        barWidth: 4,
                        dotData: FlDotData(show: true),
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                            return Text('${date.day}/${date.month}', style: const TextStyle(fontSize: 10));
                          },
                        ),
                      ),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),
            if (_selectedExercice != null && _poidsEvolution.isEmpty)
              const Text('Aucune donnée de poids pour cet exercice.'),
            if (_selectedExercice == null)
              const Text('Sélectionne un exercice pour voir l’évolution du poids.'),
          ],
        ),
      ),
    );
  }

  Future<void> _loadData() async {
    // Récupère tous les exercices uniques du programme
    final seances = await Future.value(ProgramData.getSeances());
    final allExercices = <String>{};
    for (final seance in seances) {
      for (final ex in seance.exercices) {
        allExercices.add(ex.nom);
      }
    }
    _exercices = allExercices.toList();
    _exercices.sort();

    // Récupère les dates de séances validées
    final prefs = await SharedPreferences.getInstance();
    final completedStrs = prefs.getStringList('completed_workouts') ?? [];
    _completedDates = completedStrs.map((e) => DateTime.parse(e)).toList();
    _completedDates.sort();

    // Récupère l'évolution du poids pour l'exercice sélectionné
    _poidsEvolution = [];
    if (_selectedExercice != null) {
      for (final date in _completedDates) {
        final dateStr = date.toIso8601String().substring(0, 10);
        final poidsKey = 'poids_${_selectedExercice}_$dateStr';
        final poidsStr = prefs.getString(poidsKey);
        if (poidsStr != null && poidsStr.isNotEmpty) {
          final poids = double.tryParse(poidsStr);
          if (poids != null) {
            _poidsEvolution.add(MapEntry(date, poids));
          }
        }
      }
      _poidsEvolution.sort((a, b) => a.key.compareTo(b.key));
    }

    setState(() {});
  }
}