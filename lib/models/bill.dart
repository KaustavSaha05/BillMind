class Bill {
  final int? id;
  final String name;
  final double amount;
  final DateTime dueDate;
  final String category;
  final bool isPaid;
  final bool isRecurring;
  final DateTime? paidDate;
  final DateTime createdAt;

  Bill({
    this.id,
    required this.name,
    required this.amount,
    required this.dueDate,
    required this.category,
    this.isPaid = false,
    this.isRecurring = false,
    this.paidDate,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert Bill to Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'dueDate': dueDate.millisecondsSinceEpoch,
      'category': category,
      'isPaid': isPaid ? 1 : 0,
      'isRecurring': isRecurring ? 1 : 0,
      'paidDate': paidDate?.millisecondsSinceEpoch,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  // Create Bill from Map (from database)
  factory Bill.fromMap(Map<String, dynamic> map) {
    return Bill(
      id: map['id'],
      name: map['name'],
      amount: map['amount'],
      dueDate: DateTime.fromMillisecondsSinceEpoch(map['dueDate']),
      category: map['category'],
      isPaid: map['isPaid'] == 1,
      isRecurring: map['isRecurring'] == 1,
      paidDate: map['paidDate'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['paidDate'])
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  // Create a copy of Bill with updated properties
  Bill copyWith({
    int? id,
    String? name,
    double? amount,
    DateTime? dueDate,
    String? category,
    bool? isPaid,
    bool? isRecurring,
    DateTime? paidDate,
    DateTime? createdAt,
  }) {
    return Bill(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      category: category ?? this.category,
      isPaid: isPaid ?? this.isPaid,
      isRecurring: isRecurring ?? this.isRecurring,
      paidDate: paidDate ?? this.paidDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Check if bill is overdue
  bool get isOverdue => !isPaid && dueDate.isBefore(DateTime.now());

  // Check if bill is due soon (within 3 days)
  bool get isDueSoon {
    if (isPaid) return false;
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;
    return difference >= 0 && difference <= 3;
  }

  // Get days until due
  int get daysUntilDue {
    if (isPaid) return 0;
    final now = DateTime.now();
    return dueDate.difference(now).inDays;
  }

  // Get status text
  String get statusText {
    if (isPaid) return 'Paid';
    if (isOverdue) return 'Overdue';
    if (isDueSoon) return 'Due Soon';
    return 'Upcoming';
  }

  // Get status color
  int get statusColor {
    if (isPaid) return 0xFF4CAF50; // Green
    if (isOverdue) return 0xFFF44336; // Red
    if (isDueSoon) return 0xFFFF9800; // Orange
    return 0xFF2196F3; // Blue
  }

  @override
  String toString() {
    return 'Bill(id: $id, name: $name, amount: $amount, dueDate: $dueDate, category: $category, isPaid: $isPaid)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Bill && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
