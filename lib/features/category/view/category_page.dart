import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../bloc/category_bloc.dart';
import '../bloc/category_event.dart';
import '../bloc/category_state.dart';
import '../models/category_model.dart';
import 'widgets/category_form_dialog.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  String? _filterType;

  @override
  void initState() {
    super.initState();
    context.read<CategoryBloc>().add(const LoadCategories());
  }

  void _onFilterChanged(String? type) {
    setState(() => _filterType = type);
    context.read<CategoryBloc>().add(LoadCategories(type: type));
  }

  Future<void> _showForm({CategoryModel? category}) async {
    final result = await showModalBottomSheet<CategoryModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CategoryFormDialog(category: category),
    );

    if (result != null && mounted) {
      if (category != null) {
        context.read<CategoryBloc>().add(UpdateCategory(result));
      } else {
        context.read<CategoryBloc>().add(AddCategory(result));
      }
    }
  }

  void _deleteCategory(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Kategori'),
        content: const Text('Apakah Anda yakin ingin menghapus kategori ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<CategoryBloc>().add(DeleteCategory(id));
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  static IconData _iconFromName(String name) {
    switch (name) {
      case 'restaurant':
        return Icons.restaurant;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'directions_car':
        return Icons.directions_car;
      case 'home':
        return Icons.home;
      case 'school':
        return Icons.school;
      case 'health_and_safety':
        return Icons.health_and_safety;
      case 'sports_esports':
        return Icons.sports_esports;
      case 'flight':
        return Icons.flight;
      case 'work':
        return Icons.work;
      case 'savings':
        return Icons.savings;
      case 'card_giftcard':
        return Icons.card_giftcard;
      case 'attach_money':
        return Icons.attach_money;
      case 'trending_up':
        return Icons.trending_up;
      case 'account_balance':
        return Icons.account_balance;
      case 'store':
        return Icons.store;
      default:
        return Icons.category;
    }
  }

  static Color _colorFromHex(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 7) buffer.write('FF');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kategori')),
      body: Column(
        children: [
          // Filter tabs
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            child: SegmentedButton<String?>(
              segments: const [
                ButtonSegment(
                  value: null,
                  label: Text('Semua', style: TextStyle(fontSize: 12)),
                ),
                ButtonSegment(
                  value: 'income',
                  label: Text('Pemasukan', style: TextStyle(fontSize: 12)),
                  icon: Icon(Icons.arrow_downward, size: 16),
                ),
                ButtonSegment(
                  value: 'expense',
                  label: Text('Pengeluaran', style: TextStyle(fontSize: 12)),
                  icon: Icon(Icons.arrow_upward, size: 16),
                ),
              ],
              selected: {_filterType},
              onSelectionChanged: (s) => _onFilterChanged(s.first),
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                textStyle: WidgetStatePropertyAll(
                  const TextStyle(fontSize: 12),
                ),
              ),
            ),
          ),

          // Category list
          Expanded(
            child: BlocBuilder<CategoryBloc, CategoryState>(
              builder: (context, state) {
                if (state is CategoryLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is CategoryError) {
                  return Center(child: Text(state.message));
                }
                if (state is CategoryLoaded) {
                  if (state.categories.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.category_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: AppConstants.spacingMd),
                          Text(
                            'Belum ada kategori',
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
                    itemCount: state.categories.length,
                    itemBuilder: (context, index) {
                      final cat = state.categories[index];
                      final color = _colorFromHex(cat.color);
                      return Dismissible(
                        key: Key(cat.id ?? index.toString()),
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
                          _deleteCategory(cat.id!);
                          return false;
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: color.withAlpha(30),
                                borderRadius: BorderRadius.circular(
                                  AppConstants.radiusSm,
                                ),
                              ),
                              child: Icon(
                                _iconFromName(cat.icon),
                                color: color,
                                size: 22,
                              ),
                            ),
                            title: Text(
                              cat.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              cat.type == 'income'
                                  ? 'Pemasukan'
                                  : 'Pengeluaran',
                              style: TextStyle(
                                fontSize: 12,
                                color: cat.type == 'income'
                                    ? AppConstants.incomeColor
                                    : AppConstants.expenseColor,
                              ),
                            ),
                            trailing: Icon(
                              Icons.chevron_right,
                              color: Colors.grey.shade400,
                            ),
                            onTap: () => _showForm(category: cat),
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
