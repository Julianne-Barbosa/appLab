import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'telasConta/telaConta.dart';
import 'telaInicial.dart';
import 'widgets/widgetsImagem.dart';

class Home extends StatefulWidget {

  const Home({super.key});


  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();

    // Animação de fade-in para entrar no app
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _opacity = 1.0;
      });
    });

    Future.delayed(Duration(seconds: 3), () {
      User? usuario = FirebaseAuth.instance.currentUser;

      if (usuario != null) {
        // Se o usuário já está logado, direciona para a tela inicial
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => TelaInicial()),
        );
      } else {
        // Caso o usuário ainda não tenha entrado na conta
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => TelaConta()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF63D4F2),
              Color(0xFF0056D2),
            ],
          ),
        ),
        child: Center(
          child: AnimatedOpacity(
            opacity: _opacity,
            duration: Duration(seconds: 2),
            curve: Curves.easeInOut,
            child: SuaImagem(
              caminhoArquivo: 'assets/logo.png',
              alturaImagem: 250,
              larguraImagem: 250,
            ),
          ),
        ),
      ),
    );
  }
}
