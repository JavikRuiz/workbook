# AGENTS.md

## Proyecto y arquitectura

- Es una aplicación Flutter; el punto de entrada es `lib/main.dart` y las rutas principales apuntan a las pantallas bajo `lib/features/`.
- La organización es feature-first: cada feature puede contener `data`, `domain`, `presentation` y `providers`; la inyección global está en `lib/providers/`.
- La persistencia está en `lib/core/database/`: Drift genera `database.g.dart`; no edites archivos `*.g.dart` manualmente.
- `lib/core/database/database.dart` usa importación condicional: SQLite/`NativeDatabase` en Android/iOS y sql.js/IndexedDB en web.
- La web necesita conservar `web/sql-wasm.js`, `web/sql-wasm.wasm` y la carga de `sql-wasm.js` en `web/index.html`.

## Entorno WSL

- Usa el SDK Flutter Linux en `$HOME/.local/share/flutter-sdk/flutter`; no uses `/mnt/c/Dev/flutter` desde WSL porque sus scripts Windows pueden fallar por CRLF y rutas UNC.
- Para Android se requiere JDK 17 y las variables/rutas locales del README: `$HOME/.local/share/java/jdk-17.0.21+9` y `$HOME/.local/share/android-sdk`.
- iOS solo puede compilarse en macOS con Xcode; no intentes validar un build iOS dentro de WSL.
- Un emulador Android x86_64 requiere KVM; si WSL no expone KVM, valida Android con `flutter build apk` o usa un dispositivo físico.

## Flujo de dependencias y codegen

- Después de clonar o cambiar `pubspec.yaml`, ejecuta `flutter pub get`.
- Después de modificar tablas o conexiones Drift, ejecuta `dart run build_runner build` antes de analizar o compilar.
- El `build_runner` actual no necesita `--delete-conflicting-outputs`; esa opción se ignora en la versión resuelta.

## Verificación obligatoria

Ejecuta desde la raíz y en este orden:

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build web --no-wasm-dry-run
flutter build apk --debug
flutter build apk --release
```

- `analysis_options.yaml` excluye `android/`, `ios/` y `web/`; los builds siguen siendo necesarios para detectar errores de plataforma.
- La suite actual es principalmente widget; no hay pruebas de integración configuradas.
- El APK release usa actualmente la firma debug del template; no tratarlo como artefacto de publicación.

## Ejecución y preview web

- Android requiere un dispositivo visible en `flutter devices`: `flutter run -d <device-id>`.
- En WSL, `flutter run -d chrome` puede fallar por WebSockets entre Flutter y Chrome. Para una preview estable, compila y sirve el resultado estático:

```bash
flutter build web --no-wasm-dry-run
python3 -m http.server 5353 --bind 0.0.0.0 --directory build/web
```

- La preview estática se abre en `http://localhost:5353/` o `http://127.0.0.1:5353/`; no ofrece hot reload.

## Artefactos y configuración local

- No edites ni dependas de `.dart_tool/`, `build/`, `android/local.properties`, `ios/Flutter/Generated.xcconfig` ni `ios/Flutter/ephemeral/`; son artefactos generados o específicos de la máquina.
- No elimines `web/sql-wasm.js` ni `web/sql-wasm.wasm`: son recursos runtime necesarios para la base de datos web.
