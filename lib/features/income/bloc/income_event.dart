import 'package:equatable/equatable.dart';
import '../../../core/models/list_filter.dart';
import '../models/income_model.dart';

abstract class IncomeEvent extends Equatable {
  const IncomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadIncomes extends IncomeEvent {
  final ListFilter? filter;
  const LoadIncomes({this.filter});

  @override
  List<Object?> get props => [filter];
}

class AddIncome extends IncomeEvent {
  final IncomeModel income;
  const AddIncome(this.income);

  @override
  List<Object?> get props => [income];
}

class UpdateIncome extends IncomeEvent {
  final IncomeModel income;
  const UpdateIncome(this.income);

  @override
  List<Object?> get props => [income];
}

class DeleteIncome extends IncomeEvent {
  final String id;
  const DeleteIncome(this.id);

  @override
  List<Object?> get props => [id];
}
