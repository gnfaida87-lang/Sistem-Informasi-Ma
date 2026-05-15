import 'package:flutter/material.dart';
import '../../../shared/services/ai_service.dart';

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
  final AIService _aiService = AIService();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _messages.add({
      'role': 'assistant',
      'text': 'Halo! Saya AI ${widget.assistantName}. Ada yang bisa saya bantu hari ini?',
    });
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty || _isTyping) return;
    
    final userText = _controller.text.trim();
    _controller.clear();

    setState(() {
      _messages.add({
        'role': 'user',
        'text': userText,
      });
      _isTyping = true;
    });

    try {
      // Ambil riwayat singkat (misal 5 pesan terakhir)
      final history = _messages.length > 1 
          ? _messages.sublist(1, _messages.length - 1) 
          : <Map<String, dynamic>>[];

      final response = await _aiService.getChatResponse(
        assistantName: widget.assistantName,
        prompt: userText,
        history: history,
      );

      if (!mounted) return;
      setState(() {
        _messages.add({
          'role': 'assistant',
          'text': response,
        });
        _isTyping = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add({
          'role': 'assistant',
          'text': "Maaf, terjadi kendala koneksi. Silakan coba lagi nanti.",
        });
        _isTyping = false;
      });
    }
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
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(strokeWidth: 2, color: widget.themeColor),
                          ),
                          const SizedBox(width: 8),
                          Text('Sedang mengetik...', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                  );
                }
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
