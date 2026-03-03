import 'package:equatable/equatable.dart';
import '../models/budget_model.dart';

abstract class BudgetState extends Equatable {
  const BudgetState();

  @override
  List<Object?> get props => [];
}

class BudgetInitial extends BudgetState {}

class BudgetLoading extends BudgetState {}

class BudgetLoaded extends BudgetState {
  final List<BudgetModel> budgets;

  const BudgetLoaded({required this.budgets});

  @override
  List<Object?> get props => [budgets];
}

class BudgetError extends BudgetState {
  final String message;
  const BudgetError(this.message);

  @override
  List<Object?> get props => [message];
}
