# VozPay

Camada B2B de acessibilidade e proteção integrada ao aplicativo do banco.

O VozPay transforma pagamentos digitais em um processo que o usuário consegue pedir, entender, conferir e autorizar. O módulo combina voz, texto, botões grandes, contatos confiáveis e leitura de QR Code. O banco ou provedor de pagamentos continua responsável pela identidade, biometria, antifraude e execução.

## Como funciona

1. O usuário ativa o modo VozPay no aplicativo financeiro.
2. Fala, digita, cola uma chave, escolhe um contato ou lê um QR Code.
3. A IA extrai apenas a intenção, sem inventar dados ou autorizar pagamentos.
4. O provedor consulta a chave e retorna os dados oficiais do destinatário.
5. O VozPay explica valor, nome e instituição em linguagem simples.
6. As regras de proteção verificam destinatário novo, valor elevado e sinais de golpe.
7. O usuário confirma com a autenticação do provedor.
8. O provedor executa e emite o comprovante.

## Proteção sem retirar autonomia

O produto oferece configurações iniciais prontas, mas personalizáveis. Alertas e biometria adicional são o padrão para operações de maior atenção. A aprovação de uma pessoa de apoio é opcional e ativada pelo próprio usuário, nunca imposta apenas pela idade.

## Solana

A Solana foi escolhida como camada independente de auditoria do VozPay. Depois das verificações de proteção, o sistema registra na Devnet somente uma prova criptográfica do evento e apresenta um recibo verificável.

A Solana não executa o Pix. Ela também não recebe nome, CPF, chave Pix, valor, saldo ou biometria e nunca armazena a chave privada do usuário. O Banco Uno continua representando, de forma simulada, a instituição que valida, autentica e executa a transferência.

O Conta.vc foi avaliado, mas ficou fora do MVP por não disponibilizar atualmente uma API pública para integrações de terceiros.

Veja as decisões, justificativas, critérios de aceite e roteiro em [docs/MVP.md](docs/MVP.md).

## Protótipos

- `mobile/`: aplicativo Flutter e principal demonstração;
- `index.html`, `styles.css` e `app.js`: protótipo web e visão B2B.

## Executar o Flutter

Dentro da pasta `mobile`:

```bash
cp .env.example .env
flutter pub get
flutter run -d chrome
```

No PowerShell, use `Copy-Item .env.example .env`.

A chave do serviço de IA no aplicativo é somente para demonstração. Em produção, a chamada deve passar pelo backend autenticado do provedor financeiro.

## Escopo

O pitch começa com pessoas 60+, um público com dor clara, mas a solução pode atender pessoas com deficiência visual, dificuldade de leitura, baixa familiaridade digital ou qualquer cliente que prefira uma experiência financeira mais compreensível.
