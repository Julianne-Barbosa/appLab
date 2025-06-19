import 'package:applab/telasConta/telaCadastro.dart';
import 'package:applab/telasConta/telaLogin.dart';
import 'package:applab/widgets/botoes.dart'; // Import do seu botão modernizado
import 'package:flutter/material.dart';
import '../widgets/widgetsImagem.dart';

class TelaConta extends StatefulWidget {
  const TelaConta({super.key});

  @override
  State<TelaConta> createState() => _TelaContaState();
}

class _TelaContaState extends State<TelaConta> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(),
    );
  }

  Widget _body() {
    return Container(
      width: double.infinity,
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
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(flex: 2),
              SuaImagem(
                caminhoArquivo: "assets/logo.png",
                alturaImagem: 180,
                larguraImagem: 180,
              ),
              Spacer(),
              Botoes(
                text: "Criar conta",
                width: double.infinity,
                onPressed: () => _abreTela(context, const TelaCadastro()),
                backgroundColor: const Color(0xFF0056D2),
                textColor: Colors.white,
                borderRadius: 12,
                icon: Icon(Icons.person_add, color: Colors.white),
                height: 50,
              ),
              SizedBox(height: 16),
              Botoes(
                text: "Entrar",
                width: double.infinity,
                onPressed: () => _abreTela(context, TelaLogin()),
                backgroundColor: Colors.white,
                textColor: Color(0xFF0056D2),
                borderRadius: 12,
                icon: const Icon(Icons.login, color: Color(0xFF0056D2)),
                height: 50,
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }

  void _abreTela(BuildContext ctx, Widget page) {
    Navigator.push(ctx, MaterialPageRoute(builder: (_) => page));
  }
}
