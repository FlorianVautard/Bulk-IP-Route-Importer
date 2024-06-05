# Bulk-IP-Route-Importer
This program allows you to load multiple ip route from an url which contains IP address.

## Usage
```
## Add routes from an url source
./bulk-ip-route-importer.sh --iptype <ipv4|ipv6> -i <interface> -g <gateway_ip> -u <url>

## Delete routes from an url source
./bulk-ip-route-importer.sh --del --iptype <ipv4|ipv6> -i <interface> -g <gateway_ip> -u <url>
```
