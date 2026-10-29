# Libro de Tareas

Aplicación Flutter para crear, clasificar y completar tareas. Incluye categorías, filtros, prioridad basada en fecha límite, tema claro/oscuro, dictado de voz y notificaciones locales en plataformas móviles.

## Estado y plataformas

- **Android:** soportado.
- **iOS:** soportado; requiere macOS y Xcode para compilar.
- **Web:** soportado experimentalmente con sql.js e IndexedDB.

## Arquitectura

El proyecto utiliza una arquitectura feature-first:

```text
lib/
├── core/
│   ├── constants/
│   ├── database/       # Drift, SQLite y código generado
│   ├── theme/
│   └── utils/
├── features/
│   ├── categories/     # data, domain, presentation y providers
│   ├── settings/
│   ├── tasks/
│   └── voice/
├── providers/          # inyección global de dependencias
├── services/           # voz y notificaciones
└── main.dart
```

La base de datos se crea en el directorio de documentos de la plataforma y se inicializa con configuración y categorías predeterminadas. El código `*.g.dart` es generado por Drift y no debe editarse manualmente.

## Requisitos

- Flutter **3.38.4 o superior**.
- Dart **3.5.0 o superior**.
- Android Studio, Android SDK y JDK 17 para Android.
- macOS y Xcode para iOS.

Verifica la instalación con:

```bash
flutter doctor -v
flutter devices
```

## Instalación

```bash
git clone <url-del-repositorio>
cd libro_de_tareas

flutter pub get
dart run build_runner build
```

Si se modifican tablas de Drift, vuelve a generar los archivos:

```bash
dart run build_runner build
```

## Ejecución

Lista los dispositivos disponibles:

```bash
flutter devices
```

Ejecuta la aplicación indicando el dispositivo:

```bash
flutter run -d <device-id>
```

En Android usa el identificador mostrado por `flutter devices`:

```bash
flutter run -d <android-device-id>
```

## Después de realizar cambios

Cuando se modifique el código fuente, especialmente la estructura de la base de
datos, es necesario detener la aplicación y realizar un reinicio completo.

Para Android:

```bash
flutter build apk --debug
flutter install
```

También se puede ejecutar directamente en un dispositivo conectado:

```bash
flutter run -d <device-id>
```

No basta con usar hot reload cuando se modifican tablas o migraciones de Drift.
La aplicación debe iniciar nuevamente para ejecutar la migración de base de
datos (`schemaVersion`).

Para ejecutar la versión web necesitas Chrome:

```bash
export CHROME_EXECUTABLE="/mnt/c/Program Files/Google/Chrome/Application/chrome.exe"
flutter run -d chrome
```

## Calidad y pruebas

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

Construcción Android de prueba:

```bash
flutter build apk --debug
```

Construcción Android release:

```bash
flutter build apk --release
```

## Permisos

Android declara permisos para micrófono, internet, notificaciones y alarmas. iOS declara permisos de micrófono y reconocimiento de voz. El usuario debe conceder estos permisos en tiempo de ejecución cuando el sistema los solicite.

## Desarrollo en WSL

Usa un SDK Flutter para Linux dentro de WSL. No mezcles un SDK Windows (`/mnt/c/...`) con comandos Linux, ya que sus scripts y rutas pueden fallar por CRLF y rutas UNC.

Ejemplo de instalación local:

```bash
export FLUTTER_HOME="$HOME/.local/share/flutter-sdk/flutter"
export JAVA_HOME="$HOME/.local/share/java/jdk-17.0.21+9"
export ANDROID_HOME="$HOME/.local/share/android-sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$FLUTTER_HOME/bin:$PATH"
export PATH="$JAVA_HOME/bin:$ANDROID_HOME/platform-tools:$PATH"
flutter config --android-sdk "$ANDROID_HOME"
flutter config --jdk-dir "$JAVA_HOME"
flutter doctor -v
```

## Licencia

Este proyecto se distribuye bajo licencia MIT. El archivo `LICENSE` debe acompañar al repositorio para que la declaración sea legalmente completa.
