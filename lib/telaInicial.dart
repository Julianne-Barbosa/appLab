import 'package:applab/telaChat.dart';
import 'package:applab/telaDesafios.dart';
import 'package:applab/telasAgua/telaAgua.dart';
import 'package:applab/telaConfiguracoes.dart';
import 'package:applab/telasExercicios/telaExercicios.dart';
import 'package:applab/telasSono/telaLembretesSono.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TelaInicial extends StatefulWidget {
  const TelaInicial({super.key});

  @override
  State<TelaInicial> createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {
  String? _nomeUsuario;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _buscarNomeUsuario();
  }

  Future<void> _buscarNomeUsuario() async {
    User? usuario = FirebaseAuth.instance.currentUser;
    if (usuario != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(usuario.uid)
          .get();

      if (doc.exists) {
        setState(() {
          _nomeUsuario = doc['nome'];
          _carregando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0056D2), Color(0xFF63D4F2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text("VITA", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$_nomeUsuario',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            SizedBox(height: 10),
            Text("Como podemos te ajudar hoje?",
                style: theme.textTheme.bodyLarge),
            SizedBox(height: 30),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                children: [
                  _cardAtalho(
                    titulo: "Sono",
                    icone: Icons.bedtime,
                    cor: Colors.deepPurpleAccent,
                    destino: TelaLembretesSono(),
                  ),
                  _cardAtalho(
                    titulo: "Água",
                    icone: Icons.water_drop,
                    cor: Colors.lightBlue,
                    destino: TelaAgua(),
                  ),
                  _cardAtalho(
                    titulo: "Exercícios",
                    icone: Icons.fitness_center,
                    cor: Colors.blueGrey,
                    destino: TelaExercicios(),
                  ),
                  _cardAtalho(
                    titulo: "Desafios",
                    icone: Icons.emoji_events_rounded,
                    cor: Colors.orangeAccent,
                    destino: TelaDesafios(),
                  ),
                  _cardAtalho(
                    titulo: "Chat",
                    icone: Icons.chat_bubble,
                    cor: Colors.pinkAccent,
                    destino: TelaChat(),
                  ),
                  _cardAtalho(
                    titulo: "Perfil",
                    icone: Icons.person,
                    cor: Colors.teal,
                    destino: TelaConfiguracoes(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardAtalho({
    required String titulo,
    required IconData icone,
    required Color cor,
    required Widget destino,
  }) {
    return GestureDetector(
      onTap: () => _abreTela(context, destino),
      child: Container(
        decoration: BoxDecoration(
          color: cor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cor, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icone, size: 50, color: cor),
            const SizedBox(height: 12),
            Text(
              titulo,
              style: TextStyle(
                fontSize: 18,
                color: cor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _abreTela(BuildContext ctx, Widget page) {
    Navigator.push(ctx, MaterialPageRoute(builder: (_) => page));
  }
}
