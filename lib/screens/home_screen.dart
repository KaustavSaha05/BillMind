import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:billmind/providers/bill_provider.dart';
import 'package:billmind/widgets/bill_card.dart';
import 'package:billmind/widgets/statistics_card.dart';
import 'package:billmind/widgets/empty_state.dart';
import 'package:billmind/screens/add_bill_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Initialize the provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BillProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildStatistics(),
            _buildSearchBar(),
            _buildTabBar(),
            Expanded(
              child: _buildTabBarView(),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF6366F1).withOpacity(0.1),
            const Color(0xFF8B5CF6).withOpacity(0.05),
          ],
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
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.receipt_long,
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
                  'BillMind',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1F2937),
                    fontSize: 32,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Never miss a bill again',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF6B7280),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () {
                // Show settings or profile
              },
              icon: Icon(
                Icons.settings,
                color: const Color(0xFF6B7280),
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    return Consumer<BillProvider>(
      builder: (context, billProvider, child) {
        return Container(
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Row(
            children: [
              Expanded(
                child: StatisticsCard(
                  title: 'Unpaid',
                  value: '\$${billProvider.totalUnpaidAmount.toStringAsFixed(2)}',
                  count: billProvider.billCounts['unpaid'] ?? 0,
                  color: const Color(0xFFF59E0B),
                  icon: Icons.pending_actions,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatisticsCard(
                  title: 'Overdue',
                  value: '${billProvider.billCounts['overdue'] ?? 0} bills',
                  count: billProvider.billCounts['overdue'] ?? 0,
                  color: const Color(0xFFEF4444),
                  icon: Icons.warning_rounded,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search bills...',
          prefixIcon: Icon(
            Icons.search_rounded,
            color: const Color(0xFF9CA3AF),
            size: 22,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                  icon: Icon(
                    Icons.clear_rounded,
                    color: const Color(0xFF9CA3AF),
                    size: 20,
                  ),
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          hintStyle: TextStyle(
            color: const Color(0xFF9CA3AF),
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF6B7280),
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
        tabs: const [
          Tab(text: 'Upcoming'),
          Tab(text: 'Paid'),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildUpcomingTab(),
        _buildPaidTab(),
      ],
    );
  }

  Widget _buildUpcomingTab() {
    return Consumer<BillProvider>(
      builder: (context, billProvider, child) {
        if (billProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final bills = _searchQuery.isEmpty
            ? billProvider.unpaidBills
            : billProvider.searchBills(_searchQuery)
                .where((bill) => !bill.isPaid)
                .toList();

        if (bills.isEmpty) {
          return EmptyState(
            icon: Icons.receipt_long,
            title: _searchQuery.isEmpty ? 'No upcoming bills' : 'No bills found',
            subtitle: _searchQuery.isEmpty
                ? 'Add your first bill to get started'
                : 'Try adjusting your search terms',
            actionText: _searchQuery.isEmpty ? 'Add Bill' : null,
            onAction: _searchQuery.isEmpty ? () => _navigateToAddBill() : null,
          );
        }

        return RefreshIndicator(
          onRefresh: () => billProvider.refresh(),
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: bills.length,
            itemBuilder: (context, index) {
              final bill = bills[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: BillCard(
                  bill: bill,
                  onTap: () => _showBillDetails(bill),
                  onTogglePaid: () => billProvider.toggleBillPaidStatus(bill.id!),
                  onEdit: () => _navigateToEditBill(bill),
                  onDelete: () => _showDeleteConfirmation(bill),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPaidTab() {
    return Consumer<BillProvider>(
      builder: (context, billProvider, child) {
        if (billProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final bills = _searchQuery.isEmpty
            ? billProvider.paidBills
            : billProvider.searchBills(_searchQuery)
                .where((bill) => bill.isPaid)
                .toList();

        if (bills.isEmpty) {
          return EmptyState(
            icon: Icons.check_circle,
            title: _searchQuery.isEmpty ? 'No paid bills' : 'No bills found',
            subtitle: _searchQuery.isEmpty
                ? 'Bills you mark as paid will appear here'
                : 'Try adjusting your search terms',
          );
        }

        return RefreshIndicator(
          onRefresh: () => billProvider.refresh(),
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: bills.length,
            itemBuilder: (context, index) {
              final bill = bills[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: BillCard(
                  bill: bill,
                  onTap: () => _showBillDetails(bill),
                  onTogglePaid: () => billProvider.toggleBillPaidStatus(bill.id!),
                  onEdit: () => _navigateToEditBill(bill),
                  onDelete: () => _showDeleteConfirmation(bill),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: _navigateToAddBill,
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded, size: 24),
        label: const Text(
          'Add Bill',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
    );
  }

  void _navigateToAddBill() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddBillScreen(),
      ),
    );
  }

  void _navigateToEditBill(bill) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddBillScreen(bill: bill),
      ),
    );
  }

  void _showBillDetails(bill) {
    // Show bill details in a bottom sheet or dialog
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildBillDetailsSheet(bill),
    );
  }

  Widget _buildBillDetailsSheet(bill) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bill.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildDetailRow('Amount', '\$${bill.amount.toStringAsFixed(2)}'),
                  _buildDetailRow('Due Date', _formatDate(bill.dueDate)),
                  _buildDetailRow('Category', bill.category),
                  _buildDetailRow('Status', bill.statusText),
                  if (bill.isRecurring) _buildDetailRow('Recurring', 'Yes'),
                  if (bill.isPaid && bill.paidDate != null)
                    _buildDetailRow('Paid Date', _formatDate(bill.paidDate!)),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _navigateToEditBill(bill);
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            context.read<BillProvider>().toggleBillPaidStatus(bill.id!);
                          },
                          icon: Icon(bill.isPaid ? Icons.undo : Icons.check),
                          label: Text(bill.isPaid ? 'Mark Unpaid' : 'Mark Paid'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: bill.isPaid ? Colors.orange : Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showDeleteConfirmation(bill) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Bill'),
        content: Text('Are you sure you want to delete "${bill.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<BillProvider>().deleteBill(bill.id!);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
