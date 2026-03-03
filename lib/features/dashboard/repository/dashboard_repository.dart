import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/list_filter.dart';
import '../models/dashboard_model.dart';

class DashboardRepository {
  final SupabaseClient _client;

  DashboardRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  Future<DashboardSummary> getSummary({ListFilter? filter}) async {
    try {
      // Fetch ALL data (unfiltered) – cards always show all-time totals.
      // The filter is only applied to chart monthly data.
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

      // Build monthly chart data based on filter type
      final monthlyData = _buildMonthlyData(incomes, expenses, filter);

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

  List<MonthlyData> _buildMonthlyData(
    List incomes,
    List expenses,
    ListFilter? filter,
  ) {
    final months = <DateTime>[];

    if (filter == null) {
      // Default: last 6 months
      final now = DateTime.now();
      for (int i = 5; i >= 0; i--) {
        months.add(DateTime(now.year, now.month - i, 1));
      }
    } else {
      switch (filter.filterType) {
        case ListFilterType.yearly:
          for (int m = 1; m <= 12; m++) {
            months.add(DateTime(filter.year!, m, 1));
          }
          break;
        case ListFilterType.monthly:
          months.add(DateTime(filter.year!, filter.month!, 1));
          break;
        case ListFilterType.dateRange:
          var cursor = DateTime(
            filter.startDate!.year,
            filter.startDate!.month,
            1,
          );
          final endMonth = DateTime(
            filter.endDate!.year,
            filter.endDate!.month,
            1,
          );
          while (!cursor.isAfter(endMonth)) {
            months.add(cursor);
            cursor = DateTime(cursor.year, cursor.month + 1, 1);
          }
          break;
      }
    }

    return months.map((month) {
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

      return MonthlyData(
        month: month,
        totalIncome: monthIncome,
        totalExpense: monthExpense,
      );
    }).toList();
  }
}
