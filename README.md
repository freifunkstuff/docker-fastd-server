# Dockerisierter fastd Server

Volumes:
* /config/secret: benötigt, um das Fastd-Secret zu persistieren

Umgebungsvariablen:

* `FASTD_MTU` (benötigt): MTU der fastd-Verbindung
* `FASTD_LOG_LEVEL` (default: info)
* `FASTD_PEER_LIMIT` (default: 100)
* `IPV6_PREFIX` (optional): Prefix für IPv6, nötig um hosts im Netz über ihre nicht-link-lokale IPv6 anzupingen. z.B. `fdef:ffc0:7030::/64`

Der Container muss `privileged` ausgeführt werden, um Netzwerkeinstellungen zur Laufzeit ändern zu können.
