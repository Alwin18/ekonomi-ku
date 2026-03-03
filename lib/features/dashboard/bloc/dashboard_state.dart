import 'package:equatable/equatable.dart';
import '../../../core/models/list_filter.dart';
import '../models/dashboard_model.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardSummary summary;
  final ListFilter? activeFilter;

  const DashboardLoaded(this.summary, {this.activeFilter});

  @override
  List<Object?> get props => [summary, activeFilter];
}

class DashboardError extends DashboardState {
  final String message;
  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
