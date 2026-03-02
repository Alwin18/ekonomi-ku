import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'features/dashboard/bloc/dashboard_bloc.dart';
import 'features/dashboard/repository/dashboard_repository.dart';
import 'features/expense/bloc/expense_bloc.dart';
import 'features/expense/repository/expense_repository.dart';
import 'features/income/bloc/income_bloc.dart';
import 'features/income/repository/income_repository.dart';
import 'features/loan/bloc/loan_bloc.dart';
import 'features/loan/repository/loan_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const EkonomiKuApp());
}

class EkonomiKuApp extends StatelessWidget {
  const EkonomiKuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => DashboardBloc(repository: DashboardRepository()),
        ),
        BlocProvider(create: (_) => IncomeBloc(repository: IncomeRepository())),
        BlocProvider(
          create: (_) => ExpenseBloc(repository: ExpenseRepository()),
        ),
        BlocProvider(create: (_) => LoanBloc(repository: LoanRepository())),
      ],
      child: const AppShell(),
    );
  }
}
