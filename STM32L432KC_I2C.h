// Lindsey Sands
// lsands@g.hmc.edu
// STM32L432KC_I2C.h
// Header for I2C functions

#ifndef STM32L4_I2C_H
#define STM32L4_I2C_H

#include <stdint.h>
#include <stm32l432xx.h>

#define I2C_CS 6    // PA6
#define I2C_SCL 9   // PA9
#define I2C_SDA 10  // PA10
#define I2C_SA0 8   // PA8

///////////////////////////////////////////////////////////////////////////////
// Function prototypes
///////////////////////////////////////////////////////////////////////////////

// Enables the I2C peripheral
void initI2C(void);

void setI2CCLK(void);

void i2cMasterMode(void);

void i2cSend(char send, uint32_t size);

char* i2cReceive(uint32_t size);

#endif