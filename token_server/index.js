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

// ─── Config ─────────────────────────────────────────────────

const HMS_ACCESS_KEY = process.env.HMS_ACCESS_KEY || 'your_access_key';
const HMS_SECRET = process.env.HMS_SECRET || 'your_secret_key';

// Will be set after room creation
let HMS_ROOM_ID = null;

// ─── 100ms Helpers ──────────────────────────────────────────

function generateManagementToken() {
  const now = Math.floor(Date.now() / 1000);
  return jwt.sign(
    {
      access_key: HMS_ACCESS_KEY,
      type: 'management',
      version: 2,
      iat: now,
      nbf: now,
      exp: now + 86400,
      jti: uuidv4(),
    },
    HMS_SECRET,
    { algorithm: 'HS256' }
  );
}

function generateAuthToken(roomId, userId, role) {
  const now = Math.floor(Date.now() / 1000);
  return jwt.sign(
    {
      access_key: HMS_ACCESS_KEY,
      room_id: roomId,
      user_id: userId,
      role: role,
      type: 'app',
      version: 2,
      iat: now,
      nbf: now,
      exp: now + 86400,
      jti: uuidv4(),
    },
    HMS_SECRET,
    { algorithm: 'HS256' }
  );
}

/**
 * Create a room on 100ms with 'trainer' and 'member' roles.
 * Uses the 100ms REST API.
 */
async function createRoom() {
  const mgmtToken = generateManagementToken();

  try {
    // First try to list existing rooms to find ours
    const listRes = await fetch('https://api.100ms.live/v2/rooms?limit=10', {
      headers: { Authorization: `Bearer ${mgmtToken}` },
    });

    if (listRes.ok) {
      const listData = await listRes.json();
      const existing = listData.data?.find(
        (r) => r.name === 'guru-trainer-session'
      );
      if (existing) {
        HMS_ROOM_ID = existing.id;
        console.log(`[100MS] Using existing room: ${HMS_ROOM_ID}`);
        return;
      }
    }

    // Create a new room
    const createRes = await fetch('https://api.100ms.live/v2/rooms', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${mgmtToken}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        name: 'guru-trainer-session',
        description: 'Guru-Trainer video call room',
        template_id: null, // uses default template
      }),
    });

    if (createRes.ok) {
      const room = await createRes.json();
      HMS_ROOM_ID = room.id;
      console.log(`[100MS] Room created: ${HMS_ROOM_ID}`);
    } else {
      const errText = await createRes.text();
      console.error(`[100MS] Room creation failed: ${createRes.status} ${errText}`);
      console.error('[100MS] You may need to create a room manually at https://dashboard.100ms.live');
      console.error('[100MS] Then set HMS_ROOM_ID in .env');
      HMS_ROOM_ID = process.env.HMS_ROOM_ID || null;
    }
  } catch (err) {
    console.error('[100MS] API error:', err.message);
    HMS_ROOM_ID = process.env.HMS_ROOM_ID || null;
  }
}

// ─── HTTP / REST ────────────────────────────────────────────

app.post('/api/token', (req, res) => {
  const { room_id, user_id, role } = req.body;

  if (!user_id || !role) {
    return res.status(400).json({
      error: 'Missing required fields: user_id, role',
    });
  }

  const validRoles = ['host', 'guest', 'trainer', 'member'];
  if (!validRoles.includes(role)) {
    return res.status(400).json({
      error: `Invalid role. Must be one of: ${validRoles.join(', ')}`,
    });
  }

  // Use the auto-created room ID, or the one from the request, or from env
  const actualRoomId = HMS_ROOM_ID || room_id || process.env.HMS_ROOM_ID;

  if (!actualRoomId) {
    return res.status(500).json({
      error: 'No room ID available. Create a room at https://dashboard.100ms.live and set HMS_ROOM_ID in .env',
    });
  }

  try {
    const token = generateAuthToken(actualRoomId, user_id, role);
    console.log(`[TOKEN] Generated for user=${user_id} role=${role} room=${actualRoomId}`);
    res.json({ token, room_id: actualRoomId });
  } catch (error) {
    console.error('[TOKEN] Generation failed:', error.message);
    res.status(500).json({ error: 'Token generation failed' });
  }
});

app.get('/api/room-id', (req, res) => {
  res.json({ room_id: HMS_ROOM_ID });
});

/**
 * Get a room code for a given role.
 * The Flutter SDK uses room codes via getAuthTokenByRoomCode()
 * which also handles permission requests on Android/iOS.
 */
app.post('/api/room-code', async (req, res) => {
  const { role } = req.body;

  if (!role) {
    return res.status(400).json({ error: 'Missing role' });
  }

  const actualRoomId = HMS_ROOM_ID || process.env.HMS_ROOM_ID;
  if (!actualRoomId) {
    return res.status(500).json({ error: 'No room ID available' });
  }

  try {
    const mgmtToken = generateManagementToken();

    // Enable the room first
    await fetch(`https://api.100ms.live/v2/rooms/${actualRoomId}`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${mgmtToken}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ enabled: true }),
    });

    // Get room codes
    const codeRes = await fetch(
      `https://api.100ms.live/v2/room-codes/room/${actualRoomId}`,
      {
        method: 'POST',
        headers: { Authorization: `Bearer ${mgmtToken}` },
      }
    );

    if (!codeRes.ok) {
      const errText = await codeRes.text();
      console.error(`[100MS] Room code fetch failed: ${codeRes.status} ${errText}`);
      return res.status(500).json({ error: 'Failed to get room code' });
    }

    const codeData = await codeRes.json();
    const codes = codeData.data || [];

    // Find code matching the requested role
    const match = codes.find((c) => c.role === role && c.enabled);
    if (!match) {
      // Return any enabled code as fallback
      const fallback = codes.find((c) => c.enabled);
      if (fallback) {
        console.log(`[TOKEN] Role '${role}' not found, using '${fallback.role}' code`);
        return res.json({ room_code: fallback.code, role: fallback.role });
      }
      return res.status(404).json({
        error: `No room code for role '${role}'. Available roles: ${codes.map((c) => c.role).join(', ')}`,
      });
    }

    console.log(`[TOKEN] Room code for ${role}: ${match.code}`);
    res.json({ room_code: match.code, role: match.role });
  } catch (err) {
    console.error('[100MS] Room code error:', err.message);
    res.status(500).json({ error: err.message });
  }
});

app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    clients: clients.size,
    hms_room_id: HMS_ROOM_ID,
  });
});

// ─── WebSocket Relay ────────────────────────────────────────

const server = http.createServer(app);
const wss = new WebSocketServer({ server });

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

    if (msg.type === 'register') {
      userId = msg.userId;
      clients.set(userId, ws);
      console.log(`[WS] Registered: ${userId}  (${clients.size} online)`);
      broadcast(
        { type: 'presence', data: { userId, isOnline: true } },
        userId
      );
      return;
    }

    if (!userId) return;
    console.log(`[WS] ${userId} → ${msg.type}`);
    broadcast(msg, userId);
  });

  ws.on('close', () => {
    if (userId) {
      clients.delete(userId);
      console.log(`[WS] Disconnected: ${userId}  (${clients.size} online)`);
      broadcast(
        { type: 'presence', data: { userId, isOnline: false } },
        userId
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

// ─── Start ──────────────────────────────────────────────────

const PORT = process.env.PORT || 3000;

async function start() {
  // Create 100ms room first
  await createRoom();

  server.listen(PORT, () => {
    console.log(`[SERVER] Running on port ${PORT}`);
    console.log(`[SERVER] REST:      http://localhost:${PORT}/health`);
    console.log(`[SERVER] WebSocket: ws://localhost:${PORT}`);
    if (HMS_ROOM_ID) {
      console.log(`[SERVER] 100ms Room: ${HMS_ROOM_ID}`);
    } else {
      console.log(`[SERVER] WARNING: No 100ms room. Video calls will not work.`);
      console.log(`[SERVER] Create a room at https://dashboard.100ms.live`);
      console.log(`[SERVER] Then add HMS_ROOM_ID=<id> to your .env file`);
    }
  });
}

start();
