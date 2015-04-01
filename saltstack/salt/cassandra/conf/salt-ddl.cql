CREATE KEYSPACE IF NOT EXISTS salt
    WITH replication = {'class': 'SimpleStrategy', 'replication_factor' : 1};

CREATE USER IF NOT EXISTS salt WITH PASSWORD 'salt' NOSUPERUSER;

GRANT ALL ON KEYSPACE salt TO salt;

USE salt;

CREATE TABLE salt.salt_returns (
    jid text,
    id text,
    fun text,
    alter_time timestamp,
    full_ret text,
    return text,
    success boolean,
    PRIMARY KEY (jid, id, fun)
) WITH CLUSTERING ORDER BY (id ASC, fun ASC);
CREATE INDEX id ON salt.salt_returns (id);
CREATE INDEX fun ON salt.salt_returns (fun);

CREATE TABLE salt.jids (
    jid text PRIMARY KEY,
    load text
);

CREATE TABLE salt.minions (
    id text PRIMARY KEY,
    last_fun text
);
CREATE INDEX last_fun ON salt.minions (last_fun);

CREATE TABLE salt.salt_events (
    id timeuuid,
    tag text,
    alter_time timestamp,
    data text,
    master_id text,
    PRIMARY KEY (id, tag)
) WITH CLUSTERING ORDER BY (tag ASC);
CREATE INDEX tag ON salt.salt_events (tag);
