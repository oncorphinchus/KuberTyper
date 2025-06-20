import express from 'express';
import { createServer } from 'http';
import { Server } from 'socket.io';
import cors from 'cors';
import helmet from 'helmet';
import { rateLimit } from 'express-rate-limit';
import { createClient } from 'redis';
import { config, validateConfig } from './config';
import { getRandomText, saveRaceResult, checkDatabaseHealth } from './database';

// Validate configuration on startup
validateConfig();

const app = express();
const server = createServer(app);

// Initialize Socket.IO with CORS
const io = new Server(server, {
  cors: {
    origin: config.CORS_ORIGIN,
    methods: ["GET", "POST"],
    credentials: true
  },
  transports: ['websocket', 'polling']
});

// Redis clients for pub/sub
let redisClient: any;
let redisSubscriber: any;
let redisPublisher: any;

// Initialize Redis connections
async function initRedis() {
  try {
    redisClient = createClient({
      url: config.REDIS_URL,
      socket: {
        reconnectStrategy: (retries: number) => Math.min(retries * 50, 500)
      }
    });

    redisSubscriber = createClient({
      url: config.REDIS_URL,
      socket: {
        reconnectStrategy: (retries: number) => Math.min(retries * 50, 500)
      }
    });

    redisPublisher = createClient({
      url: config.REDIS_URL,
      socket: {
        reconnectStrategy: (retries: number) => Math.min(retries * 50, 500)
      }
    });

    // Error handlers
    redisClient.on('error', (err: Error) => console.error('Redis Client Error:', err));
    redisSubscriber.on('error', (err: Error) => console.error('Redis Subscriber Error:', err));
    redisPublisher.on('error', (err: Error) => console.error('Redis Publisher Error:', err));

    // Connect all clients
    await Promise.all([
      redisClient.connect(),
      redisSubscriber.connect(),
      redisPublisher.connect()
    ]);

    console.log('✅ Redis connections established');
  } catch (error) {
    console.error('❌ Failed to initialize Redis:', error);
    throw error;
  }
}

// Security middleware
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      connectSrc: ["'self'", "ws:", "wss:"],
    },
  },
}));

app.use(cors({
  origin: config.CORS_ORIGIN,
  credentials: true
}));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: 'Too many requests from this IP, please try again later.'
});
app.use(limiter);

// Body parsing middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Health check endpoint
app.get('/healthz', async (_req, res) => {
  try {
    const dbHealthy = await checkDatabaseHealth();
    const redisHealthy = redisClient ? await redisClient.ping() === 'PONG' : false;
    
    if (dbHealthy && redisHealthy) {
      return res.status(200).json({ 
        status: 'healthy', 
        timestamp: new Date().toISOString(),
        database: 'connected',
        redis: 'connected'
      });
    } else {
      return res.status(503).json({ 
        status: 'unhealthy', 
        timestamp: new Date().toISOString(),
        database: dbHealthy ? 'connected' : 'disconnected',
        redis: redisHealthy ? 'connected' : 'disconnected'
      });
    }
  } catch (error) {
    return res.status(503).json({ 
      status: 'unhealthy', 
      timestamp: new Date().toISOString(),
      error: 'Health check failed'
    });
  }
});

// Readiness check endpoint
app.get('/readyz', async (_req, res) => {
  try {
    const dbHealthy = await checkDatabaseHealth();
    const redisHealthy = redisClient ? await redisClient.ping() === 'PONG' : false;
    
    if (dbHealthy && redisHealthy) {
      return res.status(200).json({ status: 'ready' });
    } else {
      return res.status(503).json({ status: 'not ready' });
    }
  } catch (error) {
    return res.status(503).json({ status: 'not ready' });
  }
});

// API Routes (kept for backward compatibility and race setup)
app.get('/api/texts/random', async (_req, res) => {
  try {
    const text = await getRandomText();
    
    if (!text) {
      return res.status(404).json({ 
        error: 'No texts available',
        message: 'Please seed the database with typing texts' 
      });
    }
    
    return res.json({
      id: text.id,
      content: text.content,
      difficulty: text.difficulty
    });
  } catch (error) {
    console.error('Error fetching random text:', error);
    return res.status(500).json({ 
      error: 'Internal server error',
      message: 'Failed to fetch text' 
    });
  }
});

// Create a new race
app.post('/api/races/create', async (_req, res) => {
  try {
    // Get a random text for the race
    const text = await getRandomText();
    if (!text) {
      return res.status(404).json({ error: 'No texts available' });
    }

    // Create race ID
    const raceId = `race_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    
    // Store race in Redis
    await redisClient.hSet(`race:${raceId}`, {
      textId: text.id.toString(),
      textContent: text.content,
      status: 'waiting',
      createdAt: new Date().toISOString(),
      playerCount: '0'
    });

    // Set race expiration (1 hour)
    await redisClient.expire(`race:${raceId}`, 3600);

    console.log(`🏁 Created race: ${raceId} with text: ${text.id}`);
    
    return res.status(201).json({
      raceId,
      text: {
        id: text.id,
        content: text.content,
        difficulty: text.difficulty
      }
    });
  } catch (error) {
    console.error('Error creating race:', error);
    return res.status(500).json({ 
      error: 'Internal server error',
      message: 'Failed to create race' 
    });
  }
});

// Get race state
app.get('/api/races/:raceId', async (req, res) => {
  try {
    const { raceId } = req.params;
    
    const raceData = await redisClient.hGetAll(`race:${raceId}`);
    if (!raceData || Object.keys(raceData).length === 0) {
      return res.status(404).json({ error: 'Race not found' });
    }

    const playersData = await redisClient.hGetAll(`race:${raceId}:players`);
    const players = Object.entries(playersData).map(([socketId, playerJson]) => {
      const player = JSON.parse(playerJson as string);
      return {
        socketId,
        playerId: player.playerId,
        wpm: player.wpm,
        accuracy: player.accuracy,
        progress: player.progress,
        finished: player.finished
      };
    });

    return res.json({
      raceId,
      textId: parseInt(raceData.textId),
      textContent: raceData.textContent,
      status: raceData.status,
      playerCount: parseInt(raceData.playerCount),
      players,
      createdAt: raceData.createdAt
    });
  } catch (error) {
    console.error('Error getting race state:', error);
    return res.status(500).json({ 
      error: 'Internal server error',
      message: 'Failed to get race state' 
    });
  }
});

// Handle 404 for undefined routes
app.use('*', (req, res) => {
  return res.status(404).json({ 
    error: 'Not found',
    message: `Route ${req.method} ${req.originalUrl} not found` 
  });
});

// Socket.IO real-time events
io.on('connection', (socket) => {
  console.log(`🔌 Client connected: ${socket.id}`);
  
  // Join a race room
  socket.on('joinRace', async (data: { raceId: string; playerId: string }) => {
    try {
      const { raceId, playerId } = data;
      
      // Check if race exists
      const raceExists = await redisClient.exists(`race:${raceId}`);
      if (!raceExists) {
        socket.emit('error', { message: 'Race not found' });
        return;
      }

      // Join the Socket.IO room
      socket.join(`race:${raceId}`);
      
      // Subscribe to Redis channel for this race
      await redisSubscriber.subscribe(`race-progress:${raceId}`, (message: string) => {
        const progressUpdate = JSON.parse(message);
        // Broadcast to all clients in the race room
        io.to(`race:${raceId}`).emit('opponentProgress', progressUpdate);
      });

      // Add player to race in Redis
      const playerProgress = {
        socketId: socket.id,
        playerId,
        wpm: 0,
        accuracy: 0,
        progress: 0,
        finished: false,
        joinedAt: new Date().toISOString(),
        lastUpdate: new Date().toISOString()
      };

      await redisClient.hSet(`race:${raceId}:players`, socket.id, JSON.stringify(playerProgress));
      
      // Update player count
      const playerCount = await redisClient.hLen(`race:${raceId}:players`);
      await redisClient.hSet(`race:${raceId}`, 'playerCount', playerCount.toString());

      // Get race data to send to client
      const raceData = await redisClient.hGetAll(`race:${raceId}`);
      
      socket.emit('raceJoined', {
        raceId,
        text: {
          id: parseInt(raceData.textId),
          content: raceData.textContent
        },
        playerCount
      });

      // Notify other players
      socket.to(`race:${raceId}`).emit('playerJoined', {
        playerId,
        playerCount
      });

      console.log(`👤 Player ${playerId} (${socket.id}) joined race ${raceId}`);
    } catch (error) {
      console.error('Error joining race:', error);
      socket.emit('error', { message: 'Failed to join race' });
    }
  });

  // Handle progress updates
  socket.on('progressUpdate', async (data: {
    raceId: string;
    wpm: number;
    accuracy: number;
    progress: number;
    finished: boolean;
  }) => {
    try {
      const { raceId, wpm, accuracy, progress, finished } = data;
      
      // Get current player data
      const existingData = await redisClient.hGet(`race:${raceId}:players`, socket.id);
      if (!existingData) {
        console.warn(`Player ${socket.id} not found in race ${raceId}`);
        return;
      }

      const playerProgress = JSON.parse(existingData);
      const updatedProgress = {
        ...playerProgress,
        wpm,
        accuracy,
        progress,
        finished,
        lastUpdate: new Date().toISOString()
      };

      // Save updated progress
      await redisClient.hSet(`race:${raceId}:players`, socket.id, JSON.stringify(updatedProgress));

      // Publish progress update to Redis channel
      const progressUpdate = {
        raceId,
        socketId: socket.id,
        playerId: updatedProgress.playerId,
        wpm,
        accuracy,
        progress,
        finished,
        timestamp: new Date().toISOString()
      };

      await redisPublisher.publish(`race-progress:${raceId}`, JSON.stringify(progressUpdate));

      // If player finished, save result to database
      if (finished) {
        try {
          const raceData = await redisClient.hGetAll(`race:${raceId}`);
          const textId = parseInt(raceData.textId);
          
          // Calculate race time (simplified for now)
          const raceTime = 60; // This should be calculated properly
          
          await saveRaceResult({
            text_id: textId,
            wpm: Math.round(wpm),
            accuracy: parseFloat(accuracy.toFixed(2)),
            time_taken: raceTime,
            total_characters: Math.round(progress * 100), // Simplified
            correct_characters: Math.round(progress * accuracy)
          });
          
          console.log(`🏁 Player ${updatedProgress.playerId} finished race ${raceId}`);
        } catch (error) {
          console.error('Error saving race result:', error);
        }
      }
    } catch (error) {
      console.error('Error updating progress:', error);
    }
  });

  // Handle disconnection
  socket.on('disconnect', async () => {
    try {
      // Find and remove player from all races
      const pattern = 'race:*:players';
      const keys = await redisClient.keys(pattern);
      
      for (const key of keys) {
        const raceId = key.split(':')[1];
        const playerExists = await redisClient.hExists(key, socket.id);
        
        if (playerExists) {
          await redisClient.hDel(key, socket.id);
          
          // Update player count
          const playerCount = await redisClient.hLen(key);
          await redisClient.hSet(`race:${raceId}`, 'playerCount', playerCount.toString());
          
          // Notify other players
          socket.to(`race:${raceId}`).emit('playerLeft', {
            socketId: socket.id,
            playerCount
          });
          
          console.log(`👋 Player ${socket.id} left race ${raceId}`);
        }
      }
    } catch (error) {
      console.error('Error handling disconnect:', error);
    }
    
    console.log(`🔌 Client disconnected: ${socket.id}`);
  });
});

// Global error handler
app.use((error: Error, _req: express.Request, res: express.Response, _next: express.NextFunction) => {
  console.error('Unhandled error:', error);
  return res.status(500).json({ 
    error: 'Internal server error',
    message: 'Something went wrong' 
  });
});

// Start server with Redis initialization
const port = config.PORT;

async function startServer() {
  try {
    await initRedis();
    
    server.listen(port, () => {
      console.log(`🚀 KubeTyper backend server running on port ${port}`);
      console.log(`🌐 Environment: ${config.NODE_ENV}`);
      console.log(`💚 Health check: http://localhost:${port}/healthz`);
      console.log(`🔗 Redis: ${config.REDIS_URL}`);
    });
  } catch (error) {
    console.error('❌ Failed to start server:', error);
    process.exit(1);
  }
}

// Graceful shutdown
process.on('SIGTERM', async () => {
  console.log('SIGTERM received, shutting down gracefully...');
  
  try {
    await Promise.all([
      redisClient?.disconnect(),
      redisSubscriber?.disconnect(),
      redisPublisher?.disconnect()
    ]);
  } catch (error) {
    console.error('Error during shutdown:', error);
  }
  
  process.exit(0);
});

startServer();

export default app; 