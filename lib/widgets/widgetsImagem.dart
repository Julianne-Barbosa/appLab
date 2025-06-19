import 'package:flutter/material.dart';

class SuaImagem extends StatefulWidget {
   final String caminhoArquivo;
   final double alturaImagem;
   final double larguraImagem;

   const SuaImagem( {super.key, required this.caminhoArquivo, required this.alturaImagem, required this.larguraImagem});
   //Passando um construtor para state full, obrigatoriamente
   //devemos colocar uma "marcador" (key) e o parametro do
   //construtor
  @override
  _SuaImagemState createState() => _SuaImagemState();
}

class _SuaImagemState extends State<SuaImagem> {
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      widget.caminhoArquivo,
      //Pegamos atraves do objeto widget
      filterQuality: FilterQuality.high,
      //Qualidade foto
      fit: BoxFit.cover,
      //Ajusta conforme o tamanho tela
      height: widget.alturaImagem,
      width: widget.larguraImagem,
      scale: 50,
      colorBlendMode: BlendMode.darken,
    );
  }
}
