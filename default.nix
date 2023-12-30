rec {

  # ----------------------------------------------------------------------------
  # Drop connections of easily recognized scanners.

  # We use the same approach as in
  # https://blog.reiterate.app/software/2021/11/29/how-to-filter-bots-from-your-nginx-log-files/.

  # A string that can be used in a location's extraConfig to drop a connection.
  # The request is not logged. We should probably log it and use it in a
  # fail2ban rule.
  blackhole-extra-config = ''
      access_log off;
      log_not_found off;
      return 444; # Nginx non-standard code to close the connection
    '';

  # Some predefined locations. This can be e.g. used with the // operator to
  # combine them with the normal locations.
  blackhole-locations = {
    # Don't serve dotfiles, except the .well-known directory.
    # We act as if this is a non-legitimate request and drop it.
    "~ /\\.(?!well-known)".extraConfig = blackhole-extra-config;

    # We're not a WordPress or PHP server.
    "~ /wp-".extraConfig = blackhole-extra-config;
    "~ \\.php$".extraConfig = blackhole-extra-config;
    "~ \\.php/".extraConfig = blackhole-extra-config;
    "~ /symfony/".extraConfig = blackhole-extra-config;

    # We don't serve cgi-bin, although that would be lovely.
    "~ /cgi-bin/".extraConfig = blackhole-extra-config;

    # We don't do Spring things.
    "~ /actuator/".extraConfig = blackhole-extra-config;

    # Don't accept NUL byte anywhere. Unfortunately, this doesn't seem to work.
    #"~ (*UTF8)\\u0000".extraConfig = blackhole-extra-config;
    #"~ \\x00".extraConfig = blackhole-extra-config;
  };

  # ----------------------------------------------------------------------------
  # Use JSON as a logging format.

  # A string that can be used as commonHttpConfig to define a JSON-based log
  # format and activate it for all virtual servers. The default logging format
  # is also retained.
  setup-json-log-format = ''
    # See http://nginx.org/en/docs/varindex.html,
    # e.g. content_type, or goip_ stuff.
    log_format json_format escape=json '{'
      '"time": "$time_iso8601", '
      '"request_id": "$request_id", '
      '"server_name": "$server_name", '
      '"remote_addr": "$remote_addr", '
      '"remote_user": "$remote_user", '
      '"http_host": "$http_host", '
      '"scheme": "$scheme", '
      '"request": "$request", '
      '"request_method": "$request_method", '
      '"request_uri": "$request_uri", '
      '"request_filename": "$request_filename", '
      '"normalized_uri": "$uri", '
      '"status": "$status", '
      '"request_completion": "$request_completion", '
      '"request_length": "$request_length", '
      '"request_time": "$request_time", '
      '"upstream_addr": "$upstream_addr", '
      '"upstream_bytes_received":"$upstream_bytes_received", '
      '"upstream_connect_time":"$upstream_connect_time", '
      '"upstream_response_length":"$upstream_response_length", '
      '"upstream_response_time":"$upstream_response_time", '
      '"bytes": "$body_bytes_sent", '
      '"referrer": "$http_referer", '
      '"agent": "$http_user_agent"'
      '}';
    access_log /var/log/nginx/access_json.log json_format;
    access_log /var/log/nginx/access.log;
  '';
}
