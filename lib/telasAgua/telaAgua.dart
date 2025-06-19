import 'dart:convert';
import 'package:applab/telasAgua/telaCalculadoraAgua.dart';
import 'package:applab/telasAgua/telaEstatisticasAgua.dart';
import 'package:applab/telasAgua/telaLembretesAgua.dart';
import 'package:applab/telaInicial.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:applab/widgets/botoes.dart';
import 'package:applab/widgets/widgetsInput.dart';
import 'package:applab/widgets/meutexto.dart';

class TelaAgua extends StatefulWidget {
  const TelaAgua({super.key});

  @override
  State<TelaAgua> createState() => _TelaAguaState();
}

class _TelaAguaState extends State<TelaAgua> {
  int totalConsumido = 0;
  int metaDiaria = 1800;
  final TextEditingController _manualController = TextEditingController();
  final TextEditingController _qtdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarMetaPersonalizada();
    _carregarConsumoAtual();
  }

  void adicionarAgua(int quantidade) {
    setState(() {
      totalConsumido += quantidade;
      if (totalConsumido > metaDiaria) {
        totalConsumido = metaDiaria;
      }
    });

    _salvarConsumoAtual();
  }

  void atualizarManual() {
    final valor = int.tryParse(_manualController.text.trim());

    if (valor == null || valor < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Digite um valor válido.",
            style: TextStyle(color: Theme.of(context).colorScheme.onError),
          ),
        ),
      );
      return;
    }

    setState(() {
      totalConsumido = valor > metaDiaria ? metaDiaria : valor;
    });

    _salvarConsumoAtual();
    _manualController.clear();
  }

  double get percentual =>
      (totalConsumido / metaDiaria).clamp(0, 1).toDouble() * 100;

  Future<void> _carregarConsumoAtual() async {
    final prefs = await SharedPreferences.getInstance();
    final listaJson = prefs.getStringList('agua_dados') ?? [];

    final hoje = _hojeString();

    for (final item in listaJson) {
      final dado = jsonDecode(item);
      if (dado['data'] == hoje) {
        setState(() {
          totalConsumido = dado['consumo'];
        });
        break;
      }
    }
  }

  Future<void> _salvarConsumoAtual() async {
    final prefs = await SharedPreferences.getInstance();
    final listaJson = prefs.getStringList('agua_dados') ?? [];
    final hoje = _hojeString();

    final novoRegistro = {
      'data': hoje,
      'consumo': totalConsumido,
    };

    bool atualizado = false;

    final novaLista = listaJson.map((item) {
      final dado = jsonDecode(item);
      if (dado['data'] == hoje) {
        atualizado = true;
        return jsonEncode(novoRegistro);
      }
      return item;
    }).toList();

    if (!atualizado) {
      novaLista.add(jsonEncode(novoRegistro));
    }

    await prefs.setStringList('agua_dados', novaLista);
  }

  Future<void> _carregarMetaPersonalizada() async {
    final prefs = await SharedPreferences.getInstance();
    final meta = prefs.getInt('meta_agua');
    if (meta != null && meta > 0) {
      setState(() {
        metaDiaria = meta;
      });
    }
  }

  String _hojeString() {
    final agora = DateTime.now();
    return "${agora.year}-${agora.month.toString().padLeft(2, '0')}-${agora.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final corTextoPrincipal = theme.colorScheme.onSurface;
    final corTextoSecundario = theme.colorScheme.onSurface.withOpacity(0.7);
    

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
          title: Text("ÁGUA", style: TextStyle(color: Colors.white)),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.calculate, color: Colors.white),
              tooltip: 'Calculadora de Água',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TelaCalculadoraAgua()),
                );
              },
            ),
          ],
        ),

      backgroundColor: theme.colorScheme.surface,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              MeuTexto("Atinja o seu objetivo diário", Colors.transparent,
                  corTextoPrincipal, 20),
              SizedBox(height: 20),
              MeuTexto("$totalConsumido ml", Colors.transparent,
                  corTextoPrincipal, 36),
              SizedBox(height: 8),
              MeuTexto("${percentual.toStringAsFixed(0)}% concluído",
                  Colors.transparent, corTextoSecundario, 16),
              SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.flag, color: Colors.green.shade400),
                    SizedBox(width: 4),
                    MeuTexto("${metaDiaria}ml", Colors.transparent,
                        corTextoSecundario, 14),
                  ],
                ),
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _iconeCopo(400),
                  SizedBox(width: 12),
                  _iconeCopo(300),
                  SizedBox(width: 12),
                  _iconeCopo(200),
                  SizedBox(width: 12),
                  _iconeCopo(180),
                ],
              ),
              SizedBox(height: 30),
              InputTextos("Adicionar (ml)", "Ex: 350",
                  controller: _qtdController),
              SizedBox(height: 8),
              Botoes(
                text: "BEBER",
                width: double.infinity,
                onPressed: () => adicionarAgua(int.parse(_qtdController.text)),
                backgroundColor: theme.colorScheme.primary,
                textColor: Colors.white,
                borderRadius: 12,
                icon: Icon(Icons.local_drink,
                    color: Colors.white, size: 20),
              ),
              SizedBox(height: 24),
              InputTextos("Registro manual (ml)", "Ex: 1250",
                  controller: _manualController),
              SizedBox(height: 8),
              Botoes(
                text: "Atualizar consumo",
                width: double.infinity,
                onPressed: atualizarManual,
                backgroundColor: Colors.blueAccent,
                textColor: Colors.white,
                borderRadius: 12,
                icon: Icon(Icons.update, color: Colors.white, size: 20),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        color: theme.colorScheme.surface,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.home),
              color: theme.colorScheme.primary,
              onPressed: () => _abreTela(context, TelaInicial()),
            ),
            IconButton(
              icon: Icon(Icons.notifications),
              color: theme.colorScheme.primary,
              onPressed: () => _abreTela(context, TelaLembretesAgua()),
            ),
            IconButton(
              icon: Icon(Icons.bar_chart),
              color: theme.colorScheme.primary,
              onPressed: () => _abreTela(context, TelaEstatisticasAgua()),
            ),
          ],
        ),
      ),
    );
  }

  void _abreTela(BuildContext ctx, Widget page) {
    Navigator.push(ctx, MaterialPageRoute(builder: (_) => page));
  }

  Widget _iconeCopo(int ml) {
    return GestureDetector(
      onTap: () => adicionarAgua(ml),
      child: Column(
        children: [
          const Icon(Icons.local_drink,
              color: Colors.lightBlueAccent, size: 36),
          const SizedBox(height: 4),
          MeuTexto("$ml ml", Colors.transparent,
              Theme.of(context).colorScheme.onSurface, 14),
        ],
      ),
    );
  }
}
