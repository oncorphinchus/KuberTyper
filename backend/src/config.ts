import { config as dotenvConfig } from 'dotenv';

// Load environment variables from .env file
dotenvConfig();

export const config = {
  NODE_ENV: process.env['NODE_ENV'] || 'development',
  PORT: parseInt(process.env['PORT'] || '8080', 10),
  DATABASE_URL: process.env['DATABASE_URL'] || 'postgresql://postgres:password@localhost:5432/kubetyper',
  CORS_ORIGIN: process.env['CORS_ORIGIN'] || 'http://localhost:3000',
  LOG_LEVEL: process.env['LOG_LEVEL'] || 'info',
  REDIS_HOST: process.env['REDIS_HOST'] || 'localhost',
  REDIS_PORT: parseInt(process.env['REDIS_PORT'] || '6379', 10),
  REDIS_URL: process.env['REDIS_URL'] || `redis://${process.env['REDIS_HOST'] || 'localhost'}:${process.env['REDIS_PORT'] || '6379'}`,
} as const;

// Validate required environment variables
export function validateConfig(): void {
  const required = ['DATABASE_URL'];
  const missing = required.filter(key => !process.env[key] && !(config as any)[key]);
  
  if (missing.length > 0) {
    throw new Error(`Missing required environment variables: ${missing.join(', ')}`);
  }
} 