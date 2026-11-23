-- TODO: Add the columns you'd like to insert in your preferred
-- order and update the placeholders
INSERT INTO
  grrrs (uuid, author_handle, body, created_at, updated_at)
VALUES
  ($1, $2, $3, $4, $5)
RETURNING
  *
