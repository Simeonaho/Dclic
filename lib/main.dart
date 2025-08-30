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
      home: const PageAccueil(),
    );
  }
}

class PageAccueil extends StatelessWidget {
  const PageAccueil({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestion des rédacteurs"),
        backgroundColor: Colors.pink,
        centerTitle: true,
      ),
      body: const RedacteurInterface(),
    );
  }
}

class RedacteurInterface extends StatefulWidget {
  const RedacteurInterface({super.key});

  @override
  State<RedacteurInterface> createState() => _RedacteurInterfaceState();
}

class _RedacteurInterfaceState extends State<RedacteurInterface> {
  // Contrôleurs pour les champs de texte
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();

  // Singleton de la base de données
  final DatabaseManager _dbManager = DatabaseManager.instance;

  // Liste des rédacteurs (Future)
  late Future<List<Redacteur>> _redacteursFuture = Future.value([]);

  @override
  void initState() {
    super.initState();
    _loadRedacteurs();
  }

  // Charger les rédacteurs
  void _loadRedacteurs() {
    setState(() {
      _redacteursFuture = _dbManager.getAllRedacteurs();
    });
  }

  // Ajouter un rédacteur
  Future<void> _ajouterRedacteur() async {
    final nom = _nomController.text.trim();
    final prenom = _prenomController.text.trim();
    final email = _emailController.text.trim();

    if (nom.isEmpty || prenom.isEmpty || email.isEmpty) return;

    final nouveau = Redacteur.sansId(nom: nom, prenom: prenom, email: email);
    await _dbManager.insertRedacteur(nouveau);

    _nomController.clear();
    _prenomController.clear();
    _emailController.clear();

    _loadRedacteurs();
  }

  // Supprimer un rédacteur avec confirmation
  Future<void> _confirmerSuppression(Redacteur r) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation'),
        content: Text('Voulez-vous vraiment supprimer ${r.nom} ${r.prenom} ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Supprimer')),
        ],
      ),
    );

    if (confirm == true && r.id != null) {
      await _dbManager.deleteRedacteur(r.id!);
      _loadRedacteurs();
    }
  }

  // Modifier un rédacteur via boîte de dialogue
  Future<void> _modifierRedacteur(Redacteur r) async {
    final nomController = TextEditingController(text: r.nom);
    final prenomController = TextEditingController(text: r.prenom);
    final emailController = TextEditingController(text: r.email);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier le rédacteur'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nomController, decoration: const InputDecoration(labelText: 'Nom')),
            TextField(controller: prenomController, decoration: const InputDecoration(labelText: 'Prénom')),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              final updated = Redacteur(
                id: r.id,
                nom: nomController.text.trim(),
                prenom: prenomController.text.trim(),
                email: emailController.text.trim(),
              );
              await _dbManager.updateRedacteur(updated);
              Navigator.pop(context);
              _loadRedacteurs();
            },
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Champs texte pour ajouter un rédacteur
          TextField(
            controller: _nomController,
            decoration: const InputDecoration(labelText: 'Nom'),
          ),
          TextField(
            controller: _prenomController,
            decoration: const InputDecoration(labelText: 'Prénom'),
          ),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          const SizedBox(height: 10),
          // Bouton Ajouter un rédacteur
          ElevatedButton.icon(
            onPressed: _ajouterRedacteur,
            icon: const Icon(Icons.add),
            label: const Text('Ajouter un Rédacteur'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
          // Liste des rédacteurs
          Expanded(
            child: FutureBuilder<List<Redacteur>>(
              future: _redacteursFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erreur : ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Aucun rédacteur trouvé'));
                }

                final redacteurs = snapshot.data!;

                return ListView.builder(
                  itemCount: redacteurs.length,
                  itemBuilder: (context, index) {
                    final r = redacteurs[index];
                    return ListTile(
                      title: Text('${r.nom} ${r.prenom}'),
                      subtitle: Text(r.email),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _modifierRedacteur(r),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmerSuppression(r),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _dbManager.close(); // optionnel
    super.dispose();
  }
}

