🦿 Robotic Knee Exoskeleton – Design, Control and Validation

This repository contains the code developed for the Master's thesis:
“Design and development of a robotic knee exoskeleton for walking assistance”


📌 Project Overview
This project focuses on the design, development, control, and experimental validation of a wearable robotic knee exoskeleton.
The system is designed to:
- assist human motion during lower-limb tasks  
- remain compact and lightweight  
- provide assistive torque based on user interaction**  
The validation is performed by comparing onboard measurements with an OptiTrack motion capture system, used as ground truth.


⚙️ System Description
The exoskeleton is a single-DOF wearable device with:
- polycentric knee joint (to approximate human biomechanics)
- integrated actuation system
- onboard sensing
- torque-based assistive control

 🟦 Mechanical System
- Polycentric joint mechanism (four-bar inspired)
- Integrated actuation module
- Capstan-based transmission + gear stage
- Lightweight hybrid structure (3D printed + aluminum)
  
⚡ Actuation
- Brushless motor
- Transmission:
  - Capstan drive (high ratio, low backlash)
  - Additional gear reduction

📡 Sensing System
- AS5600 magnetic encoder → joint angle
- MPU6050 IMU → limb motion
- Hall sensor + springs → interaction torque estimation

🧠 Control Strategy
- Torque-based assistive control  
- No predefined trajectories  
- Assistance adapts to user motion  


💻 Repository Contents

🔹 Embedded System
`Motor_command.ino`
- Runs on ESP32
- Reads onboard sensors:
  - AS5600 (angle)
  - IMU
  - Hall sensor (torque estimation)
- Print on serial monitor the sensors data
- Computes assistive torque
- Sends torque command via serial to the motor driver

`SimpleFOC_EXO/src/main.cpp`
- Runs on motor driver (B-G431B-ESC1)
- Receives serial commands from ESP
- Executes motor control (FOC)
- Applies requested torque

👉 Control flow:
Sensors → ESP (.ino) → torque computation → Serial → Driver (.cpp) → Motor


🔹 Data Acquisition
- ESP logs joint angle and sensor data (`.txt`)
- OptiTrack provides motion capture data (`.csv`)
- Used for validation and comparison
  
🔹 Data Analysis (MATLAB)
Scripts for:
- ESP data processing
- OptiTrack processing (marker-based angle estimation)
- Signal synchronization
- Comparative visualization


👩‍🎓 Author
Carla Finocchiaro 
Master’s Thesis – Wearable Robotics / Biomechatronics  
