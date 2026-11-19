//NOTE: Need to modify below code / not sure if working or not. Was drafted prior to hardware arrival. 
// LSM6DSOX.c
// Source code for Adafruit LSM6DSOX 6-DoF IMU driver.

#include "LSM6DSOX.h"
#include "STM32L432KC_I2C.h"
#include <math.h>
#include <stddef.h>

// LSM6DSOX Register Addresses (Datasheet Section 9)
#define LSM6DSOX_REG_WHO_AM_I   0x0F
#define LSM6DSOX_REG_CTRL1_XL   0x10
#define LSM6DSOX_REG_CTRL2_G    0x11
#define LSM6DSOX_REG_CTRL3_C    0x12
#define LSM6DSOX_REG_OUTX_L_G   0x22

// Sensor Configuration: 416 Hz ODR, +/- 8g Accel, +/- 1000 dps Gyro, BDU + Auto-Inc
#define LSM6DSOX_CFG_CTRL1_XL   0x6C
#define LSM6DSOX_CFG_CTRL2_G    0x68
#define LSM6DSOX_CFG_CTRL3_C    0x44

// Sensitivity Scale Factors (DS12814 Table 2)
#define ACCEL_SENS_8G_PER_LSB   0.000244f  // 0.244 mg/LSB -> g
#define GYRO_SENS_1000DPS_LSB   0.035f     // 35.0 mdps/LSB -> deg/s

// Burst-Read Frame Constants
#define REG_ADDR_LEN            1
#define REG_WRITE_FRAME_LEN     2
#define MOTION_BURST_LEN        12
#define BYTE_SHIFT_HIGH         8

#define IDX_GX_L                0
#define IDX_GX_H                1
#define IDX_GY_L                2
#define IDX_GY_H                3
#define IDX_GZ_L                4
#define IDX_GZ_H                5
#define IDX_AX_L                6
#define IDX_AX_H                7
#define IDX_AY_L                8
#define IDX_AY_H                9
#define IDX_AZ_L                10
#define IDX_AZ_H                11

// Complementary Filter Constants
#define COMP_FILTER_GYRO_WEIGHT 0.98f
#define COMP_FILTER_ACC_WEIGHT  0.02f
#define RAD_TO_DEG              57.2957795f
#define MIN_ACCEL_NORM_SQ       1e-6f

static int16_t combineBytes(uint8_t low_byte, uint8_t high_byte) {
    return (int16_t)(((uint16_t)high_byte << BYTE_SHIFT_HIGH) | (uint16_t)low_byte);
}

static bool writeSensorReg(uint8_t dev_addr, uint8_t reg_addr, uint8_t value) {
    uint8_t frame[REG_WRITE_FRAME_LEN] = {reg_addr, value};
    i2cMasterMode(dev_addr);
    return i2cSend(frame, REG_WRITE_FRAME_LEN, true);
}

static bool readSensorBytes(uint8_t dev_addr, uint8_t start_reg, uint8_t *buf, uint32_t len) {
    i2cMasterMode(dev_addr);
    if (!i2cSend(&start_reg, REG_ADDR_LEN, false)) {
        return false;
    }
    return i2cReceive(buf, len);
}

bool lsm6dsoxInit(uint8_t dev_addr, uint8_t *who_am_i_out) {
    uint8_t who_am_i = 0U;

    if (!readSensorBytes(dev_addr, LSM6DSOX_REG_WHO_AM_I, &who_am_i, 1U)) {
        return false;
    }

    if (who_am_i_out != NULL) {
        *who_am_i_out = who_am_i;
    }

    if (who_am_i != LSM6DSOX_WHO_AM_I_EXPECTED) {
        return false;
    }

    // Enable Block Data Update (BDU) and automatic register address increment
    if (!writeSensorReg(dev_addr, LSM6DSOX_REG_CTRL3_C, LSM6DSOX_CFG_CTRL3_C)) {
        return false;
    }
    // Wake accelerometer at 416 Hz, +/- 8g range
    if (!writeSensorReg(dev_addr, LSM6DSOX_REG_CTRL1_XL, LSM6DSOX_CFG_CTRL1_XL)) {
        return false;
    }
    // Wake gyroscope at 416 Hz, +/- 1000 dps range
    if (!writeSensorReg(dev_addr, LSM6DSOX_REG_CTRL2_G, LSM6DSOX_CFG_CTRL2_G)) {
        return false;
    }

    return true;
}

bool lsm6dsoxReadMotion(uint8_t dev_addr, LSM6DSOX_Motion_t *motion) {
    if (motion == NULL) {
        return false;
    }

    uint8_t raw[MOTION_BURST_LEN] = {0U};
    if (!readSensorBytes(dev_addr, LSM6DSOX_REG_OUTX_L_G, raw, MOTION_BURST_LEN)) {
        return false;
    }

    int16_t gx_raw = combineBytes(raw[IDX_GX_L], raw[IDX_GX_H]);
    int16_t gy_raw = combineBytes(raw[IDX_GY_L], raw[IDX_GY_H]);
    int16_t gz_raw = combineBytes(raw[IDX_GZ_L], raw[IDX_GZ_H]);

    int16_t ax_raw = combineBytes(raw[IDX_AX_L], raw[IDX_AX_H]);
    int16_t ay_raw = combineBytes(raw[IDX_AY_L], raw[IDX_AY_H]);
    int16_t az_raw = combineBytes(raw[IDX_AZ_L], raw[IDX_AZ_H]);

    motion->gx_dps = (float)gx_raw * GYRO_SENS_1000DPS_LSB;
    motion->gy_dps = (float)gy_raw * GYRO_SENS_1000DPS_LSB;
    motion->gz_dps = (float)gz_raw * GYRO_SENS_1000DPS_LSB;

    motion->ax_g = (float)ax_raw * ACCEL_SENS_8G_PER_LSB;
    motion->ay_g = (float)ay_raw * ACCEL_SENS_8G_PER_LSB;
    motion->az_g = (float)az_raw * ACCEL_SENS_8G_PER_LSB;

    return true;
}

bool lsm6dsoxUpdateOrientation(const LSM6DSOX_Motion_t *motion,
                                float dt_sec,
                                LSM6DSOX_Orientation_t *orientation) {
    if ((motion == NULL) || (orientation == NULL) || (dt_sec <= 0.0f)) {
        return false;
    }

    float yz_norm_sq = (motion->ay_g * motion->ay_g) + (motion->az_g * motion->az_g);
    if (yz_norm_sq < MIN_ACCEL_NORM_SQ) {
        orientation->roll_deg  += motion->gx_dps * dt_sec;
        orientation->pitch_deg += motion->gy_dps * dt_sec;
        orientation->yaw_deg   += motion->gz_dps * dt_sec;
        return true;
    }

    float accel_roll_deg  = atan2f(motion->ay_g, motion->az_g) * RAD_TO_DEG;
    float accel_pitch_deg = atan2f(-motion->ax_g, sqrtf(yz_norm_sq)) * RAD_TO_DEG;

    orientation->roll_deg  = (COMP_FILTER_GYRO_WEIGHT * (orientation->roll_deg + motion->gx_dps * dt_sec)) +
                             (COMP_FILTER_ACC_WEIGHT * accel_roll_deg);
    orientation->pitch_deg = (COMP_FILTER_GYRO_WEIGHT * (orientation->pitch_deg + motion->gy_dps * dt_sec)) +
                             (COMP_FILTER_ACC_WEIGHT * accel_pitch_deg);
    orientation->yaw_deg  += motion->gz_dps * dt_sec;

    return true;
}





