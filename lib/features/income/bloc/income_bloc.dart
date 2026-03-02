import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/income_repository.dart';
import 'income_event.dart';
import 'income_state.dart';

class IncomeBloc extends Bloc<IncomeEvent, IncomeState> {
  final IncomeRepository repository;
  DateTime? _currentMonth;

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
      _currentMonth = event.month;
      final incomes = await repository.getAll(month: event.month);
      final total = incomes.fold<double>(0, (sum, e) => sum + e.amount);
      emit(IncomeLoaded(incomes: incomes, totalIncome: total));
    } catch (e) {
      emit(IncomeError(e.toString()));
    }
  }

  Future<void> _onAddIncome(AddIncome event, Emitter<IncomeState> emit) async {
    try {
      await repository.create(event.income);
      add(LoadIncomes(month: _currentMonth));
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
      add(LoadIncomes(month: _currentMonth));
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
      add(LoadIncomes(month: _currentMonth));
    } catch (e) {
      emit(IncomeError(e.toString()));
    }
  }
}
