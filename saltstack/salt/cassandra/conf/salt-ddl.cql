CREATE KEYSPACE IF NOT EXISTS salt 
           WITH replication = {'class': 'SimpleStrategy', 'replication_factor' : 1};

CREATE USER IF NOT EXISTS salt WITH PASSWORD 'salt' NOSUPERUSER;

GRANT ALL ON KEYSPACE salt TO salt;

USE salt;

CREATE KEYSPACE IF NOT EXISTS salt WITH replication = {'class': 'SimpleStrategy', 'replication_factor': '1'};

CREATE TABLE IF NOT EXISTS salt.salt_returns (
    jid text PRIMARY KEY,
    alter_time timestamp,
    full_ret text,
    fun text,
    id text,
    return text,
    success boolean 
);
CREATE INDEX IF NOT EXISTS fun ON salt.salt_returns (fun);
CREATE INDEX IF NOT EXISTS id ON salt.salt_returns (id);

CREATE TABLE IF NOT EXISTS salt.jid (
    jid text PRIMARY KEY,
    load text
);

CREATE TABLE IF NOT EXISTS salt.salt_events (
    id timeuuid PRIMARY KEY,
    alter_time timestamp,
    data text,
    master_id text,
   tag text
);
 CREATE INDEX IF NOT EXISTS tag ON salt.salt_events (tag);
