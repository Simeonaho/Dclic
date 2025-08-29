import 'package:flutter/material.dart';
import 'modeles/redacteur.dart';


void main() {
  runApp(const MonApp());
}


class MonApp extends StatelessWidget {
  const MonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Magazine',
      debugShowCheckedModeBanner: false,
      home:  RedacteurInterface(),
    );
  }
}


class RedacteurInterface extends StatefulWidget {
  @override
  _RedacteurInterfaceState createState() => _RedacteurInterfaceState();
}

class _RedacteurInterfaceState extends State<RedacteurInterface> {
  final DatabaseManager _databaseManager = DatabaseManager();
  List<Redacteur> _redacteurs = [];

  // Contrôleurs pour les champs de texte
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _chargerRedacteurs();
  }

  // Charger la liste des rédacteurs depuis la base de données
  Future<void> _chargerRedacteurs() async {
    final redacteurs = await _databaseManager.getAllRedacteurs();
    setState(() {
      _redacteurs = redacteurs;
    });
  }

  // Ajouter un rédacteur
  Future<void> _ajouterRedacteur() async {
    if (_nomController.text.isEmpty || 
        _prenomController.text.isEmpty || 
        _emailController.text.isEmpty) {
      _afficherMessage('Veuillez remplir tous les champs');
      return;
    }

    final redacteur = Redacteur.sansId(
      nom: _nomController.text,
      prenom: _prenomController.text,
      email: _emailController.text,
    );

    await _databaseManager.insertRedacteur(redacteur);
    _viderChamps();
    _chargerRedacteurs();
    _afficherMessage('Rédacteur ajouté avec succès');
  }

  // Modifier un rédacteur
  Future<void> _modifierRedacteur(Redacteur redacteur) async {
    final nomController = TextEditingController(text: redacteur.nom);
    final prenomController = TextEditingController(text: redacteur.prenom);
    final emailController = TextEditingController(text: redacteur.email);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modifier le Rédacteur'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomController,
              decoration: InputDecoration(labelText: 'Nom'),
            ),
            TextField(
              controller: prenomController,
              decoration: InputDecoration(labelText: 'Prénom'),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              redacteur.nom = nomController.text;
              redacteur.prenom = prenomController.text;
              redacteur.email = emailController.text;
              
              await _databaseManager.updateRedacteur(redacteur);
              Navigator.pop(context);
              _chargerRedacteurs();
              _afficherMessage('Rédacteur modifié avec succès');
            },
            child: Text('Modifier'),
          ),
        ],
      ),
    );
  }

  // Supprimer un rédacteur
  Future<void> _supprimerRedacteur(Redacteur redacteur) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmer la suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer ${redacteur.prenom} ${redacteur.nom} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _databaseManager.deleteRedacteur(redacteur.id!);
              Navigator.pop(context);
              _chargerRedacteurs();
              _afficherMessage('Rédacteur supprimé avec succès');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  // Vider les champs de saisie
  void _viderChamps() {
    _nomController.clear();
    _prenomController.clear();
    _emailController.clear();
  }

  // Afficher un message
  void _afficherMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,

        leading: IconButton(
          icon: Icon(Icons.menu),
          tooltip: 'Navigation menu',
          onPressed: () {
          },
        ),

        title: const Text('Gestion des rédacteurs'),
        centerTitle: true,

        actions: [
          IconButton(
            icon: Icon(Icons.search),
            tooltip: 'Search',
            onPressed: () {
          
            },
          ),
        ],
      ),
 

      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Formulaire d'ajout
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _nomController,
                      decoration: InputDecoration(
                        labelText: 'Nom',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _prenomController,
                      decoration: InputDecoration(
                        labelText: 'Prénom',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 15),
                    ElevatedButton.icon(
                      onPressed: _ajouterRedacteur,
                      icon: Icon(Icons.add),
                      label: Text('Ajouter un Rédacteur'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            
            // Liste des rédacteurs
            Expanded(
              child: _redacteurs.isEmpty
                  ? Center(
                      child: Text(
                        'Aucun rédacteur enregistré',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _redacteurs.length,
                      itemBuilder: (context, index) {
                        final redacteur = _redacteurs[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(
                                '${redacteur.prenom[0]}${redacteur.nom[0]}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              backgroundColor: Colors.blue,
                            ),
                            title: Text('${redacteur.prenom} ${redacteur.nom}'),
                            subtitle: Text(redacteur.email),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.orange),
                                  onPressed: () => _modifierRedacteur(redacteur),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _supprimerRedacteur(redacteur),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}