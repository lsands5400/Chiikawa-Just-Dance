//=============I2C Connection ONLY===========================
// main.c
// Verifies the physical and protocol-level I2C connection between the STM32L432KC
// and the Adafruit LSM6DSOX by reading the WHO_AM_I register (0x0F -> 0x6C).

#include <stdio.h>
#include <stm32l432xx.h>

#include "STM32L432KC.h"
#include "STM32L432KC_GPIO.h"
#include "STM32L432KC_RCC.h"
#include "STM32L432KC_I2C.h"
#include "STM32L432KC_TIM.h"
#include "STM32L432KC_SPI.h"

#define AF4 4
#define HIGH 1
#define LOW 0

// LSM6DSOX identification constants 
#define LSM6DSOX_I2C_ADDR       0x6A  // 7-bit I2C address when SA0 pin is held LOW
#define LSM6DSOX_REG_WHO_AM_I   0x0F  // Read-only device identification register address
#define LSM6DSOX_WHO_AM_I_VAL   0x6C  // Fixed factory ID value stored in WHO_AM_I
#define SINGLE_BYTE_LEN         1     // Number of bytes for register pointer and ID read

int main(void) {
    // I2C test
    // 1. Enable Flash prefetch and 4 wait states (required before running at 48 MHz)
    configureFlash();

    // 2-3.  initialize I2C in master mode
    initI2C();
   // Configure I2C1 to address the LSM6DSOX at 7-bit slave address 0x6A
    i2cMasterMode(LSM6DSOX_I2C_ADDR);

    // 4. Execute a standard I2C register read sequence:
    //    Step A: Write the 1-byte register address (0x0F) to the IMU without sending STOP
    //            so the master holds the bus for a Repeated START
    uint8_t reg_addr = LSM6DSOX_REG_WHO_AM_I;
    uint8_t who_am_i = 0;

    bool tx_ok = i2cSend(&reg_addr, SINGLE_BYTE_LEN, false);
    bool rx_ok = false;

    //    Step B: If the IMU ACKed its address and register pointer, issue a Repeated START
    //            and read 1 byte back from register 0x0F
    if (tx_ok) {
        rx_ok = i2cReceive(&who_am_i, SINGLE_BYTE_LEN);
    }

    // 5. Print diagnostic result to the Segger Embedded Studio Debug Terminal
    if (tx_ok && rx_ok && (who_am_i == LSM6DSOX_WHO_AM_I_VAL)) {
        printf("SUCCESS: I2C connected! WHO_AM_I = 0x%X\n", who_am_i);
    } else {
        printf("FAILED: tx_ok=%d, rx_ok=%d, WHO_AM_I=0x%02X (expected 0x%X)\n",
               tx_ok, rx_ok, who_am_i, LSM6DSOX_WHO_AM_I_VAL);
    }

    while (true) {
        // Hold execution so can inspect results in the Debug Terminal
    }
}
