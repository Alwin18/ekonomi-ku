import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/list_filter.dart';
import '../utils/date_formatter.dart';

/// Reusable filter widget for list pages.
/// Displays a collapsible card with SegmentedButton (Rentang / Bulanan / Tahunan),
/// conditional input fields, and an Apply button.
class ListFilterWidget extends StatefulWidget {
  final ValueChanged<ListFilter?> onApply;
  final Color accentColor;

  const ListFilterWidget({
    super.key,
    required this.onApply,
    this.accentColor = AppConstants.primaryColor,
  });

  @override
  State<ListFilterWidget> createState() => _ListFilterWidgetState();
}

class _ListFilterWidgetState extends State<ListFilterWidget> {
  bool _expanded = false;
  ListFilterType _filterType = ListFilterType.dateRange;
  DateTime? _startDate;
  DateTime? _endDate;
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  static const _monthNames = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  void _apply() {
    ListFilter? filter;
    switch (_filterType) {
      case ListFilterType.dateRange:
        if (_startDate != null && _endDate != null) {
          filter = ListFilter(
            filterType: ListFilterType.dateRange,
            startDate: _startDate,
            endDate: _endDate,
          );
        }
        break;
      case ListFilterType.monthly:
        filter = ListFilter(
          filterType: ListFilterType.monthly,
          month: _selectedMonth,
          year: _selectedYear,
        );
        break;
      case ListFilterType.yearly:
        filter = ListFilter(
          filterType: ListFilterType.yearly,
          year: _selectedYear,
        );
        break;
    }
    widget.onApply(filter);
  }

  void _reset() {
    widget.onApply(null);
    setState(() {
      _startDate = null;
      _endDate = null;
      _selectedMonth = DateTime.now().month;
      _selectedYear = DateTime.now().year;
    });
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (_startDate ?? now) : (_endDate ?? now),
      firstDate: DateTime(2020),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header – tap to expand/collapse
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingMd,
                vertical: 12,
              ),
              child: Row(
                children: [
                  Icon(Icons.filter_list, size: 20, color: widget.accentColor),
                  const SizedBox(width: 8),
                  const Text(
                    'Filter Data',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppConstants.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey.shade500,
                  ),
                ],
              ),
            ),
          ),

          // Body (collapsible)
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.spacingMd,
                0,
                AppConstants.spacingMd,
                AppConstants.spacingMd,
              ),
              child: Column(
                children: [
                  // Filter type selector
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<ListFilterType>(
                      segments: const [
                        ButtonSegment(
                          value: ListFilterType.dateRange,
                          label: Text(
                            'Rentang',
                            style: TextStyle(fontSize: 12),
                          ),
                          icon: Icon(Icons.date_range, size: 16),
                        ),
                        ButtonSegment(
                          value: ListFilterType.monthly,
                          label: Text(
                            'Bulanan',
                            style: TextStyle(fontSize: 12),
                          ),
                          icon: Icon(Icons.calendar_month, size: 16),
                        ),
                        ButtonSegment(
                          value: ListFilterType.yearly,
                          label: Text(
                            'Tahunan',
                            style: TextStyle(fontSize: 12),
                          ),
                          icon: Icon(Icons.calendar_today, size: 16),
                        ),
                      ],
                      selected: {_filterType},
                      onSelectionChanged: (s) =>
                          setState(() => _filterType = s.first),
                      style: ButtonStyle(
                        visualDensity: VisualDensity.compact,
                        textStyle: WidgetStatePropertyAll(
                          const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingMd),

                  // Dynamic inputs
                  _buildInputs(),
                  const SizedBox(height: AppConstants.spacingMd),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _reset,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppConstants.radiusSm,
                              ),
                            ),
                          ),
                          child: const Text('Reset'),
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacingSm),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: _apply,
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text('Terapkan'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.accentColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppConstants.radiusSm,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputs() {
    switch (_filterType) {
      case ListFilterType.dateRange:
        return Row(
          children: [
            Expanded(child: _dateField('Tanggal Awal', _startDate, true)),
            const SizedBox(width: AppConstants.spacingMd),
            Expanded(child: _dateField('Tanggal Akhir', _endDate, false)),
          ],
        );
      case ListFilterType.monthly:
        return Row(
          children: [
            Expanded(child: _monthDropdown()),
            const SizedBox(width: AppConstants.spacingMd),
            Expanded(child: _yearDropdown()),
          ],
        );
      case ListFilterType.yearly:
        return _yearDropdown();
    }
  }

  Widget _dateField(String label, DateTime? value, bool isStart) {
    return GestureDetector(
      onTap: () => _pickDate(isStart: isStart),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusSm),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          suffixIcon: const Icon(Icons.calendar_today, size: 18),
        ),
        child: Text(
          value != null ? DateFormatter.formatDisplay(value) : 'Pilih tanggal',
          style: TextStyle(
            fontSize: 14,
            color: value != null
                ? AppConstants.textPrimary
                : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }

  Widget _monthDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedMonth,
      items: List.generate(12, (i) {
        return DropdownMenuItem(
          value: i + 1,
          child: Text(_monthNames[i], style: const TextStyle(fontSize: 14)),
        );
      }),
      onChanged: (v) => setState(() => _selectedMonth = v!),
      decoration: InputDecoration(
        labelText: 'Bulan',
        labelStyle: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
      ),
      style: const TextStyle(fontSize: 14, color: AppConstants.textPrimary),
      isExpanded: true,
    );
  }

  Widget _yearDropdown() {
    final currentYear = DateTime.now().year;
    return DropdownButtonFormField<int>(
      value: _selectedYear,
      items: List.generate(currentYear - 2020 + 1, (i) {
        final y = currentYear - i;
        return DropdownMenuItem(
          value: y,
          child: Text('$y', style: const TextStyle(fontSize: 14)),
        );
      }),
      onChanged: (v) => setState(() => _selectedYear = v!),
      decoration: InputDecoration(
        labelText: 'Tahun',
        labelStyle: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
      ),
      style: const TextStyle(fontSize: 14, color: AppConstants.textPrimary),
      isExpanded: true,
    );
  }
}
