import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/list_filter.dart';
import '../models/income_model.dart';

class IncomeRepository {
  final SupabaseClient _client;

  IncomeRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  Future<List<IncomeModel>> getAll({ListFilter? filter}) async {
    try {
      var query = _client.from(AppConstants.incomesTable).select();

      if (filter != null) {
        query = query
            .gte('transaction_date', filter.startDateIso)
            .lte('transaction_date', filter.endDateIso);
      }

      final response = await query.order('transaction_date', ascending: false);
      return (response as List)
          .map((json) => IncomeModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch incomes: $e');
    }
  }

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

  Future<void> delete(String id) async {
    try {
      await _client.from(AppConstants.incomesTable).delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete income: $e');
    }
  }

  Stream<List<IncomeModel>> stream() {
    return _client
        .from(AppConstants.incomesTable)
        .stream(primaryKey: ['id'])
        .order('transaction_date', ascending: false)
        .map((list) => list.map((json) => IncomeModel.fromJson(json)).toList());
  }
}
