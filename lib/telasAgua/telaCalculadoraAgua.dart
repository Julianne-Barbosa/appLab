import 'package:applab/telasAgua/telaAgua.dart';
import 'package:applab/telasAgua/telaLembretesAgua.dart';
import 'package:applab/telaInicial.dart';
import 'package:applab/widgets/meutexto.dart';
import 'package:flutter/material.dart';
import 'package:applab/widgets/botoes.dart';
import 'package:applab/widgets/widgetsInput.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TelaCalculadoraAgua extends StatefulWidget {
  const TelaCalculadoraAgua({super.key});

  @override
  State<TelaCalculadoraAgua> createState() => _TelaCalculadoraAguaState();
}

class _TelaCalculadoraAguaState extends State<TelaCalculadoraAgua> {
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _idadeController = TextEditingController();
  String nivelAtividade = 'leve';
  double? resultado;

  final int _indiceAtual = 0;

  double calcularMetaAgua({
    required double pesoKg,
    required int idade,
    required String atividadeFisica,
  }) {
    double mlPorKg;

    if (idade < 30) {
      mlPorKg = 40;
    } else if (idade < 55) {
      mlPorKg = 35;
    } else if (idade < 65) {
      mlPorKg = 30;
    } else {
      mlPorKg = 25;
    }

    double base = pesoKg * mlPorKg;
    double extra = 0;

    if (atividadeFisica == 'moderada') {
      extra = 500;
    } else if (atividadeFisica == 'intensa') {
      extra = 750;
    }

    return base + extra;
  }

  void _calcular() {
    final peso = double.tryParse(_pesoController.text);
    final idade = int.tryParse(_idadeController.text);

    if (peso == null || idade == null || peso <= 0 || idade <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Preencha peso e idade corretamente.")),
      );
      return;
    }

    final valor = calcularMetaAgua(
      pesoKg: peso,
      idade: idade,
      atividadeFisica: nivelAtividade,
    );

    setState(() {
      resultado = valor;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final corFundo = isDark ? Color(0xFF0D0D2B) : Colors.grey[100]!;
    final corSecundaria = isDark ? Color(0xFF1C1C3A) : Colors.white;
    final corTextoPrincipal = isDark ? Colors.white : Colors.black87;
    final corTextoSecundario = isDark ? Colors.white70 : Colors.black54;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: corFundo,
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
      title: Text("CALCULADORA ÁGUA", style: TextStyle(color: Colors.white)),
      centerTitle: true,
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
            icon: Icon(Icons.water_drop),
            color: theme.colorScheme.primary,
            onPressed: () => _abreTela(context, TelaAgua()),
          ),
          IconButton(
            icon: Icon(Icons.notifications),
            color: theme.colorScheme.primary,
            onPressed: () => _abreTela(context, TelaLembretesAgua()),
          ),
        ],
      ),
    ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MeuTexto("Informe seus dados:", Colors.transparent, corTextoPrincipal, 20),
            SizedBox(height: 20),
            InputTextos("Peso (kg)", "Ex: 70", controller: _pesoController),
            SizedBox(height: 20),
            InputTextos("Idade", "Ex: 25", controller: _idadeController),
            SizedBox(height: 24),
            MeuTexto("Nível de atividade física", Colors.transparent, corTextoPrincipal, 18),
            SizedBox(height: 12),
            DropdownButtonFormField<String>(
              dropdownColor: corSecundaria,
              value: nivelAtividade,
              decoration: InputDecoration(
                filled: true,
                fillColor: corSecundaria,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: corTextoSecundario),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Color(0xFF6C63FF), width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              style: TextStyle(color: corTextoPrincipal, fontSize: 16),
              items: const [
                DropdownMenuItem(value: 'leve', child: Text("Leve")),
                DropdownMenuItem(value: 'moderada', child: Text("Moderada")),
                DropdownMenuItem(value: 'intensa', child: Text("Intensa")),
              ],
              onChanged: (valor) {
                setState(() {
                  nivelAtividade = valor!;
                });
              },
            ),
            SizedBox(height: 32),
            Botoes(
              text: "Calcular",
              width: double.infinity,
              onPressed: _calcular,
              backgroundColor: Colors.blueAccent,
              textColor: Colors.white,
              borderRadius: 14,
              icon: Icon(Icons.calculate, color: Colors.white),
              height: 52,
            ),
            SizedBox(height: 32),
            if (resultado != null)
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: corSecundaria,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    MeuTexto("Recomendação diária:", Colors.transparent, corTextoSecundario, 18),
                    SizedBox(height: 10),
                    MeuTexto(
                      "${(resultado! / 1000).toStringAsFixed(2)} litros",
                      Colors.transparent,
                      corTextoPrincipal,
                      36,
                    ),
                    SizedBox(height: 24),
                    Botoes(
                      text: "Usar como meta diária",
                      width: double.infinity,
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setInt('meta_agua', resultado!.round());

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Meta personalizada salva com sucesso!"),
                              //backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                      backgroundColor: Colors.indigo,
                      textColor: Colors.white,
                      borderRadius: 14,
                      icon: Icon(Icons.calendar_today_rounded, color: Colors.white70),
                      height: 50,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _abreTela(BuildContext ctx, Widget page) {
    Navigator.push(ctx, MaterialPageRoute(builder: (_) => page));
  }
}
