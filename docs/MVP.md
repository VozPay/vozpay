# MVP VozPay

## Decisão de produto

O VozPay será apresentado como um modo de acessibilidade white-label dentro de um aplicativo financeiro, e não como um banco novo ou um aplicativo controlado somente por voz.

A voz facilita a entrada, mas não substitui texto, botões, QR Code nem autenticação. A IA interpreta o pedido; o provedor financeiro resolve a chave, autentica o cliente e executa a transferência.

## Justificativa da arquitetura

### Por que não usar apenas voz

Falar CPF, telefone ou e-mail pode ser mais difícil do que digitar, colar ou apontar a câmera. Uma interface multimodal preserva acessibilidade sem criar uma nova barreira.

### Por que a IA não executa o Pix

Modelos de linguagem podem interpretar frases, mas não são a fonte oficial do destinatário e não devem tomar decisões financeiras. O serviço retorna dados estruturados e o provedor valida tudo antes de mostrar a confirmação.

### Por que a pessoa de apoio é opcional

Exigir aprovação familiar por idade reduziria a autonomia que o produto quer criar. O padrão é explicação clara e autenticação adicional. O usuário pode ativar voluntariamente uma pessoa de apoio e escolher quando ela participa.

### Solana escolhida

A Solana será a tecnologia blockchain oficial do MVP. Seu papel é registrar uma prova independente e verificável de que as etapas de proteção foram realizadas. Ela não substitui o Pix, não valida a chave e não movimenta o dinheiro.

O Conta.vc foi avaliado por sua proximidade com Pix, passkey e autocustódia, mas ficou fora do escopo porque atualmente não oferece API pública para integrações de terceiros. O MVP não deve afirmar que existe uma conexão com essa plataforma.

### Auditoria na Solana Devnet

O aplicativo gera um evento mínimo, transforma o conteúdo em hash e envia somente essa prova para a rede de testes:

```json
{
  "policyVersion": "1.0",
  "event": "additional_confirmation_completed",
  "timestamp": "2026-09-07T18:00:00Z",
  "sessionId": "demo-001"
}
```

Não são enviados valor, nome, CPF, telefone, e-mail, chave Pix, banco, saldo ou biometria. A chave de assinatura também não fica exposta no aplicativo final; em produção, o registro deve ser assinado por um backend institucional.

## O que construir

### Entrada

Na tela inicial do banco, adicionar o botão “Usar VozPay”. O modo acessível oferece:

- comando de voz;
- campo para digitar ou colar uma chave;
- contatos confiáveis;
- leitura de QR Code simulada;
- botões grandes e instruções faladas.

O botão de voz deve ter estados claros: “Falar”, “Ouvindo”, “Concluir” e “Entendendo”. Ele precisa parar quando o usuário toca em “Concluir” ou fica em silêncio.

### Contatos confiáveis

O protótipo começa com Maria Silva salva como “minha filha”. Em uma versão real, o provedor poderia sugerir contatos frequentes, mas o usuário teria que confirmar o cadastro com biometria. Nomes e apelidos só resolvem contatos já cadastrados.

### Interpretação

A frase “mande 150 reais para minha filha” vira:

```json
{
  "acao": "pix",
  "valor": 150.00,
  "destinatarioInformado": "minha filha"
}
```

Se faltar valor ou destinatário, o fluxo para e pede a informação. A IA nunca completa silenciosamente o que não foi dito.

### Validação simulada

O backend simulado associa “minha filha” a Maria Silva e retorna nome oficial, instituição e identificador mascarado. A interface mostra e lê esses dados antes da autorização.

### Proteções iniciais

| Situação | Comportamento |
|---|---|
| Contato confiável e valor habitual | Conferência + biometria |
| Novo destinatário | Alerta e nova conferência |
| Valor acima de R$ 500 | Explicação + biometria adicional |
| Sinal de engenharia social | Perguntar se alguém orientou o Pix por ligação ou mensagem |
| Pedido incompleto | Não avançar |
| Pessoa de apoio ativada | Solicitar apoio somente conforme regra escolhida pelo usuário |

### Conclusão

A biometria, a execução do Pix e o comprovante são simulados em nome do Banco Uno ou do provedor demonstrado. A tela final pode mostrar “Proteção registrada”, sem expor o fornecedor de IA ao cliente.

## Dois cenários obrigatórios

### Cenário 1 — pagamento cotidiano

1. Ativar o VozPay.
2. Dizer ou digitar “mande 150 reais para minha filha”.
3. Interpretar o pedido.
4. Retornar Maria Silva pelo cadastro simulado.
5. Ler nome, banco e valor.
6. Confirmar com biometria simulada.
7. Mostrar o comprovante.

### Cenário 2 — maior atenção

1. Pedir “mande 2 mil reais para João”.
2. Identificar novo destinatário e valor acima do limite.
3. Explicar os motivos do alerta.
4. Perguntar sobre ligação ou mensagem suspeita.
5. Oferecer revisar ou cancelar.
6. Se continuar, pedir biometria adicional.
7. Mostrar o comprovante e o recibo verificável da Solana Devnet.

## Critérios de aceite

O MVP está pronto quando:

- voz, texto e contatos levam ao mesmo fluxo;
- o microfone sempre pode ser encerrado;
- o nome do fornecedor da IA não aparece na interface;
- pedidos incompletos não avançam;
- o destinatário oficial vem do serviço simulado, não da IA;
- os dois cenários funcionam de ponta a ponta;
- nenhuma regra obrigatória depende apenas da idade;
- pessoa de apoio é opcional;
- autenticação e execução são atribuídas ao provedor;
- nenhum dado pessoal é publicado em blockchain;
- a demonstração cabe em três minutos.

## Fora do MVP

- Pix real;
- custódia de chaves;
- voz como único fator de autenticação;
- antifraude completo;
- histórico financeiro público;
- boletos, faturas e Open Finance;
- painel administrativo completo.

## Ordem de implementação

1. Corrigir o ciclo do microfone.
2. Adicionar entrada por texto.
3. Criar o cadastro local de contatos.
4. Separar interpretação da IA e validação simulada.
5. Finalizar os dois cenários.
6. Adicionar configurações de proteção.
7. Gerar o hash do evento de proteção.
8. Registrar a prova na Solana Devnet e exibir o link do recibo.
