import 'package:equatable/equatable.dart';
import '../models/loan_model.dart';

abstract class LoanState extends Equatable {
  const LoanState();

  @override
  List<Object?> get props => [];
}

class LoanInitial extends LoanState {}

class LoanLoading extends LoanState {}

class LoanLoaded extends LoanState {
  final List<LoanModel> loans;
  final double totalActiveLoan;
  final int activeCount;
  final int paidCount;

  const LoanLoaded({
    required this.loans,
    required this.totalActiveLoan,
    required this.activeCount,
    required this.paidCount,
  });

  @override
  List<Object?> get props => [loans, totalActiveLoan, activeCount, paidCount];
}

class LoanError extends LoanState {
  final String message;
  const LoanError(this.message);

  @override
  List<Object?> get props => [message];
}
