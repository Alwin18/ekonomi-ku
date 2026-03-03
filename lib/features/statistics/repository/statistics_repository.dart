import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_constants.dart';

/// Repository for statistics aggregation queries.
class StatisticsRepository {
  final SupabaseClient _client;

  StatisticsRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  /// Get expense totals grouped by category for a given month/year.
  Future<List<Map<String, dynamic>>> getExpensesByCategory({
    required int month,
    required int year,
  }) async {
    try {
      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 0);
      final startIso = startDate.toIso8601String().split('T').first;
      final endIso = endDate.toIso8601String().split('T').first;

      final response = await _client
          .from(AppConstants.expensesTable)
          .select('amount, category_id, categories(name, color)')
          .gte('transaction_date', startIso)
          .lte('transaction_date', endIso);

      // Group by category client-side
      final Map<String, Map<String, dynamic>> grouped = {};
      for (final item in response as List) {
        final row = item as Map<String, dynamic>;
        final catId = row['category_id'] as String? ?? 'uncategorized';
        String catName = 'Lainnya';
        String catColor = '#607D8B';

        if (row['categories'] != null && row['categories'] is Map) {
          final cat = row['categories'] as Map<String, dynamic>;
          catName = cat['name'] as String? ?? 'Lainnya';
          catColor = cat['color'] as String? ?? '#607D8B';
        }

        if (grouped.containsKey(catId)) {
          grouped[catId]!['total'] =
              (grouped[catId]!['total'] as double) +
              (row['amount'] as num).toDouble();
        } else {
          grouped[catId] = {
            'category_id': catId,
            'category_name': catName,
            'color': catColor,
            'total': (row['amount'] as num).toDouble(),
          };
        }
      }

      return grouped.values.toList();
    } catch (e) {
      throw Exception('Failed to fetch expense stats by category: $e');
    }
  }

  /// Get monthly income and expense totals for the last N months.
  Future<List<Map<String, dynamic>>> getMonthlyTrend({int months = 6}) async {
    try {
      final now = DateTime.now();
      final results = <Map<String, dynamic>>[];

      for (int i = months - 1; i >= 0; i--) {
        final date = DateTime(now.year, now.month - i, 1);
        final endDate = DateTime(date.year, date.month + 1, 0);
        final startIso = date.toIso8601String().split('T').first;
        final endIso = endDate.toIso8601String().split('T').first;

        // Fetch incomes for this month
        final incomes = await _client
            .from(AppConstants.incomesTable)
            .select('amount')
            .gte('transaction_date', startIso)
            .lte('transaction_date', endIso);

        double totalIncome = 0;
        for (final item in incomes as List) {
          totalIncome += ((item as Map<String, dynamic>)['amount'] as num)
              .toDouble();
        }

        // Fetch expenses for this month
        final expenses = await _client
            .from(AppConstants.expensesTable)
            .select('amount')
            .gte('transaction_date', startIso)
            .lte('transaction_date', endIso);

        double totalExpense = 0;
        for (final item in expenses as List) {
          totalExpense += ((item as Map<String, dynamic>)['amount'] as num)
              .toDouble();
        }

        results.add({
          'month': date.month,
          'year': date.year,
          'income': totalIncome,
          'expense': totalExpense,
        });
      }

      return results;
    } catch (e) {
      throw Exception('Failed to fetch monthly trend: $e');
    }
  }

  /// Get current and previous month totals for month-over-month comparison.
  Future<Map<String, dynamic>> getMonthComparison() async {
    try {
      final now = DateTime.now();

      // Current month
      final curStart = DateTime(now.year, now.month, 1);
      final curEnd = DateTime(now.year, now.month + 1, 0);
      final curStartIso = curStart.toIso8601String().split('T').first;
      final curEndIso = curEnd.toIso8601String().split('T').first;

      // Previous month
      final prevStart = DateTime(now.year, now.month - 1, 1);
      final prevEnd = DateTime(now.year, now.month, 0);
      final prevStartIso = prevStart.toIso8601String().split('T').first;
      final prevEndIso = prevEnd.toIso8601String().split('T').first;

      double curIncome = 0, curExpense = 0;
      double prevIncome = 0, prevExpense = 0;

      // Current month data
      final curIncomes = await _client
          .from(AppConstants.incomesTable)
          .select('amount')
          .gte('transaction_date', curStartIso)
          .lte('transaction_date', curEndIso);
      for (final item in curIncomes as List) {
        curIncome += ((item as Map<String, dynamic>)['amount'] as num)
            .toDouble();
      }

      final curExpenses = await _client
          .from(AppConstants.expensesTable)
          .select('amount')
          .gte('transaction_date', curStartIso)
          .lte('transaction_date', curEndIso);
      for (final item in curExpenses as List) {
        curExpense += ((item as Map<String, dynamic>)['amount'] as num)
            .toDouble();
      }

      // Previous month data
      final prevIncomes = await _client
          .from(AppConstants.incomesTable)
          .select('amount')
          .gte('transaction_date', prevStartIso)
          .lte('transaction_date', prevEndIso);
      for (final item in prevIncomes as List) {
        prevIncome += ((item as Map<String, dynamic>)['amount'] as num)
            .toDouble();
      }

      final prevExpenses = await _client
          .from(AppConstants.expensesTable)
          .select('amount')
          .gte('transaction_date', prevStartIso)
          .lte('transaction_date', prevEndIso);
      for (final item in prevExpenses as List) {
        prevExpense += ((item as Map<String, dynamic>)['amount'] as num)
            .toDouble();
      }

      return {
        'current_income': curIncome,
        'current_expense': curExpense,
        'previous_income': prevIncome,
        'previous_expense': prevExpense,
      };
    } catch (e) {
      throw Exception('Failed to fetch month comparison: $e');
    }
  }
}
