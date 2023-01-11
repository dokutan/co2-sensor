# co2-sensor

Connecting a CO₂ sensor to Prometheus + Grafana and Home Assistant.

## Hardware
- 1 Arduino Nano or Micro
- 1 SCD30 CO₂ sensor
- 1 BMP280 air pressure and temperature sensor

The sensors are connected to the Arduino using I²C.

## sensor-bridge
This python script is a small web server that reads the sensor data over the serial connection to make it available to Prometheus. Additionally the sensor values are published to a MQTT broker.

## sensorfs
This is a 9P server that makes the sensor values available as a filesystem. The values are received over MQTT. The code is based on [rssfs](https://git.sr.ht/~rbn/rssfs).
```
cd sensorfs
go mod download github.com/eclipse/paho.mqtt.golang
go mod download github.com/gorilla/websocket
go mod download go.rbn.im/neinp
go mod download golang.org/x/net
go build sensorfs.go
./sensorfs -h # shows usage
```

Mount the filesystem:
```
sudo modprobe 9p-tcp
sudo mount -t 9p <ip> mnt -o version=9p2000,port=5644,trans=tcp
# or
9pfuse <host>:5644 mnt
```

## Prometheus config

```
scrape_configs:
  - job_name: sensors
    scrape_interval: 100s
    static_configs:
      - targets: ['localhost:8044']
```

## Home Assistant config
Requires the MQTT integration to be configured.
```
sensor:
  - platform: mqtt
    name: "CO₂ concentration"
    state_topic: "co2-sensor"
    unit_of_measurement: "ppm"
    value_template: "{{ value_json.scd30_co2_ppm }}"
    unique_id: "co2_sensor_scd30_co2_ppm"
    icon: "mdi:molecule-co2"
  - platform: mqtt
    name: "Humidity"
    state_topic: "co2-sensor"
    unit_of_measurement: "%"
    value_template: "{{ value_json.scd30_humidity_percent }}"
    unique_id: "co2_sensor_scd30_humidity_percent"
    icon: "mdi:water-percent"
  - platform: mqtt
    name: "Temperature"
    state_topic: "co2-sensor"
    unit_of_measurement: "°C"
    value_template: "{{ value_json.scd30_temperature_celsius }}"
    unique_id: "co2_sensor_scd30_temperature_celsius"
    icon: "mdi:temperature-celsius"
  - platform: mqtt
    name: "Temperature"
    state_topic: "co2-sensor"
    unit_of_measurement: "°C"
    value_template: "{{ value_json.bmp280_temperature_celsius }}"
    unique_id: "co2_sensor_bmp280_temperature_celsius"
    icon: "mdi:temperature-celsius"
  - platform: mqtt
    name: "Air pressure"
    state_topic: "co2-sensor"
    unit_of_measurement: "mbar"
    value_template: "{{ value_json.bmp280_pressure_mbar }}"
    unique_id: "co2_sensor_bmp280_pressure_mbar"
    icon: "mdi:gauge"
```
