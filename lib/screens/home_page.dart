import 'package:flutter/material.dart';
import 'package:morning_workout/data/program_data.dart';
import 'package:morning_workout/models/workout_models.dart';
import 'package:morning_workout/models/workout_detail_screen.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final List<Seance> seances;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Set<DateTime> _completedWorkouts = {};

  @override
  void initState() {
    super.initState();
    seances = ProgramData.getSeances();
    loadCompletedWorkouts();
  }

  Future<void> saveWorkoutCompletion(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'completed_workouts';
    final dateStr = date.toIso8601String().substring(0, 10);
    final List<String> saved = prefs.getStringList(key) ?? [];
    if (!saved.contains(dateStr)) {
      saved.add(dateStr);
      await prefs.setStringList(key, saved);
      setState(() {
        _completedWorkouts.add(DateTime.parse(dateStr));
      });
    }
  }

  Future<void> loadCompletedWorkouts() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'completed_workouts';
    final List<String> saved = prefs.getStringList(key) ?? [];
    setState(() {
      _completedWorkouts = saved.map((e) => DateTime.parse(e)).toSet();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mon Programme Matinal"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2100, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarFormat: CalendarFormat.month,
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  final isCompleted = _completedWorkouts.any((d) => isSameDay(d, date));
                  if (isCompleted) {
                    return Positioned(
                      bottom: 1,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.greenAccent,
                        ),
                      ),
                    );
                  }
                  return null;
                },
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16.0),
              itemCount: seances.length,
              itemBuilder: (context, index) {
                final seance = seances[index];
                return _buildSeanceCard(context, seance);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeanceCard(BuildContext context, Seance seance) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: () async {
          // Navigue vers WorkoutDetailScreen et attend un retour
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WorkoutDetailScreen(
                seance: seance,
                onWorkoutCompleted: saveWorkoutCompletion,
              ),
            ),
          );
          if (result == true) {
            // Rafraîchir le calendrier si une séance a été complétée
            await loadCompletedWorkouts();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                seance.jour,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                seance.focus,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                seance.description,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[400],
                ),
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${seance.exercices.length} exercices",
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Theme.of(context).colorScheme.secondary,
                    size: 16,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}