import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../models/expense_model.dart';

class ExpenseRepository {
  final SupabaseClient _client;

  ExpenseRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  Future<List<ExpenseModel>> getAll({DateTime? month}) async {
    try {
      var query = _client.from(AppConstants.expensesTable).select();

      if (month != null) {
        final start = DateTime(month.year, month.month, 1);
        final end = DateTime(month.year, month.month + 1, 0);
        query = query
            .gte('transaction_date', start.toIso8601String().split('T').first)
            .lte('transaction_date', end.toIso8601String().split('T').first);
      }

      final response = await query.order('transaction_date', ascending: false);
      return (response as List)
          .map((json) => ExpenseModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch expenses: $e');
    }
  }

  Future<ExpenseModel> create(ExpenseModel expense) async {
    try {
      final response = await _client
          .from(AppConstants.expensesTable)
          .insert(expense.toJson())
          .select()
          .single();
      return ExpenseModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create expense: $e');
    }
  }

  Future<ExpenseModel> update(ExpenseModel expense) async {
    try {
      final response = await _client
          .from(AppConstants.expensesTable)
          .update(expense.toJson())
          .eq('id', expense.id!)
          .select()
          .single();
      return ExpenseModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update expense: $e');
    }
  }

  Future<void> delete(String id) async {
    try {
      await _client.from(AppConstants.expensesTable).delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete expense: $e');
    }
  }

  Stream<List<ExpenseModel>> stream() {
    return _client
        .from(AppConstants.expensesTable)
        .stream(primaryKey: ['id'])
        .order('transaction_date', ascending: false)
        .map(
          (list) => list.map((json) => ExpenseModel.fromJson(json)).toList(),
        );
  }
}
