import 'dart:developer' as developer;
import 'package:speech_to_text/speech_to_text.dart';

class VoiceRecognitionService {
  final SpeechToText _speech = SpeechToText();
  bool _isInitialized = false;

  bool get isListening => _speech.isListening;
  bool get isAvailable => _isInitialized;

  /// Inicializa el servicio de reconocimiento de voz.
  Future<bool> init() async {
    if (_isInitialized) return true;

    try {
      _isInitialized = await _speech.initialize(
        onError: (val) => developer.log('Error de voz: ${val.errorMsg}',
            name: 'VoiceService'),
        onStatus: (val) =>
            developer.log('Estado de voz: $val', name: 'VoiceService'),
      );
      return _isInitialized;
    } catch (e, stackTrace) {
      developer.log('Falló la inicialización del servicio de voz',
          error: e, stackTrace: stackTrace, name: 'VoiceService');
      _isInitialized = false;
      return false;
    }
  }

  /// Inicia el dictado de voz y devuelve las transcripciones reactivamente.
  Future<void> startListening({
    required Function(String) onResult,
    required Function() onListeningFinished,
    required Function(String) onError,
  }) async {
    final disponible = await init();
    if (!disponible) {
      onError(
          'El micrófono o el servicio de transcripción no están disponibles.');
      return;
    }

    try {
      await _speech.listen(
        onResult: (result) {
          onResult(result.recognizedWords);
          if (result.finalResult) {
            onListeningFinished();
          }
        },
        listenOptions: SpeechListenOptions(
          cancelOnError: true,
          listenFor: const Duration(seconds: 20),
          pauseFor: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      onError('Error al escuchar: $e');
    }
  }

  /// Detiene el dictado de voz manualmente.
  Future<void> stopListening() async {
    try {
      await _speech.stop();
    } catch (e) {
      developer.log('Error al detener el servicio de voz',
          error: e, name: 'VoiceService');
    }
  }
}
