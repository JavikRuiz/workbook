import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libro_de_tareas/features/tasks/providers/task_providers.dart';
import 'package:libro_de_tareas/providers/global_providers.dart';
import 'package:libro_de_tareas/services/voice_recognition_service.dart';

class VoiceState {
  final bool isListening;
  final String recognizedText;
  final String? error;

  VoiceState({
    required this.isListening,
    required this.recognizedText,
    this.error,
  });

  VoiceState copyWith({
    bool? isListening,
    String? recognizedText,
    String? error,
  }) {
    return VoiceState(
      isListening: isListening ?? this.isListening,
      recognizedText: recognizedText ?? this.recognizedText,
      error: error ?? this.error,
    );
  }
}

class VoiceNotifier extends StateNotifier<VoiceState> {
  final VoiceRecognitionService _service;
  final Ref _ref;

  VoiceNotifier(this._service, this._ref)
      : super(VoiceState(isListening: false, recognizedText: ''));

  /// Toggles the voice recorder state.
  Future<void> toggleListening() async {
    if (state.isListening) {
      await stopListening();
    } else {
      await startListening();
    }
  }

  /// Starts voice recognition.
  Future<void> startListening() async {
    state = VoiceState(isListening: true, recognizedText: 'Escuchando...');

    await _service.startListening(
      onResult: (text) {
        state = state.copyWith(recognizedText: text);
      },
      onListeningFinished: () async {
        final text = state.recognizedText;
        if (text.trim().isNotEmpty && text != 'Escuchando...') {
          // Add task automatically to database via controller
          await _ref.read(tasksControllerProvider).addTask(
                title: text,
                dueDate: DateTime.now().add(const Duration(days: 1)),
              );
          state = VoiceState(
              isListening: false, recognizedText: '¡Tarea "$text" creada!');
        } else {
          state = VoiceState(isListening: false, recognizedText: '');
        }
      },
      onError: (err) {
        state = VoiceState(isListening: false, recognizedText: '', error: err);
      },
    );
  }

  /// Stops voice recognition.
  Future<void> stopListening() async {
    await _service.stopListening();
    state = state.copyWith(isListening: false);
  }

  /// Clears current message or error
  void reset() {
    state = VoiceState(isListening: false, recognizedText: '');
  }
}

final voiceProvider = StateNotifierProvider<VoiceNotifier, VoiceState>((ref) {
  final service = ref.watch(voiceRecognitionServiceProvider);
  return VoiceNotifier(service, ref);
});
