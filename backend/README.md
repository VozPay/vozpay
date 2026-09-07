# Serviço de auditoria Solana

Backend mínimo que registra na Solana Devnet uma prova criptográfica das etapas de proteção do VozPay.

## Configuração

1. Instale Node.js 20 ou superior.
2. Copie `.env.example` para `.env`.
3. Crie uma carteira exclusiva para a demonstração.
4. Coloque no ambiente o array JSON de 64 bytes da chave da carteira.
5. Solicite SOL de teste no faucet da Devnet.
6. Execute:

```bash
npm install
npm start
```

Configure `AUDIT_API_URL=http://localhost:3000` no `mobile/.env`.

## Privacidade

O endpoint aceita somente tipo do evento, versão da política e identificador aleatório da sessão. O servidor gera o timestamp e publica um hash pelo Memo Program. Não envie valor, destinatário, CPF, telefone, chave Pix, banco ou biometria.

A chave usada é institucional e exclusiva da demonstração. Nunca coloque a chave privada no Flutter, no GitHub ou no vídeo.
