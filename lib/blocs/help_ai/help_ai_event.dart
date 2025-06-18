import 'package:equatable/equatable.dart';

abstract class HelpAIEvent extends Equatable {
  const HelpAIEvent();

  @override
  List<Object?> get props => [];
}

class SendMessageEvent extends HelpAIEvent {
  final String message;
  const SendMessageEvent(this.message);
  @override
  List<Object?> get props => [message];
}

class ReceiveMessageEvent extends HelpAIEvent {
  final String message;
  const ReceiveMessageEvent(this.message);
  @override
  List<Object?> get props => [message];
}

class SetTypingEvent extends HelpAIEvent {
  final bool isTyping;
  const SetTypingEvent(this.isTyping);
  @override
  List<Object?> get props => [isTyping];
}

class CheckConnectivityEvent extends HelpAIEvent {} 