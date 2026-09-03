const screen = document.querySelector('#screen');
let transaction = { recipient: 'Maria Silva', amount: 150, trusted: true };

const money = value => value.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' });
const shell = (step, title, subtitle, body) => `
  <header class="bank-head">
    <div class="brandline"><div><strong>BANCO UNO</strong><small>Acessibilidade por VOZPAY</small></div><b>${step}</b></div>
    <h2>${title}</h2><p>${subtitle}</p>
  </header><div class="screen-body">${body}</div>`;

function home() {
  screen.innerHTML = shell('INÍCIO', 'Olá, Ana', 'Sua conta e seus pagamentos em um só lugar.', `
    <article class="card lav"><span class="label">Saldo disponível</span><strong class="amount">R$ 2.840,50</strong></article>
    <h3>O que você precisa?</h3>
    <article class="card"><h3>PIX</h3><p>Transferir, cobrar ou pagar QR Code</p></article>
    <button class="card dark" data-action="voice"><h3>Falar com o VozPay</h3><p>Faça um Pix com orientação por voz</p></button>
    <p class="screen-note">Início　 Cartão　 Pix　 Perfil</p>`);
}

function voice() {
  screen.innerHTML = shell('PIX • VOZPAY', 'Como posso ajudar?', 'Você continua no Banco Uno. O VozPay simplifica esta etapa.', `
    <div class="voice"><div><button class="voice-orb" data-action="listen" aria-label="Começar reconhecimento de voz">FALAR</button><p id="voice-status">Toque e diga o que precisa</p></div></div>
    <button class="secondary" data-demo="safe">Simular: R$ 150 para Maria</button>
    <button class="secondary" data-demo="risk">Simular: R$ 2.000 para João</button>
    <button class="back" data-action="home">← Voltar</button>`);
}

function review() {
  const risky = !transaction.trusted || transaction.amount > 500;
  if (risky) return risk();
  screen.innerHTML = shell('CONFIRMAÇÃO', 'Confira seu Pix', 'O banco mostra os dados; o VozPay explica em linguagem simples.', `
    <article class="card"><span class="label">Você vai enviar</span><strong class="amount">${money(transaction.amount)}</strong><h3>Para ${transaction.recipient}</h3><p>Banco Uno • CPF final 42</p></article>
    <article class="card safe"><h3 class="safe-text">✓ Operação dentro do padrão</h3><p>Contato confiável e valor abaixo do limite protegido.</p></article>
    <button class="primary" data-action="confirm">Confirmar com biometria</button><button class="danger" data-action="home">Cancelar</button>`);
}

function risk() {
  screen.innerHTML = shell('SEGURANÇA', 'Vamos conferir melhor', 'O banco mantém o controle; o VozPay adiciona contexto antes da decisão.', `
    <article class="card warn"><h3>! Novo destinatário</h3><strong class="amount">${money(transaction.amount)}</strong><p>Valor acima do limite protegido de R$ 500.</p></article>
    <article class="card"><h3>Alguém pediu este Pix por ligação ou WhatsApp?</h3></article>
    <button class="primary" data-action="review-recipient">Revisar destinatário</button><button class="danger" data-action="home">Cancelar Pix</button>
    <p class="screen-note">Política VozPay ativa • registro verificável</p>`);
}

function success() {
  screen.innerHTML = shell('CONCLUÍDO', 'Pix realizado', 'O comprovante continua sendo emitido pela instituição financeira.', `
    <div class="receipt"><i class="check">✓</i><strong>${money(transaction.amount)}</strong><span>enviado para ${transaction.recipient}</span></div>
    <article class="card"><h3>Comprovante Banco Uno</h3><p class="safe-text">Proteção adicional oferecida por VozPay</p></article>
    <button class="primary" data-action="share">Compartilhar comprovante</button><button class="secondary" data-action="home">Voltar ao início</button>`);
}

function runDemo(type) {
  transaction = type === 'risk'
    ? { recipient: 'João', amount: 2000, trusted: false }
    : { recipient: 'Maria Silva', amount: 150, trusted: true };
  review();
}

function listen() {
  const status = document.querySelector('#voice-status');
  const holder = document.querySelector('.voice');
  const Recognition = window.SpeechRecognition || window.webkitSpeechRecognition;
  holder.classList.add('listening'); status.textContent = 'Estou ouvindo…';
  if (!Recognition) return setTimeout(() => { holder.classList.remove('listening'); runDemo('safe'); }, 1400);
  const recognition = new Recognition(); recognition.lang = 'pt-BR'; recognition.interimResults = false;
  recognition.onresult = event => {
    const phrase = event.results[0][0].transcript.toLowerCase();
    holder.classList.remove('listening');
    runDemo(phrase.includes('dois mil') || phrase.includes('2000') || phrase.includes('joão') ? 'risk' : 'safe');
  };
  recognition.onerror = () => { holder.classList.remove('listening'); status.textContent = 'Não consegui ouvir. Escolha um cenário abaixo.'; };
  recognition.start();
}

document.addEventListener('click', event => {
  const nav = event.target.closest('[data-view]');
  if (nav) {
    document.querySelectorAll('.nav-button').forEach(x => x.classList.toggle('active', x === nav));
    document.querySelectorAll('.view').forEach(x => x.classList.remove('active-view'));
    document.querySelector(`#${nav.dataset.view}-view`).classList.add('active-view');
  }
  const demo = event.target.closest('[data-demo]'); if (demo) runDemo(demo.dataset.demo);
  const action = event.target.closest('[data-action]')?.dataset.action;
  if (action === 'voice') voice(); if (action === 'listen') listen(); if (action === 'home') home();
  if (action === 'confirm') success(); if (action === 'review-recipient') voice();
  if (action === 'share') navigator.clipboard?.writeText(`Pix Banco Uno: ${money(transaction.amount)} para ${transaction.recipient}`);
});

document.querySelector('#limit').addEventListener('input', event => {
  document.querySelector('#limit-output').textContent = money(Number(event.target.value)).replace(',00', '');
});
home();
