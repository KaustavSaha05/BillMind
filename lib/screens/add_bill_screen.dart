import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:billmind/providers/bill_provider.dart';
import 'package:billmind/models/bill.dart';
import 'package:intl/intl.dart';

class AddBillScreen extends StatefulWidget {
  final Bill? bill;

  const AddBillScreen({super.key, this.bill});

  @override
  State<AddBillScreen> createState() => _AddBillScreenState();
}

class _AddBillScreenState extends State<AddBillScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _categoryController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  bool _isRecurring = false;
  bool _isLoading = false;

  final List<String> _predefinedCategories = [
    'Utilities',
    'Rent',
    'Insurance',
    'Subscriptions',
    'Phone & Internet',
    'Transportation',
    'Entertainment',
    'Healthcare',
    'Education',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.bill != null) {
      _populateFields();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _populateFields() {
    final bill = widget.bill!;
    _nameController.text = bill.name;
    _amountController.text = bill.amount.toString();
    _categoryController.text = bill.category;
    _selectedDate = bill.dueDate;
    _isRecurring = bill.isRecurring;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.bill != null;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Bill' : 'Add New Bill',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
          ),
        ),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, size: 22),
            onPressed: () => Navigator.pop(context),
            color: const Color(0xFF6B7280),
          ),
        ),
        actions: [
          if (isEditing)
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEF4444).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.delete_rounded, size: 22),
                onPressed: _showDeleteConfirmation,
                color: Colors.white,
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 30),
              _buildNameField(),
              const SizedBox(height: 20),
              _buildAmountField(),
              const SizedBox(height: 20),
              _buildDueDateField(),
              const SizedBox(height: 20),
              _buildCategoryField(),
              const SizedBox(height: 20),
              _buildRecurringToggle(),
              const SizedBox(height: 30),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final isEditing = widget.bill != null;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF6366F1).withOpacity(0.1),
            const Color(0xFF8B5CF6).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF6366F1).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              isEditing ? Icons.edit_rounded : Icons.add_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'Edit Bill' : 'Add New Bill',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1F2937),
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isEditing 
                      ? 'Update your bill information'
                      : 'Enter the details of your new bill',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF6B7280),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bill Name',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            hintText: 'e.g., Electricity Bill, Netflix Subscription',
            prefixIcon: Icon(Icons.receipt_long),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a bill name';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amount',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: '0.00',
            prefixIcon: Icon(Icons.attach_money),
            prefixText: '\$ ',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter an amount';
            }
            final amount = double.tryParse(value);
            if (amount == null || amount <= 0) {
              return 'Please enter a valid amount';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDueDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Due Date',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE0E0E0)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Color(0xFF666666)),
                const SizedBox(width: 12),
                Text(
                  DateFormat('MMM dd, yyyy').format(_selectedDate),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.arrow_drop_down, color: Color(0xFF666666)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _categoryController,
          decoration: InputDecoration(
            hintText: 'Select or type a category',
            prefixIcon: const Icon(Icons.category),
            suffixIcon: IconButton(
              onPressed: _showCategoryPicker,
              icon: const Icon(Icons.arrow_drop_down),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please select a category';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildRecurringToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.repeat,
            color: _isRecurring ? Theme.of(context).primaryColor : Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recurring Bill',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                Text(
                  'Automatically create next month\'s bill when paid',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isRecurring,
            onChanged: (value) {
              setState(() {
                _isRecurring = value;
              });
            },
            activeColor: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveBill,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6366F1),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                widget.bill != null ? 'Update Bill' : 'Save Bill',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Category',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _predefinedCategories.length,
                itemBuilder: (context, index) {
                  final category = _predefinedCategories[index];
                  return ListTile(
                    title: Text(category),
                    leading: Icon(
                      _getCategoryIcon(category),
                      color: Theme.of(context).primaryColor,
                    ),
                    onTap: () {
                      setState(() {
                        _categoryController.text = category;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'utilities':
        return Icons.electric_bolt;
      case 'rent':
        return Icons.home;
      case 'insurance':
        return Icons.security;
      case 'subscriptions':
        return Icons.subscriptions;
      case 'phone & internet':
        return Icons.phone_android;
      case 'transportation':
        return Icons.directions_car;
      case 'entertainment':
        return Icons.movie;
      case 'healthcare':
        return Icons.local_hospital;
      case 'education':
        return Icons.school;
      default:
        return Icons.category;
    }
  }

  Future<void> _saveBill() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final bill = Bill(
        id: widget.bill?.id,
        name: _nameController.text.trim(),
        amount: double.parse(_amountController.text),
        dueDate: _selectedDate,
        category: _categoryController.text.trim(),
        isRecurring: _isRecurring,
        isPaid: widget.bill?.isPaid ?? false,
        paidDate: widget.bill?.paidDate,
      );

      final billProvider = context.read<BillProvider>();
      bool success;

      if (widget.bill != null) {
        success = await billProvider.updateBill(bill);
      } else {
        success = await billProvider.addBill(bill);
      }

      if (success) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.bill != null ? 'Bill updated successfully!' : 'Bill added successfully!',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Failed to save bill');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Bill'),
        content: Text('Are you sure you want to delete "${widget.bill!.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await context.read<BillProvider>().deleteBill(widget.bill!.id!);
              if (success && mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Bill deleted successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
