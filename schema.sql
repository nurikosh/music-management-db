-- Function to remove all tables and sequences
DROP FUNCTION IF EXISTS remove_all();

-- Function that removes all tables and sequences in the schema
CREATE OR REPLACE FUNCTION remove_all() RETURNS void AS $$
DECLARE
    rec RECORD;
    cmd TEXT;
BEGIN
    cmd := '';

    -- Remove sequences
    FOR rec IN SELECT 'DROP SEQUENCE ' || quote_ident(n.nspname) || '.' || quote_ident(c.relname) || ' CASCADE;'
               FROM pg_catalog.pg_class AS c
               LEFT JOIN pg_catalog.pg_namespace AS n ON n.oid = c.relnamespace
               WHERE relkind = 'S' AND n.nspname NOT IN ('pg_catalog', 'pg_toast') AND pg_catalog.pg_table_is_visible(c.oid)
    LOOP
        cmd := cmd || rec.name;
    END LOOP;

    -- Remove tables
    FOR rec IN SELECT 'DROP TABLE ' || quote_ident(n.nspname) || '.' || quote_ident(c.relname) || ' CASCADE;'
               FROM pg_catalog.pg_class AS c
               LEFT JOIN pg_catalog.pg_namespace AS n ON n.oid = c.relnamespace
               WHERE relkind = 'r' AND n.nspname NOT IN ('pg_catalog', 'pg_toast') AND pg_catalog.pg_table_is_visible(c.oid)
    LOOP
        cmd := cmd || rec.name;
    END LOOP;

    EXECUTE cmd;
END;
$$ LANGUAGE plpgsql;

-- Call the function to remove all tables and sequences
SELECT remove_all();

-- Create the 'artist' table
CREATE TABLE artist (
    artist_id SERIAL PRIMARY KEY, -- Primary key
    name VARCHAR(256) NOT NULL UNIQUE, -- Artist name (must be unique)
    country_of_origin VARCHAR(256) NOT NULL -- Country of origin
);

-- Create the 'albums' table
CREATE TABLE albums (
    album_id SERIAL PRIMARY KEY, -- Primary key
    artist_id INTEGER NOT NULL, -- Foreign key referencing 'artist'
    album_title VARCHAR(256) NOT NULL, -- Album title
    release_date DATE -- Album release date
);

-- Foreign key for 'albums' table
ALTER TABLE albums ADD CONSTRAINT fk_albums_artist FOREIGN KEY (artist_id) REFERENCES artist (artist_id) ON DELETE CASCADE;

-- Create the 'genres' table
CREATE TABLE genres (
    genre_id SERIAL PRIMARY KEY, -- Primary key
    name VARCHAR(256) NOT NULL UNIQUE, -- Genre name (must be unique)
    description VARCHAR(256) NOT NULL -- Genre description
);

-- Create the 'tracks' table
CREATE TABLE tracks (
    tracks_id SERIAL PRIMARY KEY, -- Primary key
    album_id INTEGER NOT NULL, -- Foreign key referencing 'albums'
    track_title VARCHAR(256) NOT NULL -- Track title
);

-- Foreign key for 'tracks' table
ALTER TABLE tracks ADD CONSTRAINT fk_tracks_albums FOREIGN KEY (album_id) REFERENCES albums (album_id) ON DELETE CASCADE;

-- Create the 'tracksgenres' table to map tracks to genres
CREATE TABLE tracksgenres (
    genre_id INTEGER NOT NULL, -- Foreign key referencing 'genres'
    tracks_id INTEGER NOT NULL, -- Foreign key referencing 'tracks'
    last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Last update timestamp
    PRIMARY KEY (genre_id, tracks_id) -- Composite primary key
);

-- Foreign keys for 'tracksgenres' table
ALTER TABLE tracksgenres ADD CONSTRAINT fk_tracksgenres_genres FOREIGN KEY (genre_id) REFERENCES genres (genre_id) ON DELETE CASCADE;
ALTER TABLE tracksgenres ADD CONSTRAINT fk_tracksgenres_tracks FOREIGN KEY (tracks_id) REFERENCES tracks (tracks_id) ON DELETE CASCADE;

-- Create the 'events' table
CREATE TABLE events (
    event_id SERIAL PRIMARY KEY, -- Primary key
    event_title VARCHAR(256) NOT NULL -- Event title
);

-- Create the 'artist_events' table to map artists to events
CREATE TABLE artist_events (
    artist_id INTEGER NOT NULL, -- Foreign key referencing 'artist'
    event_id INTEGER NOT NULL, -- Foreign key referencing 'events'
    date DATE NOT NULL, -- Event date
    PRIMARY KEY (artist_id, event_id) -- Composite primary key
);

-- Foreign keys for 'artist_events' table
ALTER TABLE artist_events ADD CONSTRAINT fk_artist_events_artist FOREIGN KEY (artist_id) REFERENCES artist (artist_id) ON DELETE CASCADE;
ALTER TABLE artist_events ADD CONSTRAINT fk_artist_events_events FOREIGN KEY (event_id) REFERENCES events (event_id) ON DELETE CASCADE;

-- Create the 'artist_merchandise' table
CREATE TABLE artist_merchendise (
    merch_id SERIAL PRIMARY KEY, -- Primary key
    artist_id INTEGER NOT NULL, -- Foreign key referencing 'artist'
    item_name VARCHAR(256) NOT NULL, -- Merchandise item name
    price MONEY NOT NULL CHECK (price > 0), -- Price of the item (must be positive)
    description VARCHAR(256) -- Optional description
);

-- Foreign key for 'artist_merchendise' table
ALTER TABLE artist_merchendise ADD CONSTRAINT fk_artist_merchendise_artist FOREIGN KEY (artist_id) REFERENCES artist (artist_id) ON DELETE CASCADE;

-- Create the 'tickets' table
CREATE TABLE tickets (
    ticket_id SERIAL, -- Serial primary key
    event_id INTEGER NOT NULL, -- Foreign key referencing 'events'
    price MONEY NOT NULL CHECK (price > 0), -- Ticket price (must be positive)
    purchase_date DATE, -- Purchase date
    PRIMARY KEY (ticket_id, event_id) -- Composite primary key
);

-- Foreign key for 'tickets' table
ALTER TABLE tickets ADD CONSTRAINT fk_tickets_events FOREIGN KEY (event_id) REFERENCES events (event_id) ON DELETE CASCADE;

-- Create the 'live' table for live albums
CREATE TABLE live (
    album_id INTEGER PRIMARY KEY, -- Foreign key referencing 'albums'
    concert_venue VARCHAR(256) NOT NULL, -- Venue of the concert
    concert_date DATE NOT NULL -- Date of the concert
);

-- Foreign key for 'live' table
ALTER TABLE live ADD CONSTRAINT fk_live_albums FOREIGN KEY (album_id) REFERENCES albums (album_id) ON DELETE CASCADE;

-- Create the 'studio' table for studio albums
CREATE TABLE studio (
    album_id INTEGER PRIMARY KEY, -- Foreign key referencing 'albums'
    producer VARCHAR(256) NOT NULL, -- Producer of the album
    studio_name VARCHAR(256) NOT NULL -- Studio name
);

-- Foreign key for 'studio' table
ALTER TABLE studio ADD CONSTRAINT fk_studio_albums FOREIGN KEY (album_id) REFERENCES albums (album_id) ON DELETE CASCADE;
