import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libro_de_tareas/core/theme/app_theme.dart';
import 'package:libro_de_tareas/core/theme/soft_ui.dart';
import 'package:libro_de_tareas/features/settings/providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    if (settings == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: AppTheme.backgroundDecoration(context),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildSectionHeader('Aspecto'),
            SoftUiSurface(
              child: SwitchListTile(
                secondary: Icon(
                  settings.darkMode ? Icons.dark_mode : Icons.light_mode,
                  color: settings.darkMode ? Colors.amber : Colors.blueGrey,
                ),
                title: const Text(
                  'Modo Oscuro',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Alternar entre tema claro y oscuro'),
                value: settings.darkMode,
                onChanged: (value) {
                  ref
                      .read(settingsProvider.notifier)
                      .updateSettings(darkMode: value);
                },
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionHeader('Reglas de prioridad'),
            SoftUiSurface(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.color_lens_outlined, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Colores según el plazo',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildRule(
                      color: const Color(0xFF10B981),
                      title: 'Verde',
                      description: 'Menos del 30% del plazo transcurrido',
                    ),
                    _buildRule(
                      color: const Color(0xFF9ACD32),
                      title: 'Verde amarillento',
                      description: 'Entre 30% y 50% del plazo transcurrido',
                    ),
                    _buildRule(
                      color: const Color(0xFFFACC15),
                      title: 'Amarillo',
                      description: 'Entre 50% y 70% del plazo transcurrido',
                    ),
                    _buildRule(
                      color: const Color(0xFFF59E0B),
                      title: 'Naranja',
                      description: 'Entre 70% y 90% del plazo transcurrido',
                    ),
                    _buildRule(
                      color: const Color(0xFFEF4444),
                      title: 'Rojo',
                      description: 'Desde 90% o cuando la tarea vence',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionHeader('Recomendación'),
            SoftUiSurface(
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Define una fecha y hora límite realistas al crear cada tarea. La prioridad se calcula automáticamente desde su creación hasta ese momento.',
                  style: TextStyle(fontSize: 13, height: 1.4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildRule({
    required Color color,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 14,
            height: 14,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
