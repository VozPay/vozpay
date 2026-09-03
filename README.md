# VozPay

MVP de uma camada de acessibilidade e proteção para pagamentos digitais, demonstrada como um módulo white-label dentro do aplicativo fictício Banco Uno.

## O que o protótipo demonstra

- Pix orientado por voz dentro do app do banco;
- confirmação em linguagem simples;
- cenário cotidiano para contato confiável;
- alerta contextual para novo destinatário e valor elevado;
- autenticação e comprovante sob responsabilidade do banco;
- console B2B para políticas de proteção;
- registro verificável da política sem publicar dados pessoais.

## Executar

Abra `index.html` no navegador ou execute um servidor estático:

```bash
python -m http.server 8000
```

Depois acesse `http://localhost:8000`.

## Estrutura

- `index.html`: experiência do cliente e console do parceiro;
- `styles.css`: identidade visual e responsividade;
- `app.js`: navegação, cenários e reconhecimento de voz.

## Observação

O projeto é uma demonstração. O Pix, a biometria e a integração bancária são simulados. Em produção, a instituição financeira continuaria responsável por autenticação, antifraude, compliance e execução das transações.
