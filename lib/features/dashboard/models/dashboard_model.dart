import 'package:equatable/equatable.dart';

class MonthlyData extends Equatable {
  final DateTime month;
  final double totalIncome;
  final double totalExpense;

  const MonthlyData({
    required this.month,
    required this.totalIncome,
    required this.totalExpense,
  });

  @override
  List<Object?> get props => [month, totalIncome, totalExpense];
}

class DashboardSummary extends Equatable {
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final double totalActiveLoan;
  final int activeLoanCount;
  final List<MonthlyData> monthlyData;

  const DashboardSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.totalActiveLoan,
    required this.activeLoanCount,
    required this.monthlyData,
  });

  @override
  List<Object?> get props => [
    totalIncome,
    totalExpense,
    balance,
    totalActiveLoan,
    activeLoanCount,
    monthlyData,
  ];
}
