# List all configs
openvpn3 configs-list

# List session
openvpn3 sessions-list

# Connect
openvpn3 session-start --config NAME

# Disconnect
openvpn3 session-manage --disconnect --config NAME

# Rename config
openvpn3 config-manage --config old-name --rename new-name

# Import config
openvpn3 config-import --config /path/to/config.ovpn --persistent --name NAME

# Fix compression algorithm error
openvpn3 config-manage --allow-compression yes  --config NAME
