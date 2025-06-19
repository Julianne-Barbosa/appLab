import 'package:applab/widgets/botoes.dart';
import 'package:applab/widgets/widgetsInput.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TelaAlterarPerfil extends StatefulWidget {
  const TelaAlterarPerfil({super.key});

  @override
  State<TelaAlterarPerfil> createState() => _TelaAlterarPerfilState();
}

class _TelaAlterarPerfilState extends State<TelaAlterarPerfil> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _senhaAtualController = TextEditingController();
  final _novaSenhaController = TextEditingController();

  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  bool _mostraSenhaAtual = false;
  bool _mostraNovaSenha = false;

  @override
  void initState() {
    super.initState();
    _carregarNome();
  }

  Future<void> _carregarNome() async {
    final user = auth.currentUser;
    if (user != null) {
      final doc = await firestore.collection('usuarios').doc(user.uid).get();
      setState(() {
        _nomeController.text = doc['nome'] ?? '';
      });
    }
  }

  Future<void> _alterarNome() async {
    final user = auth.currentUser;
    if (user != null) {
      await firestore.collection('usuarios').doc(user.uid).update({
        'nome': _nomeController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Nome atualizado com sucesso")),
      );
    }
  }

  Future<void> _alterarSenha() async {
    final user = auth.currentUser;
    if (user == null) return;

    final cred = EmailAuthProvider.credential(
      email: user.email!,
      password: _senhaAtualController.text,
    );

    try {
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(_novaSenhaController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Senha alterada com sucesso")),
      );
      _senhaAtualController.clear();
      _novaSenhaController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro! Verifique os dados e tente novamente!")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
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
        title: Text("EDITAR PERFIL", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              SizedBox(height: 20),
              InputTextos('ALTERAR NOME', '', controller: _nomeController),
              SizedBox(height: 20),
              Botoes(
                  text: "Salvar Nome",
                  width: double.infinity,
                  onPressed: _alterarNome,
                  backgroundColor: Colors.blueAccent,
                  textColor: Colors.white,
                  borderRadius: 12,
                  icon: Icon(Icons.save, color: Colors.white),
                  height: 50,
                ),
              Divider(height: 40),
              Text("Alterar Senha", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextFormField(
                controller: _senhaAtualController,
                obscureText: !_mostraSenhaAtual,
                decoration: InputDecoration(
                  labelText: "Senha atual",
                  suffixIcon: IconButton(
                    icon: Icon(_mostraSenhaAtual ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _mostraSenhaAtual = !_mostraSenhaAtual),
                  ),
                ),
              ),
              TextFormField(
                controller: _novaSenhaController,
                obscureText: !_mostraNovaSenha,
                decoration: InputDecoration(
                  labelText: "Nova senha",
                  suffixIcon: IconButton(
                    icon: Icon(_mostraNovaSenha ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _mostraNovaSenha = !_mostraNovaSenha),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Botoes(
                  text: "Salvar Nova Senha",
                  width: double.infinity,
                  onPressed: _alterarSenha,
                  backgroundColor: Colors.blueAccent,
                  textColor: Colors.white,
                  borderRadius: 12,
                  icon: Icon(Icons.save, color: Colors.white),
                  height: 50,
                ),
              Divider(height: 40),
              
            ],
          ),
        ),
      ),
    );
  }
}
