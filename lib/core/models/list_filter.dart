import 'package:equatable/equatable.dart';

enum ListFilterType { dateRange, monthly, yearly }

class ListFilter extends Equatable {
  final ListFilterType filterType;

  /// Used when filterType == dateRange
  final DateTime? startDate;
  final DateTime? endDate;

  /// Used when filterType == monthly
  final int? month;

  /// Used when filterType == monthly or yearly
  final int? year;

  const ListFilter({
    required this.filterType,
    this.startDate,
    this.endDate,
    this.month,
    this.year,
  });

  /// Resolve the effective start date based on filter type.
  DateTime get effectiveStartDate {
    switch (filterType) {
      case ListFilterType.dateRange:
        return startDate!;
      case ListFilterType.monthly:
        return DateTime(year!, month!, 1);
      case ListFilterType.yearly:
        return DateTime(year!, 1, 1);
    }
  }

  /// Resolve the effective end date based on filter type.
  DateTime get effectiveEndDate {
    switch (filterType) {
      case ListFilterType.dateRange:
        return endDate!;
      case ListFilterType.monthly:
        return DateTime(year!, month! + 1, 0, 23, 59, 59);
      case ListFilterType.yearly:
        return DateTime(year!, 12, 31, 23, 59, 59);
    }
  }

  /// ISO date string for effectiveStartDate (yyyy-MM-dd)
  String get startDateIso =>
      effectiveStartDate.toIso8601String().split('T').first;

  /// ISO date string for effectiveEndDate (yyyy-MM-dd)
  String get endDateIso => effectiveEndDate.toIso8601String().split('T').first;

  @override
  List<Object?> get props => [filterType, startDate, endDate, month, year];
}
