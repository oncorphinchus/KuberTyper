import { Pool } from 'pg';
import { config } from './config';

// Create PostgreSQL connection pool
export const pool = new Pool({
  connectionString: config.DATABASE_URL,
  ssl: config.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false,
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

// Database connection health check
export async function checkDatabaseHealth(): Promise<boolean> {
  try {
    const client = await pool.connect();
    await client.query('SELECT 1');
    client.release();
    return true;
  } catch (error) {
    console.error('Database health check failed:', error);
    return false;
  }
}

// Text-related database operations
export interface Text {
  id: number;
  content: string;
  difficulty: string;
  created_at: Date;
}

export async function getRandomText(): Promise<Text | null> {
  try {
    const result = await pool.query(
      'SELECT id, content, difficulty, created_at FROM texts ORDER BY RANDOM() LIMIT 1'
    );
    return result.rows[0] || null;
  } catch (error) {
    console.error('Error fetching random text:', error);
    throw new Error('Failed to fetch random text');
  }
}

export async function getTextById(id: number): Promise<Text | null> {
  try {
    const result = await pool.query(
      'SELECT id, content, difficulty, created_at FROM texts WHERE id = $1',
      [id]
    );
    return result.rows[0] || null;
  } catch (error) {
    console.error('Error fetching text by ID:', error);
    throw new Error('Failed to fetch text');
  }
}

// Race result operations
export interface RaceResult {
  id?: number;
  text_id?: number;
  wpm: number;
  accuracy: number;
  time_taken: number;
  total_characters: number;
  correct_characters: number;
  created_at?: Date;
}

export async function saveRaceResult(result: RaceResult): Promise<number> {
  try {
    const query = `
      INSERT INTO race_results (text_id, wpm, accuracy, time_taken, total_characters, correct_characters)
      VALUES ($1, $2, $3, $4, $5, $6)
      RETURNING id
    `;
    
    const values = [
      result.text_id,
      result.wpm,
      result.accuracy,
      result.time_taken,
      result.total_characters,
      result.correct_characters
    ];
    
    const queryResult = await pool.query(query, values);
    return queryResult.rows[0].id;
  } catch (error) {
    console.error('Error saving race result:', error);
    throw new Error('Failed to save race result');
  }
}

export async function getRecentResults(limit: number = 10): Promise<RaceResult[]> {
  try {
    const result = await pool.query(
      'SELECT * FROM race_results ORDER BY created_at DESC LIMIT $1',
      [limit]
    );
    return result.rows;
  } catch (error) {
    console.error('Error fetching recent results:', error);
    throw new Error('Failed to fetch recent results');
  }
} 