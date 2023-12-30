rec {
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
}
