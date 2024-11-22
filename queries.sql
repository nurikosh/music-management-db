-- Query 1: Retrieve artists and their merchandise items where the price is greater than 20
SELECT DISTINCT name, item_name
FROM artist
NATURAL JOIN (
    SELECT DISTINCT *
    FROM artist_merchendise 
    WHERE price > 20
);

-- Query 2: Count tickets sold for a specific event
SELECT COUNT(*) AS tickets_sold
FROM tickets
JOIN events ON tickets.event_id = events.event_id
WHERE events.event_title = 'Summer Pop Festival';

-- Query 3: Retrieve all distinct albums
SELECT DISTINCT *
FROM albums;

-- Query 4: Retrieve artists who do not have merchandise and released albums within a specific date range
SELECT DISTINCT name
FROM (
    SELECT DISTINCT *
    FROM artist
    EXCEPT
    SELECT DISTINCT artist_id, name, country_of_origin
    FROM artist
    NATURAL JOIN artist_merchendise
) AS temp
WHERE release_date > '2020-09-01' AND release_date < '2022-09-30';

-- Query 5: Get albums and their titles for a specific artist by name
SELECT DISTINCT album_id, album_title
FROM artist
NATURAL JOIN albums
WHERE name = 'Joji';

-- Query 6: Find genres associated with all albums and tracks
SELECT name
FROM genres g
WHERE NOT EXISTS (
    SELECT 1
    FROM albums a
    WHERE NOT EXISTS (
        SELECT 1
        FROM tracks t
        JOIN tracksgenres tg ON t.tracks_id = tg.tracks_id
        WHERE tg.genre_id = g.genre_id
          AND t.album_id = a.album_id
    )
);

-- Query 7: Update genre names and rollback changes
BEGIN;
UPDATE genres
SET name = 'Hip-Hop'
WHERE name = 'Hip Hop';
ROLLBACK;

-- Query 8: Delete unused genres and rollback changes
BEGIN;
DELETE FROM genres
WHERE genre_id NOT IN (
    SELECT DISTINCT genre_id
    FROM tracksgenres
);
ROLLBACK;

-- Query 9: Retrieve album titles, release dates, and track titles for albums released after a certain date
SELECT DISTINCT album_title, release_date, track_title
FROM (
    SELECT DISTINCT *
    FROM albums
    WHERE release_date > '2020-12-31'
) AS temp
NATURAL JOIN tracks;

-- Query 10: Retrieve artists who participated in events excluding a specific event title
SELECT artist_id, name, country_of_origin 
FROM artist
NATURAL JOIN (
    SELECT *
    FROM artist_events
    NATURAL JOIN events
) AS all_events
EXCEPT
SELECT artist_id, name, country_of_origin 
FROM artist
NATURAL JOIN (
    SELECT *
    FROM artist_events
    NATURAL JOIN events
    WHERE event_title != 'Summer Pop Festival'
) AS excluded_events;

-- Query 11: Retrieve artists with more than 3 tracks released after 2020
SELECT a.name, COUNT(t.tracks_id) AS track_count
FROM artist a
JOIN albums al ON a.artist_id = al.artist_id
JOIN tracks t ON al.album_id = t.album_id
WHERE al.release_date > '2020-12-31'
GROUP BY a.name
HAVING COUNT(t.tracks_id) > 3
ORDER BY track_count DESC;

-- Query 12: Create a view for popular genres with more than 5 tracks
CREATE OR REPLACE VIEW popular_genres AS
SELECT genres.name AS genre_name, 
       COUNT(DISTINCT tg.tracks_id) AS track_count
FROM genres 
JOIN tracksgenres tg ON genres.genre_id = tg.genre_id
GROUP BY genres.name
HAVING COUNT(DISTINCT tg.tracks_id) > 5;

-- Query 13: Use different methods to find artists with albums released after 2020
-- Method 1: Using EXISTS
SELECT name
FROM artist 
WHERE EXISTS (
    SELECT 1
    FROM albums al
    WHERE al.artist_id = artist.artist_id
      AND al.release_date > '2020-12-31'
)
ORDER BY name ASC;

-- Method 2: Using IN
SELECT name
FROM artist
WHERE artist_id IN (
    SELECT artist_id
    FROM albums
    WHERE release_date > '2020-12-31'
)
ORDER BY name ASC;

-- Query 14: Retrieve artists who have albums but no live records
SELECT artist.artist_id, artist.name
FROM artist
LEFT JOIN albums ON artist.artist_id = albums.artist_id
LEFT JOIN live ON albums.album_id = live.album_id
WHERE live.album_id IS NULL
UNION
SELECT artist.artist_id, artist.name
FROM artist
LEFT JOIN live ON artist.artist_id = live.album_id
LEFT JOIN albums ON live.album_id = albums.album_id
WHERE albums.album_id IS NULL
ORDER BY artist.artist_id;

-- Query 15: Retrieve albums associated with specific venues
SELECT DISTINCT artist_id, name
FROM artist
NATURAL JOIN (
    SELECT DISTINCT *
    FROM live
    NATURAL JOIN albums
    WHERE concert_venue = 'The O2 Arena'
) AS included
EXCEPT
SELECT DISTINCT artist_id, name
FROM artist
NATURAL JOIN (
    SELECT DISTINCT *
    FROM live
    NATURAL JOIN albums
    WHERE concert_venue != 'The O2 Arena'
) AS excluded;
