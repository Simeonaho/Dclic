import 'package:flutter/material.dart';
import 'Modele/Redacteur.dart'; // Importation du modèle Redacteur


void main() {
  runApp(const MonApplication());
}

class MonApplication extends StatelessWidget {
  const MonApplication({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mon Application',
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.pink,
          centerTitle: true,
          title: const WhiteText('Gestion des rédacteurs'), // Utilisation du widget WhiteText pour le titre
          leading: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.menu, color: Colors.white),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search, color: Colors.white),
            )
          ],
        ),
        body: const RedacteurInterface(), // Utilisation de RedacteurInterface dans le corps de la page
      ),
    );
  }
}

// Classe RedacteurInterface pour afficher et interagir avec les rédacteurs
class RedacteurInterface extends StatefulWidget {
  const RedacteurInterface({super.key});

  @override
  State<RedacteurInterface> createState() => _RedacteurInterfaceState();
}

class _RedacteurInterfaceState extends State<RedacteurInterface> {
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  late Future<void> _initializeDbFuture; // Future pour initialiser la base de données
  late Future<List<Redacteur>> _redacteursFuture; // Future pour obtenir la liste des rédacteurs

  @override
  void initState() {
    super.initState();

    _initializeDbFuture = DatabaseManager().initialize(); // Initialisation de la base de données
    _redacteursFuture = DatabaseManager().getAllRedacteurs(); // Récupération de tous les rédacteurs depuis la base de données
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializeDbFuture, // Future pour initialiser la base de données
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Affiche un indicateur de chargement pendant l'initialisation de la base de données
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // Affiche un message d'erreur si l'initialisation échoue
          return Center(child: Text('Erreur : ${snapshot.error}'));
        } else {
          // Si l'initialisation réussit, affiche l'interface utilisateur
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // TextFields pour saisir les données du rédacteur
                TextField(
                  controller: _nomController,
                  decoration: const InputDecoration(labelText: 'Nom'),
                ),
                const SizedBox(height: 20.0),
                TextField(
                  controller: _prenomController,
                  decoration: const InputDecoration(labelText: 'Prénom'),
                ),
                const SizedBox(height: 20.0),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 20.0),
                ElevatedButton.icon(
                  onPressed: () {
                    // Récupération des valeurs des champs de saisie
                    String nom = _nomController.text;
                    String email = _emailController.text;
                    String prenom = _prenomController.text;

                    // Création d'un objet Redacteur avec les données saisies
                    Redacteur redacteur = Redacteur.withoutId(
                      nom: nom,
                      prenom: prenom,
                      email: email,
                    );

                    // Insertion du rédacteur dans la base de données
                    DatabaseManager().insertRedacteur(redacteur).then((_) {
                      // Affichage d'un message de succès
                      if (context.mounted) {
                        
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Rédacteur ajouté avec succès !'),
                        ),
                      );
                      }

                      // Effacement des champs de saisie
                      _nomController.clear();
                      _prenomController.clear();
                      _emailController.clear();

                      // Actualisation de la liste des rédacteurs affichée
                      setState(() {
                        _redacteursFuture = DatabaseManager().getAllRedacteurs();
                      });
                    }).catchError((error) {
                      // Affichage d'un message d'erreur s'il y a un problème lors de l'ajout du rédacteur
                      if (context.mounted) {
                        
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erreur lors de l\'ajout du rédacteur: $error'),
                        ),
                      );
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const WhiteText('Ajouter un Rédacteur'),
                ),
                const SizedBox(height: 20.0),
                // FutureBuilder pour afficher la liste des rédacteurs
                Expanded(
                  child: FutureBuilder<List<Redacteur>>(
                    future: _redacteursFuture, // Future pour obtenir la liste des rédacteurs
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        // Affiche un indicateur de chargement pendant la récupération des rédacteurs
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        // Affiche un message d'erreur si la récupération échoue
                        return Center(child: Text('Erreur : ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        // Affiche un message si aucun rédacteur n'est trouvé
                        return const Center(child: Text('Aucun rédacteur trouvé.'));
                      } else {
                        // Affiche la liste des rédacteurs récupérés
                        return ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final redacteur = snapshot.data![index];
                            return ListTile(
                              title: Text('${redacteur.nom} ${redacteur.prenom}'),
                              subtitle: Text(redacteur.email),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Bouton pour supprimer le rédacteur
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text('Supprimer le rédacteur'),
                                            content: const Text('Êtes-vous sûr de vouloir supprimer ce rédacteur ?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text('Annuler'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  // Suppression du rédacteur de la base de données
                                                  DatabaseManager().deleteRedacteur(redacteur.id!).then((_) {
                                                    // Actualisation de la liste des rédacteurs affichée
                                                    setState(() {
                                                      _redacteursFuture = DatabaseManager().getAllRedacteurs();
                                                    });
                                                    // Affichage d'un message de succès
                                                    if (context.mounted) {
                                                      
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(
                                                        content: Text('Rédacteur supprimé avec succès !'),
                                                      ),
                                                    );
                                                    Navigator.of(context).pop(); // Fermer la boîte de dialogue
                                                    }
                                                  }).catchError((error) {
                                                    // Affichage d'un message d'erreur s'il y a un problème lors de la suppression du rédacteur
                                                    if (context.mounted) {
                                                      
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text('Erreur lors de la suppression du rédacteur: $error'),
                                                      ),
                                                    );
                                                    }
                                                  });
                                                },
                                                child: const Text('Supprimer',style: TextStyle(color: Colors.pink)),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  // Bouton pour modifier le rédacteur
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () {
                                      _nomController.text = redacteur.nom;
                                      _prenomController.text = redacteur.prenom;
                                      _emailController.text = redacteur.email;

                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text('Modifier le rédacteur'),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
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
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text('Annuler',style: TextStyle(color: Colors.pink)),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  String nom = _nomController.text;
                                                  String prenom = _prenomController.text;
                                                  String email = _emailController.text;

                                                  Redacteur redacteurModifie = Redacteur(
                                                    id: redacteur.id,
                                                    nom: nom,
                                                    prenom: prenom,
                                                    email: email,
                                                  );

                                                  // Mise à jour du rédacteur dans la base de données
                                                  DatabaseManager().updateRedacteur(redacteurModifie).then((_) {
                                                    // Actualisation de la liste des rédacteurs affichée
                                                    setState(() {
                                                      _redacteursFuture = DatabaseManager().getAllRedacteurs();
                                                    });
                                                    // Affichage d'un message de succès
                                                    if (context.mounted) {
                                                     
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(
                                                        content: Text('Rédacteur modifié avec succès !'),
                                                      ),
                                                    );
                                                    Navigator.of(context).pop(); // Fermer la boîte de dialogue
                                                    }
                                                    // Effacement des champs de saisie
                                                    _nomController.clear();
                                                    _prenomController.clear();
                                                    _emailController.clear();
                                                  }).catchError((error) {
                                                    // Affichage d'un message d'erreur s'il y a un problème lors de la modification du rédacteur
                                                    if (context.mounted) {
                                                   
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text('Erreur lors de la modification du rédacteur: $error'),
                                                      ),
                                                    );
                                                    }
                                                  });
                                                },
                                                child: const Text('Modifier'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

// Classe text avec la couleur blanche
class WhiteText extends StatelessWidget {
  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final bool? softWrap;
  final TextOverflow? overflow;
  final double? textScaleFactor;
  final int? maxLines;

  const WhiteText(
      this.data, {
        super.key,
        this.style,
        this.textAlign,
        this.textDirection,
        this.softWrap,
        this.overflow,
        this.textScaleFactor,
        this.maxLines,
      });

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      style: const TextStyle(color: Colors.white).merge(style),
      textAlign: textAlign,
      textDirection: textDirection,
      softWrap: softWrap,
      overflow: overflow,
      maxLines: maxLines,
    );
  }
}
