#include <Wire.h>
#include <Arduino.h>
#include <Adafruit_Sensor.h>
#include <Adafruit_MPU6050.h>

#define RXD2 16
#define TXD2 17

// I2C pins
const int SDA_PIN = 21;
const int SCL_PIN = 22;

// analog pin
const int ANAL = 34;

// I2C addresses
const uint8_t AS5600_ADDR = 0x36;
const uint8_t MPU_ADDR_1 = 0x69; //imu sopra
const uint8_t MPU_ADDR_2 = 0x68; //imu sotto

Adafruit_MPU6050 mpu1;
Adafruit_MPU6050 mpu2;

float remapped;
float deg;
float accX1;
float accY1;
float accZ1;
float accX2;
float accY2;
float accZ2;

float x; 
float k = 0.4;
float M;
float braccio = 14.732;


// ----- AS5600 -----
bool as5600ReadRegisters(uint8_t reg, uint8_t *buf, uint8_t len) {
  Wire.beginTransmission(AS5600_ADDR);
  Wire.write(reg);
  if (Wire.endTransmission(false) != 0) return false;

  uint8_t got = Wire.requestFrom((int)AS5600_ADDR, (int)len);
  if (got != len) return false;

  for (uint8_t i = 0; i < len; ++i)
    buf[i] = Wire.read();

  return true;
}

bool as5600ReadRawAngle(uint16_t &rawAngle) {
  uint8_t b[2];
  if (!as5600ReadRegisters(0x0E, b, 2)) return false;
  // raw = (MSB << 8) | LSB, lower 12 bit used
  rawAngle = ((uint16_t)b[0] << 8) | b[1];
  rawAngle &= 0x0FFF; // 12 bit

  return true;
}

float as5600RawToDegrees(uint16_t raw) {
  // 4096 steps -> 360°
  return ((float)raw * 360.0f) / 4096.0f;
}

float remapAngoloAS5600(float angolo) {
  const float inMin = 338;
  const float inMax = 402; // 42 + 360
  const float outMin = 0.0;
  const float outMax = 64.0;

  if (angolo < 331) {
    angolo += 360.0;
  }

  //if (angolo < inMin) angolo = inMin;
  //if (angolo > inMax) angolo = inMax;

  return (angolo - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;

}

float hallToDistance(float Hall)
{
  // coefficienti della curva di trasduzione
  float a = -8.5913;
  float b = -1.2008;
  float c = 0.0010;
  float d = 6.0097;
  x = a * exp(b * Hall) + c * exp(d * Hall);
  return x;
}

void setup() {
  Serial.begin(115200);
  Serial2.begin(115200, SERIAL_8N1, RXD2, TXD2);

  Wire.begin(SDA_PIN, SCL_PIN);
  Wire.setClock(100000);

  if(mpu2.begin(0x68)){
    Serial.println("MPU6050 2 read OK");
  }else{
    Serial.println("MPU6050 2 read failed");
  }

  if(mpu1.begin(0x69)){
    Serial.println("MPU6050 1 read OK");
  }else{
    Serial.println("MPU6050 1 read failed");
  }

}

void loop() {

//TIME
  unsigned long t = millis(); 
  uint16_t raw;

//ENCODER
  if (as5600ReadRawAngle(raw)) {
    deg = as5600RawToDegrees(raw);
    remapped = remapAngoloAS5600(deg);

  } else {
    Serial.println("AS5600 read failed (controlla wiring/indirizzo).");
  }

//IMU 1 (femoral)
    sensors_event_t a1, g1, temp1;
    mpu1.getEvent(&a1, &g1, &temp1);

    accX1 = a1.acceleration.x;
    accY1 = a1.acceleration.y;
    accZ1 = a1.acceleration.z;

    // a1.acceleration in m/s^2, g1.gyro in rad/s, temp1.temperature in degC
    //float gyroX1 = g1.gyro.x * 180.0f / PI;
    //float gyroY1 = g1.gyro.y * 180.0f / PI;
    //float gyroZ1 = g1.gyro.z * 180.0f / PI;

    //float tem1 = temp1.temperature;


//IMU 2 (tibial)
    sensors_event_t a2, g2, temp2;
    mpu2.getEvent(&a2, &g2, &temp2);

    accX2 = -a2.acceleration.x;
    accY2 = -a2.acceleration.y;
    accZ2 = a2.acceleration.z;

    // a2.acceleration in m/s^2, g2.gyro in rad/s, temp2.temperature in degC
    //float gyroX2 = g2.gyro.x * 180.0f / PI;
    //float gyroY2 = g2.gyro.y * 180.0f / PI;
    //float gyroZ2 = g2.gyro.z * 180.0f / PI;

    //float tem2 = temp.temperature;


// torque computation
  float Hall = analogRead(ANAL)*(3.3/4095.0);
  x = hallToDistance(Hall)-0.25;
  M = 2*k*x*braccio;
  float tau = M/3;
  
// Data log
  Serial.printf(
    "%lu, %f, %.2f, %.2f, %.2f, %.2f, %.2f, %.2f , %.2f, %.2f, %.2f \n",
     t, remapped, accX1, accY1, accZ1, accX2, accY2, accZ2, Hall, x, tau
  );
  
// Motor command
  Serial2.printf("T %.2f\n", tau);

}
