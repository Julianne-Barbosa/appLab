import 'dart:convert';
import 'package:applab/telasAgua/telaAgua.dart';
import 'package:applab/telasAgua/telaLembretesAgua.dart';
import 'package:applab/telaInicial.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:applab/widgets/meutexto.dart';
import 'package:intl/intl.dart';


class TelaEstatisticasAgua extends StatefulWidget {
  const TelaEstatisticasAgua({super.key});

  @override
  State<TelaEstatisticasAgua> createState() => _TelaEstatisticasAguaState();
}

class _TelaEstatisticasAguaState extends State<TelaEstatisticasAgua> {
  List<Map<String, dynamic>> dados = [];

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final prefs = await SharedPreferences.getInstance();
    final listaJson = prefs.getStringList('agua_dados') ?? [];

    final List<Map<String, dynamic>> convertidos = listaJson
        .map((item) => jsonDecode(item) as Map<String, dynamic>)
        .toList();

    convertidos.sort((a, b) => b['data'].compareTo(a['data'])); // mais recentes primeiro

    setState(() {
      dados = convertidos.take(7).toList().reversed.toList(); // últimos 7, ordem cronológica
    });
  }

  List<FlSpot> _gerarPontosAgua() {
    return List.generate(dados.length, (i) {
      final total = (dados[i]['consumo'] as int?) ?? 0;
      return FlSpot(i.toDouble(), total.toDouble() / 1000); // valor em litros
    });
  }

  List<String> _diasDaSemana() {
    return dados.map((e) {
      final data = DateTime.parse(e['data']);
      return ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'][data.weekday - 1];
    }).toList();
  }


  @override
Widget build(BuildContext context) {
  final pontos = _gerarPontosAgua();
  final dias = _diasDaSemana();
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  // Cores dinâmicas para o texto
  final corTextoPrincipal = isDark ? Colors.white : Colors.black87;
  final corTextoSecundario = isDark ? Colors.white70 : Colors.black54;

  // Cor do card de acordo com o tema
  final corCard = isDark ? Color(0xFF1C1C3A) : Colors.blueAccent;

  return Scaffold(
    backgroundColor: theme.colorScheme.surface,
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
      title: Text("ESTATÍSTICAS ÁGUA", style: TextStyle(color: Colors.white)),
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
    body: Padding(
      padding: EdgeInsets.all(16),
      child: dados.isEmpty
          ? Center(
              child: MeuTexto(
                "Sem dados registrados.",
                Colors.transparent,
                corTextoSecundario,
                16,
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: MeuTexto(
                  "Consumo de Água (últimos 7 dias)",
                  Colors.transparent,
                  corTextoPrincipal,
                  18,
                ),
                ),
                SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true, drawVerticalLine: false),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, _) {
                              final index = value.toInt();
                              /*   
                              if (index < dias.length) {
                                return Text(
                                  dias[index],
                                  style: TextStyle(color: corTextoSecundario, fontSize: 12),
                                );
                              }
                              */
                              return Text('');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, _) {
                              return Text(
                                '${value.toStringAsFixed(1)}L',
                                style: TextStyle(color: corTextoSecundario, fontSize: 12),
                              );
                            },
                            interval: 0.5,
                          ),
                        ),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      minX: 0,
                      maxX: (dados.length - 1).toDouble(),
                      minY: 0,
                      maxY: 3,
                      lineBarsData: [
                        LineChartBarData(
                          spots: pontos,
                          isCurved: true,
                          color: Color(0xFF6C63FF),
                          barWidth: 3,
                          dotData: FlDotData(show: true),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),
                MeuTexto(
                  "Últimos Registros:",
                  Colors.transparent,
                  corTextoPrincipal,
                  16,
                ),
                SizedBox(height: 8),
                ...dados.map((dado) {
                  return Card(
                    color: corCard,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      title: MeuTexto(
                        "Data: ${dado['data']}",
                        Colors.transparent,
                        corTextoPrincipal,
                        16,
                      ),
                      subtitle: MeuTexto(
                        "Consumo: ${(dado['consumo'] / 1000).toStringAsFixed(2)} litros",
                        Colors.transparent,
                        corTextoSecundario,
                        14,
                      ),
                    ),
                  );
                }),
              ],
            ),
    ),
  );
}


  void _abreTela(BuildContext ctx, Widget page) {
    Navigator.push(ctx, MaterialPageRoute(builder: (_) => page));
  }
}
