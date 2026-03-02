import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExpenseModel extends Equatable {
  final String? id;
  final String? userId;
  final double amount;
  final String? description;
  final DateTime transactionDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ExpenseModel({
    this.id,
    this.userId,
    required this.amount,
    this.description,
    required this.transactionDate,
    this.createdAt,
    this.updatedAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String?,
      transactionDate: DateTime.parse(json['transaction_date'] as String),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId ?? Supabase.instance.client.auth.currentUser?.id,
      'amount': amount,
      'description': description,
      'transaction_date': transactionDate.toIso8601String().split('T').first,
    };
  }

  ExpenseModel copyWith({
    String? id,
    String? userId,
    double? amount,
    String? description,
    DateTime? transactionDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      transactionDate: transactionDate ?? this.transactionDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    amount,
    description,
    transactionDate,
    createdAt,
    updatedAt,
  ];
}
