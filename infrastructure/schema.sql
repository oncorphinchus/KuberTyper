-- KubeTyper Database Schema
-- Run this script to set up the initial database structure

-- Create texts table for storing typing snippets
CREATE TABLE texts (
    id SERIAL PRIMARY KEY,
    content TEXT NOT NULL,
    difficulty VARCHAR(20) DEFAULT 'medium',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create race_results table for storing game results
CREATE TABLE race_results (
    id SERIAL PRIMARY KEY,
    text_id INTEGER REFERENCES texts(id),
    wpm INTEGER NOT NULL CHECK (wpm >= 0),
    accuracy REAL NOT NULL CHECK (accuracy >= 0 AND accuracy <= 100),
    time_taken INTEGER NOT NULL, -- in seconds
    total_characters INTEGER NOT NULL,
    correct_characters INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better query performance
CREATE INDEX idx_race_results_created_at ON race_results(created_at);
CREATE INDEX idx_race_results_wpm ON race_results(wpm);
CREATE INDEX idx_texts_difficulty ON texts(difficulty); 