import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final VoidCallback onOpenMovies;

  const HomePage({super.key, required this.onOpenMovies});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Cineminha',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Bem-vindo ao Cineminha\n\nToque em "Meus Filmes" para gerenciar seus Filmes Favoritos!.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onOpenMovies,
                child: const Text('Meus Filmes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
