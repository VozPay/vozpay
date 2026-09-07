import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AuditReceipt {
  const AuditReceipt({
    required this.signature,
    required this.explorerUrl,
    required this.network,
  });

  final String signature;
  final String explorerUrl;
  final String network;

  factory AuditReceipt.fromJson(Map<String, dynamic> json) {
    return AuditReceipt(
      signature: json['signature']?.toString() ?? '',
      explorerUrl: json['explorerUrl']?.toString() ?? '',
      network: json['network']?.toString() ?? 'devnet',
    );
  }
}

class SolanaAuditService {
  String get _baseUrl =>
      (dotenv.env['AUDIT_API_URL'] ?? '').replaceFirst(RegExp(r'/$'), '');

  bool get isConfigured => _baseUrl.isNotEmpty;

  Future<AuditReceipt> recordProtection({
    required String event,
    required String sessionId,
    required String policyVersion,
  }) async {
    if (!isConfigured) {
      throw Exception('Registro de proteção não configurado.');
    }

    final response = await http
        .post(
          Uri.parse('$_baseUrl/audit'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'event': event,
            'sessionId': sessionId,
            'policyVersion': policyVersion,
          }),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Não foi possível registrar a proteção.');
    }

    final receipt =
        AuditReceipt.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    if (receipt.signature.isEmpty || receipt.explorerUrl.isEmpty) {
      throw Exception('O recibo de proteção retornou incompleto.');
    }
    return receipt;
  }
}
