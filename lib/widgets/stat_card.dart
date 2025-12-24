import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class StatCard extends StatelessWidget {
  final String title, value, subtext;
  final Color color;
  final IconData icon;

  const StatCard({super.key, required this.title, required this.value, required this.subtext, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(color: theme.subTextColor, fontSize: 13)),
              Icon(icon, color: color, size: 20),
            ],
          ),
          Text(value, style: TextStyle(color: theme.textColor, fontSize: 26, fontWeight: FontWeight.bold)),
          Text(subtext, style: TextStyle(color: Colors.green[400], fontSize: 11)),
        ],
      ),
    );
  }
}