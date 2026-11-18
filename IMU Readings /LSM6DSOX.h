// NOTE: Need to be modified / drafted before hardware arrival. main.c still needs to be worked on to obtain and observe readings. 
// LSM6DSOX.h
// Header for Adafruit LSM6DSOX 6-DoF IMU driver.

#ifndef LSM6DSOX_H
#define LSM6DSOX_H

#include <stdbool.h>
#include <stdint.h>

#define LSM6DSOX_I2C_ADDR_DEFAULT   0x6AU
#define LSM6DSOX_WHO_AM_I_EXPECTED  0x6CU

// Holds calibrated physical acceleration (g) and angular velocity (deg/s)
typedef struct {
    float ax_g;
    float ay_g;
    float az_g;
    float gx_dps;
    float gy_dps;
    float gz_dps;
} LSM6DSOX_Motion_t;

// Holds fused 3D orientation angles in degrees
typedef struct {
    float roll_deg;
    float pitch_deg;
    float yaw_deg;
} LSM6DSOX_Orientation_t;

// Verifies WHO_AM_I (0x6C) and configures accelerometer & gyroscope for dance motion
bool lsm6dsoxInit(uint8_t dev_addr, uint8_t *who_am_i_out);

// Burst-reads 12 bytes (Gyro XYZ + Accel XYZ) and converts to deg/s and g
bool lsm6dsoxReadMotion(uint8_t dev_addr, LSM6DSOX_Motion_t *motion);

// Updates Roll, Pitch, and Yaw angles using a complementary filter
bool lsm6dsoxUpdateOrientation(const LSM6DSOX_Motion_t *motion,
                                float dt_sec,
                                LSM6DSOX_Orientation_t *orientation);

#endif 
