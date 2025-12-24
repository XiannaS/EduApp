import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart'; // <--- IMPORTER FL_CHART
import 'package:test/screens/admin/views/enrollments_view.dart';
import 'package:test/widgets/admin_header.dart';
import 'package:test/widgets/side_menu.dart';
import 'package:test/widgets/stat_card.dart';
import '../../services/dashboard_service.dart'; // <--- TON NOUVEAU SERVICE
import 'views/students_view.dart';
import 'views/course_view.dart';
import '../../providers/theme_provider.dart';

const Color kAccentBlue = Color(0xFF2D62ED);
const Color kAccentGreen = Color(0xFF1CC24A);
const Color kAccentOrange = Color(0xFFFF5C00);
const Color kAccentPurple = Color(0xFF8F00FF);

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final isDesktop = MediaQuery.of(context).size.width > 900;

    final List<Widget> pages = [
      const _StatsView(),
      const StudentsView(),
      const CoursesView(),
      const EnrollmentsView(),
    ];

    return Scaffold(
      backgroundColor: theme.bgColor,
      drawer: !isDesktop 
        ? SideMenu(
            selectedIndex: _selectedIndex,
            onIndexChanged: (index) {
              setState(() => _selectedIndex = index);
              Navigator.pop(context);
            },
          ) 
        : null,
      body: Row(
        children: [
          if (isDesktop)
            SideMenu(
              selectedIndex: _selectedIndex,
              onIndexChanged: (index) => setState(() => _selectedIndex = index),
            ),
          Expanded(
            child: Column(
              children: [
                const AdminHeader(),
                Expanded(child: pages[_selectedIndex]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- VUE STATISTIQUES AVEC GRAPHIQUES ---
class _StatsView extends StatefulWidget {
  const _StatsView();

  @override
  State<_StatsView> createState() => _StatsViewState();
}

class _StatsViewState extends State<_StatsView> {
  late Future<Map<String, dynamic>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = DashboardService().fetchDashboardStats();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final width = MediaQuery.of(context).size.width;
    int crossAxisCount = width > 1100 ? 4 : (width > 700 ? 2 : 1);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: FutureBuilder<Map<String, dynamic>>(
        future: _statsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data ?? {};
          final int ado = data['ado'] ?? 0;
          final int enf = data['enf'] ?? 0;
          final int adu = data['adu'] ?? 0;
          final int total = (int.tryParse(data['students'] ?? "0") ?? 1); 

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Tableau de Bord", style: TextStyle(color: theme.textColor, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text("Aperçu en temps réel de l'établissement.", style: TextStyle(color: theme.subTextColor, fontSize: 14)),
              const SizedBox(height: 30),

              // 1. LES CARTES (KPIs)
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 2.0,
                children: [
                  StatCard(title: "Total Étudiants", value: data['students'] ?? "0", subtext: "Inscrits actifs", color: kAccentBlue, icon: Icons.people),
                  StatCard(title: "Cours Catalogue", value: data['courses'] ?? "0", subtext: "Formations", color: kAccentGreen, icon: Icons.library_books),
                  StatCard(title: "Valeur Catalogue", value: data['revenue'] ?? "0", subtext: "Potentiel", color: kAccentPurple, icon: Icons.monetization_on),
                  const StatCard(title: "Taux de Réussite", value: "98%", subtext: "Moyenne", color: kAccentOrange, icon: Icons.school),
                ],
              ),

              const SizedBox(height: 30),

              // 2. LES GRAPHIQUES (Row sur Desktop, Column sur Mobile)
              LayoutBuilder(
                builder: (context, constraints) {
                  bool isWide = constraints.maxWidth > 900;
                  return Flex(
                    direction: isWide ? Axis.horizontal : Axis.vertical,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // GRAPHIQUE 1 : LIGNE (Inscriptions)
                      Expanded(
                        flex: isWide ? 2 : 0,
                        child: Container(
                          height: 350,
                          padding: const EdgeInsets.all(20),
                          margin: EdgeInsets.only(bottom: isWide ? 0 : 20),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.withOpacity(0.1)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Tendance des Inscriptions (6 mois)", style: TextStyle(color: theme.textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 20),
                              Expanded(
                                child: LineChart(
                                  LineChartData(
                                    gridData: const FlGridData(show: false),
                                    titlesData: const FlTitlesData(show: false), // Simplifié pour le design
                                    borderData: FlBorderData(show: false),
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: const [
                                          FlSpot(0, 1), FlSpot(1, 1.5), FlSpot(2, 1.4), FlSpot(3, 3.4), FlSpot(4, 2), FlSpot(5, 5),
                                        ],
                                        isCurved: true,
                                        color: kAccentBlue,
                                        barWidth: 4,
                                        belowBarData: BarAreaData(show: true, color: kAccentBlue.withOpacity(0.2)),
                                        dotData: const FlDotData(show: false),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      if(isWide) const SizedBox(width: 20),

                      // GRAPHIQUE 2 : CAMEMBERT (Répartition Réelle)
                      Expanded(
                        flex: isWide ? 1 : 0,
                        child: Container(
                          height: 350,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.withOpacity(0.1)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Répartition par Profil", style: TextStyle(color: theme.textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 20),
                              Expanded(
                                child: PieChart(
                                  PieChartData(
                                    sectionsSpace: 5,
                                    centerSpaceRadius: 40,
                                    sections: [
                                      // ADO
                                      PieChartSectionData(
                                        color: Colors.purple,
                                        value: ado.toDouble(),
                                        title: '$ado',
                                        radius: 50,
                                        titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                      // ENFANT
                                      PieChartSectionData(
                                        color: Colors.blue,
                                        value: enf.toDouble(),
                                        title: '$enf',
                                        radius: 50,
                                        titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                      // ADULTE
                                      PieChartSectionData(
                                        color: Colors.orange,
                                        value: adu.toDouble(),
                                        title: '$adu',
                                        radius: 50,
                                        titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Légende
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _LegendItem(color: Colors.purple, text: "Ado"),
                                  _LegendItem(color: Colors.blue, text: "Enfant"),
                                  _LegendItem(color: Colors.orange, text: "Adulte"),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String text;
  const _LegendItem({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}