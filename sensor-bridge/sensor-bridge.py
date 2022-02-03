#!/usr/bin/env python3
from http.server import BaseHTTPRequestHandler, HTTPServer
import threading
import serial
import sys

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
                message = message + sensor_labels[k] + str(k) + " " + str(v)

            self.send_response(200)
            self.send_header('Content-type','text/html')
            self.end_headers()
            self.wfile.write(bytes(message, "utf8"))

    with HTTPServer(('', 8000), handler) as server:
        server.serve_forever()

def update():
    while True:
        global sensor_values
        line = serialport.readline().decode()
        if line != "":
            kv = line.split(" ")
            sensor_values[kv[0]] = kv[1]

t1 = threading.Thread(target=serve)
t2 = threading.Thread(target=update)

t1.start()
t2.start()

t1.join()
t2.join()
