import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/database/sqflite_service.dart';
import 'core/database/realm_service.dart';
import 'features/home/cubit/home_cubit.dart';
import 'features/symptoms/cubit/symptom_cubit.dart';
import 'features/scanner/cubit/scanner_cubit.dart';
import 'features/analysis/cubit/analysis_cubit.dart';
import 'features/activity/cubit/activity_cubit.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ru', null);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Initialize databases
  final sqfliteService = SqfliteService();
  await sqfliteService.init();

  final realmService = RealmService();
  await realmService.init();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => HomeCubit(sqfliteService)),
        BlocProvider(create: (_) => SymptomCubit(sqfliteService)),
        BlocProvider(create: (_) => ScannerCubit(sqfliteService, realmService)),
        BlocProvider(create: (_) => AnalysisCubit(sqfliteService, realmService)),
        BlocProvider(create: (_) => ActivityCubit(sqfliteService)),
      ],
      child: const MedDiaryApp(),
    ),
  );
}
