import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Acceuil extends StatefulWidget {
  final String nomUtilisateur;
  final User? user;

  Acceuil({required this.nomUtilisateur, required this.user});

  @override
  AcceuilState createState() => AcceuilState();
}

class AcceuilState extends State<Acceuil> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _showProjetsResponsable = true;
  String nomProjet = '';
  String descriptionProjet = '';
  String searchText = '';
  bool _isSearchBarVisible = false; // Nouvel attribut pour contrôler la visibilité de la barre de recherche
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        // Contenu du Drawer
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Colors.white, // Fond en blanc
              ),
              arrowColor: Colors.black,
              accountName: Text(
                "Nom de l'utilisateur",
                style: TextStyle(
                  color: Colors.black,
                ),
              ), // Remplacez par le nom de l'utilisateur
              accountEmail: Text(
                widget.nomUtilisateur,
                style: TextStyle(
                  color: Colors.black,
                ),
              ), // Remplacez par l'e-mail de l'utilisateur
              currentAccountPicture: CircleAvatar(
                backgroundImage: AssetImage('images/logo.jpg'), // Remplacez par l'image de l'utilisateur
              ),

            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Accueil'),
              onTap: () {
                // Ajoutez ici la logique pour la navigation vers l'écran d'accueil
                Navigator.pop(context); // Fermer le Drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Paramètres'),
              onTap: () {
                // Ajoutez ici la logique pour la navigation vers l'écran de paramètres
                Navigator.pop(context); // Fermer le Drawer
              },
            ),
            // Ajoutez d'autres éléments de liste pour les autres options du Drawer
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: _isSearchBarVisible // Afficher la barre de recherche si _isSearchBarVisible est vrai
            ? TextField(
          onChanged: (value) {
            setState(() {
              searchText = value;
            });
          },
          decoration: InputDecoration(
            hintText: _showProjetsResponsable ? 'Rechercher un projet personnel' : 'Rechercher un projet en participation',
          ),
        )
            : Center(
              child: Text('Scrum-Manager', style: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),),
            ),

        actions: [
          IconButton(
            color: Colors.black,
            onPressed: () {
              setState(() {
                _isSearchBarVisible = !_isSearchBarVisible; // Inverser la visibilité de la barre de recherche
                searchText = ''; // Réinitialiser le texte de recherche lorsque la barre de recherche est affichée
              });
            },
            icon: Icon(_isSearchBarVisible ? Icons.close : Icons.search,),
          ),
        ],
      ),
      body: _showProjetsResponsable ? _buildProjetsResponsable() : _buildProjetsParticipation(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_showProjetsResponsable) {
            // Afficher le formulaire pour créer un nouveau projet
            showDialog(
              context: context,
              builder: (context) => _buildNouveauProjetForm(),
            );
          } else {
            _showSearchBar();
            // Ajouter la logique pour créer un projet pour la liste des projets auxquels l'utilisateur participe
            // Vous pouvez utiliser un formulaire ou une boîte de dialogue pour permettre à l'utilisateur de saisir les détails du nouveau projet
          }
        },
        child: Icon(Icons.add),
      ),
      persistentFooterButtons: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  _showProjetsResponsable = true;
                  _showProjetsResponsable? Colors.blue : Colors.black;
                });
              },
              icon: Icon(Icons.assignment_turned_in),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _showProjetsResponsable = false;
                  _showProjetsResponsable? Colors.black : Colors.blue;
                });
              },
              icon: Icon(Icons.group),
            ),
          ],
        ),
      ],
    );
  }


  Widget _buildProjetsResponsable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 15.0),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('utilisateurs').doc(widget.user?.uid).collection('projetResp').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final projetsSnapshots = snapshot.data!.docs;
                // Filtrer les projets en fonction du texte de recherche
                List<QueryDocumentSnapshot> projetsFiltres = projetsSnapshots.where((projet) {
                  final nomProjet = projet.get('nom').toString().toLowerCase();
                  return nomProjet.contains(searchText.toLowerCase());
                }).toList();

                if (projetsFiltres.isEmpty) {
                  return Center(
                    child: Text("Aucun projet trouvé"),
                  );
                }

                return ListView.builder(
                  itemCount: projetsFiltres.length,
                  itemBuilder: (context, index) {
                    final projet = projetsFiltres[index];
                    final nomProjet = projet.get('nom') ?? "Nom du projet non disponible";
                    final descriptionProjet = projet.get('description') ?? "Description du projet non disponible";
                    final dateProjet = DateTime.now().toString().substring(0, 10); // Obtenir la date du jour sous forme "aaaa-mm-jj"
                    final tauxEvolutionProjet = "60%"; // Remplacer cette valeur par le taux d'évolution du projet récupéré depuis Firebase
                    final tauxEvolutionValue = 60.0; // Remplacer cette valeur par la valeur réelle du taux d'évolution

                    return Card(
                      elevation: 8,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              dateProjet,
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  nomProjet,
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              descriptionProjet,
                              style: TextStyle(
                                fontSize: 16.0,
                                height: 1.5,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              "$tauxEvolutionProjet",
                              style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          LinearProgressIndicator(
                            value: tauxEvolutionValue / 100.0, // La valeur doit être entre 0 et 1
                            backgroundColor: Colors.grey[300], // Couleur de fond de la barre de progression
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue), // Couleur de la barre de progression
                          ),
                          SizedBox(height: 10.0), // Espacement entre la barre de progression et les icônes

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildIconButtonWithCounter(Icons.share, "10"), // Remplacez "10" par le nombre souhaité
                              _buildIconButtonWithCountercomment(Icons.comment, "5"), // Remplacez "5" par le nombre souhaité
                              _buildIconButtonWithCounterfavorite(Icons.group_add, "15"), // Remplacez "15" par le nombre souhaité
                              _buildIconButtonWithCounterlike(Icons.favorite_border, "7"), // Remplacez "7" par le nombre souhaité
                            ],
                          ),
                          SizedBox(height: 25.0), // Espacement entre chaque projet
                        ],
                      ),
                    );
                  },
                );
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
      ],
    );
  }



// Méthode pour afficher la barre de recherche
  void _showSearchBar() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Rechercher un projet"),
          content: TextField(
            onChanged: (value) {
              // Ajoutez ici la logique de recherche
              setState(() {
                searchText = value;
              });
            },
            decoration: InputDecoration(
              labelText: 'Nom du projet',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () {
                // Ajoutez ici la logique pour effectuer la recherche
                // Vous pouvez utiliser _searchemplText pour obtenir le texte saisi dans la barre de recherche
                // et effectuer la recherche en utilisant ce texte pour filtrer les projets
                Navigator.of(context).pop();
              },
              child: Text("Rechercher"),
            ),
          ],
        );
      },
    );
  }




  Widget _buildProjetsParticipation() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('utilisateurs').doc(widget.user?.uid).collection('projetEmpl').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final projetsSnapshots = snapshot.data!.docs;
          if (projetsSnapshots.isNotEmpty) {
            return ListView.builder(
              itemCount: projetsSnapshots.length,
              itemBuilder: (context, index) {
                final projet = projetsSnapshots[index];
                final nomProjet = projet.get('nom') ?? "Nom du projet non disponible";
                final descriptionProjet = projet.get('description') ?? "Description du projet non disponible";
                final dateProjet = DateTime.now().toString().substring(0, 10); // Obtenir la date du jour sous forme "aaaa-mm-jj"
                final tauxEvolutionProjet = "60%"; // Remplacer cette valeur par le taux d'évolution du projet récupéré depuis Firebase

                return ListTile(
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          nomProjet.length > 20 ? nomProjet.substring(0, 20) + "..." : nomProjet,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        dateProjet,
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          descriptionProjet,
                          style: TextStyle(
                            fontSize: 16.0,
                            height: 1.5,
                            color: Colors.green,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          "Taux d'évolution : $tauxEvolutionProjet",
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.green, // Couleur du taux d'évolution, vous pouvez ajuster selon vos préférences
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Ajoutez ici d'autres informations sur chaque projet, telles que la date, le statut, etc.
                  onLongPress: () {
                    _showContextMenu(projet);
                  },
                );
              },
            );
          } else {
            // Aucun projet trouvé
            return Center(
              child: Text("Aucun projet trouvé"),
            );
          }
        } else {
          // Chargement des données
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }


  void _showContextMenu(DocumentSnapshot projet) {
    final nomProjet = projet.get('nom') ?? "Nom du projet non disponible";
    final descriptionProjet = projet.get('description') ?? "Description du projet non disponible";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: Text("Quitter le projet"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Nom du projet : $nomProjet"),
              SizedBox(height: 8.0),
              Text("Description du projet : $descriptionProjet"),
              SizedBox(height: 16.0),
              TextField(
                decoration: InputDecoration(
                  labelText: "Raison du départ",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                minLines: 2,
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                // Logique pour quitter le projet avec la raison donnée
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text("Quitter"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text("Annuler"),
            ),
          ],
        );
      },
    );
  }



  Widget _buildNouveauProjetForm() {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25.0), // Ajustez le rayon selon vos préférences
      ),
      title: Text("Nouveau Projet"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            onChanged: (value) {
              nomProjet = value;
            },
            decoration: InputDecoration(
              labelText: 'Nom du projet',
            ),
          ),
          SizedBox(height: 10),
          TextField(
            onChanged: (value) {
              descriptionProjet = value;
            },
            decoration: InputDecoration(
              labelText: 'Description du projet',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("Annuler"),
        ),
        ElevatedButton(
          onPressed: () async {
            _showProjetsResponsable
                ? await _firestore
                .collection('utilisateurs')
                .doc(widget.user?.uid)
                .collection('projetResp')
                .doc(nomProjet)
                .set({
              'nom': nomProjet,
              'description': descriptionProjet,
            })
                : await _firestore
                .collection('utilisateurs')
                .doc(widget.user?.uid)
                .collection('projetEmpl')
                .doc(nomProjet)
                .set({
              'nom': nomProjet,
              'description': descriptionProjet,
            });

            // Fermer le formulaire
            Navigator.of(context).pop();
          },
          child: Text("Créer"),
        ),
      ],
    );
  }

  // Méthode pour créer un IconButton avec un compteur à côté
  Widget _buildIconButtonWithCounter(IconData icon, String count) {
    return Row(
      children: [
        IconButton(
          iconSize: 15.0, // Définir la taille souhaitée des icônes ici
          icon: Icon(icon),
          onPressed: () {
            // Ajouter la logique pour chaque icône ici
          },
        ),
        Text(count),
      ],
    );
  }

  Widget _buildIconButtonWithCounterfavorite(IconData icon, String count) {
    return Row(
      children: [
        IconButton(
          iconSize: 15.0, // Définir la taille souhaitée des icônes ici
          icon: Icon(icon),
          onPressed: () {
            // Ajouter la logique pour chaque icône ici
          },
        ),
        Text(count),
      ],
    );
  }

  Widget _buildIconButtonWithCountercomment(IconData icon, String count) {
    return Row(
      children: [
        IconButton(
          iconSize: 15.0, // Définir la taille souhaitée des icônes ici
          icon: Icon(icon),
          onPressed: () {
            // Ajouter la logique pour chaque icône ici
          },
        ),
        Text(count),
      ],
    );
  }

  Widget _buildIconButtonWithCounterlike(IconData icon, String count) {
    return Row(
      children: [
        IconButton(
          iconSize: 15.0, // Définir la taille souhaitée des icônes ici
          icon: Icon(icon),
          onPressed: () {
            // Ajouter la logique pour chaque icône ici
          },
        ),
        Text(count),
      ],
    );
  }

}

