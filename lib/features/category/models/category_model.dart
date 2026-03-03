import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoryModel extends Equatable {
  final String? id;
  final String? userId;
  final String name;
  final String type; // 'income' or 'expense'
  final String icon;
  final String color;
  final DateTime? createdAt;

  const CategoryModel({
    this.id,
    this.userId,
    required this.name,
    required this.type,
    this.icon = 'category',
    this.color = '#607D8B',
    this.createdAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      name: json['name'] as String,
      type: json['type'] as String,
      icon: json['icon'] as String? ?? 'category',
      color: json['color'] as String? ?? '#607D8B',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId ?? Supabase.instance.client.auth.currentUser?.id,
      'name': name,
      'type': type,
      'icon': icon,
      'color': color,
    };
  }

  CategoryModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? type,
    String? icon,
    String? color,
    DateTime? createdAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, userId, name, type, icon, color, createdAt];
}
