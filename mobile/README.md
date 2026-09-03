# VozPay Mobile

Aplicativo Flutter demonstrativo do VozPay incorporado ao Banco Uno.

## Preparação

Na pasta `mobile`, gere as pastas nativas caso ainda não existam:

```bash
flutter create --platforms=android,ios,web .
```

Copie as variáveis de ambiente:

```bash
cp .env.example .env
```

Preencha `GEMINI_API_KEY` no `.env` e execute:

```bash
flutter pub get
flutter run
```

Sem a chave, os dois cenários simulados continuam funcionando.

## Permissão de microfone

No Android, acrescente ao `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.INTERNET" />
```

No iOS, acrescente ao `ios/Runner/Info.plist`:

```xml
<key>NSSpeechRecognitionUsageDescription</key>
<string>O VozPay usa sua voz para interpretar o pedido de pagamento.</string>
<key>NSMicrophoneUsageDescription</key>
<string>O VozPay precisa do microfone para ouvir o pedido de pagamento.</string>
```

## Segurança

O uso de `.env` no aplicativo serve somente para demonstração. Aplicativos Flutter podem ter seus arquivos e chaves extraídos. Em produção, a chamada ao Gemini deve passar por um backend do banco, com autenticação, limite de uso e auditoria.
