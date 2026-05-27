# aaPanel + Cloudflare Subdomain Nginx Fix

Use this file when a new Cloudflare proxied subdomain points to the wrong
aaPanel site, returns another website's HTML, or shows a valid app on HTTP but a
different app on HTTPS.

## Problem Pattern

Symptoms:

- `https://api.example.com/health` opens another website on the same VPS.
- Cloudflare returns `200 text/html` instead of the API JSON.
- Local HTTP vhost works:

```bash
curl -H "Host: api.example.com" http://127.0.0.1/health
```

- But public HTTPS goes to the wrong site.
- aaPanel generated mixed Nginx `listen` styles, for example:

```nginx
# Existing site
listen 212.47.65.222:443 ssl;

# New proxy site
listen 443 ssl http2;
```

When multiple HTTPS vhosts share one public IP, mixing bound-IP listeners and
wildcard listeners can make Nginx route Cloudflare HTTPS/SNI traffic to the
wrong vhost.

## Fill These Values

Set these for the new domain before running commands:

```bash
DOMAIN="api.saeeddev.com"
PUBLIC_IP="212.47.65.222"
UPSTREAM="http://127.0.0.1:8080"
CONF="/www/server/panel/vhost/nginx/${DOMAIN}.conf"
```

## Safety Rules

- Do not delete existing website configs.
- Always back up the vhost config before editing.
- Use aaPanel Nginx, not the system Nginx:

```bash
/www/server/nginx/sbin/nginx -t
/www/server/nginx/sbin/nginx -s reload
```

- Do not paste private keys, database passwords, or Firebase secrets into chat.

## Diagnosis

Check the upstream service:

```bash
curl -m 10 "${UPSTREAM}/health"
```

Check local Nginx HTTP vhost routing:

```bash
curl -m 10 -H "Host: ${DOMAIN}" http://127.0.0.1/health
```

Find the vhost config:

```bash
grep -R "server_name ${DOMAIN}" /www/server/panel/vhost/nginx /www/server/nginx/conf -n
```

List all HTTPS listeners:

```bash
grep -R "listen .*443\|server_name" /www/server/panel/vhost/nginx/*.conf -n
```

Check whether public traffic is landing in the wrong site's log:

```bash
curl -s -o /dev/null -w "%{http_code} %{content_type}\n" "https://${DOMAIN}/health?nocache=$(date +%s)"
tail -n 20 "/www/wwwlogs/${DOMAIN}.log"
```

If another site's log receives the request, the HTTPS vhost routing is wrong.

## Standard Fix

Back up the new domain config:

```bash
cp "${CONF}" "${CONF}.bak.$(date +%Y%m%d%H%M%S)"
```

Normalize the new domain's HTTPS listener to the public-IP form:

```bash
sed -i "s/listen 443 ssl http2 ;/listen ${PUBLIC_IP}:443 ssl http2;/" "${CONF}"
sed -i "s/listen 443 ssl http2;/listen ${PUBLIC_IP}:443 ssl http2;/" "${CONF}"
sed -i "s/listen 443 ssl;/listen ${PUBLIC_IP}:443 ssl;/" "${CONF}"
```

If the HTTP listener is wildcard and other aaPanel sites use the bound-IP style,
normalize it too:

```bash
sed -i "s/listen 80;/listen ${PUBLIC_IP}:80;/" "${CONF}"
```

If aaPanel generated a QUIC listener but the installed Nginx does not support
QUIC, disable it:

```bash
sed -i 's/^[[:space:]]*listen 443 quic;/    # listen 443 quic; # disabled: nginx binary does not support quic/' "${CONF}"
```

Validate and reload:

```bash
/www/server/nginx/sbin/nginx -t
/www/server/nginx/sbin/nginx -s reload
```

## Expected Proxy Block

For an API proxy, the vhost should contain a location like this:

```nginx
location ^~ / {
  proxy_pass http://127.0.0.1:8080;
  proxy_set_header Host $http_host;
  proxy_set_header X-Real-IP $remote_addr;
  proxy_set_header X-Real-Port $remote_port;
  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  proxy_http_version 1.1;
  proxy_set_header Upgrade $http_upgrade;
  proxy_set_header Connection "upgrade";
}
```

For a static site, do not use the API proxy block. The important part is still
that all HTTPS vhosts on the same IP use the same `listen` style.

## Verification

Local upstream:

```bash
curl -m 10 "${UPSTREAM}/health"
```

Local Nginx vhost:

```bash
curl -m 10 -H "Host: ${DOMAIN}" http://127.0.0.1/health
```

Public Cloudflare route:

```bash
curl -m 15 "https://${DOMAIN}/health?nocache=$(date +%s)"
```

For this API, success should look like:

```json
{"status":"ok","database":"ok","authVerifier":"ok","version":"0.1.0"}
```

If public HTTPS still returns another website's HTML:

1. Check which log receives the request:

```bash
tail -n 20 "/www/wwwlogs/${DOMAIN}.log"
grep -R "GET /health" /www/wwwlogs/*.log | tail -n 20
```

2. Re-check all `listen 443` lines and make every public vhost consistent.
3. In Cloudflare, purge cache for the hostname or test with `?nocache=<time>`.
4. Confirm the DNS `A` record points to `PUBLIC_IP` and is proxied only when
   Cloudflare should front the site.

## Cloudflare Notes

- DNS record should usually be:

```text
Type: A
Name: api
Content: 212.47.65.222
Proxy: Proxied
TTL: Auto
```

- If using a Cloudflare Origin Certificate on the VPS, `Full (strict)` can be
  used only when the certificate includes the exact hostname or wildcard.
- If testing during setup and strict mode causes `526 Invalid SSL certificate`,
  temporarily use `Full`, then move back to `Full (strict)` after the origin
  certificate is correct.

## Durable Prevention

For every new aaPanel site/proxy on this VPS:

1. Create the subdomain in Cloudflare.
2. Create the aaPanel site/proxy.
3. Open the generated Nginx config.
4. Ensure `listen` lines match the public-IP style used by the other HTTPS
   vhosts:

```nginx
listen 212.47.65.222:80;
listen 212.47.65.222:443 ssl http2;
```

5. Disable unsupported `quic` listeners.
6. Run Nginx test and reload.
7. Test local vhost and public Cloudflare URL.
