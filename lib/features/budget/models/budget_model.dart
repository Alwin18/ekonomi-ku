import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BudgetModel extends Equatable {
  final String? id;
  final String? userId;
  final String categoryId;
  final String? categoryName;
  final double amount;
  final int month;
  final int year;
  final DateTime? createdAt;

  const BudgetModel({
    this.id,
    this.userId,
    required this.categoryId,
    this.categoryName,
    required this.amount,
    required this.month,
    required this.year,
    this.createdAt,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    // Handle joined category name
    String? catName;
    if (json['categories'] != null && json['categories'] is Map) {
      catName = (json['categories'] as Map<String, dynamic>)['name'] as String?;
    }
    catName ??= json['category_name'] as String?;

    return BudgetModel(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      categoryId: json['category_id'] as String,
      categoryName: catName,
      amount: (json['amount'] as num).toDouble(),
      month: json['month'] as int,
      year: json['year'] as int,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId ?? Supabase.instance.client.auth.currentUser?.id,
      'category_id': categoryId,
      'amount': amount,
      'month': month,
      'year': year,
    };
  }

  BudgetModel copyWith({
    String? id,
    String? userId,
    String? categoryId,
    String? categoryName,
    double? amount,
    int? month,
    int? year,
    DateTime? createdAt,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      amount: amount ?? this.amount,
      month: month ?? this.month,
      year: year ?? this.year,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    categoryId,
    categoryName,
    amount,
    month,
    year,
    createdAt,
  ];
}
