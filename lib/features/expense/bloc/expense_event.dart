import 'package:equatable/equatable.dart';
import '../../../core/models/list_filter.dart';
import '../models/expense_model.dart';

abstract class ExpenseEvent extends Equatable {
  const ExpenseEvent();

  @override
  List<Object?> get props => [];
}

class LoadExpenses extends ExpenseEvent {
  final ListFilter? filter;
  const LoadExpenses({this.filter});

  @override
  List<Object?> get props => [filter];
}

class AddExpense extends ExpenseEvent {
  final ExpenseModel expense;
  const AddExpense(this.expense);

  @override
  List<Object?> get props => [expense];
}

class UpdateExpense extends ExpenseEvent {
  final ExpenseModel expense;
  const UpdateExpense(this.expense);

  @override
  List<Object?> get props => [expense];
}

class DeleteExpense extends ExpenseEvent {
  final String id;
  const DeleteExpense(this.id);

  @override
  List<Object?> get props => [id];
}
