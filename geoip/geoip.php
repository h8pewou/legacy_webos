<?php
require 'geoip2.phar';
use GeoIp2\Database\Reader;

// This creates the Reader object, which should be reused across
// lookups.
$reader = new Reader('/path/to/GeoLite2-City.mmdb');
$record = $reader->city($_GET['ip']);
// Print the record as json.
header('Content-Type: application/json; charset=utf-8');
print json_encode($record, JSON_PRETTY_PRINT);
?>
