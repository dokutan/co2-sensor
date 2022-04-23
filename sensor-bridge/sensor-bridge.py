#!/usr/bin/env python3
from http.server import BaseHTTPRequestHandler, HTTPServer
import paho.mqtt.publish as publish
import threading
import serial
import sys
import time
import socket

mqtt_host = "localhost"
mqtt_topic = "co2-sensor"
mqtt_port = 1883
mqtt_sleep = 60
http_port = 8044
sensor_labels = dict({
    "scd30_co2_ppm": "# HELP scd30_co2_ppm The CO2 concentration in ppm.\n",
    "scd30_humidity_percent": "# HELP scd30_humidity_percent The realtive humidity in %.\n",
    "scd30_temperature_celsius": "# HELP scd30_temperature_celsius The temperature of the SCD30 in °C.\n",
    "bmp280_pressure_mbar": "# HELP bmp280_pressure_mbar The air pressure in mbar.\n",
    "bmp280_temperature_celsius": "# HELP bmp280_temperature_celsius The temperature of the BMP280 in °C\n"
})
sensor_values = dict()
serialport = serial.Serial(sys.argv[1], 9600, timeout=1)

def serve():
    class handler(BaseHTTPRequestHandler):
        def do_GET(self):
            message = ""
            for k, v in sensor_values.items():
                message = message + sensor_labels[k] + str(k) + " " + str(v) + "\n"

            self.send_response(200)
            self.send_header('Content-type','text/plain')
            self.end_headers()
            self.wfile.write(bytes(message, "utf8"))

    class HTTPServerV6(HTTPServer):
        address_family = socket.AF_INET6

    with HTTPServerV6(('::', http_port), handler) as server:
        server.serve_forever()

def update():
    while True:
        global sensor_values
        line = serialport.readline().decode()
        if line != "":
            kv = line.replace("\n", "").replace("\r", "").split(" ")
            sensor_values[kv[0]] = kv[1]

def publish_mqtt():
    while True:
        time.sleep(mqtt_sleep)
        message = "{ "
        for k, v in sensor_values.items():
            message += "\"" + str(k) + "\": " + str(v) + ", "
        message = message[0:-2]
        message += " }"
        publish.single(mqtt_topic, message, hostname=mqtt_host, port=mqtt_port)

t1 = threading.Thread(target=serve)
t2 = threading.Thread(target=update)
t3 = threading.Thread(target=publish_mqtt)

t1.start()
t2.start()
t3.start()

t1.join()
t2.join()
t3.join()
