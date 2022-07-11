/* Schemas */

CREATE TABLE blocks (
  bl_hash VARCHAR(66) NOT NULL,
  bl_parent VARCHAR(66) NOT NULL,

  bl_number BIGSERIAL NOT NULL,
  bl_timestamp TIMESTAMP,
  bl_chain SMALLINT NOT NULL,

  bl_extra JSONB,
  bl_raw JSONB,
  PRIMARY KEY (bl_number, bl_hash, bl_chain)
);

CREATE INDEX bl_idx_chain ON blocks (bl_chain);
CREATE INDEX bl_idx_hash ON blocks (bl_hash);
CREATE INDEX bl_idx_range ON blocks (bl_number);
CREATE INDEX bl_idx_date ON blocks (bl_timestamp);

SELECT create_hypertable('blocks', 'bl_number', chunk_time_interval => 330000);

CREATE TABLE transactions (
  tx_block BIGSERIAL NOT NULL,
  tx_hash VARCHAR(66) NOT NULL,

  tx_from VARCHAR(42),
  tx_to VARCHAR(42),
  tx_value BIGINT,
  tx_data TEXT,

  tx_gas_limit BIGINT,
  tx_gas_price BIGINT,
  tx_max_fee_per_gas BIGINT,
  tx_max_pfee_per_gas BIGINT,

  tx_nonce BIGINT,
  tx_timestamp TIMESTAMP,
  tx_chain SMALLINT NOT NULL,

  tx_extra JSONB,
  tx_raw JSONB,
  PRIMARY KEY (tx_block, tx_hash, tx_chain)
);

CREATE INDEX tx_idx_chain ON transactions (tx_chain);
CREATE INDEX tx_idx_sender ON transactions (tx_from);
CREATE INDEX tx_idx_recipient ON transactions (tx_to);
CREATE INDEX tx_idx_date ON transactions (tx_timestamp);

SELECT create_hypertable('transactions', 'tx_block', chunk_time_interval => 330000);

CREATE TABLE events (
  ev_block BIGSERIAL NOT NULL,

  ev_bhash VARCHAR(66) NOT NULL,
  ev_index SMALLINT,

  ev_data TEXT,

  ev_chain SMALLINT NOT NULL,

  ev_extra JSONB,
  ev_raw JSONB,
  PRIMARY KEY (ev_block, ev_bhash, ev_index, ev_chain)
);

CREATE INDEX ev_idx_chain ON events (ev_chain, ev_block);

SELECT create_hypertable('events', 'ev_block', chunk_time_interval => 330000);

CREATE TABLE contracts (
  ct_id TEXT,
  ct_address VARCHAR(66) NOT NULL,

  ct_tx_top BIGSERIAL,
  ct_ev_top BIGSERIAL,

  ct_extra JSONB,
  PRIMARY KEY(ct_id)
);


/* Triggers */

CREATE OR REPLACE FUNCTION notify_trigger() RETURNS trigger AS $trigger$
DECLARE
  rec RECORD;
  dat RECORD;
  payload TEXT;
BEGIN

  -- Set record row depending on operation
  CASE TG_OP
  WHEN 'UPDATE' THEN
     rec := NEW;
     dat := OLD;
  WHEN 'INSERT' THEN
     rec := NEW;
  WHEN 'DELETE' THEN
     rec := OLD;
  ELSE
     RAISE EXCEPTION 'Unknown TG_OP: "%". Should not occur!', TG_OP;
  END CASE;

  -- Build the payload
  payload := json_build_object('timestamp', CURRENT_TIMESTAMP, 'action', LOWER(TG_OP), 'schema', TG_TABLE_SCHEMA, 'identity', TG_TABLE_NAME, 'record', row_to_json(rec), 'old', row_to_json(dat));

  -- Notify the channel
  PERFORM pg_notify(TG_ARGV[0], payload);

  RETURN rec;
END;
$trigger$ LANGUAGE plpgsql;


CREATE TRIGGER ct_rehydrate AFTER UPDATE ON contracts 
FOR EACH ROW EXECUTE PROCEDURE notify_trigger('ct_rehydrate');