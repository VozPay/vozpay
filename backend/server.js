import crypto from 'node:crypto';
import express from 'express';
import cors from 'cors';
import 'dotenv/config';
import {
  Connection,
  Keypair,
  PublicKey,
  Transaction,
  TransactionInstruction,
  clusterApiUrl,
  sendAndConfirmTransaction,
} from '@solana/web3.js';

const app = express();
app.use(cors());
app.use(express.json({ limit: '8kb' }));

const network = process.env.SOLANA_NETWORK || 'devnet';
const rpcUrl = process.env.SOLANA_RPC_URL || clusterApiUrl(network);
const connection = new Connection(rpcUrl, 'confirmed');
const memoProgram = new PublicKey(
  'MemoSq4gqABAXKb96qnH8TysNcWxMyWCqXgDLGmfcHr',
);

function signerFromEnvironment() {
  const raw = process.env.SOLANA_PRIVATE_KEY;
  if (!raw) throw new Error('SOLANA_PRIVATE_KEY não configurada');
  const bytes = JSON.parse(raw);
  if (!Array.isArray(bytes) || bytes.length !== 64) {
    throw new Error('SOLANA_PRIVATE_KEY deve ser um array JSON com 64 bytes');
  }
  return Keypair.fromSecretKey(Uint8Array.from(bytes));
}

function validText(value, max) {
  return typeof value === 'string' && value.length > 0 && value.length <= max;
}

app.get('/health', (_request, response) => {
  response.json({ status: 'ok', network });
});

app.post('/audit', async (request, response) => {
  try {
    const { event, sessionId, policyVersion } = request.body ?? {};
    if (
      !validText(event, 80) ||
      !validText(sessionId, 80) ||
      !validText(policyVersion, 20)
    ) {
      return response.status(400).json({ error: 'Evento inválido' });
    }

    const protectedEvent = {
      event,
      sessionId,
      policyVersion,
      timestamp: new Date().toISOString(),
    };
    const hash = crypto
      .createHash('sha256')
      .update(JSON.stringify(protectedEvent))
      .digest('hex');

    const payer = signerFromEnvironment();
    const memo = Buffer.from(
      JSON.stringify({
        product: 'vozpay',
        type: 'protection-proof',
        version: policyVersion,
        hash,
      }),
      'utf8',
    );

    const transaction = new Transaction().add(
      new TransactionInstruction({
        keys: [],
        programId: memoProgram,
        data: memo,
      }),
    );

    const signature = await sendAndConfirmTransaction(
      connection,
      transaction,
      [payer],
      { commitment: 'confirmed' },
    );

    return response.status(201).json({
      signature,
      hash,
      network,
      explorerUrl:
        'https://explorer.solana.com/tx/' +
        signature +
        '?cluster=' +
        network,
    });
  } catch (error) {
    console.error(error);
    return response
      .status(503)
      .json({ error: 'Registro temporariamente indisponível' });
  }
});

const port = Number(process.env.PORT || 3000);
app.listen(port, () => {
  console.log('VozPay audit service on port ' + port + ' (' + network + ')');
});
