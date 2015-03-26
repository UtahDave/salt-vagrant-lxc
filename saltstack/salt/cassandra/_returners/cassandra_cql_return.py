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
        - 192.168.50.11
        - 192.168.50.12
        - 192.168.50.13
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
        success boolean
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


Required python modules: cassandra-driver 

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
import time

# Import salt libs
import salt.returners
import salt.utils.jid
import salt.exceptions
from salt.exceptions import CommandExecutionError

# Import third party libs
try:
    # This returner depends on the cassandra_cql Salt execution module.
    #
    # The cassandra_cql execution module will not load if the DataStax Python Driver
    # for Apache Cassandra is not installed. This returner cross-calls the 
    # cassandra_cql execution module using the __salt__ dunder. 
    #
    # This module will try to load all of the 3rd party dependencies on which the
    # cassandra_cql execution module depends.
    #
    # Effectively, if the DataStax Python Driver for Apache Cassandra is not
    # installed, both the cassandra_cql execution module and this returner module
    # will not be loaded by Salt's loader system.
    from cassandra.cluster import Cluster
    from cassandra.cluster import NoHostAvailable
    from cassandra.connection import ConnectionException, ConnectionShutdown
    from cassandra.auth import PlainTextAuthProvider
    from cassandra.query import dict_factory
    HAS_CASSANDRA_DRIVER = True
except ImportError as e:
    HAS_CASSANDRA_DRIVER = False

log = logging.getLogger(__name__)

# Define the module's virtual name
# NOTE: The 'cassandra' virtualname is already taken by the
# returners/cassandra_return.py module.
__virtualname__ = 'cassandra_cql'


def __virtual__():
    if not HAS_CASSANDRA_DRIVER:
        log.debug("Failed to load cassandra_cql_return module.")
        return False

    log.debug("Successfully load cassandra_cql_return module.")
    return True

def returner(ret):
    '''
    Return data to one of potentially many clustered cassandra nodes
    '''
    query = '''INSERT INTO salt.salt_returns (
                 jid, alter_time, full_ret, fun, id, return, success 
               ) VALUES (
                 '{0}', '{1}', '{2}', '{3}', '{4}', '{5}', {6}
               );'''.format(
                 ret['jid'], 
                 int(time.time() * 1000),
                 json.dumps(ret), 
                 ret['fun'], 
                 ret['id'], 
                 json.dumps(ret['return']), 
                 ret.get('success', False), 
               )

    # cassandra_cql.cql_query may raise a CommandExecutionError
    try:
        __salt__['cassandra_cql.cql_query'](query)
    except CommandExecutionError as ce:
        log.critical('Could not insert into salt_returns with Cassandra returner.')
        raise ce;
    except Exception as e:
        log.critical('Unexpected error while inserting into salt_returns: {0}'.format(sys.exec_info()[0]))
        raise


def event_return(events):
    '''
    Return event to one of potentially many clustered cassandra nodes

    Requires that configuration be enabled via 'event_return'
    option in master config.

    Cassandra does not support an auto-increment feature due to the
    highly inefficient nature of creating a monotonically increasing
    number accross all nodes in a distributed database. Each event
    will be assigned a uuid by the connecting client.
    '''
    for event in events:
        tag = event.get('tag', '')
        data = event.get('data', '')
        query = '''INSERT INTO salt.salt_events (
                     id, alter_time, data, master_id, tag
                   ) VALUES (
                     {0}, {1}, '{2}', '{3}', '{4}'
                   );'''.format(str(uuid.uuid1()),
                                int(time.time() * 1000),
                                json.dumps(data), 
                                __opts__['id'], 
                                tag)
        # cassandra_cql.cql_query may raise a CommandExecutionError
        try:
            __salt__['cassandra_cql.cql_query'](query)
        except CommandExecutionError as e:
            log.critical('Could not store events with Cassandra returner.')
            raise e;


def save_load(jid, load):
    '''
    Save the load to the specified jid id
    '''
    query = '''INSERT INTO salt.jids (
                 jid, load
               ) VALUES (
                 '{0}', '{1}'
               );'''.format(jid, json.dumps(load))

    # cassandra_cql.cql_query may raise a CommandExecutionError
    try:
        __salt__['cassandra_cql.cql_query'](query)
    except CommandExecutionError as e:
        log.critical('Could not save load in jids table.')
        raise e;


def get_load(jid):
    '''
    Return the load data that marks a specified jid
    '''
    query = '''SELECT load FROM salt.jids WHERE jid = '{0}';'''.format(jid)

    ret = {}

    # cassandra_cql.cql_query may raise a CommandExecutionError
    try:
        data = __salt__['cassandra_cql.cql_query'](query)
        ret = json.loads(data[0])
    except CommandExecutionError as e:
        log.critical('Could not get load from jids table.')
        raise e;

    return ret


def get_jid(jid):
    '''
    Return the information returned when the specified job id was executed
    '''
    query = '''SELECT id, full_ret FROM salt.salt_returns WHERE jid = '{0}';'''.format(jid)

    ret = {}

    # cassandra_cql.cql_query may raise a CommandExecutionError
    try:
        data = __salt__['cassandra_cql.cql_query'](query)
        if data:
            for minion, full_ret in data:
                ret[minion] = json.loads(full_ret)
    except CommandExecutionError as e:
        log.critical('Could not select job specific information.')
        raise e;

    return ret


# Cassandra does not support joins or sub-queries!
# The following function was implemented in the mysql returner,
# but cannot be implemented here, because joins and sub-queries
# are not supported. 
#
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
    query = '''SELECT DISTINCT jid FROM salt.jids;'''

    ret = []

    # cassandra_cql.cql_query may raise a CommandExecutionError
    try:
        data = __salt__['cassandra_cql.cql_query'](query)
        for jid in data:
            ret.append(jid[0])
    except CommandExecutionError as e:
        log.critical('Could not get a list of all job ids.')
        raise e;

    return ret


def get_minions():
    '''
    Return a list of minions
    '''
    query = '''SELECT DISTINCT id FROM salt.salt_returns;'''

    ret = []

    # cassandra_cql.cql_query may raise a CommandExecutionError
    try:
        data = __salt__['cassandra_cql.cql_query'](query)
        for minion in data:
            ret.append(jid[0])
    except CommandExecutionError as e:
        log.critical('Could not get the list of minions.')
        raise e;

    return ret


def prep_jid(nocache, passed_jid=None):  # pylint: disable=unused-argument
    '''
    Do any work necessary to prepare a JID, including sending a custom id
    '''
    return passed_jid if passed_jid is not None else salt.utils.jid.gen_jid()
