network_backend = "epoll"
daemonize = false;
admins = { }

plugin_paths = { "/opt/prosody/modules" }

modules_enabled = {
{%- for item in env['PROSODY_MODULES_ENABLED'].split(' ') %}
        "{{ item -}}";{% endfor %}
}

modules_disabled = {
{%- for item in env['PROSODY_MODULES_DISABLED'].split(' ') %}
        "{{ item -}}";{% endfor %}
}

allow_registration = false
c2s_require_encryption = true
s2s_require_encryption = true
s2s_secure_auth = false
pidfile = "/var/run/prosody/prosody.pid"
authentication = "internal_hashed"
archive_expires_after = "1w" -- Remove archived messages after 1 week

default_storage = "sql"
storage = {}

sql = { 
        port = 5432, 
        username = '{{ env['PROSODY_POSTGRES_USER'] or 'prosody'}}', 
        host = 'db', 
        database = 'prosody', 
        password = '{{ env['PROSODY_DB_PASSWORD'] }}', 
        driver = "PostgreSQL" 
}

sql_manage_tables = true

-- log = {
--     {levels = {min = "info"}, to = "console"};
-- }

-- certificates = "/etc/prosody/certs"
-- certificate = "/etc/prosody/certs/{{ env['HOST'] }}.{{ env['DOMAIN'] }}/fullchain.pem";
-- key = "/etc/prosody/certs/{{ env['HOST'] }}.{{ env['DOMAIN'] }}/privkey.pem";

Include "vhost.d/*.cfg.lua"

Include "conf.d/*.cfg.lua"