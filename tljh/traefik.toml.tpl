# traefik.toml file template
{% if https['enabled'] %}
defaultEntryPoints = ["http", "https"]
{% else %}
defaultEntryPoints = ["http"]
{% endif %}

debug = true
logLevel = "INFO"
# log errors, which could be proxy errors
[accessLog]
format = "json"
[accessLog.filters]
statusCodes = ["500-999"]

[accessLog.fields.headers]
[accessLog.fields.headers.names]
Authorization = "redact"
Cookie = "redact"
Set-Cookie = "redact"
X-Xsrftoken = "redact"

[respondingTimeouts]
idleTimeout = "10m0s"

[wss]
protocol = "http"

[entryPoints]
  [entryPoints.http]
  address = ":{{http['port']}}"
  {% if https['enabled'] %}
    [entryPoints.http.redirect]
    entryPoint = "https"
  {% endif %}

  {% if https['enabled'] %}
  [entryPoints.https]
  address = ":{{https['port']}}"
  [entryPoints.https.tls]
  {% if https['tls']['cert'] %}
    [[entryPoints.https.tls.certificates]]
      certFile = "{{https['tls']['cert']}}"
      keyFile = "{{https['tls']['key']}}"
  {% endif %}
  {% endif %}

{% if https['enabled'] and https['letsencrypt']['email'] %}
[acme]
email = "{{https['letsencrypt']['email']}}"
storage = "acme.json"
entryPoint = "https"
  [acme.httpChallenge]
  entryPoint = "http"

{% for domain in https['letsencrypt']['domains'] %}
[[acme.domains]]
  main = "{{domain}}"
{% endfor %}
{% endif %}

[file]
filename = "/opt/tljh/state/rules.toml"
watch = true
