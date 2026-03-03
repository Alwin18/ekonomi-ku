import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/list_filter.dart';
import '../repository/income_repository.dart';
import 'income_event.dart';
import 'income_state.dart';

class IncomeBloc extends Bloc<IncomeEvent, IncomeState> {
  final IncomeRepository repository;
  ListFilter? _currentFilter;

  IncomeBloc({required this.repository}) : super(IncomeInitial()) {
    on<LoadIncomes>(_onLoadIncomes);
    on<AddIncome>(_onAddIncome);
    on<UpdateIncome>(_onUpdateIncome);
    on<DeleteIncome>(_onDeleteIncome);
  }

  Future<void> _onLoadIncomes(
    LoadIncomes event,
    Emitter<IncomeState> emit,
  ) async {
    emit(IncomeLoading());
    try {
      _currentFilter = event.filter;
      final incomes = await repository.getAll(filter: event.filter);
      final total = incomes.fold<double>(0, (sum, e) => sum + e.amount);
      emit(IncomeLoaded(incomes: incomes, totalIncome: total));
    } catch (e) {
      emit(IncomeError(e.toString()));
    }
  }

  Future<void> _onAddIncome(AddIncome event, Emitter<IncomeState> emit) async {
    try {
      await repository.create(event.income);
      add(LoadIncomes(filter: _currentFilter));
    } catch (e) {
      emit(IncomeError(e.toString()));
    }
  }

  Future<void> _onUpdateIncome(
    UpdateIncome event,
    Emitter<IncomeState> emit,
  ) async {
    try {
      await repository.update(event.income);
      add(LoadIncomes(filter: _currentFilter));
    } catch (e) {
      emit(IncomeError(e.toString()));
    }
  }

  Future<void> _onDeleteIncome(
    DeleteIncome event,
    Emitter<IncomeState> emit,
  ) async {
    try {
      await repository.delete(event.id);
      add(LoadIncomes(filter: _currentFilter));
    } catch (e) {
      emit(IncomeError(e.toString()));
    }
  }
}
