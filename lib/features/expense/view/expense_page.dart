import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../bloc/expense_bloc.dart';
import '../bloc/expense_event.dart';
import '../bloc/expense_state.dart';
import '../models/expense_model.dart';
import 'widgets/expense_form_dialog.dart';

class ExpensePage extends StatefulWidget {
  const ExpensePage({super.key});

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  DateTime? _selectedMonth;

  @override
  void initState() {
    super.initState();
    context.read<ExpenseBloc>().add(const LoadExpenses());
  }

  void _showForm({ExpenseModel? expense}) {
    final bloc = context.read<ExpenseBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ExpenseFormDialog(expense: expense),
    ).then((result) {
      if (result != null && result is ExpenseModel) {
        if (expense != null) {
          bloc.add(UpdateExpense(result));
        } else {
          bloc.add(AddExpense(result));
        }
      }
    });
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Pengeluaran'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus pengeluaran ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ExpenseBloc>().add(DeleteExpense(id));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _filterByMonth(DateTime? month) {
    setState(() => _selectedMonth = month);
    context.read<ExpenseBloc>().add(LoadExpenses(month: month));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengeluaran'),
        actions: [
          PopupMenuButton<DateTime?>(
            icon: const Icon(Icons.filter_list),
            onSelected: _filterByMonth,
            itemBuilder: (_) => [
              const PopupMenuItem(value: null, child: Text('Semua')),
              ...DateFormatter.getLastNMonths(6).map(
                (month) => PopupMenuItem(
                  value: month,
                  child: Text(DateFormatter.formatMonthYear(month)),
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocBuilder<ExpenseBloc, ExpenseState>(
        builder: (context, state) {
          if (state is ExpenseLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ExpenseError) {
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
                    onPressed: () => context.read<ExpenseBloc>().add(
                      LoadExpenses(month: _selectedMonth),
                    ),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (state is ExpenseLoaded) {
            if (state.expenses.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 80,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: AppConstants.spacingMd),
                    Text(
                      'Belum ada pengeluaran',
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
              );
            }

            return Column(
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(AppConstants.spacingMd),
                  padding: const EdgeInsets.all(AppConstants.spacingLg),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppConstants.expenseColor, Color(0xFFEF5350)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    boxShadow: [
                      BoxShadow(
                        color: AppConstants.expenseColor.withAlpha(77),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Pengeluaran',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: AppConstants.spacingXs),
                      Text(
                        CurrencyFormatter.formatRupiah(state.totalExpense),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_selectedMonth != null)
                        Padding(
                          padding: const EdgeInsets.only(
                            top: AppConstants.spacingXs,
                          ),
                          child: Text(
                            DateFormatter.formatMonthYear(_selectedMonth!),
                            style: const TextStyle(color: Colors.white60),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingSm,
                    ),
                    itemCount: state.expenses.length,
                    itemBuilder: (context, index) {
                      final expense = state.expenses[index];
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
                              color: AppConstants.expenseColor.withAlpha(26),
                              borderRadius: BorderRadius.circular(
                                AppConstants.radiusSm,
                              ),
                            ),
                            child: const Icon(
                              Icons.arrow_upward,
                              color: AppConstants.expenseColor,
                            ),
                          ),
                          title: Text(
                            expense.description ?? '',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            DateFormatter.formatDisplay(
                              expense.transactionDate,
                            ),
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                          trailing: Text(
                            CurrencyFormatter.formatRupiah(expense.amount),
                            style: const TextStyle(
                              color: AppConstants.expenseColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          onTap: () => _showForm(expense: expense),
                          onLongPress: () {
                            if (expense.id != null) _confirmDelete(expense.id!);
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
        heroTag: 'expense_fab',
        onPressed: () => _showForm(),
        backgroundColor: AppConstants.expenseColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
