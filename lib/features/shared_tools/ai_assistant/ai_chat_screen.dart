import 'package:flutter/material.dart';

class AIChatScreen extends StatefulWidget {
  final String assistantName; // e.g., "Sahabat Belajar" or "Sahabat Guru"
  final Color themeColor;

  const AIChatScreen({
    super.key, 
    required this.assistantName, 
    required this.themeColor
  });

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _messages.add({
      'role': 'assistant',
      'text': 'Halo! Saya AI ${widget.assistantName}. Ada yang bisa saya bantu hari ini?',
    });
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    
    setState(() {
      _messages.add({
        'role': 'user',
        'text': _controller.text,
      });
      
      // Simulating AI Response after a delay
      String userText = _controller.text.toLowerCase();
      _controller.clear();
      
      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        setState(() {
          String response = 'Tentu, saya bisa membantu Anda terkait hal tersebut. Apakah ada detail spesifik yang ingin Anda tanyakan?';
          if (userText.contains('halo') || userText.contains('hi')) {
            response = 'Halo juga! Senang bisa menyapa Anda.';
          } else if (userText.contains('terima kasih')) {
            response = 'Sama-sama! Senang bisa membantu.';
          }
          
          _messages.add({
            'role': 'assistant',
            'text': response,
          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI ${widget.assistantName}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: widget.themeColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                bool isUser = _messages[index]['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isUser ? widget.themeColor : Colors.grey.shade200,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft: Radius.circular(isUser ? 12 : 0),
                        bottomRight: Radius.circular(isUser ? 0 : 12),
                      ),
                    ),
                    child: Text(
                      _messages[index]['text'],
                      style: TextStyle(color: isUser ? Colors.white : Colors.black87),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Ketik pesan Anda...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _sendMessage,
                  icon: Icon(Icons.send, color: widget.themeColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
