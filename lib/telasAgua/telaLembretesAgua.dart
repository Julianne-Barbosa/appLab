import 'package:applab/telasAgua/telaAgua.dart';
import 'package:applab/telasAgua/telaEstatisticasAgua.dart';
import 'package:applab/telaInicial.dart';
import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TelaLembretesAgua extends StatefulWidget {
  const TelaLembretesAgua({super.key});

  @override
  State<TelaLembretesAgua> createState() => _TelaLembretesAguaState();
}

class _TelaLembretesAguaState extends State<TelaLembretesAgua> {
  List<Map<String, dynamic>> lembretes = [];

  @override
  void initState() {
    super.initState();
    AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'agua_channel',
          channelName: 'Lembretes de Água',
          channelDescription: 'Notificações para lembrar de beber água',
          defaultColor: const Color(0xFF6C63FF),
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
              'id': l['id'],
              'ativo': l['ativo'],
            })
        .toList();
    prefs.setString('lembretes_agua', jsonEncode(dados));
  }

  Future<void> carregarLembretes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('lembretes_agua');
    if (jsonString != null) {
      final List dados = jsonDecode(jsonString);
      setState(() {
        lembretes = dados.map<Map<String, dynamic>>((l) {
          final partes = l['hora'].split(':');
          return {
            'hora': TimeOfDay(
                hour: int.parse(partes[0]), minute: int.parse(partes[1])),
            'id': l['id'],
            'ativo': l['ativo'],
          };
        }).toList();
      });
    }
  }

  Future<void> agendarNotificacao(TimeOfDay hora, int id) async {
    final now = DateTime.now();
    final dateTime =
        DateTime(now.year, now.month, now.day, hora.hour, hora.minute);

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'agua_channel',
        title: 'Hora de beber água!',
        body: 'Hidrate-se para manter sua saúde em dia.',
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar(
        hour: hora.hour,
        minute: hora.minute,
        second: 0,
        millisecond: 0,
        repeats: true,
      ),
    );

    salvarLembretes();
  }

  Future<void> cancelarNotificacao(int id) async {
    await AwesomeNotifications().cancel(id);
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
      final novoId = DateTime.now().millisecondsSinceEpoch.remainder(100000);
      await agendarNotificacao(horaSelecionada, novoId);
      setState(() {
        lembretes.add({
          'hora': horaSelecionada,
          'id': novoId,
          'ativo': true,
        });
      });
    }

    salvarLembretes();
  }

  void alternarLembrete(int index) async {
    final item = lembretes[index];
    setState(() {
      lembretes[index]['ativo'] = !item['ativo'];
    });

    if (lembretes[index]['ativo']) {
      await agendarNotificacao(item['hora'], item['id']);
    } else {
      await cancelarNotificacao(item['id']);
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
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0056D2), Color(0xFF63D4F2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text("LEMBRETES ÁGUA", style: TextStyle(color: Colors.white)),
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
        icon: Icon(Icons.water_drop),
        color: theme.colorScheme.primary,
        onPressed: () => _abreTela(context, TelaAgua()),
      ),
      IconButton(
        icon: Icon(Icons.bar_chart),
        color: theme.colorScheme.primary,
        onPressed: () => _abreTela(context, TelaEstatisticasAgua()),
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
                        formatarHora(item['hora']),
                        style: TextStyle(color: textColor, fontSize: 20),
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
