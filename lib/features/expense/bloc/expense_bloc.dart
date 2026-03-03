import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/list_filter.dart';
import '../repository/expense_repository.dart';
import 'expense_event.dart';
import 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final ExpenseRepository repository;
  ListFilter? _currentFilter;

  ExpenseBloc({required this.repository}) : super(ExpenseInitial()) {
    on<LoadExpenses>(_onLoadExpenses);
    on<AddExpense>(_onAddExpense);
    on<UpdateExpense>(_onUpdateExpense);
    on<DeleteExpense>(_onDeleteExpense);
  }

  Future<void> _onLoadExpenses(
    LoadExpenses event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpenseLoading());
    try {
      _currentFilter = event.filter;
      final expenses = await repository.getAll(filter: event.filter);
      final total = expenses.fold<double>(0, (sum, e) => sum + e.amount);
      emit(ExpenseLoaded(expenses: expenses, totalExpense: total));
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }

  Future<void> _onAddExpense(
    AddExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      await repository.create(event.expense);
      add(LoadExpenses(filter: _currentFilter));
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }

  Future<void> _onUpdateExpense(
    UpdateExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      await repository.update(event.expense);
      add(LoadExpenses(filter: _currentFilter));
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }

  Future<void> _onDeleteExpense(
    DeleteExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      await repository.delete(event.id);
      add(LoadExpenses(filter: _currentFilter));
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }
}
