Some bits of Nginx configuration that can be used with the Nginx NixOS module.

Currently, we only define some Nginx locations that drop the connection when
requests that look like malicious scanners are recognized.
