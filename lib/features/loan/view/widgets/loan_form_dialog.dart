import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_constants.dart';
import '../../models/loan_model.dart';

class LoanFormDialog extends StatefulWidget {
  final LoanModel? loan;

  const LoanFormDialog({super.key, this.loan});

  @override
  State<LoanFormDialog> createState() => _LoanFormDialogState();
}

class _LoanFormDialogState extends State<LoanFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;
  late DateTime _selectedDueDate;

  bool get isEditing => widget.loan != null;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.loan?.amount.toStringAsFixed(0) ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.loan?.description ?? '',
    );
    _selectedDueDate =
        widget.loan?.dueDate ?? DateTime.now().add(const Duration(days: 30));
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedDueDate = picked);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final loan = LoanModel(
      id: widget.loan?.id,
      amount: double.parse(_amountController.text),
      description: _descriptionController.text.trim(),
      status: widget.loan?.status ?? 'active',
      dueDate: _selectedDueDate,
    );

    Navigator.of(context).pop(loan);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppConstants.spacingLg,
        right: AppConstants.spacingLg,
        top: AppConstants.spacingLg,
        bottom:
            MediaQuery.of(context).viewInsets.bottom + AppConstants.spacingLg,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusXl),
        ),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppConstants.spacingMd),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                isEditing ? 'Edit Pinjaman' : 'Tambah Pinjaman',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimary,
                ),
              ),
              const SizedBox(height: AppConstants.spacingLg),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Jumlah (Rp)',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah harus diisi';
                  }
                  if (double.tryParse(value) == null ||
                      double.parse(value) <= 0) {
                    return 'Masukkan angka yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.spacingMd),
              TextFormField(
                controller: _descriptionController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi / Kepada siapa',
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Deskripsi harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.spacingMd),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Jatuh Tempo',
                    prefixIcon: Icon(Icons.event),
                  ),
                  child: Text(
                    '${_selectedDueDate.day}/${_selectedDueDate.month}/${_selectedDueDate.year}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spacingLg),
              ElevatedButton.icon(
                onPressed: _submit,
                icon: Icon(isEditing ? Icons.save : Icons.add),
                label: Text(isEditing ? 'Simpan' : 'Tambah'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.loanColor,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppConstants.spacingMd,
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spacingSm),
            ],
          ),
        ),
      ),
    );
  }
}
