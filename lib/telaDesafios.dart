import 'package:applab/widgets/meutexto.dart';
import 'package:applab/widgets/widgetsInput.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TelaDesafios extends StatefulWidget {
  const TelaDesafios({super.key});

  @override
  State<TelaDesafios> createState() => _TelaDesafiosState();
}

class _TelaDesafiosState extends State<TelaDesafios> {
  final TextEditingController _desafioController = TextEditingController();
  final TextEditingController _premioController = TextEditingController();
  DateTime? _dataFim;

  final List<Map<String, dynamic>> _usuarios = [];
  final List<Map<String, dynamic>> _selecionados = [];
  final List<Map<String, dynamic>> _desafiosCriados = [];

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Map<String, dynamic>? _usuarioSelecionado;

  @override
  void initState() {
    super.initState();
    _carregarUsuarios();
    _carregarDesafiosCriados();
  }

  Future<void> _carregarUsuarios() async {
    final uidAtual = _auth.currentUser?.uid;
    final snapshot = await _firestore.collection('usuarios').get();

    setState(() {
      _usuarios.clear();
      for (var doc in snapshot.docs) {
        if (doc.id != uidAtual) {
          _usuarios.add({
            'id': doc.id,
            'nome': doc['nome'],
            'email': doc['email'],
          });
        }
      }
    });
  }

  Future<void> _carregarDesafiosCriados() async {
    final uid = _auth.currentUser?.uid;

    final snapshot = await _firestore
        .collection('desafios')
        .where('concluido', isEqualTo: false)
        .orderBy('criadoEm', descending: true)
        .get();


    print("Total de desafios encontrados: ${snapshot.docs.length}");

    setState(() {
      _desafiosCriados.clear();
      _desafiosCriados.addAll(snapshot.docs.map((doc) => {
            ...doc.data(),
            'docId': doc.id,
          }));
    });
  }

  Future<void> _salvarDesafio() async {
    if (_selecionados.isEmpty || _desafioController.text.isEmpty || _dataFim == null) return;

    final uid = _auth.currentUser?.uid;
    final participantes = _selecionados.map((u) => u['id']).toList();
    participantes.add(uid); 

    await _firestore.collection('desafios').add({
      'descricao': _desafioController.text,
      'premio': _premioController.text,
      'dataFim': _dataFim,
      'concluido': false,
      'participantes': participantes,
      'criadoPor': uid,
      'criadoEm': DateTime.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Desafio criado com sucesso!')),
    );

    setState(() {
      _selecionados.clear();
      _usuarioSelecionado = null;
      _desafioController.clear();
      _premioController.clear();
      _dataFim = null;
    });

    _carregarDesafiosCriados();
  }

  Future<void> _marcarConcluido(String docId) async {
    await _firestore.collection('desafios').doc(docId).update({'concluido': true});
    _carregarDesafiosCriados();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Color(0xFF0D0D2B) : Colors.grey[100];
    final theme = Theme.of(context);
    final corTextoPrincipal = theme.colorScheme.onSurface;
    final corTextoSecundario = theme.colorScheme.onSurface.withOpacity(0.7);

    return Scaffold(
      backgroundColor: backgroundColor,
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
        title: Text("DESAFIOS", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MeuTexto("Selecione seus amigos", Colors.transparent, corTextoPrincipal, 20),
            SizedBox(height: 10),

            DropdownButton<Map<String, dynamic>>(
              value: _usuarioSelecionado,
              hint: Text("Selecione um amigo"),
              isExpanded: true,
              items: _usuarios.map((usuario) {
                return DropdownMenuItem<Map<String, dynamic>>(
                  value: usuario,
                  child: Text(usuario['nome']),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null && !_selecionados.contains(value)) {
                  setState(() {
                    _usuarioSelecionado = null;
                    _selecionados.add(value);
                  });
                }
              },
            ),
            SizedBox(height: 10),

            // Lista dos amigos selecionados para o desafio
            Wrap(
              spacing: 8.0,
              children: _selecionados
                  .map((usuario) => Chip(
                        label: Text(usuario['nome']),
                        onDeleted: () {
                          setState(() {
                            _selecionados.remove(usuario);
                          });
                        },
                      ))
                  .toList(),
            ),

            Divider(height: 30),
            MeuTexto("Desafio em grupo", Colors.transparent, corTextoPrincipal, 20),
            SizedBox(height: 10),
            InputTextos("", "Descreva o desafio", controller: _desafioController),
            SizedBox(height: 10),
            InputTextos("", "Defina o prêmio", controller: _premioController),
            SizedBox(height: 10),
            ListTile(
              title: Text(_dataFim == null
                  ? "Escolher data de fim"
                  : "Data final: ${_dataFim!.day}/${_dataFim!.month}/${_dataFim!.year}"),
              trailing: Icon(Icons.calendar_today),
              onTap: () async {
                final data = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 7)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (data != null) {
                  setState(() => _dataFim = data);
                }
              },
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _salvarDesafio,
              child: Text("Criar Desafio"),
            ),

            Divider(height: 30),
            MeuTexto("Desafios criados por você", Colors.transparent, corTextoPrincipal, 20),
            SizedBox(height: 10),
            if (_desafiosCriados.isEmpty)
              Text("Nenhum desafio criado.", style: TextStyle(color: corTextoSecundario)),
            ..._desafiosCriados.map((d) => Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(d['descricao']),
                    subtitle: Text("Prêmio: ${d['premio']}"),
                    trailing: IconButton(
                      icon: Icon(Icons.check_circle, color: Colors.green),
                      tooltip: "Marcar como concluído",
                      onPressed: () => _marcarConcluido(d['docId']),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
