import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../cubit/activity_cubit.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/activity_model.dart';
import '../../../shared/widgets/liquid_glass_card.dart';
import '../../../shared/widgets/glowing_orbs_background.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Background handled by MainScreen or GlowingOrbs
      body: GlowingOrbsBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Text(
                      'Активность',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: BlocBuilder<ActivityCubit, ActivityState>(
                  builder: (context, state) {
                    if (state is ActivityLoading) {
                      return const Center(child: CircularProgressIndicator(color: AppTheme.aquamarine));
                    }
                    if (state is ActivityError) {
                      return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
                    }
                    final loaded = state as ActivityLoaded;
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          _HealthScoreGauge(score: loaded.snapshot.healthScore),
                          const SizedBox(height: 16),
                          _PipelineInfoCard(snapshot: loaded.snapshot),
                          const SizedBox(height: 16),
                          _StepsBarChart(data: loaded.activityList),
                          const SizedBox(height: 16),
                          _PulseLineCard(data: loaded.activityList),
                          const SizedBox(height: 16),
                          const _AddActivityCard(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HealthScoreGauge extends StatelessWidget {
  final double score;
  const _HealthScoreGauge({required this.score});

  @override
  Widget build(BuildContext context) {
    final color = score >= 70 ? AppTheme.emerald : score >= 40 ? AppTheme.amber : AppTheme.ruby;
    return LiquidGlassCard(
      useBlur: true,
      borderRadius: 24,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text('Индекс здоровья (HealthPipeline)', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: RepaintBoundary(
              child: PieChart(
                PieChartData(
                  startDegreeOffset: 180,
                  sectionsSpace: 0,
                  centerSpaceRadius: 50,
                  sections: [
                    PieChartSectionData(
                      value: score,
                      color: color,
                      radius: 20,
                      showTitle: false,
                    ),
                    PieChartSectionData(
                      value: 100 - score,
                      color: Colors.white12,
                      radius: 20,
                      showTitle: false,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${score.round()}',
            style: TextStyle(color: color, fontSize: 42, fontWeight: FontWeight.bold),
          ),
          const Text('/100', style: TextStyle(color: Colors.white38, fontSize: 14)),
        ],
      ),
    );
  }
}

class _PipelineInfoCard extends StatelessWidget {
  final snapshot;
  const _PipelineInfoCard({required this.snapshot});

  @override
  Widget build(BuildContext context) {
    return LiquidGlassCard(
      borderRadius: 16,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.stream, color: AppTheme.indigo, size: 16),
              const SizedBox(width: 6),
              const Text('Реактивный конвейер данных', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 10),
          _PipelineRow('Маркеры анализов', '${snapshot.markers.length} шт.', AppTheme.aquamarine),
          _PipelineRow('Аномальных маркеров', '${snapshot.abnormalCount} шт.', snapshot.abnormalCount > 0 ? AppTheme.ruby : AppTheme.emerald),
          _PipelineRow('Шаги (сегодня)', '${snapshot.latestActivity?.steps ?? 0}', AppTheme.aquamarine),
          _PipelineRow('Пульс', '${snapshot.latestActivity?.pulse ?? 0} уд/мин', AppTheme.coral),
        ],
      ),
    );
  }
}

class _PipelineRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _PipelineRow(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          Text(value, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _StepsBarChart extends StatelessWidget {
  final List<ActivityModel> data;
  const _StepsBarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final reversed = data.reversed.toList();
    return LiquidGlassCard(
      borderRadius: 20,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Шаги за 14 дней', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: reversed.isEmpty
                ? const Center(child: Text('Нет данных', style: TextStyle(color: Colors.white38)))
                : RepaintBoundary(
                    child: BarChart(
                      BarChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (_) => FlLine(color: Colors.white.withOpacity(0.05), strokeWidth: 1),
                        ),
                        borderData: FlBorderData(show: false),
                        titlesData: const FlTitlesData(
                          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        barGroups: reversed.asMap().entries.map((e) {
                          final isGoal = e.value.steps >= 8000;
                          return BarChartGroupData(
                            x: e.key,
                            barRods: [
                              BarChartRodData(
                                toY: e.value.steps.toDouble(),
                                color: isGoal ? AppTheme.aquamarine : AppTheme.indigo.withOpacity(0.6),
                                width: 14,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                              ),
                            ],
                          );
                        }).toList(),
                        maxY: 12000,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(width: 12, height: 12, decoration: BoxDecoration(color: AppTheme.aquamarine, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 4),
              const Text('≥ 8000 шагов', style: TextStyle(color: Colors.white38, fontSize: 10)),
              const SizedBox(width: 16),
              Container(width: 12, height: 12, decoration: BoxDecoration(color: AppTheme.indigo.withOpacity(0.6), borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 4),
              const Text('< 8000 шагов', style: TextStyle(color: Colors.white38, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}

class _PulseLineCard extends StatelessWidget {
  final List<ActivityModel> data;
  const _PulseLineCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final reversed = data.reversed.toList();
    return LiquidGlassCard(
      borderRadius: 20,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Пульс', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: reversed.isEmpty
                ? const Center(child: Text('Нет данных', style: TextStyle(color: Colors.white38)))
                : RepaintBoundary(
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        titlesData: const FlTitlesData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: reversed.asMap().entries
                                .map((e) => FlSpot(e.key.toDouble(), e.value.pulse.toDouble()))
                                .toList(),
                            isCurved: true,
                            color: AppTheme.coral,
                            barWidth: 2.5,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                                radius: 3,
                                color: AppTheme.coral,
                                strokeWidth: 0,
                              ),
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppTheme.coral.withOpacity(0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _AddActivityCard extends StatefulWidget {
  const _AddActivityCard({super.key});

  @override
  State<_AddActivityCard> createState() => _AddActivityCardState();
}

class _AddActivityCardState extends State<_AddActivityCard> {
  final _stepsCtrl = TextEditingController();
  final _pulseCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return LiquidGlassCard(
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Добавить запись активности', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _stepsCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Шаги',
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.06),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _pulseCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Пульс',
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.06),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final steps = int.tryParse(_stepsCtrl.text) ?? 0;
                final pulse = int.tryParse(_pulseCtrl.text) ?? 72;
                await context.read<ActivityCubit>().addActivity(steps: steps, pulse: pulse);
                _stepsCtrl.clear();
                _pulseCtrl.clear();
              },
              child: const Text('Записать', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _stepsCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }
}
