import 'package:sqflite/sqflite.dart' as sqflite show Database, ConflictAlgorithm, openDatabase, getDatabasesPath;
import 'package:path/path.dart' show join;

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static sqflite.Database? _database;

  DatabaseHelper._init();

  Future<sqflite.Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('loans.db');
    return _database!;
  }

  Future<sqflite.Database> _initDB(String filePath) async {
    final dbPath = await sqflite.getDatabasesPath();
    final path = join(dbPath, filePath);
    print('Full database path: $path');

    return await sqflite.openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(sqflite.Database db, int version) async {
    await db.execute('''
      CREATE TABLE loans(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        total_amount REAL NOT NULL,
        monthly_payment REAL NOT NULL,
        due_date INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
    
    await db.execute('''
      CREATE TABLE credits(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        amount REAL NOT NULL,
        label TEXT NOT NULL,
        date TEXT,
        created_at TEXT NOT NULL
      )
    ''');
  }


  Future<int> createLoan(Map<String, dynamic> loan) async {
    print('DatabaseHelper.createLoan called with loan: $loan');
    try {
      final db = await instance.database;
      print('Got database instance');
      final result = await db.insert('loans', loan);
      print('Insert completed with result: $result');
      return result;
    } catch (e) {
      print('Error in createLoan: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllLoans() async {
    final db = await instance.database;
    return await db.query('loans', orderBy: 'created_at DESC');
  }

  Future<void> deleteLoan(int id) async {
    final db = await database;
    await db.delete(
      'loans',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<double> getTotalMonthlyCommitment() async {
    final db = await database;
    final result = await db.rawQuery('SELECT SUM(monthly_payment) as total FROM loans');
    return result.first['total'] as double? ?? 0.0;
  }

  Future<int> createCredit(Map<String, dynamic> credit) async {
    final db = await database;
    return await db.insert('credits', credit);
  }

  Future<List<Map<String, dynamic>>> getCredits() async {
    final db = await database;
    return await db.query('credits', orderBy: 'created_at DESC');
  }

  Future<int> insertCredit(Map<String, dynamic> credit) async {
    print('DatabaseHelper.insertCredit called with credit: $credit');
    try {
      final db = await instance.database;
      print('Got database instance');
      final result = await db.insert('credits', credit);
      print('Insert completed with result: $result');
      return result;
    } catch (e) {
      print('Error in insertCredit: $e');
      rethrow;
    }
  }

  // Delete credit
  Future<int> deleteCredit(int id) async {
    final db = await database;
    return await db.delete('credits', where: 'id = ?', whereArgs: [id]);
  }

    // Get all credits
  Future<List<Map<String, dynamic>>> getAllCredits() async {
    final db = await database;
    return await db.query('credits', orderBy: 'created_at DESC');
  }

  Future<double> getTotalCreditCardUsage() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT SUM(amount) as total FROM credits
    ''');
    return result.first['total'] as double? ?? 0.0;
  }
} 