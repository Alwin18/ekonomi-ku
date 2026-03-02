import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../models/dashboard_model.dart';

class DashboardRepository {
  final SupabaseClient _client;

  DashboardRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  Future<DashboardSummary> getSummary() async {
    try {
      // Fetch all data in parallel
      final results = await Future.wait([
        _client
            .from(AppConstants.incomesTable)
            .select('amount, transaction_date'),
        _client
            .from(AppConstants.expensesTable)
            .select('amount, transaction_date'),
        _client.from(AppConstants.loansTable).select('amount, status'),
      ]);

      final incomes = results[0] as List;
      final expenses = results[1] as List;
      final loans = results[2] as List;

      // Calculate totals
      final totalIncome = incomes.fold<double>(
        0,
        (sum, e) => sum + (e['amount'] as num).toDouble(),
      );
      final totalExpense = expenses.fold<double>(
        0,
        (sum, e) => sum + (e['amount'] as num).toDouble(),
      );

      final activeLoans = loans.where((l) => l['status'] == 'active').toList();
      final totalActiveLoan = activeLoans.fold<double>(
        0,
        (sum, l) => sum + (l['amount'] as num).toDouble(),
      );

      // Build monthly data for last 6 months
      final now = DateTime.now();
      final monthlyData = <MonthlyData>[];

      for (int i = 5; i >= 0; i--) {
        final month = DateTime(now.year, now.month - i, 1);
        final nextMonth = DateTime(month.year, month.month + 1, 1);

        final monthIncome = incomes
            .where((e) {
              final date = DateTime.parse(e['transaction_date'] as String);
              return !date.isBefore(month) && date.isBefore(nextMonth);
            })
            .fold<double>(0, (sum, e) => sum + (e['amount'] as num).toDouble());

        final monthExpense = expenses
            .where((e) {
              final date = DateTime.parse(e['transaction_date'] as String);
              return !date.isBefore(month) && date.isBefore(nextMonth);
            })
            .fold<double>(0, (sum, e) => sum + (e['amount'] as num).toDouble());

        monthlyData.add(
          MonthlyData(
            month: month,
            totalIncome: monthIncome,
            totalExpense: monthExpense,
          ),
        );
      }

      return DashboardSummary(
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        balance: totalIncome - totalExpense,
        totalActiveLoan: totalActiveLoan,
        activeLoanCount: activeLoans.length,
        monthlyData: monthlyData,
      );
    } catch (e) {
      throw Exception('Failed to fetch dashboard data: $e');
    }
  }
}
