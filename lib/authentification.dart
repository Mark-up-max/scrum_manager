import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:scrum_manager/test.dart';
import 'package:scrum_manager/acceuil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class PageInscriptionConnexion extends StatefulWidget {
  @override
  _PageInscriptionConnexionState createState() => _PageInscriptionConnexionState();
}

class _PageInscriptionConnexionState extends State<PageInscriptionConnexion> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _motDePasseController = TextEditingController();
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool _connexionMode = false; // Variable pour suivre le mode d'affichage (inscription ou connexion)
  bool _passwordVisible = false; // Variable pour suivre l'état de visibilité du mot de passe
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image circulaire au-dessus du titre "Scrum-Manager"
              CircleAvatar(
                radius: 40.0, // Ajustez le rayon selon votre préférence
                backgroundImage: AssetImage('images/logo.jpg'), // Remplacez 'chemin_vers_votre_image' par le chemin de votre image
              ),
              // Titre "Scrum-Manager" avec une police et une taille adaptée
              Text(
                "Scrum-Manager",
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 50.0),
              // Champ de saisie pour l'email
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  icon: Icon(Icons.email),
                ),
              ),
              SizedBox(height: 20.0),
              // Champ de saisie pour le mot de passe
              TextField(
                controller: _motDePasseController,
                obscureText: !_passwordVisible, // Masquer ou montrer le mot de passe en fonction de l'état de la variable _passwordVisible
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  icon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 20.0),

              // Bouton d'inscription ou de connexion en fonction du mode
              ElevatedButton(
                onPressed: () {
                  if (_connexionMode) {
                    // Appeler la méthode de connexion si le mode est "connexion"
                    connexionUtilisateur(_emailController.text, _motDePasseController.text);
                  } else {
                    // Appeler la méthode d'inscription si le mode est "inscription"
                    inscriptionUtilisateur(_emailController.text, _motDePasseController.text);
                    collectionUser(_emailController.text, _motDePasseController.text);
                  }
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue, // Couleur de fond du bouton
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), // Ajustez le rayon selon vos préférences, il devrait être le même que pour le Card
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0), // Espacement autour du texte
                ),
                child: Text(_connexionMode ? 'Connexion' : "S'inscrire"),
              ),
              SizedBox(height: 60.0),
              ElevatedButton(
                onPressed: _isLoading ? null : () {
                  // ... Votre code de connexion ...
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  primary: Colors.white, // Couleur de fond du bouton
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0), // Ajustez le rayon selon vos préférences
                  ),
                ),
                child: _isLoading
                    ? Container(
                  color: Colors.white, // Fond blanc
                  padding: EdgeInsets.all(20.0), // Espacement intérieur pour le CircularProgressIndicator
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                )
                    : Text(""), // Remplacez "Connexion" par le texte souhaité
              )
            ],
          ),
        ),
      ),

      // Bouton de switch en bas de l'écran sans marge
      persistentFooterButtons: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _connexionMode = !_connexionMode;
                    _emailController.clear();
                    _motDePasseController.clear();
                  });
                },
                child: Text(_connexionMode ? 'S\'inscrire' : 'Se connecter'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Méthode pour inscrire un nouvel utilisateur avec email et mot de passe
  Future<void> inscriptionUtilisateur(String email, String motDePasse) async {
    setState(() {
      _isLoading = true;
    });
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: motDePasse,
      );
      User? user = userCredential.user;

      // Inscription réussie
      if (user != null) {
        setState(() {
          _isLoading = false;
        });
        // Afficher une SnackBar avec un message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Inscription réussie pour l\'utilisateur avec l\'adresse email : ${user.email}'),
            backgroundColor: Colors.green,
          ),
        );

        // Rediriger vers la page des projets
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PageBienvenue(nomUtilisateur: email),
          ),
        );
      } else {
        setState(() {
          _isLoading = false;
        });
        // Afficher une SnackBar avec un message d'échec
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('L\'inscription a échoué. Veuillez réessayer.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Gestion des erreurs lors de l'inscription
      print("Erreur lors de l'inscription : $e");
      // Afficher une SnackBar avec un message d'échec
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('L\'inscription a échoué. Veuillez réessayer.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Méthode pour connecter un utilisateur avec email et mot de passe
  Future<void> connexionUtilisateur(String email, String motDePasse) async {

    // Afficher l'image de chargement (ou une image statique)
    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: motDePasse,
      );
      User? user = userCredential.user;

      // Connexion réussie
      if (user != null) {
        setState(() {
          _isLoading = false;
        });
        // Afficher une SnackBar avec un message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connexion réussie pour l\'utilisateur avec l\'adresse email : ${user.email}'),
            backgroundColor: Colors.green,
          ),
        );

        // Rediriger vers la page des projets
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Acceuil(nomUtilisateur: email, user: user,),
          ),
        );
      } else {
        // Afficher une SnackBar avec un message d'échec
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('La connexion a échoué. Veuillez vérifier votre email et mot de passe.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Gestion des erreurs lors de la connexion
      print("Erreur lors de la connexion : $e");
      // Afficher une SnackBar avec un message d'échec
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('La connexion a échoué. Veuillez vérifier votre email et mot de passe.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> collectionUser(String email, String motDePasse) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: motDePasse,
      );
      User? user = userCredential.user;

      if (user != null) {
        // Créer un nouveau document avec l'ID de l'utilisateur dans la collection "utilisateurs"
        await _firestore.collection('utilisateurs').doc(user.uid).set({
          'email': user.email,
          // Ajoutez ici d'autres informations sur l'utilisateur si nécessaire
        });

        // Créer une nouvelle collection "projetResp" sur le document de l'utilisateur
        await _firestore.collection('utilisateurs').doc(user.uid).collection('projetResp').add({
          // Ajoutez ici les informations des projets personnels de l'utilisateur
        });
        await _firestore.collection('utilisateurs').doc(user.uid).collection('projetEmpl').add({
          // Ajoutez ici les informations des projets personnels de l'utilisateur
        });

        print("Inscription réussie pour l'utilisateur avec l'adresse email : $email");
      } else {
        print("L'utilisateur nouvellement inscrit est null.");
      }
    } catch (e) {
      // Gestion des erreurs lors de l'inscription
      print("Erreur lors de l'inscription : $e");
      // Vous pouvez personnaliser la gestion des erreurs selon vos besoins, par exemple, afficher un message d'erreur à l'utilisateur.
    }
  }




}


