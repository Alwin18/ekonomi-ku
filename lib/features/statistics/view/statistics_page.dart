import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../category/view/category_page.dart';
import '../../budget/view/budget_page.dart';
import '../repository/statistics_repository.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  final StatisticsRepository _repository = StatisticsRepository();

  bool _loading = true;
  List<Map<String, dynamic>> _expenseByCategory = [];
  List<Map<String, dynamic>> _monthlyTrend = [];
  Map<String, dynamic> _monthComparison = {};

  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  static const _monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  static const _fullMonthNames = [
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
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _repository.getExpensesByCategory(
          month: _selectedMonth,
          year: _selectedYear,
        ),
        _repository.getMonthlyTrend(months: 6),
        _repository.getMonthComparison(),
      ]);
      if (mounted) {
        setState(() {
          _expenseByCategory = results[0] as List<Map<String, dynamic>>;
          _monthlyTrend = results[1] as List<Map<String, dynamic>>;
          _monthComparison = results[2] as Map<String, dynamic>;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Color _colorFromHex(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 7) buffer.write('FF');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistik'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'category') {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const CategoryPage()));
              } else if (value == 'budget') {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const BudgetPage()));
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'category',
                child: ListTile(
                  leading: Icon(Icons.category),
                  title: Text('Kategori'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: 'budget',
                child: ListTile(
                  leading: Icon(Icons.account_balance_wallet),
                  title: Text('Anggaran'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppConstants.spacingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Month/Year selector for pie chart
                    _buildMonthYearSelector(),
                    const SizedBox(height: AppConstants.spacingMd),

                    // Pie chart
                    _buildPieChartSection(),
                    const SizedBox(height: AppConstants.spacingLg),

                    // Line chart
                    _buildLineChartSection(),
                    const SizedBox(height: AppConstants.spacingLg),

                    // Month-over-month
                    _buildMomSection(),
                    const SizedBox(height: AppConstants.spacingLg),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMonthYearSelector() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<int>(
            value: _selectedMonth,
            items: List.generate(12, (i) {
              return DropdownMenuItem(
                value: i + 1,
                child: Text(
                  _fullMonthNames[i],
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
              labelStyle: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusSm),
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
              labelStyle: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusSm),
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
    );
  }

  Widget _buildPieChartSection() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pengeluaran per Kategori',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.spacingMd),
          if (_expenseByCategory.isEmpty)
            SizedBox(
              height: 200,
              child: Center(
                child: Text(
                  'Belum ada data pengeluaran',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ),
            )
          else
            SizedBox(
              height: 240,
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: _expenseByCategory.map((cat) {
                          final total = _expenseByCategory.fold<double>(
                            0,
                            (s, c) => s + (c['total'] as double),
                          );
                          final percentage = total > 0
                              ? (cat['total'] as double) / total * 100
                              : 0;
                          return PieChartSectionData(
                            color: _colorFromHex(cat['color'] as String),
                            value: cat['total'] as double,
                            title: '${percentage.toStringAsFixed(0)}%',
                            radius: 50,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingMd),
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _expenseByCategory.map((cat) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: _colorFromHex(cat['color'] as String),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  cat['category_name'] as String,
                                  style: const TextStyle(fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLineChartSection() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tren Pemasukan vs Pengeluaran',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              _legendDot(AppConstants.incomeColor, 'Pemasukan'),
              const SizedBox(width: 16),
              _legendDot(AppConstants.expenseColor, 'Pengeluaran'),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMd),
          if (_monthlyTrend.isEmpty)
            SizedBox(
              height: 200,
              child: Center(
                child: Text(
                  'Belum ada data',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ),
            )
          else
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: _calcInterval(),
                    getDrawingHorizontalLine: (value) =>
                        FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        getTitlesWidget: (value, meta) => Text(
                          CurrencyFormatter.formatCompact(value),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < _monthlyTrend.length) {
                            final m = _monthlyTrend[index]['month'] as int;
                            return Text(
                              _monthNames[m - 1],
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade600,
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    // Income line
                    LineChartBarData(
                      spots: _monthlyTrend.asMap().entries.map((e) {
                        return FlSpot(
                          e.key.toDouble(),
                          e.value['income'] as double,
                        );
                      }).toList(),
                      isCurved: true,
                      color: AppConstants.incomeColor,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppConstants.incomeColor.withAlpha(30),
                      ),
                    ),
                    // Expense line
                    LineChartBarData(
                      spots: _monthlyTrend.asMap().entries.map((e) {
                        return FlSpot(
                          e.key.toDouble(),
                          e.value['expense'] as double,
                        );
                      }).toList(),
                      isCurved: true,
                      color: AppConstants.expenseColor,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppConstants.expenseColor.withAlpha(30),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  double _calcInterval() {
    if (_monthlyTrend.isEmpty) return 1;
    double maxVal = 0;
    for (final m in _monthlyTrend) {
      final income = m['income'] as double;
      final expense = m['expense'] as double;
      if (income > maxVal) maxVal = income;
      if (expense > maxVal) maxVal = expense;
    }
    if (maxVal == 0) return 1;
    return maxVal / 4;
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildMomSection() {
    final curIncome =
        (_monthComparison['current_income'] as num?)?.toDouble() ?? 0;
    final curExpense =
        (_monthComparison['current_expense'] as num?)?.toDouble() ?? 0;
    final prevIncome =
        (_monthComparison['previous_income'] as num?)?.toDouble() ?? 0;
    final prevExpense =
        (_monthComparison['previous_expense'] as num?)?.toDouble() ?? 0;

    final incomeChange = prevIncome > 0
        ? ((curIncome - prevIncome) / prevIncome * 100)
        : (curIncome > 0 ? 100 : 0).toDouble();
    final expenseChange = prevExpense > 0
        ? ((curExpense - prevExpense) / prevExpense * 100)
        : (curExpense > 0 ? 100 : 0).toDouble();

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Perbandingan Bulan Sebelumnya',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.spacingMd),
          _momCard('Pemasukan', curIncome, incomeChange, isPositiveGood: true),
          const SizedBox(height: AppConstants.spacingSm),
          _momCard(
            'Pengeluaran',
            curExpense,
            expenseChange,
            isPositiveGood: false,
          ),
          const SizedBox(height: AppConstants.spacingSm),
          _momCard(
            'Saldo',
            curIncome - curExpense,
            prevIncome - prevExpense != 0
                ? ((curIncome - curExpense) - (prevIncome - prevExpense)) /
                      (prevIncome - prevExpense).abs() *
                      100
                : 0,
            isPositiveGood: true,
          ),
        ],
      ),
    );
  }

  Widget _momCard(
    String label,
    double amount,
    double changePercent, {
    required bool isPositiveGood,
  }) {
    final isPositive = changePercent >= 0;
    final isGood = isPositiveGood ? isPositive : !isPositive;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isGood
            ? AppConstants.incomeColor.withAlpha(15)
            : AppConstants.expenseColor.withAlpha(15),
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppConstants.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                CurrencyFormatter.formatRupiah(amount),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimary,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isGood
                  ? AppConstants.incomeColor.withAlpha(30)
                  : AppConstants.expenseColor.withAlpha(30),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 14,
                  color: isGood
                      ? AppConstants.incomeColor
                      : AppConstants.expenseColor,
                ),
                const SizedBox(width: 2),
                Text(
                  '${changePercent.abs().toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isGood
                        ? AppConstants.incomeColor
                        : AppConstants.expenseColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
