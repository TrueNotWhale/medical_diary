import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../cubit/symptom_cubit.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/symptom_model.dart';
import '../../../shared/widgets/liquid_glass_card.dart';
import '../../../shared/widgets/glowing_orbs_background.dart';
import '../../../core/navigation/app_router.dart';

class SymptomScreen extends StatelessWidget {
  const SymptomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: GlowingOrbsBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: BlocBuilder<SymptomCubit, SymptomState>(
                  builder: (context, state) {
                    if (state is SymptomLoading) {
                      return const Center(
                          child: CircularProgressIndicator(
                              color: AppTheme.aquamarine));
                    }
                    if (state is SymptomError) {
                      return Center(
                          child: Text(state.message,
                              style: const TextStyle(
                                  color: Colors.red)));
                    }
                    final loaded = state as SymptomLoaded;
                    if (loaded.symptoms.isEmpty) {
                      return const Center(
                        child: Text(
                          'Симптомы не зафиксированы.\nНажмите + чтобы добавить.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white38,
                              fontSize: 14),
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: loaded.symptoms.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final s = loaded.symptoms[index];
                        return _SymptomCard(symptom: s);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context),
        backgroundColor: AppTheme.aquamarine,
        foregroundColor: AppTheme.bgDark,
        icon: const Icon(Icons.add),
        label: const Text('Добавить',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      bottomNavigationBar:
          const _SymptomBottomNav(selected: AppRouter.symptoms),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(20, 16, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white70, size: 20),
          ),
          const SizedBox(width: 12),
          const Text(
            'Симптомы',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bgDeep,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(24)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<SymptomCubit>(),
        child: const _AddSymptomSheet(),
      ),
    );
  }
}

// ── Symptom Card ──────────────────────────────────────────────────────────────

class _SymptomCard extends StatelessWidget {
  final SymptomModel symptom;

  const _SymptomCard({required this.symptom});

  @override
  Widget build(BuildContext context) {
    const severityColors = [
      Color(0xFF2ECC71),
      Color(0xFFF1C40F),
      Color(0xFFE67E22),
      Color(0xFFE74C3C),
      Color(0xFF8E44AD),
    ];
    final color =
        severityColors[(symptom.severity - 1).clamp(0, 4)];

    return LiquidGlassCard(
      borderRadius: 16,
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Severity indicator
          Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(symptom.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
                if (symptom.notes.isNotEmpty)
                  Text(symptom.notes,
                      style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(
                  DateFormat('d MMM, HH:mm', 'ru')
                      .format(symptom.timestamp),
                  style: const TextStyle(
                      color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ),
          // Severity badge
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                symptom.severity,
                (_) => Icon(Icons.circle,
                    size: 6, color: color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Add Symptom Sheet ─────────────────────────────────────────────────────────

class _AddSymptomSheet extends StatefulWidget {
  const _AddSymptomSheet();

  @override
  State<_AddSymptomSheet> createState() =>
      _AddSymptomSheetState();
}

class _AddSymptomSheetState extends State<_AddSymptomSheet> {
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  double _severity = 2;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding:
          EdgeInsets.fromLTRB(20, 20, 20, bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Text(
            'Новый симптом',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          // Name field
          TextField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Название симптома',
              labelStyle:
                  const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: Colors.white.withOpacity(0.07),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Severity slider
          Row(
            children: [
              const Text('Интенсивность:',
                  style: TextStyle(
                      color: Colors.white70, fontSize: 14)),
              const Spacer(),
              Text('${_severity.round()}',
                  style: const TextStyle(
                      color: AppTheme.aquamarine,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
            ],
          ),
          Slider(
            value: _severity,
            min: 1,
            max: 5,
            divisions: 4,
            activeColor: AppTheme.aquamarine,
            inactiveColor: Colors.white12,
            onChanged: (v) => setState(() => _severity = v),
          ),
          const SizedBox(height: 12),
          // Notes field
          TextField(
            controller: _notesController,
            style: const TextStyle(color: Colors.white),
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Заметки (необязательно)',
              labelStyle:
                  const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: Colors.white.withOpacity(0.07),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.aquamarine,
                foregroundColor: AppTheme.bgDark,
                padding:
                    const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.bgDark))
                  : const Text('Сохранить',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    setState(() => _submitting = true);
    await context.read<SymptomCubit>().addSymptom(
          name: name,
          severity: _severity.round(),
          notes: _notesController.text.trim(),
        );
    if (mounted) Navigator.pop(context);
  }
}

// ── Bottom Nav ────────────────────────────────────────────────────────────────

class _SymptomBottomNav extends StatelessWidget {
  final String selected;

  const _SymptomBottomNav({required this.selected});

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
          Navigator.pushNamedAndRemoveUntil(
              context, route, (_) => false);
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
                style:
                    TextStyle(color: color, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
