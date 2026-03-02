import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/loan_repository.dart';
import 'loan_event.dart';
import 'loan_state.dart';

class LoanBloc extends Bloc<LoanEvent, LoanState> {
  final LoanRepository repository;
  String? _currentFilter;

  LoanBloc({required this.repository}) : super(LoanInitial()) {
    on<LoadLoans>(_onLoadLoans);
    on<AddLoan>(_onAddLoan);
    on<UpdateLoan>(_onUpdateLoan);
    on<MarkLoanAsPaid>(_onMarkAsPaid);
    on<DeleteLoan>(_onDeleteLoan);
  }

  Future<void> _onLoadLoans(LoadLoans event, Emitter<LoanState> emit) async {
    emit(LoanLoading());
    try {
      _currentFilter = event.statusFilter;
      final loans = await repository.getAll(statusFilter: event.statusFilter);
      final activeLoans = loans.where((l) => l.isActive);
      final totalActive = activeLoans.fold<double>(
        0,
        (sum, l) => sum + l.amount,
      );
      emit(
        LoanLoaded(
          loans: loans,
          totalActiveLoan: totalActive,
          activeCount: activeLoans.length,
          paidCount: loans.where((l) => l.isPaid).length,
        ),
      );
    } catch (e) {
      emit(LoanError(e.toString()));
    }
  }

  Future<void> _onAddLoan(AddLoan event, Emitter<LoanState> emit) async {
    try {
      await repository.create(event.loan);
      add(LoadLoans(statusFilter: _currentFilter));
    } catch (e) {
      emit(LoanError(e.toString()));
    }
  }

  Future<void> _onUpdateLoan(UpdateLoan event, Emitter<LoanState> emit) async {
    try {
      await repository.update(event.loan);
      add(LoadLoans(statusFilter: _currentFilter));
    } catch (e) {
      emit(LoanError(e.toString()));
    }
  }

  Future<void> _onMarkAsPaid(
    MarkLoanAsPaid event,
    Emitter<LoanState> emit,
  ) async {
    try {
      await repository.markAsPaid(event.id);
      add(LoadLoans(statusFilter: _currentFilter));
    } catch (e) {
      emit(LoanError(e.toString()));
    }
  }

  Future<void> _onDeleteLoan(DeleteLoan event, Emitter<LoanState> emit) async {
    try {
      await repository.delete(event.id);
      add(LoadLoans(statusFilter: _currentFilter));
    } catch (e) {
      emit(LoanError(e.toString()));
    }
  }
}
