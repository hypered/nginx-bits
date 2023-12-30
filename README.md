Some bits of Nginx configuration that can be used with the Nginx NixOS module.

Currently, we define:

- Some Nginx locations that drop the connection when requests that look like
  malicious scanners are recognized.
- A JSON-based log format, with quite a few additional fields compared to the
  default.
