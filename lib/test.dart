import 'package:flutter/material.dart';

class PageBienvenue extends StatelessWidget {
  final String nomUtilisateur; // Le nom de l'utilisateur pour l'afficher sur la page de bienvenue

  // Constructeur de la classe
  PageBienvenue({required this.nomUtilisateur});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenue'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Texte d'accueil personnalisé
            Text(
              'Bienvenue, $nomUtilisateur !',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.0),
            // Bouton pour revenir à la page précédente
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Retour'),
            ),
          ],
        ),
      ),
    );
  }
}
