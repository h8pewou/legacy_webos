# Legacy WebOS self hosting tools

Server side tools to keep WebOS 2 & 3 devices functional after the demise of Palm.

## Dockerizing Squid with SSL bump for old WebOS and Mac OS X PPC devices

Create a new directory for your Squid docker container:

``` bash
mkdir sslbump
cd sslbump/
```
Get the latest release of [squid-alpine-ssl](https://hub.docker.com/r/alatas/squid-alpine-ssl) release:

```bash
curl -s https://api.github.com/repos/alatas/squid-alpine-ssl/releases/latest | grep "browser_download_url.*docker.zip" | head -1 | cut -d : -f 2,3 | cut -d '"' -f 2 | xargs curl -L -o release.zip ; unzip release.zip ; rm release.zip
```

Edit your squid.conf:

```bash
vi conf/squid.conf
```
Here is a squid.conf example:
```
#
# Recommended minimum configuration:
#

# Example rule allowing access from your local networks.
# Adapt to list your (internal) IP networks from where browsing
# should be allowed
acl localnet src 10.0.0.0/8     # RFC1918 possible internal network
acl localnet src 172.16.0.0/12  # RFC1918 possible internal network
acl localnet src 192.168.0.0/16 # RFC1918 possible internal network
acl localnet src fc00::/7       # RFC 4193 local private network range
acl localnet src fe80::/10      # RFC 4291 link-local (directly plugged) machines

acl SSL_ports port 443
acl Safe_ports port 80          # http
acl Safe_ports port 21          # ftp
acl Safe_ports port 443         # https
acl Safe_ports port 70          # gopher
acl Safe_ports port 210         # wais
acl Safe_ports port 1025-65535  # unregistered ports
acl Safe_ports port 280         # http-mgmt
acl Safe_ports port 488         # gss-http
acl Safe_ports port 591         # filemaker
acl Safe_ports port 777         # multiling http
# ftp
acl safe_ports port 21
# email
acl safe_ports port 143
acl safe_ports port 110
acl safe_ports port 993
acl safe_ports port 995
acl safe_ports port 587
acl CONNECT method CONNECT

#
# Recommended minimum Access Permission configuration:
#
# Deny requests to certain unsafe ports
http_access deny !Safe_ports

# Deny CONNECT to other than secure SSL ports
http_access deny CONNECT !SSL_ports

# Only allow cachemgr access from localhost
http_access allow localhost manager
http_access deny manager

# We strongly recommend the following be uncommented to protect innocent
# web applications running on the proxy server who think the only
# one who can access services on "localhost" is a local user
#http_access deny to_localhost

#
# INSERT YOUR OWN RULE(S) HERE TO ALLOW ACCESS FROM YOUR CLIENTS
#

# Example rule allowing access from your local networks.
# Adapt localnet in the ACL section to list your (internal) IP networks
# from where browsing should be allowed
http_access allow localnet
http_access allow localhost

# And finally deny all other access to this proxy
http_access deny all

# Squid normally listens to port 3128
#http_port 3128

icap_service_failure_limit -1
ssl_bump server-first all
sslproxy_flags DONT_VERIFY_PEER

# Squid normally listens to port 4128 for ssl bump
http_port 3128 ssl-bump generate-host-certificates=on dynamic_cert_mem_cache_size=4MB cert=/etc/squid-cert/private.pem key=/etc/squid-cert/private.pem
ssl_bump server-first all
always_direct allow all

# Uncomment and adjust the following to add a disk cache directory.
cache_dir ufs /var/cache/squid 100 16 256

# Leave coredumps in the first cache dir
coredump_dir /var/cache/squid

#
# Add any of your own refresh_pattern entries above these.
#
refresh_pattern ^ftp:           1440    20%     10080
refresh_pattern ^gopher:        1440    0%      1440
refresh_pattern -i (/cgi-bin/|\?) 0     0%      0
refresh_pattern .               30      20%     4320 reload-into-ims


range_offset_limit 200 MB
maximum_object_size 200 MB
quick_abort_min -1
```

Edit your docker-compose.yml:

```bash
vi docker-compose.yml
```
Here is a docker-compose.yml example:

```yaml
version: "3"
services:
  squid-alpine-ssl:
    image: alatas/squid-alpine-ssl:r3
    environment:
      - CN=squid.local
      - O=squid
      - OU=squid
      - C=HU
    ports:
      - "3128:3128"
    volumes:
      - ./log:/var/log/
      - ./conf/squid.conf:/etc/squid/squid.conf
      - ./cache:/var/cache
      - ./cert:/etc/squid-cert
    restart: always
```

Once happy with the configuration file run docker-compose up. If everything worked fine, hit CTRL-C and restart your container using docker start sslbump_squid-alpine-ssl_1.

```bash
docker-compose up
docker start sslbump_squid-alpine-ssl_1
```

## Dockerizing codepoet80's metube Service Wrapper

This is based on [codepoet80's great work](https://github.com/codepoet80/metube-php-servicewrapper).

+ Create a new directory for metube related files
```
WEBOS-METUBE=<Path to your metube directory>
mkdir $WEBOS-METUBE
cd $WEBOS-METUBE
```

+ Clone the metube wrapper from git
    + `git clone https://github.com/codepoet80/metube-php-servicewrapper`

+ Create a config file based on this:
    + [https://raw.githubusercontent.com/h8pewou/legacy_webos/main/metube-webos-docker-compose.yml](https://raw.githubusercontent.com/h8pewou/legacy_webos/main/metube-webos-docker-compose.yml)
+ You will have to change the values in the config file! Obtain your Youtube API key from Google.
    + `nano metube-php-servicewrapper/config.php`

+ Create your docker-compose.yaml based on this:
    + [https://raw.githubusercontent.com/h8pewou/legacy_webos/main/metube-webos-docker-compose.yml](https://raw.githubusercontent.com/h8pewou/legacy_webos/main/metube-webos-docker-compose.yml)
+ This works without any modifications but it only contains the bare minimum configuration.
    + `nano docker-compose.yml`

+ Bring up your docker containers
    + `docker-compose --file docker-compose.yml --project-name metube_webos up --detach`

+ Check if everything came up fine:
    + `docker ps`

+ Logs are available here:
    + `docker logs -f metube_webos_service_1`
    + `docker logs -f metube_webos_wrapper_1`

+ Next step: setup a clean-up solution for $WEBOS-METUBE/downloads
    + Example clean-up script is available at $WEBOS-METUBE/metube-php-servicewrapper/youtube-cleanup.sh 
    + Crontab example: `9 9 * * * /usr/bin/find /home/metube-webos/downloads/*.mp4 -type f -amin +100 -exec rm -f {} \;`
