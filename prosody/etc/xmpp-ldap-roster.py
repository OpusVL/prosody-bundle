#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""LICENSE="SPDX-License-Identifier: AGPL-3.0-or-later"
RELEASE="Revision 1.0.0"
AUTHOR="(c) 2020 Paul Bargewell (paul.bargewell@opusvl.com)"

Output a prosody roster file from LDAP using environment variables from .env.

    LDAP_SERVER       - LDAP server. Default localhost:389
    LDAP_USERNAME     - LDAP bind DN
    LDAP_PASSWORD     - The LDAP password
    LDAP_DOMAIN       - Used for the filename prefix and user domain
    LDAP_ORGANISATION - Used for roster name

"""

import os
import sys
import ldap
from dotenv import load_dotenv

load_dotenv(verbose=True)

env = os.environ

def get_users():
    """Extract the users from the LDAP server.

    Returns:
        dictionary ([{dn, {uid, cn}}]) : {error} or ldap attributes
    """

    if not 'LDAP_SERVER' in env:
        env['LDAP_SERVER'] = 'localhost'

    LDAP_SERVER = 'ldap://%s' % env['LDAP_SERVER']
    LDAP_USERNAME = 'cn=readonly,%s' % env['LDAP_BASE_DN']
    LDAP_PASSWORD = env['LDAP_READONLY_USER_PASSWORD']
    base_dn = env['LDAP_BASE_DN']
    ldap_filter = '(objectClass=person)'
    attrs = ['uid', 'cn']
    try:
        # build a client
        ldap_client = ldap.initialize('ldap://%s' % env['LDAP_SERVER'])
        # perform a synchronous bind
        ldap_client.set_option(ldap.OPT_REFERRALS, 0)
        ldap_client.simple_bind_s(
            'cn=readonly,%s' % env['LDAP_BASE_DN'],
            env['LDAP_READONLY_USER_PASSWORD'])
    except ldap.INVALID_CREDENTIALS:
        ldap_client.unbind()
        return {'error': 'Invalid username or password.'}
    except ldap.SERVER_DOWN:
        return {'error': 'LDAP Server not Available'}
    # all is well
    results = ldap_client.search_s(base_dn,
                                   ldap.SCOPE_SUBTREE, ldap_filter, attrs)
    ldap_client.unbind()
    return results


def create_roster(users):
    """Iterate the users attributes and write a text file

    Parameters:
        users (dictionary): [{dn, {uid, cn}}] LDAP attributes

    Returns: 
        None: Outputs to a text file
    """

    file = open('%s/vhost.d/%s-ldap-roster.txt' %
                (os.path.dirname(__file__), env['LDAP_DOMAIN']),
                'w')
    file.write('[%s]\n' % env['LDAP_ORGANISATION'])
    for user in users:
        attrs = user[1]
        file.write('%s@%s=%s\n' % (
            attrs['uid'][0].decode(),
            env['LDAP_DOMAIN'],
            attrs['cn'][0].decode()
        )
        )
    file.close()


if __name__ == "__main__":
    results = get_users()
    if not 'error' in results:
        create_roster(results)
    else:
        print(results['error'])
