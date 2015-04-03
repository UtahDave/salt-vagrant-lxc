CREATE KEYSPACE IF NOT EXISTS salt
    WITH replication = {'class': 'SimpleStrategy', 'replication_factor' : 1};

CREATE USER IF NOT EXISTS salt WITH PASSWORD 'salt' NOSUPERUSER;

GRANT ALL ON KEYSPACE salt TO salt;

USE salt;

CREATE TABLE IF NOT EXISTS salt.salt_returns (
    jid text,
    minion_id text,
    fun text,
    alter_time timestamp,
    full_ret text,
    return text,
    success boolean,
    PRIMARY KEY (jid, minion_id, fun)
) WITH CLUSTERING ORDER BY (minion_id ASC, fun ASC);
CREATE INDEX IF NOT EXISTS salt_returns_id ON salt.salt_returns (minion_id);
CREATE INDEX IF NOT EXISTS salt_returns_fun ON salt.salt_returns (fun);

CREATE TABLE IF NOT EXISTS salt.jids (
    jid text PRIMARY KEY,
    load text
);

CREATE TABLE IF NOT EXISTS salt.minions (
    minion_id text PRIMARY KEY,
    last_fun text
);
CREATE INDEX IF NOT EXISTS minions_last_fun ON salt.minions (last_fun);

CREATE TABLE IF NOT EXISTS salt.salt_events (
    id timeuuid,
    tag text,
    alter_time timestamp,
    data text,
    master_id text,
    PRIMARY KEY (id, tag)
) WITH CLUSTERING ORDER BY (tag ASC);
CREATE INDEX IF NOT EXISTS tag ON salt.salt_events (tag);
