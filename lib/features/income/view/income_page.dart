import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../bloc/income_bloc.dart';
import '../bloc/income_event.dart';
import '../bloc/income_state.dart';
import '../models/income_model.dart';
import 'widgets/income_form_dialog.dart';

class IncomePage extends StatefulWidget {
  const IncomePage({super.key});

  @override
  State<IncomePage> createState() => _IncomePageState();
}

class _IncomePageState extends State<IncomePage> {
  DateTime? _selectedMonth;

  @override
  void initState() {
    super.initState();
    context.read<IncomeBloc>().add(const LoadIncomes());
  }

  void _showForm({IncomeModel? income}) {
    final bloc = context.read<IncomeBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => IncomeFormDialog(income: income),
    ).then((result) {
      if (result != null && result is IncomeModel) {
        if (income != null) {
          bloc.add(UpdateIncome(result));
        } else {
          bloc.add(AddIncome(result));
        }
      }
    });
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Pemasukan'),
        content: const Text('Apakah Anda yakin ingin menghapus pemasukan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<IncomeBloc>().add(DeleteIncome(id));
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
    context.read<IncomeBloc>().add(LoadIncomes(month: month));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pemasukan'),
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
      body: BlocBuilder<IncomeBloc, IncomeState>(
        builder: (context, state) {
          if (state is IncomeLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is IncomeError) {
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
                    onPressed: () => context.read<IncomeBloc>().add(
                      LoadIncomes(month: _selectedMonth),
                    ),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (state is IncomeLoaded) {
            if (state.incomes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 80,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: AppConstants.spacingMd),
                    Text(
                      'Belum ada pemasukan',
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
                // Total card
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(AppConstants.spacingMd),
                  padding: const EdgeInsets.all(AppConstants.spacingLg),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppConstants.incomeColor, Color(0xFF66BB6A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    boxShadow: [
                      BoxShadow(
                        color: AppConstants.incomeColor.withAlpha(77),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Pemasukan',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: AppConstants.spacingXs),
                      Text(
                        CurrencyFormatter.formatRupiah(state.totalIncome),
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

                // List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingSm,
                    ),
                    itemCount: state.incomes.length,
                    itemBuilder: (context, index) {
                      final income = state.incomes[index];
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
                              color: AppConstants.incomeColor.withAlpha(26),
                              borderRadius: BorderRadius.circular(
                                AppConstants.radiusSm,
                              ),
                            ),
                            child: const Icon(
                              Icons.arrow_downward,
                              color: AppConstants.incomeColor,
                            ),
                          ),
                          title: Text(
                            income.description ?? '',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            DateFormatter.formatDisplay(income.transactionDate),
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                          trailing: Text(
                            CurrencyFormatter.formatRupiah(income.amount),
                            style: const TextStyle(
                              color: AppConstants.incomeColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          onTap: () => _showForm(income: income),
                          onLongPress: () {
                            if (income.id != null) _confirmDelete(income.id!);
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
        heroTag: 'income_fab',
        onPressed: () => _showForm(),
        backgroundColor: AppConstants.incomeColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
