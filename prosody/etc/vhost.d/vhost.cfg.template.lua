VirtualHost "{{ env['HOST'] }}.{{ env['DOMAIN'] }}"

    modules_enabled = {
        "bosh";
        "conversejs";
        "http_altconnect";
        "websocket";
        "webpresence";
    }

    cross_domain_bosh = true
    cross_domain_websocket = true
    
    authentication = "ldap"
    ldap_base = "{{ env['LDAP_BASE_DN'] }}"
    ldap_server = "{{ env['LDAP_URI'] or 'slapd:389' }}"
    ldap_rootdn = "cn=readonly,{{ env['LDAP_BASE_DN'] }}"
    ldap_password = "{{ env['LDAP_READONLY_USER_PASSWORD'] }}"
    ldap_filter = "(uid=$user)"
    ldap_admin_filter = "(memberOf=cn=access-role-sysadmin,ou=groups,{{ env['LDAP_BASE_DN'] }})"

    groups_file = "/etc/prosody/vhost.d/{{ env['LDAP_DOMAIN'] }}-ldap-roster.txt"

    http_host = "xmpp.{{ env['HOST'] }}.{{ env['DOMAIN'] }}"
    http_external_url = "https://xmpp.{{ env['HOST'] }}.{{ env['DOMAIN'] }}/"

    conversejs_options = {
        debug = true;
        view_mode = "fullscreen";
    }

    pep_max_items = 10000

Component "chat.{{ env['HOST'] }}.{{ env['DOMAIN'] }}" "muc"

    name = "{{ env['LDAP_ORGANIZATION'] }} Chat Room Server"

    modules_enabled = {
        "muc_mam";
        "muc_inject_mentions";
        "pastebin";
        "swedishchef";
        "vcard_muc";
    }

    name = "{{ env['LDAP_ORGANIZATION'] }} MUC"

    restrict_room_creation = "local"
    muc_room_default_persistent = true
    muc_log_by_default = true
    muc_log_expires_after = "never"
    log_all_rooms = true
    muc_room_locking = false

    pastebin_trigger = "!paste"
    pastebin_expire_after = 0

    http_host = "xmpp.{{ env['HOST'] }}.{{ env['DOMAIN'] }}"
    http_external_url = "https://xmpp.{{ env['HOST'] }}.{{ env['DOMAIN'] }}/"

    http_paths = {
        pastebin = "/paste";
    }

    swedishchef_trigger = "!chef"

Component "xmpp.{{ env['HOST'] }}.{{ env['DOMAIN'] }}" "http_upload"

    modules_enabled = {
        "proxy65";
    }

    http_host = "xmpp.{{ env['HOST'] }}.{{ env['DOMAIN'] }}" 
    http_external_url = "https://xmpp.{{ env['HOST'] }}.{{ env['DOMAIN'] }}/" 
    http_paths = { upload = "/upload" }
    http_upload_file_size_limit = 8388608
    http_upload_expire_after = 60 * 60 * 24 * 14

    proxy65_address = "xmpp.{{ env['HOST'] }}.{{ env['DOMAIN'] }}"
    pubsub_max_items = 10000

Component "pubsub.{{ env['HOST'] }}.{{ env['DOMAIN'] }}" "pubsub"

    -- autocreate_on_subscribe = false
    -- autocreate_on_publish = false

