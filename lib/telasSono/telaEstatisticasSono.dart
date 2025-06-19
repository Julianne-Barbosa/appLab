import 'package:applab/telaInicial.dart';
import 'package:applab/telasSono/telaLembretesSono.dart';
import 'package:applab/telasSono/telaSono.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:applab/widgets/meutexto.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TelaEstatisticasSono extends StatefulWidget {
  const TelaEstatisticasSono({super.key});

  @override
  State<TelaEstatisticasSono> createState() => _TelaEstatisticasSonoState();
}

class _TelaEstatisticasSonoState extends State<TelaEstatisticasSono> {
  final user = FirebaseAuth.instance.currentUser;
  List<Map<String, dynamic>> registros = [];

  @override
  void initState() {
    super.initState();
    _carregarRegistros();
    
  }

  Future<void> _carregarRegistros() async {
  try {
    final uid = user?.uid;
    if (uid == null) return;

    final dados = <Map<String, dynamic>>[];

    final dadosSonoRef = FirebaseFirestore.instance
        .collection('dados_sono');

    final snapshot = await dadosSonoRef.get(); 

    for (final doc in snapshot.docs) {
      final map = doc.data();
      map['data'] = doc.id;
      dados.add(map);
    }

    setState(() => registros = dados);
  } catch (e) {
    print("Erro ao carregar dados do Firestore: $e");
  }
}


  Map<String, double> get dadosSemanais {
    final agora = DateTime.now();
    final inicioSemana = agora.subtract(Duration(days: 6));

    Map<String, double> mapa = {
      for (int i = 0; i < 7; i++)
        DateFormat('E').format(inicioSemana.add(Duration(days: i))): 0.0
    };

    for (var reg in registros) {
      final data = DateTime.parse(reg['data']);
      if (data.isAfter(inicioSemana.subtract(const Duration(days: 1)))) {
        final dia = DateFormat('E').format(data);
        mapa[dia] = (mapa[dia] ?? 0) + (reg['horasDormidas'] as num).toDouble();
      }
    }

    return mapa;
  }

  int get qtdOtimo => registros.where((r) => r['qualidadeSono'] == 1).length;
  int get qtdOk => registros.where((r) => r['qualidadeSono'] == 2).length;
  int get qtdPessimo => registros.where((r) => r['qualidadeSono'] == 3).length;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final subColor = isDark ? Colors.white70 : Colors.black54;
    final cardColor = isDark ? const Color(0xFF1C1C3A) : Colors.grey.shade200;

    final dados = dadosSemanais;
    final dias = dados.keys.toList();
    final valores = dados.values.toList();

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("ESTATÍSTICAS SONO",
            style: TextStyle(color: Colors.white)),
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
        color: theme.colorScheme.background,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.home),
              color: theme.colorScheme.primary,
              onPressed: () => _abreTela(context, TelaInicial()),
            ),
            IconButton(
              icon: Icon(Icons.nightlight_round),
              color: theme.colorScheme.primary,
              onPressed: () => _abreTela(context, TelaSono()),
            ),
            IconButton(
              icon: Icon(Icons.notifications),
              color: theme.colorScheme.primary,
              onPressed: () => _abreTela(context, TelaLembretesSono()),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MeuTexto("Horas dormidas - últimos 7 dias", Colors.transparent,
                textColor, 16),
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
                          toY: valores[index],
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
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: false),
                ),
              ),
            ),
            SizedBox(height: 24),
            MeuTexto("Qualidade do sono nos registros", Colors.transparent,
                textColor, 16),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQualidadeBox("Ótimo", qtdOtimo, Colors.green),
                _buildQualidadeBox("Ok", qtdOk, Colors.orange),
                _buildQualidadeBox("Péssimo", qtdPessimo, Colors.red),
              ],
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

                      String qualidadeTexto;
                      switch (item['qualidadeSono']) {
                        case 1:
                          qualidadeTexto = 'Ótimo';
                          break;
                        case 2:
                          qualidadeTexto = 'Ok';
                          break;
                        case 3:
                          qualidadeTexto = 'Péssimo';
                          break;
                        default:
                          qualidadeTexto = 'Inválido';
                      }

                    return Card(
                      color: cardColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        title: MeuTexto(
                          "${item['horasDormidas']} horas dormidas",
                          Colors.transparent,
                          textColor,
                          16,
                        ),
                        subtitle: MeuTexto(
                          "Qualidade: $qualidadeTexto - ${data.day}/${data.month}",
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
                child: MeuTexto("Nenhum registro de sono encontrado.",
                    Colors.transparent, subColor, 14),
              ),
          ],
        ),
      ),
    );
  }

  void _abreTela(BuildContext ctx, Widget page) {
    Navigator.push(ctx, MaterialPageRoute(builder: (_) => page));
  }

  Widget _buildQualidadeBox(String label, int count, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color),
      ),
      child: Column(
        children: [
          Text(
            "$count",
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 14, color: color),
          ),
        ],
      ),
    );
  }
}
