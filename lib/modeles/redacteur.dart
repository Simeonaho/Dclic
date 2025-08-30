import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// ---------------------
/// Modèle Redacteur
/// ---------------------
class Redacteur {
  final int? id;
  final String nom;
  final String prenom;
  final String email;

  Redacteur({
    this.id,
    required this.nom,
    required this.prenom,
    required this.email,
  });

  // Constructeur secondaire (sans id)
  Redacteur.sansId({
    required this.nom,
    required this.prenom,
    required this.email,
  }) : id = null;

  // Conversion en Map (utile pour sqflite)
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'nom': nom,
      'prenom': prenom,
      'email': email,
    };
    if (id != null) map['id'] = id;
    return map;
  }

  // Créer un objet depuis une Map
  factory Redacteur.fromMap(Map<String, dynamic> map) {
    return Redacteur(
      id: map['id'],
      nom: map['nom'],
      prenom: map['prenom'],
      email: map['email'],
    );
  }

  @override
  String toString() {
    return 'Redacteur{id: $id, nom: $nom, prenom: $prenom, email: $email}';
  }
}

/// ---------------------
/// DatabaseManager 
/// ---------------------
class DatabaseManager {
  static final DatabaseManager instance = DatabaseManager._internal();
  DatabaseManager._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB("redacteurs_database.db");
    return _database!;
  }

  // Initialisation de la DB
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // Création de la table
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE redacteurs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT,
        prenom TEXT,
        email TEXT
      )
    ''');
  }

  /// ---------------------
  /// CRUD
  /// ---------------------

  Future<List<Redacteur>> getAllRedacteurs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('redacteurs');
    return maps.map((map) => Redacteur.fromMap(map)).toList();
  }

  Future<int> insertRedacteur(Redacteur redacteur) async {
    final db = await database;
    return await db.insert(
      'redacteurs',
      redacteur.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateRedacteur(Redacteur redacteur) async {
    final db = await database;
    return await db.update(
      'redacteurs',
      redacteur.toMap(),
      where: 'id = ?',
      whereArgs: [redacteur.id],
    );
  }

  Future<int> deleteRedacteur(int id) async {
    final db = await database;
    return await db.delete(
      'redacteurs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}
