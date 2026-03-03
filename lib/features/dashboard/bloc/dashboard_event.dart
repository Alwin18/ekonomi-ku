import 'package:equatable/equatable.dart';
import '../../../core/models/list_filter.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadDashboard extends DashboardEvent {
  final ListFilter? filter;
  const LoadDashboard({this.filter});

  @override
  List<Object?> get props => [filter];
}

class RefreshDashboard extends DashboardEvent {
  final ListFilter? filter;
  const RefreshDashboard({this.filter});

  @override
  List<Object?> get props => [filter];
}
