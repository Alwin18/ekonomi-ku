import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoanModel extends Equatable {
  final String? id;
  final String? userId;
  final double amount;
  final String? description;
  final String status; // 'active' or 'paid'
  final DateTime? dueDate;
  final DateTime? paidAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const LoanModel({
    this.id,
    this.userId,
    required this.amount,
    this.description,
    this.status = 'active',
    this.dueDate,
    this.paidAt,
    this.createdAt,
    this.updatedAt,
  });

  bool get isActive => status == 'active';
  bool get isPaid => status == 'paid';

  factory LoanModel.fromJson(Map<String, dynamic> json) {
    return LoanModel(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'active',
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      paidAt: json['paid_at'] != null
          ? DateTime.parse(json['paid_at'] as String)
          : null,
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
      'status': status,
      if (dueDate != null)
        'due_date': dueDate!.toIso8601String().split('T').first,
    };
  }

  LoanModel copyWith({
    String? id,
    String? userId,
    double? amount,
    String? description,
    String? status,
    DateTime? dueDate,
    DateTime? paidAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LoanModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      paidAt: paidAt ?? this.paidAt,
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
    status,
    dueDate,
    paidAt,
    createdAt,
    updatedAt,
  ];
}
