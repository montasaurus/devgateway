#!/bin/sh
set -eu

CADDYFILE="/etc/caddy/Caddyfile"
UPSTREAM_HOST="${UPSTREAM_HOST:-host.docker.internal}"

# Start a fresh Caddyfile
cat > "$CADDYFILE" <<'CADDYEOF'
{
  auto_https off
}
:80 {
CADDYEOF

DEFAULT_PORT=""

printenv > /tmp/envlist
while IFS= read -r line; do
  case "$line" in
    HOST__*=*)
      name="${line%%=*}"
      port="${line#*=}"
      host="${name#HOST__}"
      host_lc=$(printf '%s' "$host" | tr '[:upper:]' '[:lower:]')
      matcher_id=$(printf '%s' "$host_lc" | tr -c 'a-z0-9' '_')

      if [ "$host_lc" = "default" ]; then
        DEFAULT_PORT="$port"
      else
        # Match any domain with this subdomain via Host header regex.
        {
          printf '  @host_%s header_regexp Host ^%s\\..+$\n' "$matcher_id" "$host_lc"
          printf '  handle @host_%s {\n' "$matcher_id"
          printf '    reverse_proxy %s:%s\n' "$UPSTREAM_HOST" "$port"
          printf '  }\n'
        } >> "$CADDYFILE"
      fi
      ;;
  esac
  done < /tmp/envlist
rm -f /tmp/envlist

if [ -n "$DEFAULT_PORT" ]; then
  {
    printf '  handle {\n'
    printf '    reverse_proxy %s:%s\n' "$UPSTREAM_HOST" "$DEFAULT_PORT"
    printf '  }\n'
  } >> "$CADDYFILE"
else
  # No default configured; return a helpful error.
  printf '  respond "No HOST__default configured" 502\n' >> "$CADDYFILE"
fi

printf '}\n' >> "$CADDYFILE"

exec caddy run --config "$CADDYFILE" --adapter caddyfile
