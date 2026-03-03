import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../expense/repository/expense_repository.dart';
import '../bloc/budget_bloc.dart';
import '../bloc/budget_event.dart';
import '../bloc/budget_state.dart';
import '../models/budget_model.dart';
import 'widgets/budget_form_dialog.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  late int _selectedMonth;
  late int _selectedYear;

  // Actual expense amounts per category
  Map<String, double> _actualExpenses = {};

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

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now().month;
    _selectedYear = DateTime.now().year;
    _loadData();
  }

  void _loadData() {
    context.read<BudgetBloc>().add(
      LoadBudgets(month: _selectedMonth, year: _selectedYear),
    );
    _loadActualExpenses();
  }

  Future<void> _loadActualExpenses() async {
    try {
      final startDate = DateTime(_selectedYear, _selectedMonth, 1);
      final endDate = DateTime(_selectedYear, _selectedMonth + 1, 0);

      final expenses = await ExpenseRepository().getAll();
      final Map<String, double> map = {};
      for (final expense in expenses) {
        if (expense.categoryId != null &&
            !expense.transactionDate.isBefore(startDate) &&
            !expense.transactionDate.isAfter(endDate)) {
          map[expense.categoryId!] =
              (map[expense.categoryId!] ?? 0) + expense.amount;
        }
      }
      if (mounted) {
        setState(() => _actualExpenses = map);
      }
    } catch (_) {}
  }

  Future<void> _showForm({BudgetModel? budget}) async {
    final result = await showModalBottomSheet<BudgetModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BudgetFormDialog(
        budget: budget,
        month: _selectedMonth,
        year: _selectedYear,
      ),
    );

    if (result != null && mounted) {
      context.read<BudgetBloc>().add(UpsertBudget(result));
      // Refresh actual expenses after budget change
      _loadActualExpenses();
    }
  }

  void _deleteBudget(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Anggaran'),
        content: const Text('Apakah Anda yakin ingin menghapus anggaran ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<BudgetBloc>().add(DeleteBudget(id));
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Anggaran')),
      body: Column(
        children: [
          // Month/year selector
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedMonth,
                    items: List.generate(12, (i) {
                      return DropdownMenuItem(
                        value: i + 1,
                        child: Text(
                          _monthNames[i],
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }),
                    onChanged: (v) {
                      setState(() => _selectedMonth = v!);
                      _loadData();
                    },
                    decoration: InputDecoration(
                      labelText: 'Bulan',
                      labelStyle: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusSm,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    isExpanded: true,
                  ),
                ),
                const SizedBox(width: AppConstants.spacingMd),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedYear,
                    items: List.generate(DateTime.now().year - 2020 + 1, (i) {
                      final y = DateTime.now().year - i;
                      return DropdownMenuItem(
                        value: y,
                        child: Text('$y', style: const TextStyle(fontSize: 14)),
                      );
                    }),
                    onChanged: (v) {
                      setState(() => _selectedYear = v!);
                      _loadData();
                    },
                    decoration: InputDecoration(
                      labelText: 'Tahun',
                      labelStyle: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusSm,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    isExpanded: true,
                  ),
                ),
              ],
            ),
          ),

          // Budget list
          Expanded(
            child: BlocBuilder<BudgetBloc, BudgetState>(
              builder: (context, state) {
                if (state is BudgetLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is BudgetError) {
                  return Center(child: Text(state.message));
                }
                if (state is BudgetLoaded) {
                  if (state.budgets.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: AppConstants.spacingMd),
                          Text(
                            'Belum ada anggaran untuk bulan ini',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingMd,
                    ),
                    itemCount: state.budgets.length,
                    itemBuilder: (context, index) {
                      final budget = state.budgets[index];
                      final actual = _actualExpenses[budget.categoryId] ?? 0.0;
                      final progress = budget.amount > 0
                          ? actual / budget.amount
                          : 0.0;
                      final isOverBudget = progress > 1.0;

                      return Dismissible(
                        key: Key(budget.id ?? index.toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(
                              AppConstants.radiusMd,
                            ),
                          ),
                          child: const Icon(Icons.delete, color: Colors.red),
                        ),
                        confirmDismiss: (_) async {
                          _deleteBudget(budget.id!);
                          return false;
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: Padding(
                            padding: const EdgeInsets.all(
                              AppConstants.spacingMd,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        budget.categoryName ?? 'Kategori',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 18),
                                      onPressed: () =>
                                          _showForm(budget: budget),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: progress.clamp(0.0, 1.0),
                                    backgroundColor: Colors.grey.shade200,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      isOverBudget
                                          ? AppConstants.expenseColor
                                          : AppConstants.primaryColor,
                                    ),
                                    minHeight: 8,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Terpakai: ${CurrencyFormatter.formatRupiah(actual)}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isOverBudget
                                            ? AppConstants.expenseColor
                                            : AppConstants.textSecondary,
                                        fontWeight: isOverBudget
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                    Text(
                                      'Anggaran: ${CurrencyFormatter.formatRupiah(budget.amount)}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppConstants.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                if (isOverBudget)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      'Melebihi anggaran sebesar ${CurrencyFormatter.formatRupiah(actual - budget.amount)}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppConstants.expenseColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
