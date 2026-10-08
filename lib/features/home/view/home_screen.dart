import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../cubit/home_cubit.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/activity_model.dart';
import '../../../core/models/symptom_model.dart';
import '../../../core/models/analysis_model.dart';
import '../../../shared/widgets/liquid_glass_card.dart';
import '../../../shared/widgets/glowing_orbs_background.dart';
import '../../../core/navigation/app_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: GlowingOrbsBackground(
        child: SafeArea(
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              if (state is HomeLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppTheme.aquamarine),
                );
              }
              if (state is HomeError) {
                return Center(
                  child: Text(state.message,
                      style: const TextStyle(color: Colors.red)),
                );
              }
              final loaded = state as HomeLoaded;
              return RefreshIndicator(
                onRefresh: () =>
                    context.read<HomeCubit>().loadData(),
                color: AppTheme.aquamarine,
                backgroundColor: AppTheme.bgDeep,
                child: CustomScrollView(
                  slivers: [
                    _buildAppBar(context),
                    SliverPadding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          const SizedBox(height: 8),
                          _HealthScoreCard(
                              activityData: loaded.activityData),
                          const SizedBox(height: 16),
                          _ActivityChartCard(
                              data: loaded.activityData),
                          const SizedBox(height: 16),
                          _RecentSymptomsCard(
                              symptoms: loaded.recentSymptoms),
                          const SizedBox(height: 16),
                          _AnalysesCard(
                              analyses: loaded.analyses),
                          const SizedBox(height: 24),
                        ]),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: const _BottomNav(selected: AppRouter.home),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 80,
      floating: true,
      snap: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding:
            const EdgeInsets.only(left: 20, bottom: 12),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('EEEE, d MMMM', 'ru')
                  .format(DateTime.now()),
              style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 11),
            ),
            const Text(
              'МедДневник',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        background: Container(color: Colors.transparent),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.qr_code_scanner_rounded,
              color: AppTheme.aquamarine),
          onPressed: () =>
              Navigator.pushNamed(context, AppRouter.scanner),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

// ── Health Score Card ─────────────────────────────────────────────────────────

class _HealthScoreCard extends StatelessWidget {
  final List<ActivityModel> activityData;

  const _HealthScoreCard({required this.activityData});

  @override
  Widget build(BuildContext context) {
    final latest =
        activityData.isNotEmpty ? activityData.first : null;
    final steps = latest?.steps ?? 0;
    final pulse = latest?.pulse ?? 72;
    final score =
        (steps / 10000 * 70 + (pulse < 90 ? 30 : 15))
            .clamp(0, 100)
            .round();

    return LiquidGlassCard(
      borderRadius: 24,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Индекс здоровья',
                    style: TextStyle(
                        color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 4),
                Text('$score',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold)),
                const Text('/100',
                    style: TextStyle(
                        color: Colors.white54, fontSize: 14)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _StatBadge(
                  icon: Icons.directions_walk,
                  value: '$steps',
                  label: 'шагов',
                  color: AppTheme.aquamarine),
              const SizedBox(height: 12),
              _StatBadge(
                  icon: Icons.favorite,
                  value: '$pulse',
                  label: 'уд/мин',
                  color: AppTheme.coral),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatBadge(
      {required this.icon,
      required this.value,
      required this.label,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(value,
            style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 15)),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                color: Colors.white54, fontSize: 12)),
      ],
    );
  }
}

// ── Activity Chart Card ───────────────────────────────────────────────────────

class _ActivityChartCard extends StatelessWidget {
  final List<ActivityModel> data;

  const _ActivityChartCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return LiquidGlassCard(
      borderRadius: 20,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Активность за неделю',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15)),
          const SizedBox(height: 4),
          const Text('шаги · пульс',
              style:
                  TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 16),
          SizedBox(
            height: 130,
            child: data.isEmpty
                ? const Center(
                    child: Text('Нет данных',
                        style:
                            TextStyle(color: Colors.white38)))
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: Colors.white.withOpacity(0.06),
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: const FlTitlesData(
                        leftTitles: AxisTitles(
                            sideTitles:
                                SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(
                            sideTitles:
                                SideTitles(showTitles: false)),
                        topTitles: AxisTitles(
                            sideTitles:
                                SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: _dayLabel,
                            reservedSize: 22,
                          ),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _stepsSpots(data),
                          isCurved: true,
                          color: AppTheme.aquamarine,
                          barWidth: 2.5,
                          dotData:
                              const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppTheme.aquamarine
                                .withOpacity(0.12),
                          ),
                        ),
                        LineChartBarData(
                          spots: _pulseSpots(data),
                          isCurved: true,
                          color: AppTheme.coral,
                          barWidth: 2,
                          dashArray: [4, 4],
                          dotData:
                              const FlDotData(show: false),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  static List<FlSpot> _stepsSpots(List<ActivityModel> data) {
    final reversed = data.reversed.toList();
    return reversed
        .asMap()
        .entries
        .map((e) =>
            FlSpot(e.key.toDouble(), e.value.steps.toDouble()))
        .toList();
  }

  static List<FlSpot> _pulseSpots(List<ActivityModel> data) {
    final reversed = data.reversed.toList();
    // Scale pulse to same visual range as steps
    return reversed
        .asMap()
        .entries
        .map((e) => FlSpot(
            e.key.toDouble(), e.value.pulse * 80.0))
        .toList();
  }

  static Widget _dayLabel(double value, TitleMeta meta) {
    const days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    final idx = value.toInt();
    if (idx < 0 || idx >= days.length) {
      return const SizedBox.shrink();
    }
    return Text(days[idx],
        style: const TextStyle(
            color: Colors.white38, fontSize: 10));
  }
}

// ── Recent Symptoms Card ──────────────────────────────────────────────────────

class _RecentSymptomsCard extends StatelessWidget {
  final List<SymptomModel> symptoms;

  const _RecentSymptomsCard({required this.symptoms});

  @override
  Widget build(BuildContext context) {
    return LiquidGlassCard(
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Симптомы',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15)),
              TextButton(
                onPressed: () => Navigator.pushNamed(
                    context, AppRouter.symptoms),
                child: const Text('+ Добавить',
                    style: TextStyle(
                        color: AppTheme.aquamarine,
                        fontSize: 12)),
              ),
            ],
          ),
          if (symptoms.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Симптомы не зафиксированы',
                  style: TextStyle(color: Colors.white38)),
            )
          else
            ...symptoms.map((s) => _SymptomRow(symptom: s)),
        ],
      ),
    );
  }
}

class _SymptomRow extends StatelessWidget {
  final SymptomModel symptom;

  const _SymptomRow({required this.symptom});

  @override
  Widget build(BuildContext context) {
    const colors = [
      Colors.green,
      Colors.yellow,
      Colors.orange,
      Colors.deepOrange,
      Colors.red,
    ];
    final color = colors[(symptom.severity - 1).clamp(0, 4)];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                  color: color, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Expanded(
              child: Text(symptom.name,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 13))),
          Text('x${symptom.severity}',
              style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ── Analyses Card ─────────────────────────────────────────────────────────────

class _AnalysesCard extends StatelessWidget {
  final List<AnalysisModel> analyses;

  const _AnalysesCard({required this.analyses});

  @override
  Widget build(BuildContext context) {
    return LiquidGlassCard(
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Анализы',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15)),
              TextButton(
                onPressed: () => Navigator.pushNamed(
                    context, AppRouter.scanner),
                child: const Text('Сканировать',
                    style: TextStyle(
                        color: AppTheme.aquamarine,
                        fontSize: 12)),
              ),
            ],
          ),
          if (analyses.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Нет загруженных анализов',
                  style: TextStyle(color: Colors.white38)),
            )
          else
            ...analyses.take(3).map((a) => _AnalysisRow(
                  analysis: a,
                  onTap: () => Navigator.pushNamed(
                      context, AppRouter.analysis,
                      arguments: a.id),
                )),
        ],
      ),
    );
  }
}

class _AnalysisRow extends StatelessWidget {
  final AnalysisModel analysis;
  final VoidCallback onTap;

  const _AnalysisRow(
      {required this.analysis, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final abnormal =
        analysis.markers.where((m) => m.isOutOfNorm).length;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            const Icon(Icons.science_rounded,
                color: AppTheme.indigo, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(analysis.labName,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 13)),
                  Text(
                    DateFormat('d MMM yyyy', 'ru')
                        .format(analysis.date),
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
            ),
            if (abnormal > 0)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.ruby.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppTheme.ruby.withOpacity(0.5)),
                ),
                child: Text('!$abnormal',
                    style: const TextStyle(
                        color: AppTheme.ruby,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
              ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right,
                color: Colors.white38, size: 18),
          ],
        ),
      ),
    );
  }
}

// ── Bottom Navigation ─────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final String selected;

  const _BottomNav({required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1226).withOpacity(0.9),
        border: Border(
            top: BorderSide(
                color: Colors.white.withOpacity(0.08))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
              icon: Icons.home_rounded,
              label: 'Главная',
              route: AppRouter.home,
              selected: selected == AppRouter.home),
          _NavItem(
              icon: Icons.monitor_heart_rounded,
              label: 'Активность',
              route: AppRouter.activity,
              selected: selected == AppRouter.activity),
          _NavItem(
              icon: Icons.qr_code_scanner_rounded,
              label: 'Сканер',
              route: AppRouter.scanner,
              selected: selected == AppRouter.scanner),
          _NavItem(
              icon: Icons.healing_rounded,
              label: 'Симптомы',
              route: AppRouter.symptoms,
              selected: selected == AppRouter.symptoms),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final bool selected;

  const _NavItem(
      {required this.icon,
      required this.label,
      required this.route,
      this.selected = false});

  @override
  Widget build(BuildContext context) {
    final color =
        selected ? AppTheme.aquamarine : Colors.white38;
    return GestureDetector(
      onTap: () {
        if (!selected) {
          Navigator.pushNamed(context, route);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            vertical: 10, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(color: color, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
