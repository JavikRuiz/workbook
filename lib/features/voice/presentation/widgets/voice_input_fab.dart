import 'package:flutter/material.dart';
import 'package:libro_de_tareas/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libro_de_tareas/features/voice/providers/voice_provider.dart';

class VoiceInputFab extends ConsumerWidget {
  const VoiceInputFab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voiceState = ref.watch(voiceProvider);

    // Watch for voiceState updates and trigger bottom sheet programmatically
    ref.listen<VoiceState>(voiceProvider, (previous, next) {
      if (next.isListening && !(previous?.isListening ?? false)) {
        _showListeningSheet(context, ref);
      }
    });

    return FloatingActionButton(
      onPressed: () {
        ref.read(voiceProvider.notifier).toggleListening();
      },
      heroTag: 'voice_fab',
      backgroundColor: voiceState.isListening
          ? Colors.red.shade600
          : Theme.of(context).colorScheme.primary,
      child: Icon(
        voiceState.isListening ? Icons.stop : Icons.mic,
        color: Colors.white,
        size: 28,
      ),
    );
  }

  void _showListeningSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final state = ref.watch(voiceProvider);

            // Automatically close the bottom sheet when listening concludes
            if (!state.isListening) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                // Ensure sheet is popped
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }

                // Show Snackbar confirmation if task was created
                if (state.recognizedText.isNotEmpty &&
                    state.recognizedText.contains('creada')) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 10),
                          Expanded(child: Text(state.recognizedText)),
                        ],
                      ),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.green.shade600,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                  ref.read(voiceProvider.notifier).reset();
                }
              });
            }

            return Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              decoration: AppTheme.softDecoration(context, radius: 30).copyWith(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Pull line
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Dictando Nueva Tarea',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Pulsing mic animation
                  const VoiceRippleWave(),
                  const SizedBox(height: 20),

                  // Real-time transcribed output
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    constraints: const BoxConstraints(minHeight: 80),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade900
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Text(
                      state.recognizedText.isEmpty ||
                              state.recognizedText == 'Escuchando...'
                          ? 'Escuchando... habla ahora'
                          : state.recognizedText,
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: state.recognizedText.isEmpty
                            ? FontStyle.italic
                            : FontStyle.normal,
                        color:
                            state.recognizedText.isEmpty ? Colors.grey : null,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  if (state.error != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      state.error!,
                      style:
                          TextStyle(color: Colors.red.shade400, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Control Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          ref.read(voiceProvider.notifier).stopListening();
                          ref.read(voiceProvider.notifier).reset();
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.close),
                        label: const Text('Cancelar'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          ref.read(voiceProvider.notifier).stopListening();
                        },
                        icon: const Icon(Icons.check),
                        label: const Text('Guardar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 28, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class VoiceRippleWave extends StatefulWidget {
  const VoiceRippleWave({super.key});

  @override
  State<VoiceRippleWave> createState() => _VoiceRippleWaveState();
}

class _VoiceRippleWaveState extends State<VoiceRippleWave>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Ripple 1
              Container(
                width: 50 + (30 * _animationController.value),
                height: 50 + (30 * _animationController.value),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primary.withValues(
                      alpha: 0.3 * (1 - _animationController.value)),
                ),
              ),
              // Mic Icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: const Icon(
                  Icons.mic,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
