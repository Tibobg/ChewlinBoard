import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import '../theme/colors.dart';

class AvailabilityCalendar extends StatefulWidget {
  const AvailabilityCalendar({super.key});

  @override
  State<AvailabilityCalendar> createState() => _AvailabilityCalendarState();
}

class _AvailabilityCalendarState extends State<AvailabilityCalendar> {
  final String calendarId = 'chewlincorp@gmail.com';
  final String apiKey = 'AIzaSyCxHIowhgMNEQCNCkINKGsFqztbix_4o_g';

  Map<DateTime, List<String>> _events = {};
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    final now = DateTime.now();
    final nowLocalToUtc = DateTime.utc(
      now.year,
      now.month,
      now.day,
    ); // 👉 au lieu de .toUtc()
    final future = DateTime.utc(now.year + 1, 12, 31);

    final url =
        'https://www.googleapis.com/calendar/v3/calendars/$calendarId/events?key=$apiKey'
        '&singleEvents=true&orderBy=startTime'
        '&timeMin=${nowLocalToUtc.toIso8601String()}'
        '&timeMax=${future.toIso8601String()}';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final items = data['items'] as List;

      Map<DateTime, List<String>> events = {};

      for (var item in items) {
        final startStr = item['start']['date'] ?? item['start']['dateTime'];
        final endStr = item['end']['date'] ?? item['end']['dateTime'];

        final start = DateTime.parse(startStr).toLocal();
        final end = DateTime.parse(endStr).toLocal();

        for (
          DateTime d = start;
          !d.isAfter(end.subtract(const Duration(days: 1)));
          d = d.add(const Duration(days: 1))
        ) {
          final date = DateTime(d.year, d.month, d.day);
          events
              .putIfAbsent(date, () => [])
              .add(item['summary'] ?? 'Événement');
        }
      }

      setState(() => _events = events);
    } else {
      print("Erreur de récupération des événements : ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      locale: 'fr_FR',
      firstDay: DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      ),
      lastDay: DateTime(DateTime.now().year + 1, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: CalendarFormat.month,
      startingDayOfWeek: StartingDayOfWeek.monday,
      headerStyle: const HeaderStyle(
        titleCentered: true,
        formatButtonVisible: false,
        titleTextStyle: TextStyle(color: Colors.white),
        leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
        rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
      ),
      daysOfWeekStyle: const DaysOfWeekStyle(
        weekdayStyle: TextStyle(color: Colors.white70),
        weekendStyle: TextStyle(color: Colors.white70),
      ),
      calendarStyle: const CalendarStyle(
        defaultTextStyle: TextStyle(color: Colors.white), // 👈 correction ici
        weekendTextStyle: TextStyle(color: Colors.white70),
        outsideDaysVisible: false,
        todayDecoration: BoxDecoration(
          color: AppColors.green,
          shape: BoxShape.circle,
        ),
        markerDecoration: BoxDecoration(
          color: Colors.redAccent,
          shape: BoxShape.circle,
        ),
      ),

      eventLoader: (day) {
        final date = DateTime(day.year, day.month, day.day);
        return _events[date] ?? [];
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() => _focusedDay = focusedDay);
      },
      selectedDayPredicate: (_) => false,
      onPageChanged: (newFocusedDay) {
        _focusedDay = newFocusedDay;
      },
    );
  }
}
