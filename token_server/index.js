const express = require('express');
const http = require('http');
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');
const cors = require('cors');
const { WebSocketServer, WebSocket } = require('ws');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());

// ─── HTTP / REST ────────────────────────────────────────────────

const HMS_ACCESS_KEY = process.env.HMS_ACCESS_KEY || 'your_access_key';
const HMS_SECRET = process.env.HMS_SECRET || 'your_secret_key';

app.post('/api/token', (req, res) => {
  const { room_id, user_id, role } = req.body;

  if (!room_id || !user_id || !role) {
    return res.status(400).json({
      error: 'Missing required fields: room_id, user_id, role',
    });
  }

  const validRoles = ['trainer', 'member'];
  if (!validRoles.includes(role)) {
    return res.status(400).json({
      error: `Invalid role. Must be one of: ${validRoles.join(', ')}`,
    });
  }

  try {
    const now = Math.floor(Date.now() / 1000);
    const payload = {
      access_key: HMS_ACCESS_KEY,
      room_id,
      user_id,
      role,
      type: 'app',
      version: 2,
      iat: now,
      nbf: now,
      exp: now + 86400,
      jti: uuidv4(),
    };

    const token = jwt.sign(payload, HMS_SECRET, { algorithm: 'HS256' });
    console.log(`[TOKEN] Generated for user=${user_id} role=${role}`);
    res.json({ token });
  } catch (error) {
    console.error('[TOKEN] Generation failed:', error.message);
    res.status(500).json({ error: 'Token generation failed' });
  }
});

app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    clients: clients.size,
  });
});

// ─── WebSocket Relay ────────────────────────────────────────────

const server = http.createServer(app);
const wss = new WebSocketServer({ server });

// userId → WebSocket
const clients = new Map();

wss.on('connection', (ws) => {
  let userId = null;

  ws.on('message', (raw) => {
    let msg;
    try {
      msg = JSON.parse(raw.toString());
    } catch {
      return;
    }

    // First message must be a register event
    if (msg.type === 'register') {
      userId = msg.userId;
      clients.set(userId, ws);
      console.log(`[WS] Registered: ${userId}  (${clients.size} online)`);

      // Tell all clients about online status
      broadcast(
        { type: 'presence', data: { userId, isOnline: true } },
        userId,
      );
      return;
    }

    if (!userId) return; // not registered yet

    console.log(`[WS] ${userId} → ${msg.type}`);

    // Relay to every OTHER connected client
    broadcast(msg, userId);
  });

  ws.on('close', () => {
    if (userId) {
      clients.delete(userId);
      console.log(`[WS] Disconnected: ${userId}  (${clients.size} online)`);
      broadcast(
        { type: 'presence', data: { userId, isOnline: false } },
        userId,
      );
    }
  });

  ws.on('error', (err) => {
    console.error(`[WS] Error for ${userId}:`, err.message);
  });
});

function broadcast(msg, excludeUserId) {
  const payload = JSON.stringify(msg);
  for (const [id, client] of clients) {
    if (id !== excludeUserId && client.readyState === WebSocket.OPEN) {
      client.send(payload);
    }
  }
}

// ─── Start ──────────────────────────────────────────────────────

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`[SERVER] Running on port ${PORT}`);
  console.log(`[SERVER] REST:      http://localhost:${PORT}/health`);
  console.log(`[SERVER] WebSocket: ws://localhost:${PORT}`);
});
