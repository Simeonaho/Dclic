import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';


class Redacteur {
  int? id;
  String nom;
  String prenom;
  String email;

  // Constructeur avec tous les attributs
  Redacteur({
    this.id,
    required this.nom,
    required this.prenom,
    required this.email,
  });

  // Constructeur sans l'attribut id (pour l'insertion)
  Redacteur.sansId({
    required this.nom,
    required this.prenom,
    required this.email,
  });

  // Méthode pour convertir un objet Rédacteur en Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'email': email,
    };
  }

  // Méthode pour créer un Rédacteur à partir d'un Map
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


class DatabaseManager {
  static Database? _database;
  static const String _tableName = 'redacteurs';

  // Singleton pattern pour avoir une seule instance
  static final DatabaseManager _instance = DatabaseManager._internal();
  factory DatabaseManager() => _instance;
  DatabaseManager._internal();

  // Getter pour la base de données
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialisation de la base de données
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'redacteurs.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Création de la table
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        prenom TEXT NOT NULL,
        email TEXT NOT NULL
      )
    ''');
  }

  // Récupérer tous les rédacteurs
  Future<List<Redacteur>> getAllRedacteurs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_tableName);
    return List.generate(maps.length, (i) => Redacteur.fromMap(maps[i]));
  }

  // Insérer un rédacteur
  Future<int> insertRedacteur(Redacteur redacteur) async {
    final db = await database;
    return await db.insert(_tableName, redacteur.toMap());
  }

  // Mettre à jour un rédacteur
  Future<int> updateRedacteur(Redacteur redacteur) async {
    final db = await database;
    return await db.update(
      _tableName,
      redacteur.toMap(),
      where: 'id = ?',
      whereArgs: [redacteur.id],
    );
  }

  // Supprimer un rédacteur
  Future<int> deleteRedacteur(int id) async {
    final db = await database;
    return await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
