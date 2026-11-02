import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:billmind/models/bill.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'billmind.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE bills(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        amount REAL NOT NULL,
        dueDate INTEGER NOT NULL,
        category TEXT NOT NULL,
        isPaid INTEGER NOT NULL DEFAULT 0,
        isRecurring INTEGER NOT NULL DEFAULT 0,
        paidDate INTEGER,
        createdAt INTEGER NOT NULL
      )
    ''');
  }

  // Insert a new bill
  Future<int> insertBill(Bill bill) async {
    final db = await database;
    return await db.insert('bills', bill.toMap());
  }

  // Get all bills
  Future<List<Bill>> getAllBills() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bills',
      orderBy: 'dueDate ASC',
    );
    return List.generate(maps.length, (i) => Bill.fromMap(maps[i]));
  }

  // Get bills by status
  Future<List<Bill>> getBillsByStatus({bool? isPaid}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bills',
      where: isPaid != null ? 'isPaid = ?' : null,
      whereArgs: isPaid != null ? [isPaid ? 1 : 0] : null,
      orderBy: 'dueDate ASC',
    );
    return List.generate(maps.length, (i) => Bill.fromMap(maps[i]));
  }

  // Get overdue bills
  Future<List<Bill>> getOverdueBills() async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final List<Map<String, dynamic>> maps = await db.query(
      'bills',
      where: 'isPaid = 0 AND dueDate < ?',
      whereArgs: [now],
      orderBy: 'dueDate ASC',
    );
    return List.generate(maps.length, (i) => Bill.fromMap(maps[i]));
  }

  // Get bills due soon (within 3 days)
  Future<List<Bill>> getBillsDueSoon() async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final threeDaysFromNow = DateTime.now().add(const Duration(days: 3)).millisecondsSinceEpoch;
    final List<Map<String, dynamic>> maps = await db.query(
      'bills',
      where: 'isPaid = 0 AND dueDate >= ? AND dueDate <= ?',
      whereArgs: [now, threeDaysFromNow],
      orderBy: 'dueDate ASC',
    );
    return List.generate(maps.length, (i) => Bill.fromMap(maps[i]));
  }

  // Get bills by category
  Future<List<Bill>> getBillsByCategory(String category) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bills',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'dueDate ASC',
    );
    return List.generate(maps.length, (i) => Bill.fromMap(maps[i]));
  }

  // Update a bill
  Future<int> updateBill(Bill bill) async {
    final db = await database;
    return await db.update(
      'bills',
      bill.toMap(),
      where: 'id = ?',
      whereArgs: [bill.id],
    );
  }

  // Delete a bill
  Future<int> deleteBill(int id) async {
    final db = await database;
    return await db.delete(
      'bills',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Mark bill as paid
  Future<int> markBillAsPaid(int id, {bool isPaid = true}) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    return await db.update(
      'bills',
      {
        'isPaid': isPaid ? 1 : 0,
        'paidDate': isPaid ? now : null,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get total amount of unpaid bills
  Future<double> getTotalUnpaidAmount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM bills WHERE isPaid = 0'
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // Get total amount of paid bills
  Future<double> getTotalPaidAmount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM bills WHERE isPaid = 1'
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // Get bill count by status
  Future<Map<String, int>> getBillCounts() async {
    final db = await database;
    final unpaidResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM bills WHERE isPaid = 0'
    );
    final paidResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM bills WHERE isPaid = 1'
    );
    final overdueResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM bills WHERE isPaid = 0 AND dueDate < ?',
      [DateTime.now().millisecondsSinceEpoch]
    );
    
    return {
      'unpaid': unpaidResult.first['count'] as int,
      'paid': paidResult.first['count'] as int,
      'overdue': overdueResult.first['count'] as int,
    };
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
