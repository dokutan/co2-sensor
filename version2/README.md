# co2-sensor v2

## Hardware
ESP32 devkit + sensors:
- SCD30 (CO₂, temperature, humidity)
- BMP280 (pressure, temperature)
- BH1750 (illuminance)
- DHT11 (temperature)

See schematic.pdf for details. OpenSCAD files for a 3D-printed case are in the case directory.

## Upload firmware
``esphome upload co2-sensor.yaml`` or ``esphome run co2-sensor.yaml``

## Home Assistant config
Use the ESPHome integration.

## mdns-to-dns
Contains a script to keep an AAAA record updated with the global IPv6 address of the ESP32 and systemdd service files to run the script every 5 minutes.
```sh
cd mdns-to-dns
# edit mdns-to-dns.service and mdns-to-dns.sh
cp mdns-to-dns.sh ~/.local/bin
cp mdns-to-dns.timer mdns-to-dns.service ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now mdns-to-dns.timer
systemctl --user enable --now mdns-to-dns.service
```

## Troubleshooting
If the Wifi connection fails with ``reason='Auth Expired'``, restart the Wifi access point/router.
