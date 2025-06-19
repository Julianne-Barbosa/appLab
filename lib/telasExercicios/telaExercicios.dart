import 'package:applab/telaInicial.dart';
import 'package:applab/telasExercicios/telaEstatisticasExercicios.dart';
import 'package:applab/telasExercicios/telaLembretesExercicios.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:applab/widgets/botoes.dart';
import 'package:applab/widgets/widgetsInput.dart';
import 'package:applab/widgets/meutexto.dart';
import 'package:percent_indicator/percent_indicator.dart';

class TelaExercicios extends StatefulWidget {
  const TelaExercicios({super.key});

  @override
  State<TelaExercicios> createState() => _TelaExerciciosState();
}

class _TelaExerciciosState extends State<TelaExercicios> {
  final TextEditingController _atividadeController = TextEditingController();
  final TextEditingController _tempoController = TextEditingController();
  final TextEditingController _metaController = TextEditingController();

  int metaSemanal = 150;
  List<Map<String, dynamic>> exercicios = [];
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _carregarMeta();
    _carregarExercicios();
  }

  Future<void> _carregarMeta() async {
    final doc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user!.uid)
        .get();

    final dados = doc.data();
    if (dados != null && dados['meta_exercicios'] != null) {
      setState(() => metaSemanal = dados['meta_exercicios']);
    }
  }

  Future<void> _salvarMeta() async {
    final valor = int.tryParse(_metaController.text.trim());
    if (valor == null || valor <= 0) return;

    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user!.uid)
        .set({'meta_exercicios': valor}, SetOptions(merge: true));

    setState(() => metaSemanal = valor);
    _metaController.clear();
  }

  Future<void> _carregarExercicios() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user!.uid)
        .collection('exercicios')
        .get();

    final convertidos = snapshot.docs
        .map((doc) => doc.data())
        .toList();

    setState(() => exercicios = convertidos);
  }

  Future<void> _salvarExercicio(String nome, int tempo) async {
    final novo = {
      'data': DateTime.now().toIso8601String(),
      'atividade': nome,
      'minutos': tempo,
    };

    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user!.uid)
        .collection('exercicios')
        .add(novo);

    setState(() => exercicios.add(novo));
  }

  int get totalSemanal {
    return exercicios
        .where((e) {
          final data = DateTime.parse(e['data']);
          final agora = DateTime.now();
          final inicioSemana =
              agora.subtract(Duration(days: agora.weekday - 1));
          return data.isAfter(inicioSemana);
        })
        .map((e) => e['minutos'] as int)
        .fold(0, (a, b) => a + b);
  }

  double get percentual => (totalSemanal / metaSemanal).clamp(0, 1).toDouble();

  void _registrarAtividade() {
    final nome = _atividadeController.text.trim();
    final tempo = int.tryParse(_tempoController.text.trim());

    if (nome.isEmpty || tempo == null || tempo <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Preencha os campos corretamente.")),
      );
      return;
    }

    _salvarExercicio(nome, tempo);
    _atividadeController.clear();
    _tempoController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final subColor = isDark ? Colors.white70 : Colors.black54;
    final cardColor = isDark ? Color(0xFF1C1C3A) : Colors.grey.shade200;
    final theme = Theme.of(context);

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
      title: Text("EXERCÍCIOS", style: TextStyle(color: Colors.white)),
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
              icon: Icon(Icons.notifications),
              color: theme.colorScheme.primary,
              onPressed: () => _abreTela(context, TelaLembretesExercicios()),
            ),
            IconButton(
              icon: Icon(Icons.bar_chart),
              color: theme.colorScheme.primary,
              onPressed: () => _abreTela(context, TelaEstatisticasExercicios()),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
    child: Padding(
    padding: EdgeInsets.all(18),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    MeuTexto("Meta semanal (min):", Colors.transparent, textColor, 16),
    Row(
    children: [
    Expanded(
    child: InputTextos("Meta", "Ex: 150", controller: _metaController),
    ),
    SizedBox(width: 2),
          Botoes(
          text: "Sim",
          width: 48,
          onPressed: _salvarMeta,
          backgroundColor: Colors.blueAccent,
          textColor: Colors.white,
          borderRadius: 12,
          icon: Icon(Icons.check, color: Colors.white),
          height: 50,
          ),
    ],
    ),
    SizedBox(height: 18),
    Center(
          child: CircularPercentIndicator(
          radius: 80,
          lineWidth: 12,
          percent: percentual,
          animation: true,
          center: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
              MeuTexto("${(percentual * 100).toStringAsFixed(0)}%", Colors.transparent, textColor, 20),
              MeuTexto("$totalSemanal / $metaSemanal min", Colors.transparent, subColor, 12),
          ],
          ),
          progressColor: Colors.blueAccent,
          backgroundColor: subColor.withOpacity(0.2),
          circularStrokeCap: CircularStrokeCap.round,
          ),
    ),
    SizedBox(height: 20),
    MeuTexto("Registrar Atividade", Colors.transparent, textColor, 16),
    SizedBox(height: 6),
    InputTextos("Atividade", "Ex: Corrida", controller: _atividadeController),
    SizedBox(height: 6),
    InputTextos("Minutos", "Ex: 30", controller: _tempoController),
    SizedBox(height: 6),
          Botoes(
          text: "Registrar",
          width: double.infinity,
          onPressed: _registrarAtividade,
          backgroundColor: Colors.blueAccent,
          textColor: Colors.white,
          borderRadius: 12,
          icon: Icon(Icons.check, color: Colors.white),
          height: 50,
          ),
    SizedBox(height: 24),

    MeuTexto("Histórico da Semana", Colors.transparent, textColor, 16),
    SizedBox(height: 8),

    if (exercicios.isNotEmpty)
            SizedBox(
            height: MediaQuery.of(context).size.height * 0.4, // altura controlada
            child: ListView.builder(
            itemCount: exercicios.length,
            itemBuilder: (context, index) {
            final item = exercicios[exercicios.length - 1 - index];
            final data = DateTime.parse(item['data']);
            return Card(
            color: cardColor,
            shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
            child: ListTile(
            title: MeuTexto(item['atividade'], Colors.transparent, textColor, 16),
            subtitle: MeuTexto("${item['minutos']} min em ${data.day}/${data.month}", Colors.transparent, subColor, 12),
            ),
    );
    },
    ),
    )
    else
        MeuTexto("Nenhuma atividade registrada ainda.", Colors.transparent, subColor, 14),
    SizedBox(height: 32),
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
