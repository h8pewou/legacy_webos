# GeoIP lookup service for webOS Archive visitor statistics reporting
## Initial Setup
Obtain PHAR from here: https://github.com/maxmind/GeoIP2-php/releases

Obtain the geolite2 city db from here: https://dev.maxmind.com/geoip/geolite2-free-geolocation-data?lang=en
## Create the PHP file
See above.

Ensure that the phar is in the same directory. The city database may require the full path.
## How to use?
Use the URL to the PHP file followed by ?ip=<ip address>

Example: http://webserver.tld/geoip.php?ip=1.1.1.1
