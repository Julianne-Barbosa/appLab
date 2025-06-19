import 'package:applab/telaInicial.dart';
import 'package:applab/telasExercicios/telaExercicios.dart';
import 'package:applab/telasExercicios/telaLembretesExercicios.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:applab/widgets/meutexto.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class TelaEstatisticasExercicios extends StatefulWidget {
  const TelaEstatisticasExercicios({super.key});

  @override
  State<TelaEstatisticasExercicios> createState() => _TelaEstatisticasExerciciosState();
}

class _TelaEstatisticasExerciciosState extends State<TelaEstatisticasExercicios> {
  final user = FirebaseAuth.instance.currentUser;
  List<Map<String, dynamic>> registros = [];

  @override
  void initState() {
    super.initState();
    _carregarRegistros();
  }

  Future<void> _carregarRegistros() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user!.uid)
        .collection('exercicios')
        .get();

    final dados = snapshot.docs
        .map((doc) => doc.data())
        .toList();

    setState(() => registros = dados);
  }

  Map<String, int> get dadosSemanais {
    final agora = DateTime.now();
    final inicioSemana = agora.subtract(Duration(days: 6));

    Map<String, int> mapa = {
      for (int i = 0; i < 7; i++)
        DateFormat('E').format(inicioSemana.add(Duration(days: i))): 0
    };

    for (var reg in registros) {
      final data = DateTime.parse(reg['data']);
      if (data.isAfter(inicioSemana.subtract(Duration(days: 1)))) {
        final dia = DateFormat('E').format(data);
        mapa[dia] = (mapa[dia] ?? 0) + (reg['minutos'] as int);
      }
    }

    return mapa;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final subColor = isDark ? Colors.white70 : Colors.black54;
    final cardColor = isDark ? Color(0xFF1C1C3A) : Colors.grey.shade200;

    final dados = dadosSemanais;
    final dias = dados.keys.toList();
    final valores = dados.values.toList();

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Estatísticas de Exercícios", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0056D2), Color(0xFF63D4F2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
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
              icon: Icon(Icons.directions_run),
              color: theme.colorScheme.primary,
              onPressed: () => _abreTela(context, TelaExercicios()),
            ),
            IconButton(
              icon: Icon(Icons.notifications),
              color: theme.colorScheme.primary,
              onPressed: () => _abreTela(context, TelaLembretesExercicios()),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MeuTexto("Nível de atividade - últimos 7 dias", Colors.transparent, textColor, 16),
            SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barGroups: List.generate(7, (index) {
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: valores[index].toDouble(),
                          color: Colors.blueAccent,
                          width: 18,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          return Text(
                            dias[value.toInt()],
                            style: TextStyle(fontSize: 12, color: subColor),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: false),
                ),
              ),
            ),
            SizedBox(height: 24),
            MeuTexto("Últimos registros", Colors.transparent, textColor, 16),
            SizedBox(height: 12),
            if (registros.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: registros.length,
                  itemBuilder: (context, index) {
                    final item = registros[registros.length - 1 - index];
                    final data = DateTime.parse(item['data']);
                    return Card(
                      color: cardColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        title: MeuTexto(item['atividade'], Colors.transparent, textColor, 16),
                        subtitle: MeuTexto(
                          "${item['minutos']} min em ${data.day}/${data.month}",
                          Colors.transparent,
                          subColor,
                          12,
                        ),
                      ),
                    );
                  },
                ),
              )
            else
              Center(
                child: MeuTexto("Nenhum exercício registrado.", Colors.transparent, subColor, 14),
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
