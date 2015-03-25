# -*- coding: utf-8 -*-
'''
Return data to a cassandra server

:maintainer:    Corin Kochenower<ckochenower@saltstack.com>
:maturity:      new as of 2015.2
:depends:       salt.modules.cassandra_cql
:depends:       DataStax Python Driver for Apache Cassandra
                https://github.com/datastax/python-driver
                pip install cassandra-driver
:platform:      all

:configuration:
    To enable this returner, the minion will need the DataStax Python Driver
    for Apache Cassandra ( https://github.com/datastax/python-driver ) 
    installed and the following values configured in the minion or master 
    config. The list of cluster IPs must include at least one cassandra node 
    IP address. No assumption or default will be used for the cluster IPs. 
    The cluster IPs will be tried in the order listed. The port, username,
    and password values shown below will be the assumed defaults if you do
    not provide values.::

    cassandra:
      cluster:
        - 192.168.50.10
        - 192.168.50.11
        - 192.168.50.12
      port: 9042
      username: salt
      password: salt

Use the following cassandra database schema::

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
        success text
    );
    CREATE INDEX IF NOT EXISTS fun ON salt.salt_returns (fun);
    CREATE INDEX IF NOT EXISTS id ON salt.salt_returns (id);
    
    CREATE TABLE IF NOT EXISTS salt.jids (
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


Required python modules: Cassandradb

  To use the cassandra returner, append '--return cassandra' to the salt command. ex:

    salt '*' test.ping --return cassandra
'''
from __future__ import absolute_import
# Let's not allow PyLint complain about string substitution
# pylint: disable=W1321,E1321

# Import python libs
import sys
import json
import logging
import uuid

# Import salt libs
import salt.returners
import salt.utils.jid
import salt.exceptions

# Import third party libs
try:
    import salt.modules.cassandra_cql
    HAS_CASSANDRA_DRIVER = True
except ImportError:
    HAS_CASSANDRA_DRIVER = False

log = logging.getLogger(__name__)

# Define the module's virtual name
__virtualname__ = 'cassandra_cql_return'


def __virtual__():
    if not HAS_CASSANDRA_DRIVER:
        return False
    return True

def returner(ret):
    '''
    Return data to one of potentially many clustered cassandra nodes
    '''
    query = '''INSERT INTO salt.salt_returns (
                 fun, jid, return, id, success, full_ret, alter_time
               ) VALUES (
                 {0}, {1}, {2}, {3}, {4}, {5}, {6}
               );'''.format(
                 ret['fun'], 
                 ret['jid'], 
                 json.dumps(ret['return']), 
                 ret['id'], 
                 ret.get('success', False), 
                 json.dumps(ret), 
                 str(uuid.uuid1())
               )

    # _query may raise a CommandExecutionError
    try:
        #_query(query, contact_points, port, cql_user, cql_pass)
        _query(query)
    except CommandExecutionError as e:
        log.critical('Could not store return with Cassandra returner. Cassandra server unavailable.')
        raise e;


def event_return(events):
    '''
    Return event to one of potentially many clustered cassandra nodes

    Requires that configuration be enabled via 'event_return'
    option in master config.
    '''
    for event in events:
        tag = event.get('tag', '')
        data = event.get('data', '')
        query = '''INSERT INTO salt_events (
                     tag, data, master_id, alter_time
                   ) VALUES (
                     {0}, {1}, {2}, {3}
                   );'''.format(tag, 
                                json.dumps(data), 
                                __opts__['id'], 
                                str(uuid.uuid1()))
        # _query may raise a CommandExecutionError
        try:
            #_query(query, contact_points, port, cql_user, cql_pass)
            _query(query)
        except CommandExecutionError as e:
            log.critical('Could not store events with Cassandra returner. Cassandra server unavailable.')
            raise e;


def save_load(jid, load):
    '''
    Save the load to the specified jid id
    '''
    query = '''INSERT INTO jids (
                 jid, load
               ) VALUES (
                 {0}, {1}
               );'''.format(jid, json.dumps(load))

    # _query may raise a CommandExecutionError
    try:
        #_query(query, contact_points, port, cql_user, cql_pass)
        _query(query)
    except CommandExecutionError as e:
        log.critical('Could not save load in jids table. Cassandra server unavailable.')
        raise e;


def get_load(jid):
    '''
    Return the load data that marks a specified jid
    '''
    query = '''SELECT load FROM jids WHERE jid = {0};'''.format(jid)

    ret = {}

    # _query may raise a CommandExecutionError
    try:
        #return _query(query, contact_points, port, cql_user, cql_pass)
        data = _query(query)
        ret = json.loads(data[0])
    except CommandExecutionError as e:
        log.critical('Could not get load from jids table. Cassandra server unavailable.')
        raise e;

    return ret


def get_jid(jid):
    '''
    Return the information returned when the specified job id was executed
    '''
    query = '''SELECT id, full_ret FROM salt_returns WHERE jid = {0}'''.format(jid)

    ret = {}

    # _query may raise a CommandExecutionError
    try:
        #data = _query(query, contact_points, port, cql_user, cql_pass)
        data = _query(query)
        if data:
            for minion, full_ret in data:
                ret[minion] = json.loads(full_ret)
    except CommandExecutionError as e:
        log.critical('Could not select job specific information. Cassandra server unavailable.')
        raise e;

    return ret


# Cassandra does not support joins or sub-queries!
#def get_fun(fun):
#    '''
#    Return a dict of the last function called for all minions
#    '''
#    with _get_serv(ret=None, commit=True) as cur:
#
#        sql = '''SELECT s.id,s.jid, s.full_ret
#                FROM `salt_returns` s
#                JOIN ( SELECT MAX(`jid`) as jid
#                    from `salt_returns` GROUP BY fun, id) max
#                ON s.jid = max.jid
#                WHERE s.fun = %s
#                '''
#
#        cur.execute(sql, (fun,))
#        data = cur.fetchall()
#
#        ret = {}
#        if data:
#            for minion, _, full_ret in data:
#                ret[minion] = json.loads(full_ret)
#        return ret


def get_jids():
    '''
    Return a list of all job ids
    '''
    query = '''SELECT DISTINCT jid FROM jids'''

    ret = []

    # _query may raise a CommandExecutionError
    try:
        #data = _query(query, contact_points, port, cql_user, cql_pass)
        data = _query(query)
        for jid in data:
            ret.append(jid[0])
    except CommandExecutionError as e:
        log.critical('Could not get a list of all job ids. Cassandra server unavailable.')
        raise e;

    return ret


def get_minions():
    '''
    Return a list of minions
    '''
    query = '''SELECT DISTINCT id FROM salt_returns'''

    ret = []

    # _query may raise a CommandExecutionError
    try:
        #data = _query(query, contact_points, port, cql_user, cql_pass)
        data = _query(query)
        for minion in data:
            ret.append(jid[0])
    except CommandExecutionError as e:
        log.critical('Could not get the list of minions. Cassandra server unavailable.')
        raise e;

    return ret


def prep_jid(nocache, passed_jid=None):  # pylint: disable=unused-argument
    '''
    Do any work necessary to prepare a JID, including sending a custom id
    '''
    return passed_jid if passed_jid is not None else salt.utils.jid.gen_jid()
