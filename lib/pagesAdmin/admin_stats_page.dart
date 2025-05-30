import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/colors.dart';
import '../pages/login_page.dart';
import '../services/auth_service.dart';

class AdminStatsPage extends StatefulWidget {
  const AdminStatsPage({super.key});

  @override
  State<AdminStatsPage> createState() => _AdminStatsPageState();
}

class _AdminStatsPageState extends State<AdminStatsPage> {
  int totalOrders = 0;
  double totalRevenue = 0;
  Map<String, int> statusCounts = {};
  int soldCount = 0;
  int availableCount = 0;
  bool loading = true;

  final statusColors = [
    Colors.orange,
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.red,
    Colors.grey,
  ];

  @override
  void initState() {
    super.initState();
    fetchStats();
  }

  Future<void> fetchStats() async {
    final ordersSnapshot =
        await FirebaseFirestore.instance.collection('orders').get();
    final skateboardsSnapshot =
        await FirebaseFirestore.instance.collection('skateboards').get();

    int orders = ordersSnapshot.docs.length;
    double revenue = 0;
    Map<String, int> statuses = {};

    for (var doc in ordersSnapshot.docs) {
      final data = doc.data();
      final status = data['status'] ?? 'inconnu';
      final price = double.tryParse(data['price'].toString()) ?? 0;

      revenue += price;
      statuses[status] = (statuses[status] ?? 0) + 1;
    }

    int sold = 0;
    int available = 0;

    for (var doc in skateboardsSnapshot.docs) {
      final isSold = doc['isSold'] == true;
      if (isSold) {
        sold++;
      } else {
        available++;
      }
    }

    setState(() {
      totalOrders = orders;
      totalRevenue = revenue;
      statusCounts = statuses;
      soldCount = sold;
      availableCount = available;
      loading = false;
    });
  }

  List<PieChartSectionData> getPieSections() {
    final total = statusCounts.values.fold(0, (sum, val) => sum + val);
    int i = 0;
    return statusCounts.entries.map((entry) {
      final percentage = (entry.value / total) * 100;
      final color = statusColors[i++ % statusColors.length];
      return PieChartSectionData(
        color: color,
        value: entry.value.toDouble(),
        title: "${percentage.toStringAsFixed(1)}%",
        radius: 60,
        titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
      );
    }).toList();
  }

  BarChartGroupData buildBarGroup(int x, double value, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: value,
          color: color,
          width: 30,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Statistiques',
          style: TextStyle(fontFamily: 'ReginaBlack', fontSize: 22),
        ),
        backgroundColor: AppColors.black,
        foregroundColor: AppColors.beige,
      ),
      body:
          loading
              ? const Center(
                child: CircularProgressIndicator(color: AppColors.green),
              )
              : Padding(
                padding: const EdgeInsets.all(16),
                child: ListView(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.logout, color: AppColors.beige),
                      onPressed: () async {
                        await AuthService().signOut();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                          (route) => false,
                        );
                      },
                    ),
                    const Text(
                      'Commandes',
                      style: TextStyle(
                        color: AppColors.beige,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Nombre total : $totalOrders',
                      style: const TextStyle(color: AppColors.beige),
                    ),
                    Text(
                      'Revenu total : ${totalRevenue.toStringAsFixed(2)} €',
                      style: const TextStyle(color: AppColors.beige),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Répartition des statuts',
                      style: TextStyle(
                        color: AppColors.beige,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sections: getPieSections(),
                          sectionsSpace: 2,
                          centerSpaceRadius: 30,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...statusCounts.entries.map(
                      (entry) => Text(
                        '${entry.key} : ${entry.value}',
                        style: const TextStyle(color: AppColors.beige),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Inventaire',
                      style: TextStyle(
                        color: AppColors.beige,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: true),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, _) {
                                  switch (value.toInt()) {
                                    case 0:
                                      return const Text(
                                        'Vendues',
                                        style: TextStyle(
                                          color: AppColors.beige,
                                        ),
                                      );
                                    case 1:
                                      return const Text(
                                        'Dispo',
                                        style: TextStyle(
                                          color: AppColors.beige,
                                        ),
                                      );
                                    default:
                                      return const Text('');
                                  }
                                },
                              ),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          barGroups: [
                            buildBarGroup(0, soldCount.toDouble(), Colors.red),
                            buildBarGroup(
                              1,
                              availableCount.toDouble(),
                              Colors.green,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Planches vendues : $soldCount',
                      style: const TextStyle(color: AppColors.beige),
                    ),
                    Text(
                      'Planches disponibles : $availableCount',
                      style: const TextStyle(color: AppColors.beige),
                    ),
                  ],
                ),
              ),
    );
  }
}
