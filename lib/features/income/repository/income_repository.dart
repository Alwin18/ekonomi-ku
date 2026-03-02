import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../models/income_model.dart';

class IncomeRepository {
  final SupabaseClient _client;

  IncomeRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  /// Fetch all incomes, optionally filtered by month
  Future<List<IncomeModel>> getAll({DateTime? month}) async {
    try {
      var query = _client.from(AppConstants.incomesTable).select();

      if (month != null) {
        final start = DateTime(month.year, month.month, 1);
        final end = DateTime(month.year, month.month + 1, 0);
        query = query
            .gte('transaction_date', start.toIso8601String().split('T').first)
            .lte('transaction_date', end.toIso8601String().split('T').first);
      }

      final response = await query.order('transaction_date', ascending: false);
      return (response as List)
          .map((json) => IncomeModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch incomes: $e');
    }
  }

  /// Create a new income
  Future<IncomeModel> create(IncomeModel income) async {
    try {
      final response = await _client
          .from(AppConstants.incomesTable)
          .insert(income.toJson())
          .select()
          .single();
      return IncomeModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create income: $e');
    }
  }

  /// Update an existing income
  Future<IncomeModel> update(IncomeModel income) async {
    try {
      final response = await _client
          .from(AppConstants.incomesTable)
          .update(income.toJson())
          .eq('id', income.id!)
          .select()
          .single();
      return IncomeModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update income: $e');
    }
  }

  /// Delete an income by id
  Future<void> delete(String id) async {
    try {
      await _client.from(AppConstants.incomesTable).delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete income: $e');
    }
  }

  /// Realtime stream of incomes
  Stream<List<IncomeModel>> stream() {
    return _client
        .from(AppConstants.incomesTable)
        .stream(primaryKey: ['id'])
        .order('transaction_date', ascending: false)
        .map((list) => list.map((json) => IncomeModel.fromJson(json)).toList());
  }
}
