import 'package:applab/telaInicial.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/botoes.dart';
import '../utilitarios/firebase_helper.dart';
import 'telaLembretesSono.dart';
import 'telaEstatisticasSono.dart';

class TelaSono extends StatefulWidget {
  const TelaSono({super.key});

  @override
  State<TelaSono> createState() => _TelaSonoState();
}

class _TelaSonoState extends State<TelaSono> {
  TimeOfDay? horaDormir;
  TimeOfDay? horaAcordar;
  double? horasDormidas;
  int? qualidadeSono;
  final TextEditingController _horasDormidasController = TextEditingController();

  final firebaseHelper = FirebaseHelper();

  @override
  void initState() {
    super.initState();
    _carregarDadosFirebase();
  }

  Future<void> _carregarDadosFirebase() async {
    try {
      final dadosFirebase = await firebaseHelper.obterUltimoRegistroSono(
        FirebaseAuth.instance.currentUser?.uid ?? '',
      );

      if (dadosFirebase != null) {
        setState(() {
          horaDormir = TimeOfDay(
            hour: dadosFirebase['horaDormir'] ?? 22,
            minute: dadosFirebase['minutoDormir'] ?? 0,
          );
          horaAcordar = TimeOfDay(
            hour: dadosFirebase['horaAcordar'] ?? 8,
            minute: dadosFirebase['minutoAcordar'] ?? 0,
          );
          horasDormidas = dadosFirebase['horasDormidas']?.toDouble() ?? 0;
          qualidadeSono = dadosFirebase['qualidadeSono'] ?? 2;
          _horasDormidasController.text = horasDormidas.toString();
        });
      } else {
        setState(() {
          horaDormir = TimeOfDay(hour: 22, minute: 0);
          horaAcordar = TimeOfDay(hour: 7, minute: 0);
          horasDormidas = 0;
          qualidadeSono = 2;
          _horasDormidasController.text = '0';
        });
      }

      _calcularHorasDormidas();
    } catch (e) {
      debugPrint('Erro ao carregar dados do Firestore: $e');
    }
  }

  void _calcularHorasDormidas() {
    if (horaDormir != null && horaAcordar != null) {
      final dormir = DateTime(0, 1, 1, horaDormir!.hour, horaDormir!.minute);
      var acordar = DateTime(0, 1, 1, horaAcordar!.hour, horaAcordar!.minute);

      if (acordar.isBefore(dormir)) {
        acordar = acordar.add(Duration(days: 1));
      }

      final duration = acordar.difference(dormir);
      final double horas = duration.inMinutes / 60;

      setState(() {
        horasDormidas = horas;
        _horasDormidasController.text = horas.toStringAsFixed(1);
      });
    }
  }

  Future<void> _selecionarHora(BuildContext context, bool dormir) async {
    final TimeOfDay? hora = await showTimePicker(
      context: context,
      initialTime: dormir
          ? (horaDormir ?? TimeOfDay(hour: 23, minute: 0))
          : (horaAcordar ?? TimeOfDay(hour: 7, minute: 0)),
    );
    if (hora != null) {
      setState(() {
        if (dormir) {
          horaDormir = hora;
        } else {
          horaAcordar = hora;
        }
        _calcularHorasDormidas();
      });
    }
  }

  Future<void> _salvarDados() async {
    if (horaDormir == null ||
        horaAcordar == null ||
        horasDormidas == null ||
        qualidadeSono == null) {
      return;
    }

    final String dataHoje = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final dadosSono = {
      'horaDormir': horaDormir!.hour,
      'minutoDormir': horaDormir!.minute,
      'horaAcordar': horaAcordar!.hour,
      'minutoAcordar': horaAcordar!.minute,
      'horasDormidas': horasDormidas ?? 0,
      'qualidadeSono': qualidadeSono ?? 2,
      'data': dataHoje,
    };

    await firebaseHelper.salvarRegistroSono(
      dadosSono,
      FirebaseAuth.instance.currentUser?.uid ?? '',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Dados salvos com sucesso!")),
    );
  }


  void _abreTela(BuildContext ctx, Widget page) {
    Navigator.pushReplacement(ctx, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text("SONO", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Hora de Dormir", style: theme.textTheme.titleMedium),
              TextButton(
                onPressed: () => _selecionarHora(context, true),
                child: Text(
                  horaDormir?.format(context) ?? TimeOfDay(hour: 22, minute: 0).format(context),
                ),
              ),
              SizedBox(height: 10),
              Text("Hora de Acordar", style: theme.textTheme.titleMedium),
              TextButton(
                onPressed: () => _selecionarHora(context, false),
                child: Text(
                  horaAcordar?.format(context) ?? TimeOfDay(hour: 7, minute: 0).format(context),
                ),
              ),
              SizedBox(height: 10),
              Text("Horas Dormidas", style: theme.textTheme.titleMedium),
              TextField(
                controller: _horasDormidasController,
                keyboardType: TextInputType.number,
                onChanged: (value) => horasDormidas = double.tryParse(value.trim()),
                decoration: InputDecoration(hintText: "Ex: 7"),
              ),
              SizedBox(height: 10),
              Text("Qualidade do Sono", style: theme.textTheme.titleMedium),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: Text("😴 Ótimo", style: TextStyle(fontSize: 20)),
                    onPressed: () => setState(() => qualidadeSono = 1),
                    color: qualidadeSono == 1 ? theme.colorScheme.primary : null,
                  ),
                  IconButton(
                    icon: Text("🙂 Ok", style: TextStyle(fontSize: 20)),
                    onPressed: () => setState(() => qualidadeSono = 2),
                    color: qualidadeSono == 2 ? theme.colorScheme.primary : null,
                  ),
                  IconButton(
                    icon: Text("😫 Péssimo", style: TextStyle(fontSize: 20)),
                    onPressed: () => setState(() => qualidadeSono = 3),
                    color: qualidadeSono == 3 ? theme.colorScheme.primary : null,
                  ),
                ],
              ),
              SizedBox(height: 20),
              Botoes(
                text: "Salvar Dados",
                onPressed: () => _salvarDados(),
                backgroundColor: Colors.blueAccent,
                textColor: Colors.white,
                width: double.infinity,
                height: 50,
                borderRadius: 12,
                icon: Icon(Icons.save, color: Colors.white),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () => _abreTela(context, TelaInicial()),
            ),
            IconButton(
              icon: Icon(Icons.notifications),
              onPressed: () => _abreTela(context, TelaLembretesSono()),
            ),
            IconButton(
              icon: Icon(Icons.bar_chart),
              onPressed: () => _abreTela(context, TelaEstatisticasSono()),
            ),
          ],
        ),
      ),
    );
  }
}

