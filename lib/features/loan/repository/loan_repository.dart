import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../models/loan_model.dart';

class LoanRepository {
  final SupabaseClient _client;

  LoanRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  Future<List<LoanModel>> getAll({String? statusFilter}) async {
    try {
      var query = _client.from(AppConstants.loansTable).select();

      if (statusFilter != null) {
        query = query.eq('status', statusFilter);
      }

      final response = await query.order('created_at', ascending: false);
      return (response as List)
          .map((json) => LoanModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch loans: $e');
    }
  }

  Future<LoanModel> create(LoanModel loan) async {
    try {
      final response = await _client
          .from(AppConstants.loansTable)
          .insert(loan.toJson())
          .select()
          .single();
      return LoanModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create loan: $e');
    }
  }

  Future<LoanModel> update(LoanModel loan) async {
    try {
      final response = await _client
          .from(AppConstants.loansTable)
          .update(loan.toJson())
          .eq('id', loan.id!)
          .select()
          .single();
      return LoanModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update loan: $e');
    }
  }

  Future<void> markAsPaid(String id) async {
    try {
      await _client
          .from(AppConstants.loansTable)
          .update({
            'status': 'paid',
            'paid_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to mark loan as paid: $e');
    }
  }

  Future<void> delete(String id) async {
    try {
      await _client.from(AppConstants.loansTable).delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete loan: $e');
    }
  }

  Stream<List<LoanModel>> stream() {
    return _client
        .from(AppConstants.loansTable)
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((list) => list.map((json) => LoanModel.fromJson(json)).toList());
  }
}
