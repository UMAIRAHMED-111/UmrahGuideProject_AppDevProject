import 'package:equatable/equatable.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  const ChatMessage({required this.text, required this.isUser});
}

abstract class HelpAIState extends Equatable {
  const HelpAIState();
  @override
  List<Object?> get props => [];
}

class HelpAIInitial extends HelpAIState {}

class HelpAIChatState extends HelpAIState {
  final List<ChatMessage> messages;
  final bool isTyping;
  final bool connectivityChecked;

  const HelpAIChatState({
    required this.messages,
    required this.isTyping,
    required this.connectivityChecked,
  });

  HelpAIChatState copyWith({
    List<ChatMessage>? messages,
    bool? isTyping,
    bool? connectivityChecked,
  }) {
    return HelpAIChatState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      connectivityChecked: connectivityChecked ?? this.connectivityChecked,
    );
  }

  @override
  List<Object?> get props => [messages, isTyping, connectivityChecked];
} 