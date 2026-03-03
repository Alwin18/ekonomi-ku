import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../models/category_model.dart';

class CategoryRepository {
  final SupabaseClient _client;

  CategoryRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  Future<List<CategoryModel>> getAll({String? type}) async {
    try {
      var query = _client.from(AppConstants.categoriesTable).select();

      if (type != null) {
        query = query.eq('type', type);
      }

      final response = await query.order('name', ascending: true);
      return (response as List)
          .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  Future<CategoryModel> create(CategoryModel category) async {
    try {
      final response = await _client
          .from(AppConstants.categoriesTable)
          .insert(category.toJson())
          .select()
          .single();
      return CategoryModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create category: $e');
    }
  }

  Future<CategoryModel> update(CategoryModel category) async {
    try {
      final response = await _client
          .from(AppConstants.categoriesTable)
          .update(category.toJson())
          .eq('id', category.id!)
          .select()
          .single();
      return CategoryModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  Future<void> delete(String id) async {
    try {
      await _client.from(AppConstants.categoriesTable).delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }
}
