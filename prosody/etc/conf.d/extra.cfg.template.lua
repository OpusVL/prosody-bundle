-- contains config variables to be included to the global config file
http_default_host = "xmpp.{{ env['HOST'] }}.{{ env['DOMAIN'] }}"

-- disable https internally since we're using nginx
https_ports = {}
https_interfaces = {}

-- consider BOSH secure since we terminate TLS with nginx
cross_domain_bosh = true
consider_bosh_secure = true

-- Same-Origin policy and nginx proxy fix
cross_domain_websocket = true
consider_websocket_secure = true

-- mam settings
default_archive_policy = true
archive_expires_after = "never" -- keep messages forever
max_archive_query_results = 80 -- 80 messages per page request


-- misc

lastlog_ip_address = true

-- server contact info
contact_info = {
  abuse = { "mailto:support@{{ env['HOST'] }}.{{ env['DOMAIN'] }}" };
  admin = { "mailto:support@{{ env['HOST'] }}.{{ env['DOMAIN'] }}" };
  support = { "https://www.{{ env['HOST'] }}.{{ env['DOMAIN'] }}/contact", "mailto:support@{{ env['HOST'] }}.{{ env['DOMAIN'] }}" };
}
