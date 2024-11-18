-- Create necessary tables
CREATE TABLE IF NOT EXISTS "user" (
    id SERIAL PRIMARY KEY,
    username VARCHAR(80) UNIQUE NOT NULL,
    password_hash VARCHAR(120) NOT NULL,
    name VARCHAR(100) NOT NULL,
    is_admin BOOLEAN DEFAULT FALSE
);

CREATE TABLE IF NOT EXISTS lead (
    id SERIAL PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    mobile VARCHAR(12) NOT NULL,
    followup_date TIMESTAMP NOT NULL,
    remarks TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    creator_id INTEGER REFERENCES "user"(id) NOT NULL
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_lead_followup_date ON lead(followup_date);
CREATE INDEX IF NOT EXISTS idx_lead_creator_id ON lead(creator_id);