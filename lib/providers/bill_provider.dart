import 'package:flutter/foundation.dart';
import 'package:billmind/models/bill.dart';
import 'package:billmind/services/database_service.dart';
import 'package:billmind/services/notification_service.dart';

class BillProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final NotificationService _notificationService = NotificationService();
  
  List<Bill> _bills = [];
  List<Bill> _unpaidBills = [];
  List<Bill> _paidBills = [];
  List<Bill> _overdueBills = [];
  List<Bill> _billsDueSoon = [];
  
  double _totalUnpaidAmount = 0.0;
  double _totalPaidAmount = 0.0;
  Map<String, int> _billCounts = {'unpaid': 0, 'paid': 0, 'overdue': 0};
  
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Bill> get bills => _bills;
  List<Bill> get unpaidBills => _unpaidBills;
  List<Bill> get paidBills => _paidBills;
  List<Bill> get overdueBills => _overdueBills;
  List<Bill> get billsDueSoon => _billsDueSoon;
  
  double get totalUnpaidAmount => _totalUnpaidAmount;
  double get totalPaidAmount => _totalPaidAmount;
  Map<String, int> get billCounts => _billCounts;
  
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize provider
  Future<void> initialize() async {
    await loadBills();
    await loadStatistics();
  }

  // Load all bills from database
  Future<void> loadBills() async {
    try {
      _setLoading(true);
      _clearError();
      
      _bills = await _databaseService.getAllBills();
      _categorizeBills();
      
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load bills: $e');
      _setLoading(false);
    }
  }

  // Categorize bills by status
  void _categorizeBills() {
    _unpaidBills = _bills.where((bill) => !bill.isPaid).toList();
    _paidBills = _bills.where((bill) => bill.isPaid).toList();
    _overdueBills = _bills.where((bill) => bill.isOverdue).toList();
    _billsDueSoon = _bills.where((bill) => bill.isDueSoon).toList();
  }

  // Load statistics
  Future<void> loadStatistics() async {
    try {
      _totalUnpaidAmount = await _databaseService.getTotalUnpaidAmount();
      _totalPaidAmount = await _databaseService.getTotalPaidAmount();
      _billCounts = await _databaseService.getBillCounts();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load statistics: $e');
    }
  }

  // Add new bill
  Future<bool> addBill(Bill bill) async {
    try {
      _setLoading(true);
      _clearError();
      
      final id = await _databaseService.insertBill(bill);
      final newBill = bill.copyWith(id: id);
      
      _bills.add(newBill);
      _categorizeBills();
      await loadStatistics();
      
      // Schedule notifications for the new bill
      await _notificationService.scheduleMultipleReminders(newBill);
      
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to add bill: $e');
      _setLoading(false);
      return false;
    }
  }

  // Update existing bill
  Future<bool> updateBill(Bill bill) async {
    try {
      _setLoading(true);
      _clearError();
      
      await _databaseService.updateBill(bill);
      
      final index = _bills.indexWhere((b) => b.id == bill.id);
      if (index != -1) {
        _bills[index] = bill;
        _categorizeBills();
        await loadStatistics();
        
        // Update notifications
        await _notificationService.cancelBillReminder(bill.id!);
        if (!bill.isPaid) {
          await _notificationService.scheduleMultipleReminders(bill);
        }
      }
      
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update bill: $e');
      _setLoading(false);
      return false;
    }
  }

  // Delete bill
  Future<bool> deleteBill(int id) async {
    try {
      _setLoading(true);
      _clearError();
      
      await _databaseService.deleteBill(id);
      
      _bills.removeWhere((bill) => bill.id == id);
      _categorizeBills();
      await loadStatistics();
      
      // Cancel notifications for the deleted bill
      await _notificationService.cancelBillReminder(id);
      
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete bill: $e');
      _setLoading(false);
      return false;
    }
  }

  // Mark bill as paid/unpaid
  Future<bool> toggleBillPaidStatus(int id, {bool? isPaid}) async {
    try {
      final bill = _bills.firstWhere((b) => b.id == id);
      final newPaidStatus = isPaid ?? !bill.isPaid;
      
      await _databaseService.markBillAsPaid(id, isPaid: newPaidStatus);
      
      final updatedBill = bill.copyWith(
        isPaid: newPaidStatus,
        paidDate: newPaidStatus ? DateTime.now() : null,
      );
      
      final index = _bills.indexWhere((b) => b.id == id);
      if (index != -1) {
        _bills[index] = updatedBill;
        _categorizeBills();
        await loadStatistics();
        
        // Handle recurring bills
        if (newPaidStatus && updatedBill.isRecurring) {
          await _handleRecurringBill(updatedBill);
        }
        
        // Update notifications
        if (newPaidStatus) {
          await _notificationService.cancelBillReminder(id);
        } else {
          await _notificationService.scheduleMultipleReminders(updatedBill);
        }
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update bill status: $e');
      return false;
    }
  }

  // Handle recurring bills
  Future<void> _handleRecurringBill(Bill paidBill) async {
    try {
      // Calculate next due date (add 1 month)
      final nextDueDate = DateTime(
        paidBill.dueDate.year,
        paidBill.dueDate.month + 1,
        paidBill.dueDate.day,
      );
      
      final nextBill = paidBill.copyWith(
        id: null,
        dueDate: nextDueDate,
        isPaid: false,
        paidDate: null,
        createdAt: DateTime.now(),
      );
      
      await addBill(nextBill);
    } catch (e) {
      _setError('Failed to create recurring bill: $e');
    }
  }

  // Get bills by category
  Future<List<Bill>> getBillsByCategory(String category) async {
    try {
      return await _databaseService.getBillsByCategory(category);
    } catch (e) {
      _setError('Failed to get bills by category: $e');
      return [];
    }
  }

  // Search bills
  List<Bill> searchBills(String query) {
    if (query.isEmpty) return _bills;
    
    return _bills.where((bill) =>
      bill.name.toLowerCase().contains(query.toLowerCase()) ||
      bill.category.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  // Sort bills
  void sortBills({String? sortBy}) {
    switch (sortBy) {
      case 'dueDate':
        _bills.sort((a, b) => a.dueDate.compareTo(b.dueDate));
        break;
      case 'amount':
        _bills.sort((a, b) => a.amount.compareTo(b.amount));
        break;
      case 'name':
        _bills.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'category':
        _bills.sort((a, b) => a.category.compareTo(b.category));
        break;
      default:
        _bills.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    }
    _categorizeBills();
    notifyListeners();
  }

  // Clear error
  void _clearError() {
    _error = null;
  }

  // Set error
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Refresh all data
  Future<void> refresh() async {
    await loadBills();
    await loadStatistics();
  }

  // Clear all data (for testing)
  Future<void> clearAllData() async {
    try {
      _bills.clear();
      _unpaidBills.clear();
      _paidBills.clear();
      _overdueBills.clear();
      _billsDueSoon.clear();
      _totalUnpaidAmount = 0.0;
      _totalPaidAmount = 0.0;
      _billCounts = {'unpaid': 0, 'paid': 0, 'overdue': 0};
      notifyListeners();
    } catch (e) {
      _setError('Failed to clear data: $e');
    }
  }
}
