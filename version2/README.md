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

## Troubleshooting
If the Wifi connection fails with ``reason='Auth Expired'``, restart the Wifi access point/router.
