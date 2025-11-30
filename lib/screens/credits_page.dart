import 'package:flutter/material.dart';

class CreditsPage extends StatelessWidget {
  const CreditsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Créditos')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'Projeto Cineminha\n\nDesenvolvido por:\n- Maycon\n- Luiz Artur\n\nAPI: The Movie Database (TMDB).',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

}
