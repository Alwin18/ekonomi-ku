import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/budget_repository.dart';
import 'budget_event.dart';
import 'budget_state.dart';

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  final BudgetRepository repository;
  int _currentMonth = DateTime.now().month;
  int _currentYear = DateTime.now().year;

  BudgetBloc({required this.repository}) : super(BudgetInitial()) {
    on<LoadBudgets>(_onLoadBudgets);
    on<UpsertBudget>(_onUpsertBudget);
    on<DeleteBudget>(_onDeleteBudget);
  }

  Future<void> _onLoadBudgets(
    LoadBudgets event,
    Emitter<BudgetState> emit,
  ) async {
    emit(BudgetLoading());
    try {
      _currentMonth = event.month;
      _currentYear = event.year;
      final budgets = await repository.getAll(
        month: event.month,
        year: event.year,
      );
      emit(BudgetLoaded(budgets: budgets));
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  Future<void> _onUpsertBudget(
    UpsertBudget event,
    Emitter<BudgetState> emit,
  ) async {
    try {
      await repository.upsert(event.budget);
      add(LoadBudgets(month: _currentMonth, year: _currentYear));
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  Future<void> _onDeleteBudget(
    DeleteBudget event,
    Emitter<BudgetState> emit,
  ) async {
    try {
      await repository.delete(event.id);
      add(LoadBudgets(month: _currentMonth, year: _currentYear));
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }
}
