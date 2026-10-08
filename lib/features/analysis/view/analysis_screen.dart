import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../cubit/analysis_cubit.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/analysis_model.dart';
import '../../../shared/widgets/liquid_glass_card.dart';
import '../../../shared/widgets/glowing_orbs_background.dart';

class AnalysisScreen extends StatefulWidget {
  final int? analysisId;
  const AnalysisScreen({super.key, this.analysisId});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.analysisId != null) {
      context.read<AnalysisCubit>().loadAnalysis(widget.analysisId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: GlowingOrbsBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white70),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Карточка анализа',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: BlocBuilder<AnalysisCubit, AnalysisState>(
                  builder: (context, state) {
                    if (state is AnalysisLoading) {
                      return const Center(child: CircularProgressIndicator(color: AppTheme.aquamarine));
                    }
                    if (state is AnalysisError) {
                      return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
                    }
                    if (state is AnalysisLoaded) {
                      return _AnalysisBody(analysis: state.analysis);
                    }
                    return const SizedBox.shrink();
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

class _AnalysisBody extends StatelessWidget {
  final AnalysisModel analysis;
  const _AnalysisBody({required this.analysis});

  @override
  Widget build(BuildContext context) {
    final abnormal = analysis.markers.where((m) => m.isOutOfNorm).toList();
    final normal = analysis.markers.where((m) => !m.isOutOfNorm).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // Header card
          LiquidGlassCard(
            borderRadius: 20,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.science_rounded, color: AppTheme.indigo, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(analysis.labName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(
                        DateFormat('d MMMM yyyy', 'ru').format(analysis.date),
                        style: const TextStyle(color: Colors.white54, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${analysis.markers.length}', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    const Text('показателей', style: TextStyle(color: Colors.white38, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          if (abnormal.isNotEmpty) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.warning_rounded, color: AppTheme.ruby, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Отклонения (${abnormal.length})',
                  style: const TextStyle(color: AppTheme.ruby, fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...abnormal.map((m) => _MarkerDetailCard(marker: m)),
          ],
          if (normal.isNotEmpty) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: AppTheme.emerald, size: 16),
                const SizedBox(width: 6),
                Text(
                  'В норме (${normal.length})',
                  style: const TextStyle(color: AppTheme.emerald, fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...normal.map((m) => _MarkerDetailCard(marker: m)),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _MarkerDetailCard extends StatelessWidget {
  final MarkerModel marker;
  const _MarkerDetailCard({required this.marker});

  @override
  Widget build(BuildContext context) {
    final isAbove = marker.isAboveNorm;
    final isBelow = marker.isBelowNorm;
    final isNormal = !marker.isOutOfNorm;

    Color accent;
    String deviationLabel;
    if (isNormal) {
      accent = AppTheme.emerald;
      deviationLabel = 'В норме';
    } else if (isAbove) {
      accent = AppTheme.ruby;
      final pct = marker.normMax != null ? ((marker.value - marker.normMax!) / marker.normMax! * 100).toStringAsFixed(0) : '?';
      deviationLabel = '↑ $pct% выше нормы';
    } else {
      accent = AppTheme.amber;
      final pct = marker.normMin != null ? ((marker.normMin! - marker.value) / marker.normMin! * 100).toStringAsFixed(0) : '?';
      deviationLabel = '↓ $pct% ниже нормы';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: accent.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: accent.withOpacity(isNormal ? 0.18 : 0.4), width: 1.2),
          boxShadow: isNormal ? [] : [
            BoxShadow(color: accent.withOpacity(0.15), blurRadius: 10, spreadRadius: 0),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(marker.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                ),
                Text(
                  '${marker.value} ${marker.unit}',
                  style: TextStyle(color: accent, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Progress bar showing value vs norm range
            _NormBar(marker: marker, accent: accent),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Норма: ${marker.normMin ?? '–'} – ${marker.normMax ?? '–'} ${marker.unit}',
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(deviationLabel, style: TextStyle(color: accent, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NormBar extends StatelessWidget {
  final MarkerModel marker;
  final Color accent;
  const _NormBar({required this.marker, required this.accent});

  @override
  Widget build(BuildContext context) {
    if (marker.normMin == null || marker.normMax == null) return const SizedBox.shrink();

    final min = marker.normMin!;
    final max = marker.normMax!;
    final val = marker.value;

    final rangeMin = (min * 0.7);
    final rangeMax = (max * 1.3);
    final totalRange = rangeMax - rangeMin;

    final valuePos = ((val - rangeMin) / totalRange).clamp(0.0, 1.0);
    final normStart = (min - rangeMin) / totalRange;
    final normEnd = (max - rangeMin) / totalRange;

    return LayoutBuilder(builder: (_, constraints) {
      final width = constraints.maxWidth;
      return SizedBox(
        height: 20,
        child: Stack(
          children: [
            // Background bar
            Positioned(
              top: 7,
              left: 0,
              right: 0,
              child: Container(height: 6, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(3))),
            ),
            // Norm range (green zone)
            Positioned(
              top: 7,
              left: normStart * width,
              width: (normEnd - normStart) * width,
              child: Container(height: 6, decoration: BoxDecoration(color: AppTheme.emerald.withOpacity(0.35), borderRadius: BorderRadius.circular(3))),
            ),
            // Value indicator
            Positioned(
              top: 2,
              left: (valuePos * width - 8).clamp(0, width - 16),
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: accent.withOpacity(0.5), blurRadius: 6)],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
