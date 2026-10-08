import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/main_cubit.dart';
import '../../home/view/home_screen.dart';
import '../../activity/view/activity_screen.dart';
import '../../scanner/view/scanner_screen.dart';
import '../../symptoms/view/symptom_screen.dart';
import '../../../core/theme/app_theme.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MainCubit(),
      child: BlocBuilder<MainCubit, int>(
        builder: (context, currentIndex) {
          return Scaffold(
            backgroundColor: AppTheme.bgDark,
            body: IndexedStack(
              index: currentIndex,
              children: const [
                HomeScreen(),
                ActivityScreen(),
                ScannerScreen(),
                SymptomScreen(),
              ],
            ),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0D1226).withOpacity(0.9),
                border: Border(
                  top: BorderSide(color: Colors.white.withOpacity(0.08)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    icon: Icons.home_rounded,
                    label: 'Главная',
                    index: 0,
                    currentIndex: currentIndex,
                  ),
                  _NavItem(
                    icon: Icons.monitor_heart_rounded,
                    label: 'Активность',
                    index: 1,
                    currentIndex: currentIndex,
                  ),
                  _NavItem(
                    icon: Icons.qr_code_scanner_rounded,
                    label: 'Сканер',
                    index: 2,
                    currentIndex: currentIndex,
                  ),
                  _NavItem(
                    icon: Icons.healing_rounded,
                    label: 'Симптомы',
                    index: 3,
                    currentIndex: currentIndex,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int currentIndex;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final selected = index == currentIndex;
    final color = selected ? AppTheme.aquamarine : Colors.white38;
    return GestureDetector(
      onTap: () {
        if (!selected) {
          context.read<MainCubit>().setTab(index);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: color, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
