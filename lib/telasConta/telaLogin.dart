import 'package:applab/telaInicial.dart';
import 'package:applab/widgets/botoes.dart';
import 'package:applab/widgets/widgetsImagem.dart';
import 'package:applab/widgets/widgetsInput.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _carregando = false;

  Future<void> _loginUser() async {
    String email = _emailController.text.trim();
    String senha = _senhaController.text.trim();

    if (email.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Preencha todos os campos')),
      );
      return;
    }

    setState(() => _carregando = true);

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: senha);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login realizado com sucesso!')),
      );

      

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => TelaInicial()));

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Informações incorretas! Tente novamente.')),
      );
    } finally {
      setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
                      Text("EMAIL",
                          style: TextStyle(color: Colors.white)),
                      SizedBox(height: 5),
                      InputTextos('', 'Digite seu email',
                          controller: _emailController),
                      SizedBox(height: 30),
                      Text("SENHA",
                          style: TextStyle(color: Colors.white)),
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
                              text: "Entrar",
                              width: double.infinity,
                              onPressed: _loginUser,
                              backgroundColor: Colors.white,
                              textColor: Color(0xFF0056D2),
                              borderRadius: 12,
                              icon: Icon(Icons.login,
                                  color: Color(0xFF0056D2)),
                              height: 50,
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
