import 'package:cloud_firestore/cloud_firestore.dart';

class ConversaDatabase {
  static final _firestore = FirebaseFirestore.instance;
  static final _colecaoConversas = _firestore.collection('conversas');

  static Future<void> salvarConversa(String mensagem, String autor) async {
    await _colecaoConversas.add({
      'mensagem': mensagem,
      'autor': autor,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  static Future<List<String>> carregarConversas() async {
    final snapshot = await _colecaoConversas.orderBy('timestamp').get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      final autor = data['autor'] == 'usuario' ? 'Você' : 'IA';
      return "$autor: ${data['mensagem']}";
    }).toList();
  }

  static Future<void> limparConversas() async {
    final snapshot = await _colecaoConversas.get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
