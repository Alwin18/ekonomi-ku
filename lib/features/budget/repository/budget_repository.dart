import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../models/budget_model.dart';

class BudgetRepository {
  final SupabaseClient _client;

  BudgetRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  /// Fetch budgets for a specific month/year, joining with categories for name.
  Future<List<BudgetModel>> getAll({
    required int month,
    required int year,
  }) async {
    try {
      final response = await _client
          .from(AppConstants.budgetsTable)
          .select('*, categories(name)')
          .eq('month', month)
          .eq('year', year)
          .order('created_at', ascending: false);
      return (response as List)
          .map((json) => BudgetModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch budgets: $e');
    }
  }

  /// Upsert a budget (insert or update if exists for same user/category/month/year).
  Future<BudgetModel> upsert(BudgetModel budget) async {
    try {
      final response = await _client
          .from(AppConstants.budgetsTable)
          .upsert(budget.toJson(), onConflict: 'user_id,category_id,month,year')
          .select('*, categories(name)')
          .single();
      return BudgetModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to upsert budget: $e');
    }
  }

  Future<void> delete(String id) async {
    try {
      await _client.from(AppConstants.budgetsTable).delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete budget: $e');
    }
  }
}
