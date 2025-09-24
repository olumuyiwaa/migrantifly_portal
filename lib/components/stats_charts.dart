import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import '../models/dashboard_stats.dart';

class StatsCharts extends StatelessWidget {
  final DashboardStats? stats;

  const StatsCharts({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    if (stats == null){
      return Container(
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: secondaryColor,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),height:200,child: Center(child: CircularProgressIndicator(),),);
    }
    else {
      return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;
        return Row(
          spacing: 12,
          children: [
            Expanded(child: _ChartCard(
              title: 'Applications by Visa Type',
              // width: isWide ? constraints.maxWidth / 2 - 6 : constraints.maxWidth,
              height: 320,
              child: VisaTypePieChart(data: stats!.applicationsByVisaType),
            )),
        Expanded(child:  _ChartCard(
              title: 'Applications by Stage',
              //  width: isWide ? constraints.maxWidth / 2 - 6 : constraints.maxWidth,
              height: 320,
              child: StagePieChart(data: stats!.applicationsByStage),
            )),
          ],
        );
      },
    );
  }}
}

class _ChartCard extends StatelessWidget {
  final String title;
  final double height;
  final Widget child;

  const _ChartCard({
    required this.title,
    required this.height,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: 8),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class VisaTypePieChart extends StatelessWidget {
  final Map<String, int> data;
  const VisaTypePieChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final entries = data.entries.where((e) => e.value > 0).toList();
    final total = entries.fold<int>(0, (sum, e) => sum + e.value);

    if (total == 0) {
      return const Center(child: Text('No data'));
    }

    final colors = _palette;
    final sections = <PieChartSectionData>[
      for (int i = 0; i < entries.length; i++)
        PieChartSectionData(
          color: colors[i % colors.length],
          value: entries[i].value.toDouble(),
          radius: 100,
          title: '${_pretty(entries[i].key)}\n${entries[i].value}',
          titleStyle: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          titlePositionPercentageOffset: 0.6,
        ),
    ];

    return Column(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 0,
              sectionsSpace: 2,
              startDegreeOffset: -90,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (int i = 0; i < entries.length; i++)
              _Legend(
                color: colors[i % colors.length],
                label:
                '${_pretty(entries[i].key)} (${((entries[i].value / total) * 100).toStringAsFixed(0)}%)',
              ),
          ],
        ),
      ],
    );
  }
}

class StagePieChart extends StatelessWidget {
  final Map<String, int> data;

  StagePieChart({super.key, required this.data});

  // Define a set of distinct colors
  final List<Color> _chartColors = const [
    Colors.blue,
    Colors.orange,
    Colors.green,
    Colors.purple,
    Colors.red,
    Colors.teal,
    Colors.brown,
    Colors.pink,
  ];

  @override
  Widget build(BuildContext context) {
    final total = data.values.fold(0.0, (a, b) => a + b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 72,
              sections: data.entries.map((entry) {
                final index = data.keys.toList().indexOf(entry.key);
                final color = _chartColors[index % _chartColors.length];
                final percentage = total == 0 ? 0 : (entry.value / total * 100);

                return PieChartSectionData(
                  color: color,
                  value: entry.value.toDouble(),
                  title: '${percentage.toStringAsFixed(1)}%',
                  radius: 32,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Legend
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 16,
          runSpacing: 8,
          children: data.entries.map((entry) {
            final index = data.keys.toList().indexOf(entry.key);
            final color = _chartColors[index % _chartColors.length];
            final percentage = total == 0 ? 0 : (entry.value / total * 100);

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${entry.key.replaceAll("_", " ")} (${percentage.toStringAsFixed(1)}%)',
                  style: const TextStyle(fontSize: 10),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}

String _pretty(String raw) {
  // Convert snake_case or kebab-case to Title Case
  final replaced = raw.replaceAll('_', ' ').replaceAll('-', ' ');
  return replaced.split(' ').map((w) {
    if (w.isEmpty) return w;
    return '${w[0].toUpperCase()}${w.substring(1)}';
  }).join(' ');
}

const List<Color> _palette = [
  Color(0xFF7E57C2), // Deep Purple 400
  Color(0xFF42A5F5), // Blue 400
  Color(0xFF66BB6A), // Green 400
  Color(0xFFFFA726), // Orange 400
  Color(0xFFEC407A), // Pink 400
  Color(0xFF26C6DA), // Cyan 400
  Color(0xFFAB47BC), // Purple 400
];