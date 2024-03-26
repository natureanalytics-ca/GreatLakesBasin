DROP PROCEDURE IF EXISTS clip_layer(
  in_schema text
  in_layer
  clip_layer text
  out_layer text
);

CREATE
PROCEDURE clip_layer(
  in_schema text
  in_layer text
  clip_layer text
  out_layer text
)
AS $$
DECLARE
  table_name text;
BEGIN

  SELECT column_name
  FROM information_schema.columns
  WHERE table_schema = in_schema
  AND table_name = in_layer
  AND column_name not in ('fid', 'geom');
  LOOP
    EXECUTE 'UPDATE ' || schema || '.' || quote_ident(table_name) || ' SET geom = ST_CollectionExtract(ST_MAKEVALID(geom)) WHERE NOT ST_ISVALID(geom)';
  END LOOP;
END;
$$
LANGUAGE 'plpgsql';
