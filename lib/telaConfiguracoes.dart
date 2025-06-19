import 'package:applab/home.dart';
import 'package:applab/telasConta/telaAlterarPerfil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'utilitarios/tema_provider.dart';
import '../widgets/botoes.dart';
import 'telasConta/telaConta.dart';

class TelaConfiguracoes extends StatelessWidget {
  const TelaConfiguracoes({super.key});


  Future<void> _excluirConta(BuildContext context) async {
    final confirmacao = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirmar exclusão"),
        content: Text(
            "Tem certeza que deseja excluir sua conta? Essa ação não pode ser desfeita."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text("Cancelar")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text("Excluir")),
        ],
      ),
    );

    if (confirmacao == true) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).delete();
        await user.delete();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => Home()),
          (route) => false,
        );
      }
    }
  }

  void _abreTela(BuildContext ctx, Widget page) {
    Navigator.push(ctx, MaterialPageRoute(builder: (_) => page));
  }


  void _fazerLogout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => TelaConta()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final temaProvider = Provider.of<TemaProvider>(context);
    final isEscuro = temaProvider.modoEscuro;

    return Scaffold(
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
        title: Text("CONFIGURAÇÕES", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Modo Escuro',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(width: 16),
                Switch(
                  value: isEscuro,
                  onChanged: (valor) => temaProvider.alternarTema(valor),
                ),
              ],
            ),
            SizedBox(height: 60),
            Botoes(
              text: "Editar Perfil",
              width: double.infinity,
              onPressed: () => _abreTela(context, TelaAlterarPerfil()),
              backgroundColor: Colors.blueAccent,
              textColor: Colors.white,
              borderRadius: 12,
              icon: Icon(Icons.edit, color: Colors.white),
              height: 50,
            ),
            SizedBox(height: 20),
            Botoes(
              text: "Sair",
              width: double.infinity,
              onPressed: () => _fazerLogout(context),
              backgroundColor: Colors.blueAccent,
              textColor: Colors.white,
              borderRadius: 12,
              icon: Icon(Icons.logout, color: Colors.white),
              height: 50,
            ),
            SizedBox(height: 80),
            Botoes(
              text: "Excluir conta",
              width: double.infinity,
              onPressed: () => _excluirConta(context),
              backgroundColor: Color.fromARGB(255, 168, 33, 23),
              textColor: Colors.white,
              borderRadius: 12,
              icon: Icon(Icons.delete, color: Colors.white),
              height: 50,
            ),
          ],
        ),
      ),
    );
  }
}
