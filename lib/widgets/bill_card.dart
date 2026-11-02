import 'package:flutter/material.dart';
import 'package:billmind/models/bill.dart';
import 'package:intl/intl.dart';

class BillCard extends StatelessWidget {
  final Bill bill;
  final VoidCallback? onTap;
  final VoidCallback? onTogglePaid;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const BillCard({
    super.key,
    required this.bill,
    this.onTap,
    this.onTogglePaid,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildHeader(),
            _buildContent(),
            if (onEdit != null || onDelete != null) _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getStatusColor().withOpacity(0.1),
            _getStatusColor().withOpacity(0.05),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _getStatusColor(),
                  _getStatusColor().withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: _getStatusColor().withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              _getCategoryIcon(bill.category),
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bill.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  bill.category,
                  style: TextStyle(
                    fontSize: 15,
                    color: _getStatusColor().withOpacity(0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          _buildStatusChip(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Amount',
                  style: TextStyle(
                    fontSize: 13,
                    color: const Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${bill.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Due Date',
                  style: TextStyle(
                    fontSize: 13,
                    color: const Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('MMM dd').format(bill.dueDate),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _getDueDateColor(),
                  ),
                ),
                Text(
                  _getDueDateText(),
                  style: TextStyle(
                    fontSize: 13,
                    color: _getDueDateColor(),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (onTogglePaid != null)
            Column(
              children: [
                Text(
                  'Status',
                  style: TextStyle(
                    fontSize: 13,
                    color: const Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Switch(
                  value: bill.isPaid,
                  onChanged: (_) => onTogglePaid!(),
                  activeColor: const Color(0xFF10B981),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Row(
        children: [
          if (bill.isRecurring)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.repeat,
                    size: 14,
                    color: Colors.blue[700],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Recurring',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          const Spacer(),
          if (onEdit != null)
            TextButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit, size: 16),
              label: const Text('Edit'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue[700],
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
              ),
            ),
          if (onDelete != null) ...[
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: onDelete,
              icon: const Icon(Icons.delete, size: 16),
              label: const Text('Delete'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red[700],
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        bill.statusText,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _getStatusColor(),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    return Color(bill.statusColor);
  }

  Color _getDueDateColor() {
    if (bill.isPaid) return Colors.grey[600]!;
    if (bill.isOverdue) return Colors.red[700]!;
    if (bill.isDueSoon) return Colors.orange[700]!;
    return Colors.green[700]!;
  }

  String _getDueDateText() {
    if (bill.isPaid) return 'Paid';
    
    final now = DateTime.now();
    final difference = bill.dueDate.difference(now).inDays;
    
    if (difference < 0) {
      return '${difference.abs()} days overdue';
    } else if (difference == 0) {
      return 'Due today';
    } else if (difference == 1) {
      return 'Due tomorrow';
    } else {
      return 'Due in $difference days';
    }
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
        return Icons.receipt_long;
    }
  }
}
