import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/help_ai/help_ai_bloc.dart';
import '../../blocs/help_ai/help_ai_event.dart';
import '../../blocs/help_ai/help_ai_state.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:ui';
import 'package:connectivity_plus/connectivity_plus.dart';

class HelpAIScreen extends StatelessWidget {
  const HelpAIScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HelpAIBloc(),
      child: const _HelpAIView(),
    );
  }
}

class _HelpAIView extends StatefulWidget {
  const _HelpAIView({Key? key}) : super(key: key);

  @override
  State<_HelpAIView> createState() => _HelpAIViewState();
}

class _HelpAIViewState extends State<_HelpAIView> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage(BuildContext context) {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();
    context.read<HelpAIBloc>().add(SendMessageEvent(text));
  }

  Future<void> _checkConnectivityAndShowSnackbar(BuildContext context, bool connectivityChecked) async {
    if (connectivityChecked) return;
    context.read<HelpAIBloc>().add(CheckConnectivityEvent());
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No internet connection. Some features may not work.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HelpAIBloc, HelpAIState>(
      builder: (context, state) {
        List<ChatMessage> messages = [];
        bool isTyping = false;
        bool connectivityChecked = false;
        if (state is HelpAIChatState) {
          messages = state.messages;
          isTyping = state.isTyping;
          connectivityChecked = state.connectivityChecked;
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _checkConnectivityAndShowSnackbar(context, connectivityChecked);
        });

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text('Help & AI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Cairo', fontSize: 26)),
            centerTitle: true,
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F3D2E), Color(0xFF1A6244)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 12),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          return _buildMessageBubble(message);
                        },
                      ),
                    ),
                    if (isTyping)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'AI is typing...',
                          style: TextStyle(
                            color: Colors.white70,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            style: const TextStyle(color: Colors.white),
                            cursorColor: Colors.white,
                            decoration: InputDecoration(
                              hintText: 'Type your question...',
                              hintStyle: TextStyle(color: Colors.white54),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.1),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                            onSubmitted: (_) => _sendMessage(context),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => _sendMessage(context),
                          icon: const Icon(Icons.send, color: Color(0xFF32D27F)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: message.isUser ? const Color(0xFF32D27F) : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: message.isUser
            ? Text(
                message.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              )
            : MarkdownBody(
                data: message.text,
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(color: Colors.white, fontSize: 14),
                  strong: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  em: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
                  listBullet: const TextStyle(color: Colors.white, fontSize: 14),
                  blockquote: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
                  code: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
                ),
              ),
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  _ChatMessage({required this.text, required this.isUser});
} 