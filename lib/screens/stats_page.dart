import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  Set<DateTime> _completedWorkouts = {};
  int _weekCount = 0;
  int _monthCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCompletedWorkouts();
  }


  Future<void> _loadCompletedWorkouts() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'completed_workouts';
    final List<String> saved = prefs.getStringList(key) ?? [];
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final monthStart = DateTime(now.year, now.month, 1);
    final completed = saved.map((e) => DateTime.parse(e)).toSet();
    setState(() {
      _completedWorkouts = completed;
      _weekCount = completed.where((d) => d.isAfter(weekStart.subtract(const Duration(days: 1)))).length;
      _monthCount = completed.where((d) => d.isAfter(monthStart.subtract(const Duration(days: 1)))).length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques & Assiduité'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              color: Colors.black12,
              child: ListTile(
                leading: const Icon(Icons.calendar_today, color: Colors.blue),
                title: Text('Séances cette semaine : $_weekCount'),
                subtitle: Text('Ce mois-ci : $_monthCount'),
              ),
            ),
            const SizedBox(height: 16),
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2100, 12, 31),
              focusedDay: DateTime.now(),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  final isCompleted = _completedWorkouts.any((d) => _isSameDay(d, date));
                  if (isCompleted) {
                    return Positioned(
                      bottom: 1,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green,
                        ),
                      ),
                    );
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
