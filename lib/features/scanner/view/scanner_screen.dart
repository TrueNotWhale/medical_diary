import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/scanner_cubit.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/analysis_model.dart';
import '../../../shared/widgets/liquid_glass_card.dart';
import '../../../shared/widgets/glowing_orbs_background.dart';
import '../../../core/navigation/app_router.dart';

class ScannerScreen extends StatelessWidget {
  const ScannerScreen({super.key});

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
                      'Сканер бланков',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: BlocConsumer<ScannerCubit, ScannerState>(
                  listener: (context, state) {
                    if (state is ScannerSaved) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Анализ сохранён'), backgroundColor: AppTheme.emerald),
                      );
                      Navigator.pushReplacementNamed(context, AppRouter.home);
                    }
                  },
                  builder: (context, state) {
                    if (state is ScannerIdle) return _IdleView();
                    if (state is ScannerProcessing) return _ProcessingView();
                    if (state is ScannerResult) return _ResultView(markers: state.markers);
                    if (state is ScannerError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, color: AppTheme.ruby, size: 48),
                            const SizedBox(height: 12),
                            Text(state.message, style: const TextStyle(color: AppTheme.ruby)),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => context.read<ScannerCubit>().reset(),
                              child: const Text('Повторить'),
                            ),
                          ],
                        ),
                      );
                    }
                    return _IdleView();
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

class _IdleView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 24),
          // Camera preview placeholder
          LiquidGlassCard(
            borderRadius: 24,
            padding: const EdgeInsets.all(0),
            child: Container(
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Colors.white.withOpacity(0.03),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt_rounded, color: Colors.white24, size: 56),
                  const SizedBox(height: 12),
                  const Text('Камера недоступна в эмуляторе', style: TextStyle(color: Colors.white38, fontSize: 13)),
                  const SizedBox(height: 4),
                  const Text('Используйте тестовый бланк ниже', style: TextStyle(color: Colors.white24, fontSize: 11)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Mock button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.aquamarine,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.science_rounded),
              label: const Text(
                'Загрузить тестовый бланк ОАК',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              onPressed: () => context.read<ScannerCubit>().scanMock(),
            ),
          ),
          const SizedBox(height: 16),
          LiquidGlassCard(
            borderRadius: 16,
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppTheme.indigo, size: 18),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Поддерживаются бланки HELIX и Инвитро. Направьте камеру на бланк или загрузите тестовый образец.',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProcessingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              color: AppTheme.aquamarine,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          const Text('Распознавание текста...', style: TextStyle(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 8),
          const Text('OCR + сверка с базой норм', style: TextStyle(color: Colors.white38, fontSize: 12)),
        ],
      ),
    );
  }
}

class _ResultView extends StatefulWidget {
  final List<MarkerModel> markers;
  const _ResultView({required this.markers});

  @override
  State<_ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends State<_ResultView> {
  final _labController = TextEditingController(text: 'HELIX');

  @override
  Widget build(BuildContext context) {
    final abnormalCount = widget.markers.where((m) => m.isOutOfNorm).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // Summary badge
          LiquidGlassCard(
            borderRadius: 20,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Результат распознавания', style: TextStyle(color: Colors.white54, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text('${widget.markers.length} показателей', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                if (abnormalCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.ruby.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.ruby.withOpacity(0.5)),
                    ),
                    child: Text('⚠ $abnormalCount откл.', style: const TextStyle(color: AppTheme.ruby, fontWeight: FontWeight.bold)),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.emerald.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.emerald.withOpacity(0.5)),
                    ),
                    child: const Text('✓ Всё в норме', style: TextStyle(color: AppTheme.emerald, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Markers list
          ...widget.markers.map((m) => _MarkerCard(marker: m)),
          const SizedBox(height: 16),
          // Lab name input
          TextField(
            controller: _labController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Название лаборатории',
              labelStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: Colors.white.withOpacity(0.06),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.emerald,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.save_rounded),
              label: const Text('Сохранить анализ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              onPressed: () => context.read<ScannerCubit>().saveResult(
                labName: _labController.text.trim().isNotEmpty ? _labController.text.trim() : 'HELIX',
                markers: widget.markers,
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => context.read<ScannerCubit>().reset(),
            child: const Text('Сканировать заново', style: TextStyle(color: Colors.white38)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _labController.dispose();
    super.dispose();
  }
}

class _MarkerCard extends StatelessWidget {
  final MarkerModel marker;
  const _MarkerCard({required this.marker});

  @override
  Widget build(BuildContext context) {
    final isAbove = marker.isAboveNorm;
    final isBelow = marker.isBelowNorm;
    final isNormal = !marker.isOutOfNorm;

    Color cardColor;
    Color badgeColor;
    String badgeLabel;
    IconData badgeIcon;

    if (isNormal) {
      cardColor = AppTheme.emerald;
      badgeColor = AppTheme.emerald;
      badgeLabel = 'В норме';
      badgeIcon = Icons.check_circle_rounded;
    } else if (isAbove) {
      cardColor = AppTheme.ruby;
      badgeColor = AppTheme.ruby;
      badgeLabel = '↑ Выше';
      badgeIcon = Icons.arrow_upward_rounded;
    } else {
      cardColor = AppTheme.amber;
      badgeColor = AppTheme.amber;
      badgeLabel = '↓ Ниже';
      badgeIcon = Icons.arrow_downward_rounded;
    }

    final card = Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cardColor.withOpacity(isNormal ? 0.2 : 0.45), width: 1.2),
          boxShadow: isNormal ? [] : [
            BoxShadow(color: cardColor.withOpacity(0.2), blurRadius: 8, spreadRadius: 1),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(marker.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(
                    'Норма: ${marker.normMin ?? '?'} – ${marker.normMax ?? '?'} ${marker.unit}',
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${marker.value} ${marker.unit}',
                  style: TextStyle(color: cardColor, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(badgeIcon, size: 10, color: badgeColor),
                      const SizedBox(width: 3),
                      Text(badgeLabel, style: TextStyle(color: badgeColor, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    return card;
  }
}
