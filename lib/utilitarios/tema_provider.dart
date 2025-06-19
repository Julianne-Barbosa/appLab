import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TemaProvider with ChangeNotifier {
  bool _modoEscuro = false;

  bool get modoEscuro => _modoEscuro;

  TemaProvider() {
    _carregarPreferencias();
  }

  void alternarTema(bool valor) {
    _modoEscuro = valor;
    _salvarPreferencias(valor);
    notifyListeners();
  }

  void _carregarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();
    _modoEscuro = prefs.getBool('modoEscuro') ?? false;
    notifyListeners();
  }

  void _salvarPreferencias(bool valor) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('modoEscuro', valor);
  }
}
