import 'package:applab/telaInicial.dart';
import 'package:applab/telasExercicios/telaEstatisticasExercicios.dart';
import 'package:applab/telasExercicios/telaExercicios.dart';
import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TelaLembretesExercicios extends StatefulWidget {
  const TelaLembretesExercicios({super.key});

  @override
  State<TelaLembretesExercicios> createState() => _TelaLembretesExerciciosState();
}

class _TelaLembretesExerciciosState extends State<TelaLembretesExercicios> {
  List<Map<String, dynamic>> lembretes = [];

  @override
  void initState() {
    super.initState();
    AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'exercicio_channel',
          channelName: 'Lembretes de Exercício',
          channelDescription: 'Notificações para lembrar de se exercitar',
          defaultColor: Color(0xFF6C63FF),
          importance: NotificationImportance.High,
          channelShowBadge: true,
        )
      ],
      debug: true,
    );
    _pedirPermissaoNotificacao();
    carregarLembretes();
  }

  void _pedirPermissaoNotificacao() {
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  Future<void> salvarLembretes() async {
    final prefs = await SharedPreferences.getInstance();
    final dados = lembretes
        .map((l) => {
              'hora': '${l['hora'].hour}:${l['hora'].minute}',
              'dias': l['dias'],
              'id': l['id'],
              'ativo': l['ativo'],
            })
        .toList();
    prefs.setString('lembretes_exercicio', jsonEncode(dados));
  }

  Future<void> carregarLembretes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('lembretes_exercicio');
    if (jsonString != null) {
      final List dados = jsonDecode(jsonString);
      setState(() {
        lembretes = dados.map<Map<String, dynamic>>((l) {
          final partes = l['hora'].split(':');
          return {
            'hora': TimeOfDay(hour: int.parse(partes[0]), minute: int.parse(partes[1])),
            'dias': List<String>.from(l['dias']),
            'id': l['id'],
            'ativo': l['ativo'],
          };
        }).toList();
      });
    }
  }

  Future<void> agendarNotificacao(TimeOfDay hora, List<String> dias, int id) async {
    for (String dia in dias) {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id + dia.hashCode,
          channelKey: 'exercicio_channel',
          title: 'Hora de se exercitar!',
          body: 'Movimente-se para manter sua saúde em dia.',
          notificationLayout: NotificationLayout.Default,
        ),
        schedule: NotificationCalendar(
          weekday: _diaParaNumero(dia),
          hour: hora.hour,
          minute: hora.minute,
          second: 0,
          millisecond: 0,
          repeats: true,
        ),
      );
    }
  }

  int _diaParaNumero(String dia) {
    switch (dia) {
      case 'Seg':
        return DateTime.monday;
      case 'Ter':
        return DateTime.tuesday;
      case 'Qua':
        return DateTime.wednesday;
      case 'Qui':
        return DateTime.thursday;
      case 'Sex':
        return DateTime.friday;
      case 'Sáb':
        return DateTime.saturday;
      case 'Dom':
        return DateTime.sunday;
      default:
        return DateTime.monday;
    }
  }

  Future<void> cancelarNotificacao(int id, List<String> dias) async {
    for (String dia in dias) {
      await AwesomeNotifications().cancel(id + dia.hashCode);
    }
  }

  void adicionarLembrete() async {
    final TimeOfDay? horaSelecionada = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (horaSelecionada != null) {
      final List<String> diasSelecionados = await selecionarDiasSemana();

      if (diasSelecionados.isNotEmpty) {
        final novoId = DateTime.now().millisecondsSinceEpoch.remainder(100000);
        await agendarNotificacao(horaSelecionada, diasSelecionados, novoId);
        setState(() {
          lembretes.add({
            'hora': horaSelecionada,
            'dias': diasSelecionados,
            'id': novoId,
            'ativo': true,
          });
        });

        salvarLembretes();
      }
    }
  }

  Future<List<String>> selecionarDiasSemana() async {
    final dias = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    List<String> selecionados = [];

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Escolha os dias'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: dias
                    .map((dia) => CheckboxListTile(
                          title: Text(dia),
                          value: selecionados.contains(dia),
                          onChanged: (value) {
                            setState(() {
                              if (value!) {
                                selecionados.add(dia);
                              } else {
                                selecionados.remove(dia);
                              }
                            });
                          },
                        ))
                    .toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Confirmar'),
                ),
              ],
            );
          },
        );
      },
    );

    return selecionados;
  }

  void alternarLembrete(int index) async {
    final item = lembretes[index];
    setState(() {
      lembretes[index]['ativo'] = !item['ativo'];
    });

    if (lembretes[index]['ativo']) {
      await agendarNotificacao(item['hora'], item['dias'], item['id']);
    } else {
      await cancelarNotificacao(item['id'], item['dias']);
    }

    salvarLembretes();
  }

  String formatarHora(TimeOfDay hora) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, hora.hour, hora.minute);
    return DateFormat('HH:mm').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Color(0xFF0D0D2B) : Colors.grey[100];
    final cardColor = isDark ? Color(0xFF1C1C3A) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0056D2), Color(0xFF63D4F2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text("LEMBRETES EXERCÍCIO", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: adicionarLembrete,
        child: Icon(Icons.add),
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
              icon: Icon(Icons.bar_chart),
              color: theme.colorScheme.primary,
              onPressed: () => _abreTela(context, TelaEstatisticasExercicios()),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: lembretes.isEmpty
            ? Center(
                child: Text(
                  "Nenhum lembrete configurado.",
                  style: TextStyle(color: textColor.withOpacity(0.7)),
                ),
              )
            : ListView.builder(
                itemCount: lembretes.length,
                itemBuilder: (context, index) {
                  final item = lembretes[index];
                  return Card(
                    color: cardColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      title: Text(
                        '${formatarHora(item['hora'])} - ${item['dias'].join(', ')}',
                        style: TextStyle(color: textColor, fontSize: 18),
                      ),
                      trailing: Switch(
                        value: item['ativo'],
                        onChanged: (_) => alternarLembrete(index),
                        activeColor: Colors.blueAccent,
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  void _abreTela(BuildContext ctx, Widget page) {
    Navigator.push(ctx, MaterialPageRoute(builder: (_) => page));
  }
}
