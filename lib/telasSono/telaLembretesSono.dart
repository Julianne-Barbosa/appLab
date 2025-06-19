import 'package:applab/telaInicial.dart';
import 'package:applab/telasSono/telaEstatisticasSono.dart';
import 'package:applab/telasSono/telaSono.dart';
import 'package:applab/widgets/botoes.dart';
import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:timezone/data/latest.dart' as tzData;
import 'package:cloud_firestore/cloud_firestore.dart';

class TelaLembretesSono extends StatefulWidget {
  const TelaLembretesSono({super.key});

  @override
  _TelaLembretesSonoState createState() => _TelaLembretesSonoState();
}

class _TelaLembretesSonoState extends State<TelaLembretesSono> {
  TimeOfDay dormir = TimeOfDay(hour: 22, minute: 0);
  TimeOfDay acordar = TimeOfDay(hour: 7, minute: 0);
  bool lembreteAtivo = true;
  int tempoAntesDormir = 15;
  List<bool> diasSelecionados = List.generate(7, (index) => false);

  final List<String> nomesDias = [
    'Dom',
    'Seg',
    'Ter',
    'Qua',
    'Qui',
    'Sex',
    'Sáb'
  ];

  @override
  void initState() {
    super.initState();
    tzData.initializeTimeZones();
    AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'sono_channel',
          channelName: 'Lembretes de Sono',
          channelDescription: 'Notificações para dormir e acordar',
          importance: NotificationImportance.High,
        )
      ],
    );
  }

  int getDuracaoSono() {
    final inicio = dormir.hour * 60 + dormir.minute;
    final fim = acordar.hour * 60 + acordar.minute;
    return fim >= inicio ? fim - inicio : (1440 - inicio + fim);
  }

  String _formatarHorario(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _selecionaHorario(bool ehDormir) async {
    final resultado = await showTimePicker(
      context: context,
      initialTime: ehDormir ? dormir : acordar,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (resultado != null) {
      setState(() {
        if (ehDormir) {
          dormir = resultado;
        } else {
          acordar = resultado;
        }
      });
    }
  }

  TimeOfDay _ajustaHorario(TimeOfDay hora, int minutos) {
    final totalMinutos = hora.hour * 60 + hora.minute + minutos;
    final novaHora = (totalMinutos ~/ 60) % 24;
    final novoMin = totalMinutos % 60;
    return TimeOfDay(hour: novaHora, minute: novoMin);
  }

  Future<void> agendarNotificacoes() async {
    await AwesomeNotifications().cancelAll();

    for (int i = 0; i < 7; i++) {
      if (diasSelecionados[i]) {
        final dia = i;
        final horarioDormir = _ajustaHorario(dormir, -tempoAntesDormir);
        await _agendarNotificacao(
            dia, horarioDormir, 'Hora de se preparar para dormir!', 100 + i);
        await _agendarNotificacao(dia, acordar, 'Hora de acordar!', 200 + i);
      }
    }

    await _salvarNoFirebase();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Notificações agendadas!')),
      );
    }
  }

  Future<void> _agendarNotificacao(
      int diaSemana, TimeOfDay hora, String msg, int id) async {
    final agora = DateTime.now();
    var data = DateTime(
      agora.year,
      agora.month,
      agora.day,
      hora.hour,
      hora.minute,
    );

    while (data.weekday != diaSemana + 1 || data.isBefore(agora)) {
      data = data.add(const Duration(days: 1));
    }

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'sono_channel',
        title: 'Vita',
        body: msg,
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar(
        weekday: data.weekday,
        hour: data.hour,
        minute: data.minute,
        second: 0,
        repeats: true,
      ),
    );
  }

  Future<void> _salvarNoFirebase() async {
    try {
      final duracao = getDuracaoSono();
      final data = DateTime.now().toIso8601String().split('T')[0];
      final docRef =
          FirebaseFirestore.instance.collection('dados_sono').doc(data);
      await docRef.set({
        'data': data,
        'horaDormir': dormir.hour,
        'minutoDormir': dormir.minute,
        'horaAcordar': acordar.hour,
        'minutoAcordar': acordar.minute,
        'duracao': duracao,
        'lembreteAtivo': lembreteAtivo ? 1 : 0,
        'tempoAntesDormir': tempoAntesDormir,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Erro ao salvar no Firebase: $e');
    }
  }

  Widget _cardHorario(
      String titulo, TimeOfDay hora, bool ehDormir, IconData icone) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => _selecionaHorario(ehDormir),
      child: Container(
        width: 140,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icone, color: Colors.white, size: 20),
                 SizedBox(height: 8),
            Text(titulo,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: Colors.white.withOpacity(0.8))),
            SizedBox(height: 4),
            Text(
              _formatarHorario(hora),
              style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final duracao = getDuracaoSono();
    final horas = duracao ~/ 60;
    final minutos = duracao % 60;
    final theme = Theme.of(context);

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
        title: Text("LEMBRETES SONO", style: TextStyle(color: Colors.white)),
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
              icon: Icon(Icons.nightlight_round),
              color: theme.colorScheme.primary,
              onPressed: () => _abreTela(context, TelaSono()),
            ),
            IconButton(
              icon: Icon(Icons.bar_chart),
              color: theme.colorScheme.primary,
              onPressed: () => _abreTela(context, TelaEstatisticasSono()),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 10),
              SleekCircularSlider(
                initialValue: duracao.toDouble(),
                min: 0,
                max: 720,
                appearance: CircularSliderAppearance(
                  infoProperties: InfoProperties(
                    mainLabelStyle: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                    ),
                    modifier: (value) =>
                        '$horas h ${minutos.toString().padLeft(2, '0')} m',
                  ),
                  customColors: CustomSliderColors(
                    progressBarColor: Colors.blueAccent,
                    trackColor:
                        theme.colorScheme.onSurface.withOpacity(0.24),
                    dotColor: theme.colorScheme.onPrimary,
                  ),
                  size: 220,
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _cardHorario("Dormir", dormir, true, Icons.nightlight_round),
                  _cardHorario("Acordar", acordar, false, Icons.wb_sunny),
                ],
              ),
            SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Lembrete", style: theme.textTheme.bodyLarge),
                  Switch(
                    value: lembreteAtivo,
                    onChanged: (valor) => setState(() => lembreteAtivo = valor),
                    activeColor: theme.colorScheme.primary,
                  ),
                ],
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  labelText: "Notificar antes de dormir",
                  labelStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7)),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: theme.colorScheme.primary.withOpacity(0.5))),
                ),
                value: tempoAntesDormir,
                items: [5, 10, 15, 20, 30]
                    .map((e) => DropdownMenuItem(value: e, child: Text("$e min")))
                    .toList(),
                onChanged: (valor) {
                  if (valor != null) setState(() => tempoAntesDormir = valor);
                },
              ),
              SizedBox(height: 10),
              Text("Dias da semana para notificar",
                  style: theme.textTheme.bodyLarge),
              SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: List.generate(
                  7,
                  (index) => FilterChip(
                    label: Text(nomesDias[index]),
                    selected: diasSelecionados[index],
                    onSelected: (selecionado) {
                      setState(() => diasSelecionados[index] = selecionado);
                    },
                    selectedColor: Colors.blueAccent.withOpacity(0.6),
                    checkmarkColor: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 15),
              Botoes(
                text: "Agendar notificações",
                onPressed:  () {
                  if (lembreteAtivo) {
                    agendarNotificacoes();
                  }
                },
                backgroundColor: Colors.blueAccent,
                textColor: Colors.white,
                width: double.infinity,
                height: 40,
                borderRadius: 12,
                icon: Icon(Icons.notifications, color: Colors.white),
              )
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
