import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;

  DBHelper._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'vita.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _criarTabelas,
      onUpgrade: _atualizarTabelas,
    );
  }

  Future<void> _criarTabelas(Database db, int version) async {
    await db.execute('''
      CREATE TABLE sono_registros (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT,
        horaDormir INTEGER,
        minutoDormir INTEGER,
        horaAcordar INTEGER,
        minutoAcordar INTEGER,
        horasDormidas TEXT,
        qualidadeSono INT
      )
    ''');

    await db.execute('''
      CREATE TABLE sono_lembretes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          data TEXT,
          horaDormir INTEGER,
          minutoDormir INTEGER,
          horaAcordar INTEGER,
          minutoAcordar INTEGER,
          duracao TEXT,
          lembreteAtivo INTEGER,
          tempoAntesDormir INTEGER
        );

    ''');
  }

  Future<void> _atualizarTabelas(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
    }
  }

  // ==================== REGISTROS DE SONO ====================

  Future<void> salvarRegistroSono(Map<String, dynamic> dados) async {
    final db = await database;

    final resultado = await db.query(
      'sono_registros',
      where: 'data = ?',
      whereArgs: [dados['data']],
    );

    if (resultado.isNotEmpty) {
      await db.update(
        'sono_registros',
        dados,
        where: 'data = ?',
        whereArgs: [dados['data']],
      );
    } else {
      await db.insert(
        'sono_registros',
        dados,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<List<Map<String, dynamic>>> buscarRegistrosSono() async {
    final db = await database;
    return await db.query('sono_registros', orderBy: 'data DESC');
  }

  Future<Map<String, dynamic>?> obterUltimoRegistroSono() async {
    final db = await database;
    final resultado = await db.query(
      'sono_registros',
      orderBy: 'data DESC',
      limit: 1,
    );

    if (resultado.isNotEmpty) {
      return resultado.first;
    } else {
      return null;
    }
  }

  Future<void> atualizarRegistroSono(int id, Map<String, dynamic> novosDados) async {
    final db = await database;
    await db.update(
      'sono_registros',
      novosDados,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deletarRegistroSono(int id) async {
    final db = await database;
    await db.delete(
      'sono_registros',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deletarTodosRegistrosSono() async {
    final db = await database;
    await db.delete('sono_registros');
  }

  // ==================== LEMBRETES DE SONO ====================

  Future<void> salvarLembreteSono(Map<String, dynamic> dados) async {
    final db = await database;

    final resultado = await db.query(
      'sono_lembretes',
      where: 'data = ?',
      whereArgs: [dados['data']],
    );

    if (resultado.isNotEmpty) {
      await db.update(
        'sono_lembretes',
        dados,
        where: 'data = ?',
        whereArgs: [dados['data']],
      );
    } else {
      await db.insert(
        'sono_lembretes',
        dados,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<List<Map<String, dynamic>>> buscarLembretesSono() async {
    final db = await database;
    return await db.query('sono_lembretes', orderBy: 'data DESC');
  }

  Future<void> deletarLembreteSono(int id) async {
    final db = await database;
    await db.delete(
      'sono_lembretes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deletarTodosLembretesSono() async {
    final db = await database;
    await db.delete('sono_lembretes');
  }
}
