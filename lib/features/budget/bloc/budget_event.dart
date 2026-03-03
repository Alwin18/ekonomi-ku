import 'package:equatable/equatable.dart';
import '../models/budget_model.dart';

abstract class BudgetEvent extends Equatable {
  const BudgetEvent();

  @override
  List<Object?> get props => [];
}

class LoadBudgets extends BudgetEvent {
  final int month;
  final int year;
  const LoadBudgets({required this.month, required this.year});

  @override
  List<Object?> get props => [month, year];
}

class UpsertBudget extends BudgetEvent {
  final BudgetModel budget;
  const UpsertBudget(this.budget);

  @override
  List<Object?> get props => [budget];
}

class DeleteBudget extends BudgetEvent {
  final String id;
  const DeleteBudget(this.id);

  @override
  List<Object?> get props => [id];
}
