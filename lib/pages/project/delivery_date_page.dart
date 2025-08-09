import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/project_data.dart';
import '../../theme/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'project_order_page.dart';

class PaymentPage extends StatefulWidget {
  final ProjectData project;

  const PaymentPage({super.key, required this.project});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  List<DateTime> unavailableDates = [];
  bool loadingDates = true;
  DateTime? selectedDate;

  bool _isBusy(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return unavailableDates.any(
      (x) => x.year == d.year && x.month == d.month && x.day == d.day,
    );
  }

  bool _isDeliveryDateAllowed(DateTime date) {
    // Jour lui-même libre ?
    if (_isBusy(date)) return false;

    // Les 21 jours précédents doivent être libres
    for (int i = 1; i <= 21; i++) {
      final prev = date.subtract(Duration(days: i));
      if (_isBusy(prev)) return false;
    }
    return true;
  }

  DateTime? _findFirstAllowedDate(DateTime from, DateTime to) {
    var d = DateTime(from.year, from.month, from.day);
    final end = DateTime(to.year, to.month, to.day);
    while (!d.isAfter(end)) {
      if (_isDeliveryDateAllowed(d)) return d;
      d = d.add(const Duration(days: 1));
    }
    return null;
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final earliest = now.add(const Duration(days: 21));
    final latest = now.add(const Duration(days: 730));

    // Trouver une date initiale qui passe la predicate
    final initial = _findFirstAllowedDate(earliest, latest);
    if (initial == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Aucune date disponible pour le moment.")),
      );
      return;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: earliest,
      lastDate: latest,
      selectableDayPredicate: (date) => _isDeliveryDateAllowed(date),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _fetchUnavailableDates() async {
    const calendarId = 'chewlincorp@gmail.com';
    const apiKey = 'AIzaSyCxHIowhgMNEQCNCkINKGsFqztbix_4o_g';
    final now = DateTime.now().toUtc();
    final future = now.add(const Duration(days: 730));

    final url =
        'https://www.googleapis.com/calendar/v3/calendars/$calendarId/events?timeMin=${now.toIso8601String()}&timeMax=${future.toIso8601String()}&singleEvents=true&orderBy=startTime&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List events = data['items'];
      final Set<DateTime> dates = {};

      for (var event in events) {
        final startStr = event['start']['date'] ?? event['start']['dateTime'];
        final endStr = event['end']['date'] ?? event['end']['dateTime'];

        final start = DateTime.parse(startStr).toLocal();
        final end = DateTime.parse(endStr).toLocal();

        for (
          DateTime d = start;
          !d.isAfter(end.subtract(const Duration(days: 1)));
          d = d.add(const Duration(days: 1))
        ) {
          final date = DateTime(d.year, d.month, d.day);
          dates.add(date);
        }
      }

      setState(() {
        unavailableDates = dates.toList();
        loadingDates = false;
      });
    } else {
      setState(() {
        loadingDates = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur de récupération de l'agenda.")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUnavailableDates();
  }

  @override
  Widget build(BuildContext context) {
    if (loadingDates) {
      return const Scaffold(
        backgroundColor: AppColors.black,
        body: Center(child: CircularProgressIndicator(color: AppColors.green)),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        iconTheme: const IconThemeData(color: AppColors.green),
        title: const Text(
          "Paiement",
          style: TextStyle(color: AppColors.beige, fontFamily: 'ReginaBlack'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Planche : ${widget.project.boardName}",
              style: const TextStyle(color: AppColors.beige, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              "Prix : ${widget.project.boardPrice}",
              style: const TextStyle(color: AppColors.beige, fontSize: 16),
            ),
            const SizedBox(height: 24),
            const Text(
              "La création prend 3 semaines. Choisis une date de livraison telle que "
              "les 21 jours PRÉCÉDENTS soient libres dans l'agenda.",
              style: TextStyle(color: AppColors.green),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _selectDate,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.green),
              child: Text(
                selectedDate != null
                    ? DateFormat('dd MMM yyyy').format(selectedDate!)
                    : 'Sélectionner une date',
                style: const TextStyle(color: AppColors.beige),
              ),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (selectedDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Veuillez choisir une date."),
                      ),
                    );
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => ProjectOrderPage(
                            projectData: widget.project,
                            deliveryDate: selectedDate!,
                          ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  "Payer maintenant",
                  style: TextStyle(
                    color: AppColors.beige,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
