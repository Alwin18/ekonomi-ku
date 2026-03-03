import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/list_filter.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/list_filter_widget.dart';
import '../bloc/loan_bloc.dart';
import '../bloc/loan_event.dart';
import '../bloc/loan_state.dart';
import '../models/loan_model.dart';
import 'widgets/loan_form_dialog.dart';

class LoanPage extends StatefulWidget {
  const LoanPage({super.key});

  @override
  State<LoanPage> createState() => _LoanPageState();
}

class _LoanPageState extends State<LoanPage> {
  String? _statusFilter;
  ListFilter? _activeFilter;

  @override
  void initState() {
    super.initState();
    context.read<LoanBloc>().add(const LoadLoans());
  }

  void _showForm({LoanModel? loan}) {
    final bloc = context.read<LoanBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LoanFormDialog(loan: loan),
    ).then((result) {
      if (result != null && result is LoanModel) {
        if (loan != null) {
          bloc.add(UpdateLoan(result));
        } else {
          bloc.add(AddLoan(result));
        }
      }
    });
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Pinjaman'),
        content: const Text('Apakah Anda yakin ingin menghapus pinjaman ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<LoanBloc>().add(DeleteLoan(id));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _confirmMarkAsPaid(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tandai Lunas'),
        content: const Text('Apakah Anda yakin pinjaman ini sudah lunas?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<LoanBloc>().add(MarkLoanAsPaid(id));
            },
            style: TextButton.styleFrom(
              foregroundColor: AppConstants.incomeColor,
            ),
            child: const Text('Ya, Lunas'),
          ),
        ],
      ),
    );
  }

  void _filterByStatus(String? status) {
    setState(() => _statusFilter = status);
    context.read<LoanBloc>().add(
      LoadLoans(statusFilter: status, filter: _activeFilter),
    );
  }

  void _onDateFilterApply(ListFilter? filter) {
    setState(() => _activeFilter = filter);
    context.read<LoanBloc>().add(
      LoadLoans(statusFilter: _statusFilter, filter: filter),
    );
  }

  String _filterLabel() {
    if (_activeFilter == null) return '';
    switch (_activeFilter!.filterType) {
      case ListFilterType.dateRange:
        return '${DateFormatter.formatDisplay(_activeFilter!.startDate!)} – ${DateFormatter.formatDisplay(_activeFilter!.endDate!)}';
      case ListFilterType.monthly:
        return DateFormatter.formatMonthYear(
          DateTime(_activeFilter!.year!, _activeFilter!.month!),
        );
      case ListFilterType.yearly:
        return 'Tahun ${_activeFilter!.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pinjaman'),
        actions: [
          PopupMenuButton<String?>(
            icon: const Icon(Icons.filter_list),
            onSelected: _filterByStatus,
            itemBuilder: (_) => [
              const PopupMenuItem(value: null, child: Text('Semua')),
              const PopupMenuItem(value: 'active', child: Text('Aktif')),
              const PopupMenuItem(value: 'paid', child: Text('Lunas')),
            ],
          ),
        ],
      ),
      body: BlocBuilder<LoanBloc, LoanState>(
        builder: (context, state) {
          if (state is LoanLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is LoanError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  Text(
                    'Terjadi kesalahan',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.red.shade300,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingSm),
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: AppConstants.spacingMd),
                  ElevatedButton(
                    onPressed: () => context.read<LoanBloc>().add(
                      LoadLoans(
                        statusFilter: _statusFilter,
                        filter: _activeFilter,
                      ),
                    ),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (state is LoanLoaded) {
            return Column(
              children: [
                // Summary card
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(AppConstants.spacingMd),
                  padding: const EdgeInsets.all(AppConstants.spacingLg),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppConstants.loanColor, Color(0xFFFFB74D)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    boxShadow: [
                      BoxShadow(
                        color: AppConstants.loanColor.withAlpha(77),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Pinjaman Aktif',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: AppConstants.spacingXs),
                      Text(
                        CurrencyFormatter.formatRupiah(state.totalActiveLoan),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingSm),
                      Row(
                        children: [
                          _buildChip(
                            'Aktif: ${state.activeCount}',
                            Colors.white,
                          ),
                          const SizedBox(width: AppConstants.spacingSm),
                          _buildChip(
                            'Lunas: ${state.paidCount}',
                            Colors.white70,
                          ),
                        ],
                      ),
                      if (_activeFilter != null)
                        Padding(
                          padding: const EdgeInsets.only(
                            top: AppConstants.spacingXs,
                          ),
                          child: Text(
                            _filterLabel(),
                            style: const TextStyle(color: Colors.white60),
                          ),
                        ),
                    ],
                  ),
                ),

                // Date filter widget
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingMd,
                  ),
                  child: ListFilterWidget(
                    onApply: _onDateFilterApply,
                    accentColor: AppConstants.loanColor,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingSm),

                // List
                Expanded(
                  child: state.loans.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.handshake_outlined,
                                size: 80,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: AppConstants.spacingMd),
                              Text(
                                'Belum ada pinjaman',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: AppConstants.spacingSm),
                              Text(
                                'Tap + untuk menambahkan',
                                style: TextStyle(color: Colors.grey.shade400),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.spacingSm,
                          ),
                          itemCount: state.loans.length,
                          itemBuilder: (context, index) {
                            final loan = state.loans[index];
                            final isOverdue =
                                loan.isActive &&
                                loan.dueDate != null &&
                                loan.dueDate!.isBefore(DateTime.now());

                            return Card(
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: AppConstants.spacingMd,
                                  vertical: AppConstants.spacingSm,
                                ),
                                leading: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: loan.isPaid
                                        ? AppConstants.incomeColor.withAlpha(26)
                                        : AppConstants.loanColor.withAlpha(26),
                                    borderRadius: BorderRadius.circular(
                                      AppConstants.radiusSm,
                                    ),
                                  ),
                                  child: Icon(
                                    loan.isPaid
                                        ? Icons.check_circle
                                        : Icons.schedule,
                                    color: loan.isPaid
                                        ? AppConstants.incomeColor
                                        : AppConstants.loanColor,
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        loan.description ?? '',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          decoration: loan.isPaid
                                              ? TextDecoration.lineThrough
                                              : null,
                                        ),
                                      ),
                                    ),
                                    if (isOverdue)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade50,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          'Jatuh Tempo!',
                                          style: TextStyle(
                                            color: Colors.red.shade700,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                subtitle: Text(
                                  loan.dueDate != null
                                      ? 'Jatuh tempo: ${DateFormatter.formatDisplay(loan.dueDate!)}'
                                      : 'Tanpa jatuh tempo',
                                  style: TextStyle(
                                    color: isOverdue
                                        ? Colors.red.shade400
                                        : Colors.grey.shade500,
                                    fontSize: 12,
                                  ),
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      CurrencyFormatter.formatRupiah(
                                        loan.amount,
                                      ),
                                      style: TextStyle(
                                        color: loan.isPaid
                                            ? AppConstants.incomeColor
                                            : AppConstants.loanColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      loan.isPaid ? 'Lunas' : 'Aktif',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: loan.isPaid
                                            ? AppConstants.incomeColor
                                            : AppConstants.loanColor,
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () => _showForm(loan: loan),
                                onLongPress: () {
                                  if (loan.id == null) return;
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (_) => SafeArea(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (loan.isActive)
                                            ListTile(
                                              leading: const Icon(
                                                Icons.check_circle,
                                                color: AppConstants.incomeColor,
                                              ),
                                              title: const Text('Tandai Lunas'),
                                              onTap: () {
                                                Navigator.pop(context);
                                                _confirmMarkAsPaid(loan.id!);
                                              },
                                            ),
                                          ListTile(
                                            leading: const Icon(
                                              Icons.delete,
                                              color: AppConstants.expenseColor,
                                            ),
                                            title: const Text('Hapus'),
                                            onTap: () {
                                              Navigator.pop(context);
                                              _confirmDelete(loan.id!);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'loan_fab',
        onPressed: () => _showForm(),
        backgroundColor: AppConstants.loanColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
