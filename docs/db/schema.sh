CREATE TABLE IF NOT EXISTS teachers (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS students (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name TEXT NOT NULL,
  tab_session_id TEXT NOT NULL UNIQUE,
  last_seen TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS sessions (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name TEXT,
  teacher_id BIGINT REFERENCES teachers(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

DO $$ BEGIN
    CREATE TYPE poll_status AS ENUM ('DRAFT', 'ACTIVE', 'ENDED');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

CREATE TABLE IF NOT EXISTS polls (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  session_id BIGINT REFERENCES sessions(id) ON DELETE CASCADE,
  question TEXT NOT NULL,
  status poll_status NOT NULL,
  duration_seconds INT NOT NULL CHECK (duration_seconds > 0),
  start_time TIMESTAMPTZ,
  end_time TIMESTAMPTZ,
  created_by BIGINT REFERENCES teachers(id),
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS one_active_poll_per_session
ON polls(session_id)
WHERE status = 'ACTIVE';

CREATE TABLE IF NOT EXISTS poll_options (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  poll_id BIGINT NOT NULL REFERENCES polls(id) ON DELETE CASCADE,
  label TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_options_poll ON poll_options(poll_id);

CREATE TABLE IF NOT EXISTS poll_participants (
  poll_id BIGINT NOT NULL REFERENCES polls(id) ON DELETE CASCADE,
  student_id BIGINT NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  joined_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  has_voted BOOLEAN NOT NULL DEFAULT false,
  PRIMARY KEY (poll_id, student_id)
);

CREATE INDEX IF NOT EXISTS idx_participants_poll ON poll_participants(poll_id);

CREATE TABLE IF NOT EXISTS votes (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  poll_id BIGINT NOT NULL REFERENCES polls(id) ON DELETE CASCADE,
  option_id BIGINT NOT NULL REFERENCES poll_options(id),
  student_id BIGINT NOT NULL REFERENCES students(id),
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE (poll_id, student_id)
);

CREATE INDEX IF NOT EXISTS idx_votes_poll ON votes(poll_id);
CREATE INDEX IF NOT EXISTS idx_votes_option ON votes(option_id);

CREATE TABLE IF NOT EXISTS poll_results (
  poll_id BIGINT PRIMARY KEY REFERENCES polls(id) ON DELETE CASCADE,
  results JSONB NOT NULL,
  total_votes INT NOT NULL,
  ended_at TIMESTAMPTZ NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_students_last_seen ON students(last_seen);