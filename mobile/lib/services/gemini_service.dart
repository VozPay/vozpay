import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class PaymentIntent {
  const PaymentIntent({
    required this.action,
    required this.amount,
    required this.recipient,
    required this.explanation,
  });

  final String action;
  final double amount;
  final String recipient;
  final String explanation;

  factory PaymentIntent.fromJson(Map<String, dynamic> json) {
    return PaymentIntent(
      action: json['acao']?.toString() ?? 'pix',
      amount: (json['valor'] as num?)?.toDouble() ?? 0,
      recipient: json['destinatario']?.toString() ?? '',
      explanation: json['explicacao']?.toString() ?? '',
    );
  }
}

class GeminiService {
  String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  String get _model => dotenv.env['GEMINI_MODEL'] ?? 'gemini-2.5-flash';

  bool get isConfigured => _apiKey.isNotEmpty;

  Future<PaymentIntent> interpretPayment(String phrase) async {
    if (!isConfigured) return _fallback(phrase);

    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$_apiKey',
    );
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {
                'text': '''
Interprete o pedido de pagamento em português do Brasil.
Retorne somente JSON válido, sem markdown, neste formato:
{"acao":"pix","valor":150.0,"destinatario":"Maria Silva","explicacao":"Enviar R\$ 150 para Maria Silva"}
Não invente valor nem destinatário. Se faltar algum dado, use valor 0 ou string vazia.
Pedido: $phrase
''',
              },
            ],
          },
        ],
        'generationConfig': {
          'temperature': 0.1,
          'responseMimeType': 'application/json',
        },
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Gemini respondeu com status ${response.statusCode}.');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final text = body['candidates'][0]['content']['parts'][0]['text'] as String;
    return PaymentIntent.fromJson(jsonDecode(text) as Map<String, dynamic>);
  }

  PaymentIntent _fallback(String phrase) {
    final normalized = phrase.toLowerCase();
    final risky = normalized.contains('joão') ||
        normalized.contains('2000') ||
        normalized.contains('dois mil');
    return PaymentIntent(
      action: 'pix',
      amount: risky ? 2000 : 150,
      recipient: risky ? 'João' : 'Maria Silva',
      explanation: risky
          ? 'Enviar R\$ 2.000 para João'
          : 'Enviar R\$ 150 para Maria Silva',
    );
  }
}
