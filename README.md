# co2-sensor

Connecting a CO₂ sensor to Prometheus + Grafana.

## Hardware
- 1 Arduino Nano or Micro
- 1 SCD30 CO₂ sensor
- 1 BMP280 air pressure and temperature sensor

The sensors are connected to the Arduino using I²C.

## sensor-bridge
This python script is a small web server that reads the sensor data over the serial connection to make it available to Prometheus.

## Prometheus config

```
TODO!
```
