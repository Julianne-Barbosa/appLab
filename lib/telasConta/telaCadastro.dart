import 'package:applab/telasConta/telaLogin.dart';
import 'package:applab/widgets/botoes.dart';
import 'package:applab/widgets/widgetsImagem.dart';
import 'package:applab/widgets/widgetsInput.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance; // inicialização direta
  bool _carregando = false;

  Future<void> _createUser() async {
    String nome = _nomeController.text.trim();
    String email = _emailController.text.trim();
    String senha = _senhaController.text.trim();

    if (nome.isEmpty || email.isEmpty || senha.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Preencha todos os campos corretamente.')),
      );
      return;
    }

    setState(() => _carregando = true);

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      CollectionReference usuarios =
          FirebaseFirestore.instance.collection('usuarios');
      await usuarios.doc(userCredential.user?.uid).set({
        'nome': nome,
        'email': email,
        'criado_em': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conta criada com sucesso!')),
      );

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => TelaLogin()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao criar conta: $e')),
      );
    } finally {
      setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // permite que o conteúdo suba com o teclado
      body: Container(
      width: double.infinity,
      height: double.infinity, // ocupa 100% da altura da tela
      decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF63D4F2), Color(0xFF0056D2)],
      ),
    ),
    child: SafeArea(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: IntrinsicHeight(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                SizedBox(height: 60),
                SuaImagem(
                    caminhoArquivo: 'assets/logo.png',
                    alturaImagem: 180,
                    larguraImagem: 180),
                SizedBox(height: 40),
                Text("NOME DE USUÁRIO",
                    style: TextStyle(color: Colors.white)),
                SizedBox(height: 5),
                InputTextos('', 'Digite seu nome', controller: _nomeController),
                SizedBox(height: 30),
                Text("EMAIL", style: TextStyle(color: Colors.white)),
                SizedBox(height: 5),
                InputTextos('', 'Digite seu email',
                    controller: _emailController),
                SizedBox(height: 30),
                Text("SENHA", style: TextStyle(color: Colors.white)),
                SizedBox(height: 5),
                TextField(
                  controller: _senhaController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    hintText: 'Digite sua senha',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                SizedBox(height: 30),
                _carregando
                    ? CircularProgressIndicator()
                    : Botoes(
                        text: "Criar Conta",
                        width: double.infinity,
                        onPressed: _createUser,
                        backgroundColor: Colors.white,
                        textColor: Color(0xFF0056D2),
                        borderRadius: 12,
                        icon: Icon(Icons.login, color: Color(0xFF0056D2)),
                        height: 50,
                      ),
              ],
            ),
          ),
        ),
      ),
    )
    )
      )
    );
  }
}
