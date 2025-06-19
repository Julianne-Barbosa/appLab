import 'package:flutter/material.dart';

class MeuTexto extends StatelessWidget {
  String texto = "";
  double tamanhoFonte = 12;
  Color corFundo = Colors.cyan;
  Color corFonte = Colors.cyan;
  MeuTexto(
    this.texto,
    this.corFundo,
    this.corFonte,
    this.tamanhoFonte, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: TextStyle(
          backgroundColor: corFundo,
          fontSize: tamanhoFonte,
          color: corFonte),
    );
  }
}
