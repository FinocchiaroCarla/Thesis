#include <Arduino.h>
#include <SimpleFOC.h>
#include "AS5600.h"
#include <SimpleFOCDrivers.h>
#include <encoders/smoothing/SmoothingSensor.h>
#include <encoders/calibrated/CalibratedSensor.h>

// creazione del motore
BLDCMotor motor = BLDCMotor(11, 0.65, 370);

// Creazione di un'istanza del sensore AS5600
MagneticSensorI2C sensor = MagneticSensorI2C(AS5600_I2C);
// SmoothingSensor smooth(sensor, motor);
AS5600 as5600(&Wire);
//CalibratedSensor sensor_calibrated = CalibratedSensor(sensor);

// creazione del driver
BLDCDriver6PWM driver = BLDCDriver6PWM(PA8, PC13, PA9, PA12, PA10, PB15);

LowsideCurrentSense currentSense = LowsideCurrentSense(0.003, -64.0 / 7.0, A_OP1_OUT, A_OP2_OUT, A_OP3_OUT);

float t; // torque target 

Commander command = Commander(Serial);
void onMotor(char *cmd) { command.motor(&motor, cmd); }
void doT(char *cmd) { command.scalar(&t, cmd); }

void setup()
{
    Serial2.begin(115200);
    // Serial2.println("Inserisci batteria...");
    delay(5000);
    // SimpleFOCDebug::enable();
    motor.monitor_variables = _MON_VOLT_Q | _MON_VEL; // default _MON_TARGET | _MON_VOLT_Q | _MON_VEL | _MON_ANGLE | _MON_CURR_Q
    //motor.monitor_downsample = 5000;
    motor.monitor_separator = ' ';
    motor.monitor_start_char = '&';
    motor.monitor_end_char = '&';

    // Inizializzazione I2C e configurazione sensore per aumentare la velocità
    Wire.begin();
    as5600.begin();
    as5600.setConfigure(0x1f00); // fast filter
    sensor.init();
    Wire.setClock(1000000);

    motor.linkSensor(&sensor);

    // Inizializzazione del driver
    driver.voltage_power_supply = 12; // alimentazione
    if (!driver.init())
    {
        Serial2.println("Driver init failed!");
        return;
    }
    motor.linkDriver(&driver);

    // current sense probabilmente non funziona
    currentSense.linkDriver(&driver);
    currentSense.init();

    // aligning voltage
    motor.voltage_sensor_align = 1;

    // modulazione e tipo di controllo
    motor.foc_modulation = FOCModulationType::SpaceVectorPWM;
    motor.controller = MotionControlType::torque;

    // pid per il controllo in velocità
    motor.PID_velocity.P = 0.4;
    motor.PID_velocity.I = 4;
    motor.PID_velocity.D = 0.001;
    // default value is 300 volts per sec  ~ 0.3V per millisecond
    motor.PID_velocity.output_ramp = 1000;

    // velocity low pass filtering
    // default 5ms - try different values to see what is the best.
    // the lower the less filtered
    motor.LPF_velocity.Tf = 0.02;

    motor.current_limit = 10; // Amps

    if (!motor.init())
    {
        Serial2.println("Motor init failed!");
        return;
    }

    // set voltage to run calibration
    //sensor_calibrated.voltage_calibration = 1;
    // Running calibration
    //sensor_calibrated.calibrate(motor);

   // motor.linkSensor(&sensor_calibrated);

    motor.initFOC();

    // motor.linkCurrentSense(&currentSense);

    // comandi
    command.add('M', onMotor, "my motor motion");
    command.add('T', doT, "T");

    Serial.println(F("Motor ready."));
    delay(1000);
}

void loop()
{
    motor.loopFOC();
    motor.move(t);
    command.run();
}