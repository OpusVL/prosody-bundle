plugin_paths = { "/opt/prosody/modules" }

modules_enabled = {
    {%- for item in env['PROSODY_MODULES_ENABLED'].split(' ') %}
        "{{ item -}}";{% endfor %}
}

-- These modules are auto-loaded, but should you want
-- to disable them then uncomment them here:

modules_disabled = {
    {%- for item in env['PROSODY_MODULES_DISABLED'].split(' ') %}
        "{{ item -}}";{% endfor %}}
