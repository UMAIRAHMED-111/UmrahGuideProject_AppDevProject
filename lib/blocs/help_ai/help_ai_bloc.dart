import 'package:flutter_bloc/flutter_bloc.dart';
import 'help_ai_event.dart';
import 'help_ai_state.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HelpAIBloc extends Bloc<HelpAIEvent, HelpAIState> {
  HelpAIBloc() : super(HelpAIInitial()) {
    on<SendMessageEvent>(_onSendMessage);
    on<ReceiveMessageEvent>(_onReceiveMessage);
    on<SetTypingEvent>(_onSetTyping);
    on<CheckConnectivityEvent>(_onCheckConnectivity);
  }

  Future<void> _onSendMessage(SendMessageEvent event, Emitter<HelpAIState> emit) async {
    final currentState = state is HelpAIChatState
        ? state as HelpAIChatState
        : HelpAIChatState(messages: [], isTyping: false, connectivityChecked: false);
    final updatedMessages = List<ChatMessage>.from(currentState.messages)
      ..add(ChatMessage(text: event.message, isUser: true));
    emit(currentState.copyWith(messages: updatedMessages, isTyping: true));

    try {
      final response = await http.post(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=AIzaSyBN6KebKnWt84NOZsFV0FQVEMxtXWPlgDc'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text': 'You are an Umrah guide assistant. Please answer the following question about Umrah rituals, duas, or any related topic: ${event.message}'
                }
              ]
            }
          ]
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiResponse = data['candidates'][0]['content']['parts'][0]['text'];
        add(ReceiveMessageEvent(aiResponse));
      } else {
        add(const ReceiveMessageEvent('Sorry, I encountered an error. Please try again.'));
      }
    } catch (e) {
      add(const ReceiveMessageEvent('Sorry, I encountered an error. Please try again.'));
    }
  }

  void _onReceiveMessage(ReceiveMessageEvent event, Emitter<HelpAIState> emit) {
    final currentState = state is HelpAIChatState
        ? state as HelpAIChatState
        : HelpAIChatState(messages: [], isTyping: false, connectivityChecked: false);
    final updatedMessages = List<ChatMessage>.from(currentState.messages)
      ..add(ChatMessage(text: event.message, isUser: false));
    emit(currentState.copyWith(messages: updatedMessages, isTyping: false));
  }

  void _onSetTyping(SetTypingEvent event, Emitter<HelpAIState> emit) {
    final currentState = state is HelpAIChatState
        ? state as HelpAIChatState
        : HelpAIChatState(messages: [], isTyping: false, connectivityChecked: false);
    emit(currentState.copyWith(isTyping: event.isTyping));
  }

  Future<void> _onCheckConnectivity(CheckConnectivityEvent event, Emitter<HelpAIState> emit) async {
    final currentState = state is HelpAIChatState
        ? state as HelpAIChatState
        : HelpAIChatState(messages: [], isTyping: false, connectivityChecked: false);
    if (currentState.connectivityChecked) return;
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      // You can handle showing a snackbar in the UI if needed
    }
    emit(currentState.copyWith(connectivityChecked: true));
  }
} 