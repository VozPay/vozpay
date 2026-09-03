import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'services/gemini_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {}
  runApp(const VozPayApp());
}

class VozPayApp extends StatelessWidget {
  const VozPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF6F0796);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Banco Uno + VozPay',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: purple),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
        textTheme: const TextTheme(
          headlineMedium: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
          titleLarge: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
          bodyLarge: TextStyle(fontSize: 17, height: 1.35),
        ),
      ),
      home: const BankExperience(),
    );
  }
}

enum FlowStep { home, voice, review, risk, success }

class BankExperience extends StatefulWidget {
  const BankExperience({super.key});

  @override
  State<BankExperience> createState() => _BankExperienceState();
}

class _BankExperienceState extends State<BankExperience> {
  static const purple = Color(0xFF6F0796);
  static const lavender = Color(0xFFF2E4F8);
  static const safe = Color(0xFF087C50);
  static const safeBg = Color(0xFFDDF8EC);
  static const warningBg = Color(0xFFFFF0BD);

  final _gemini = GeminiService();
  final _speech = SpeechToText();
  final _tts = FlutterTts();
  FlowStep _step = FlowStep.home;
  PaymentIntent _intent = const PaymentIntent(
    action: 'pix',
    amount: 150,
    recipient: 'Maria Silva',
    explanation: 'Enviar R\$ 150 para Maria Silva',
  );
  bool _busy = false;
  bool _isListening = false;
  String _heard = '';
  String _voiceStatus = 'Toque e diga o que precisa';
  Timer? _speechDebounce;
  bool _speechSubmitted = false;

  bool get _isRisky => _intent.amount > 500 || _intent.recipient == 'João';

  Future<void> _interpret(String phrase) async {
    final cleanPhrase = phrase.trim();
    if (cleanPhrase.isEmpty || _busy) return;
    setState(() {
      _busy = true;
      _heard = cleanPhrase;
      _voiceStatus = 'Entendendo seu pedido…';
    });
    try {
      final result = await _gemini.interpretPayment(cleanPhrase);
      if (!mounted) return;
      setState(() {
        _intent = result;
        _step = result.amount > 500 || result.recipient.toLowerCase() == 'joão'
            ? FlowStep.risk
            : FlowStep.review;
      });
      await _tts.speak(result.explanation);
    } catch (error) {
      if (!mounted) return;
      setState(() => _voiceStatus = 'Não foi possível interpretar a fala.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$error'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 6),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _listen() async {
    if (_isListening || _speech.isListening) {
      await _submitRecognizedSpeech();
      return;
    }
    _speechDebounce?.cancel();
    _speechSubmitted = false;
    setState(() {
      _heard = '';
      _isListening = false;
      _voiceStatus = 'Preparando o microfone…';
    });
    final available = await _speech.initialize(
      onStatus: (status) {
        if (!mounted) return;
        setState(() => _isListening = status == 'listening');
        if ((status == 'done' || status == 'notListening') &&
            _heard.trim().isNotEmpty) {
          _submitRecognizedSpeech();
        }
      },
      onError: (error) {
        if (!mounted) return;
        setState(() {
          _isListening = false;
          _voiceStatus = 'Não consegui ouvir. Toque para tentar novamente.';
        });
      },
    );
    if (!available) {
      if (mounted) {
        setState(() => _voiceStatus = 'Permissão de microfone indisponível.');
      }
      return;
    }
    setState(() {
      _heard = '';
      _isListening = true;
      _voiceStatus = 'Estou ouvindo. Toque novamente quando terminar.';
    });
    await _speech.listen(
      localeId: 'pt_BR',
      listenFor: const Duration(seconds: 12),
      pauseFor: const Duration(seconds: 2),
      listenOptions: SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
      ),
      onResult: (result) {
        final words = result.recognizedWords.trim();
        if (words.isEmpty || !mounted) return;
        setState(() {
          _heard = words;
          _voiceStatus = result.finalResult
              ? 'Fala concluída. Entendendo seu pedido…'
              : 'Toque em CONCLUIR ou faça uma pausa.';
        });
        _speechDebounce?.cancel();
        _speechDebounce = Timer(
          const Duration(milliseconds: 1800),
          _submitRecognizedSpeech,
        );
        if (result.finalResult) _submitRecognizedSpeech();
      },
    );
  }

  Future<void> _submitRecognizedSpeech() async {
    if (_speechSubmitted || _heard.trim().isEmpty) return;
    _speechSubmitted = true;
    _speechDebounce?.cancel();
    if (mounted) {
      setState(() {
        _isListening = false;
        _voiceStatus = 'Entendendo seu pedido…';
      });
    }
    if (_speech.isListening) await _speech.stop();
    await _interpret(_heard);
  }

  @override
  void dispose() {
    _speechDebounce?.cancel();
    _speech.stop();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _BankHeader(step: _step),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                child: SingleChildScrollView(
                  key: ValueKey(_step),
                  padding: const EdgeInsets.all(22),
                  child: _content(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content() {
    switch (_step) {
      case FlowStep.home:
        return _column([
          _card(color: lavender, children: const [
            Text('Saldo disponível'),
            SizedBox(height: 5),
            Text('R\$ 2.840,50', style: TextStyle(fontSize: 31, fontWeight: FontWeight.w800)),
          ]),
          const Text('O que você precisa?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          _card(children: const [
            Text('PIX', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: purple)),
            Text('Transferir, cobrar ou pagar QR Code'),
          ]),
          _actionCard(),
          if (!_gemini.isConfigured)
            const Text('Assistente temporariamente indisponível.', textAlign: TextAlign.center),
        ]);
      case FlowStep.voice:
        return _column([
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 34),
            decoration: BoxDecoration(color: lavender, borderRadius: BorderRadius.circular(24)),
            child: Column(children: [
              FilledButton(
                onPressed: _busy ? null : _listen,
                style: FilledButton.styleFrom(shape: const CircleBorder(), fixedSize: const Size(116, 116), backgroundColor: purple),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_isListening ? Icons.stop_rounded : Icons.mic_rounded),
                    const SizedBox(height: 4),
                    Text(_busy ? 'AGUARDE' : _isListening ? 'CONCLUIR' : 'FALAR'),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                _heard.isEmpty ? _voiceStatus : '“$_heard”\n\n$_voiceStatus',
                textAlign: TextAlign.center,
              ),
            ]),
          ),
          _button('Simular: R\$ 150 para Maria', () => _interpret('Manda 150 reais para Maria Silva'), secondary: true),
          _button('Simular: R\$ 2.000 para João', () => _interpret('Manda dois mil reais para João'), secondary: true),
          TextButton(onPressed: () => setState(() => _step = FlowStep.home), child: const Text('Voltar')),
        ]);
      case FlowStep.review:
        return _column([
          _card(children: [
            const Text('Você vai enviar'),
            Text(_money(_intent.amount), style: const TextStyle(fontSize: 33, fontWeight: FontWeight.w800)),
            Text('Para ${_intent.recipient}', style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700)),
            const Text('Banco Uno • CPF final 42'),
          ]),
          _card(color: safeBg, children: const [
            Text('✓ Operação dentro do padrão', style: TextStyle(color: safe, fontWeight: FontWeight.w800)),
            Text('Contato confiável e valor abaixo do limite protegido.'),
          ]),
          _button('Confirmar com biometria', () => setState(() => _step = FlowStep.success)),
          _button('Cancelar', () => setState(() => _step = FlowStep.home), destructive: true),
        ]);
      case FlowStep.risk:
        return _column([
          _card(color: warningBg, children: [
            const Text('! Novo destinatário', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            Text('${_money(_intent.amount)} para ${_intent.recipient}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const Text('Valor acima do limite protegido de R\$ 500.'),
          ]),
          _card(children: const [
            Text('Alguém pediu este Pix por ligação ou WhatsApp?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          ]),
          _button('Revisar destinatário', () => setState(() => _step = FlowStep.voice)),
          _button('Cancelar Pix', () => setState(() => _step = FlowStep.home), destructive: true),
          const Text('Política VozPay ativa • registro verificável', textAlign: TextAlign.center),
        ]);
      case FlowStep.success:
        return _column([
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(color: safeBg, borderRadius: BorderRadius.circular(24)),
            child: Column(children: [
              const CircleAvatar(radius: 30, backgroundColor: safe, child: Icon(Icons.check, color: Colors.white, size: 35)),
              const SizedBox(height: 14),
              Text(_money(_intent.amount), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800)),
              Text('enviado para ${_intent.recipient}'),
            ]),
          ),
          _card(children: const [
            Text('Comprovante Banco Uno', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            Text('Proteção adicional oferecida por VozPay', style: TextStyle(color: safe)),
          ]),
          _button('Voltar ao início', () => setState(() => _step = FlowStep.home)),
        ]);
    }
  }

  Widget _actionCard() => InkWell(
        onTap: () => setState(() => _step = FlowStep.voice),
        borderRadius: BorderRadius.circular(20),
        child: _card(color: purple, children: const [
          Text('Falar com o VozPay', style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w800)),
          Text('Faça um Pix com orientação por voz', style: TextStyle(color: Color(0xFFF0D8F8))),
        ]),
      );

  Widget _card({Color color = Colors.white, required List<Widget> children}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20), border: color == Colors.white ? Border.all(color: const Color(0xFFE6DFE9)) : null),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
      );

  Widget _button(String label, VoidCallback action, {bool secondary = false, bool destructive = false}) => SizedBox(
        width: double.infinity,
        height: 56,
        child: destructive
            ? OutlinedButton(onPressed: action, child: Text(label, style: const TextStyle(color: Colors.red)))
            : FilledButton(
                onPressed: action,
                style: FilledButton.styleFrom(backgroundColor: secondary ? lavender : purple, foregroundColor: secondary ? purple : Colors.white),
                child: Text(label),
              ),
      );

  Widget _column(List<Widget> children) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children.expand((item) => [item, const SizedBox(height: 15)]).toList(),
      );

  String _money(double value) => 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',').replaceAllMapped(RegExp(r'(?<=\d)(?=(\d{3})+(?!\d))'), (_) => '.')}';
}

class _BankHeader extends StatelessWidget {
  const _BankHeader({required this.step});
  final FlowStep step;

  @override
  Widget build(BuildContext context) {
    final titles = {
      FlowStep.home: ('Olá, Ana', 'Sua conta e seus pagamentos em um só lugar.'),
      FlowStep.voice: ('Como posso ajudar?', 'Você continua no Banco Uno.'),
      FlowStep.review: ('Confira seu Pix', 'O VozPay explica os dados em linguagem simples.'),
      FlowStep.risk: ('Vamos conferir melhor', 'O banco mantém o controle da operação.'),
      FlowStep.success: ('Pix realizado', 'Comprovante emitido pelo Banco Uno.'),
    };
    final copy = titles[step]!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 25),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF6F0796), Color(0xFF9019B8)]),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('BANCO UNO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
            Text('Acessibilidade por VOZPAY', style: TextStyle(color: Color(0xFFECCDF7), fontSize: 12)),
          ]),
          Icon(Icons.account_circle_outlined, color: Colors.white),
        ]),
        const SizedBox(height: 27),
        Text(copy.$1, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white)),
        const SizedBox(height: 7),
        Text(copy.$2, style: const TextStyle(color: Color(0xFFF0D8F8), fontSize: 16)),
      ]),
    );
  }
}
