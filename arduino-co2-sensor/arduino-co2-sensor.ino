#include <Arduino.h>
#include <Wire.h>
#include <BMx280I2C.h>
#include <Adafruit_SCD30.h>

// measuring interval in seconds
#define INTERVAL_S 120
long remaining_ms = INTERVAL_S * 1000;

// sensor values
float bmp280_temperature_celsius = -1, bmp280_pressure_mbar = -1, scd30_temperature_celsius = -1, scd30_humidity_percent = -1, scd30_co2_ppm = -1;

Adafruit_SCD30  scd30;
BMx280I2C bmx280(0x76);

void setup() {
  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(LED_BUILTIN, HIGH);
  
  // serial
  Serial.begin(9600);
  while (!Serial) delay(10);

  // I2C
  //Wire.begin();

  // scd30
  if (!scd30.begin()) {
    Serial.println("SCD30 init failed");
    while (1);
  }
  scd30.setMeasurementInterval(INTERVAL_S);

  // BMP280
  if (!bmx280.begin())
  {
    Serial.println("BMP280 init failed.");
    while (1);
  }
  bmx280.resetToDefaults();
  bmx280.writeOversamplingPressure(BMx280MI::OSRS_P_x16);
  bmx280.writeOversamplingTemperature(BMx280MI::OSRS_T_x16);

  digitalWrite(LED_BUILTIN, HIGH);
}

void loop() {

  // measure ?
  if(remaining_ms <= 0){
    remaining_ms = INTERVAL_S*1000;

    // bmp280
    bmx280.measure();
    do
    {
      delay(100);
    } while (!bmx280.hasValue());
    bmp280_pressure_mbar = bmx280.getPressure64() / 10;
    bmp280_temperature_celsius = bmx280.getTemperature();
    
    // scd30
    if(scd30.dataReady()){
      scd30.read();
      
      scd30_co2_ppm = scd30.CO2;
      scd30_humidity_percent = scd30.relative_humidity;
      scd30_temperature_celsius = scd30.temperature; 
    }
    
  }

  Serial.print("bmp280_temperature_celsius ");
  Serial.print(bmp280_temperature_celsius);
  Serial.print("\n");
  Serial.print("bmp280_pressure_mbar ");
  Serial.print(bmp280_pressure_mbar);
  Serial.print("\n");
  Serial.print("scd30_temperature_celsius ");
  Serial.print(scd30_temperature_celsius);
  Serial.print("\n");
  Serial.print("scd30_humidity_percent ");
  Serial.print(scd30_humidity_percent);
  Serial.print("\n");
  Serial.print("scd30_co2_ppm ");
  Serial.print(scd30_co2_ppm);
  Serial.print("\n");
  
  delay(10000);
  remaining_ms-=10000;
}
