import 'package:flutter/material.dart';

class ProfileSportMeet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Dados fictícios para exibir na página de perfil
    String nome = "João Silva";
    String imageUrl = "https://via.placeholder.com/150"; // URL para a imagem do perfil
    DateTime dataNascimento = DateTime(1990, 7, 25);
    String sexo = "Masculino";
    String desportoMaisJogado = "Futebol";
    int numeroJogos = 150;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profile",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w400, // Reduz a espessura do texto
          ),
        ),
        centerTitle: true, // Centraliza o título
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Imagem do perfil com espaçamento maior
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(imageUrl),
            ),
            SizedBox(height: 30), // Maior espaçamento entre a imagem e o nome
            
            // Nome
            Text(
              nome,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 20), // Espaçamento maior entre o nome e as informações abaixo
            
            // Data de nascimento
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cake, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  "Data de nascimento: ${dataNascimento.day}/${dataNascimento.month}/${dataNascimento.year}",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ],
            ),
            SizedBox(height: 20), // Espaçamento entre as linhas
            
            // Sexo
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  "Sexo: $sexo",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ],
            ),
            SizedBox(height: 20),
            
            // Desporto mais jogado
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sports_soccer, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  "Desporto mais jogado: $desportoMaisJogado",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ],
            ),
            SizedBox(height: 20),
            
            // Número de jogos já jogados
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sports, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  "Número de jogos: $numeroJogos",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
