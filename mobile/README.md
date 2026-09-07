# VozPay Mobile

Aplicativo Flutter demonstrativo do VozPay incorporado ao Banco Uno.

## Recursos do MVP

- pedido por voz ou texto;
- encerramento manual e automático do microfone;
- contato confiável “minha filha”;
- interpretação do pedido por IA;
- validação bancária simulada;
- cenário cotidiano e cenário de maior atenção;
- biometria simulada;
- recibo verificável na Solana Devnet.

O nome do fornecedor da IA não é apresentado ao cliente.

## Preparação

Dentro da pasta `mobile`, copie as variáveis:

```powershell
Copy-Item .env.example .env
```

Preencha `GEMINI_API_KEY` e mantenha `AUDIT_API_URL=http://localhost:3000` para executar o backend local.

Depois:

```powershell
flutter pub get
flutter run -d chrome
```

Se aparecer “No pubspec.yaml file found”, o comando foi executado fora da pasta `mobile`.

## Auditoria Solana

Antes de confirmar um pagamento, inicie o serviço da pasta `backend` conforme o README daquela pasta. Sem o backend, o fluxo de pagamento continua funcionando, mas o comprovante informa que a auditoria está indisponível.

## Permissão de microfone

Android, em `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.INTERNET" />
```

iOS, em `ios/Runner/Info.plist`:

```xml
<key>NSSpeechRecognitionUsageDescription</key>
<string>O VozPay usa sua voz para interpretar o pedido de pagamento.</string>
<key>NSMicrophoneUsageDescription</key>
<string>O VozPay precisa do microfone para ouvir o pedido de pagamento.</string>
```

## Segurança

Os arquivos `.env` servem somente para demonstração. Em produção, a chamada de IA e a assinatura Solana devem ocorrer em serviços autenticados do banco. Nunca publique uma chave real no GitHub ou compile uma chave privada dentro do aplicativo.
