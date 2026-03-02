import 'package:equatable/equatable.dart';
import '../models/income_model.dart';

abstract class IncomeState extends Equatable {
  const IncomeState();

  @override
  List<Object?> get props => [];
}

class IncomeInitial extends IncomeState {}

class IncomeLoading extends IncomeState {}

class IncomeLoaded extends IncomeState {
  final List<IncomeModel> incomes;
  final double totalIncome;

  const IncomeLoaded({required this.incomes, required this.totalIncome});

  @override
  List<Object?> get props => [incomes, totalIncome];
}

class IncomeError extends IncomeState {
  final String message;
  const IncomeError(this.message);

  @override
  List<Object?> get props => [message];
}
