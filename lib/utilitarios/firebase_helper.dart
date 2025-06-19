import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class FirebaseHelper {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference _sonoCollection = _firestore.collection('sono_dados');

  // Para adicionar um novo registro de sono
  static Future<void> adicionarSono(Map<String, dynamic> dados) async {
    try {
      await _sonoCollection.add(dados);
    } catch (e) {
      print('Erro ao adicionar dados no Firebase: $e');
    }
  }

  // Para recuperar todos os registros
  static Future<List<Map<String, dynamic>>> buscarTodos() async {
    try {
      final snapshot = await _sonoCollection.orderBy('data', descending: true).get();
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print('Erro ao buscar dados: $e');
      return [];
    }
  }

  // Para atualizar um registro por ID
  static Future<void> atualizarSono(String docId, Map<String, dynamic> novosDados) async {
    try {
      await _sonoCollection.doc(docId).update(novosDados);
    } catch (e) {
      print('Erro ao atualizar dados: $e');
    }
  }

  // Para deletar um registro por ID
  static Future<void> deletarSono(String docId) async {
    try {
      await _sonoCollection.doc(docId).delete();
    } catch (e) {
      print('Erro ao deletar dados: $e');
    }
  }


  Future<void> salvarRegistroSono(Map<String, dynamic> dadosSono, String userId) async {
    try {
      String? data = dadosSono['data'];
      if (data == null) {
        data = DateFormat('yyyy-MM-dd').format(DateTime.now());
        dadosSono['data'] = data;
      }

      final docRef = _firestore.collection('dados_sono').doc(data);

      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        await docRef.update(dadosSono);
      } else {
        await docRef.set(dadosSono);
      }
    } catch (e) {
      print('Erro ao salvar registro de sono no Firebase: $e');
    }
  }



 Future<Map<String, dynamic>?> obterUltimoRegistroSono(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('dados_sono')
          .orderBy('data', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data();
      }
      return null;
    } catch (e) {
      print('Erro ao obter registro de sono: $e');
      return null;
    }
  }
}


