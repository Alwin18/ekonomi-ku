import 'package:equatable/equatable.dart';
import '../../../core/models/list_filter.dart';
import '../models/loan_model.dart';

abstract class LoanEvent extends Equatable {
  const LoanEvent();

  @override
  List<Object?> get props => [];
}

class LoadLoans extends LoanEvent {
  final String? statusFilter;
  final ListFilter? filter;
  const LoadLoans({this.statusFilter, this.filter});

  @override
  List<Object?> get props => [statusFilter, filter];
}

class AddLoan extends LoanEvent {
  final LoanModel loan;
  const AddLoan(this.loan);

  @override
  List<Object?> get props => [loan];
}

class UpdateLoan extends LoanEvent {
  final LoanModel loan;
  const UpdateLoan(this.loan);

  @override
  List<Object?> get props => [loan];
}

class MarkLoanAsPaid extends LoanEvent {
  final String id;
  const MarkLoanAsPaid(this.id);

  @override
  List<Object?> get props => [id];
}

class DeleteLoan extends LoanEvent {
  final String id;
  const DeleteLoan(this.id);

  @override
  List<Object?> get props => [id];
}
