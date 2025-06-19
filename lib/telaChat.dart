import 'package:flutter/material.dart';
import 'utilitarios/api_service.dart';
import 'utilitarios/chat_database.dart';

class TelaChat extends StatefulWidget {
  const TelaChat({super.key});

  @override
  State<TelaChat> createState() => _TelaChatState();
}

class _TelaChatState extends State<TelaChat> {
  final _controller = TextEditingController();
  final List<String> _conversas = [];
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _carregarConversasSalvas();
  }

  Future<void> _carregarConversasSalvas() async {
    final conversasSalvas = await ConversaDatabase.carregarConversas();
    setState(() {
      _conversas.addAll(conversasSalvas);
    });
    _irParaFinal();
  }

  void _irParaFinal() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _enviarMensagem([String? textoSugestao]) async {
    final mensagem = textoSugestao ?? _controller.text.trim();
    if (mensagem.isEmpty) return;

    setState(() {
      _conversas.add("Você: $mensagem");
      if (textoSugestao == null) _controller.clear();
    });
    _irParaFinal();

    await ConversaDatabase.salvarConversa(mensagem, "usuario");

    final resposta = await enviarParaMistral(mensagem);

    setState(() {
      _conversas.add("IA: $resposta");
    });
    _irParaFinal();

    await ConversaDatabase.salvarConversa(resposta, "ia");
  }

  void _mostrarSugestoes() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.all(16),
          child: Wrap(
            runSpacing: 10,
            children: [
              Text(
                "Sugestões rápidas:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              _buildSugestao("Monte um plano de exercícios"),
              _buildSugestao("Me ensine uma técnica de relaxamento"),
              _buildSugestao("Dicas para dormir melhor"),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSugestao(String texto) {
    return ListTile(
      title: Text(texto),
      trailing: Icon(Icons.send),
      onTap: () {
        Navigator.pop(context);
        _enviarMensagem(texto);
      },
    );
  }

  Widget _mensagemChat(String texto) {
    final ehIA = texto.startsWith("IA:");
    final ehUsuario = texto.startsWith("Você:");

    String conteudo = texto;
    if (ehIA) conteudo = texto.replaceFirst("IA: ", "");
    if (ehUsuario) conteudo = texto.replaceFirst("Você: ", "");

    return Align(
      alignment: ehIA ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: ehIA ? Colors.grey.shade200 : Colors.lightBlueAccent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          conteudo,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
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
        title: Text("VITA AI CHAT", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () async {
              await ConversaDatabase.limparConversas();
              setState(() {
                _conversas.clear();
              });
            },
          )
        ],
      ),
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _conversas.length,
                itemBuilder: (context, index) {
                  return _mensagemChat(_conversas[index]);
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Digite sua mensagem...",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: _enviarMensagem,
                  ),
                  IconButton(
                    icon: Icon(Icons.lightbulb_outline),
                    tooltip: "Sugestões de conversa",
                    onPressed: _mostrarSugestoes,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
