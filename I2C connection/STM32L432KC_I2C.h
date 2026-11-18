// STM32L432KC_I2C.h
// Header for I2C functions

#ifndef STM32L4_I2C_H
#define STM32L4_I2C_H

#include <stdbool.h>  // Provides 'bool', 'true', and 'false' return types 
#include <stddef.h>  // Provides fixed-width integer types (uint8_t, uint32_t) 
#include <stdint.h>
#include <stm32l432xx.h>
#include "STM32L432KC_GPIO.h" 

// I2C1 Pin Definitions 
#define I2C_CS 6    // PA6, must be driven HIGH (3.3V) to select I2C mode on LSM6DSOX  
#define I2C_SCL 9   // PA9
#define I2C_SDA 10  // PA10
#define I2C_SA0 8   // PA8; Slave Address bit 0 pin: driven LOW (0V) to set 7-bit address to 0x6A 

///////////////////////////////////////////////////////////////////////////////
// Function prototypes
///////////////////////////////////////////////////////////////////////////////

// Enables the I2C peripheral
// Configures GPIO pins, sets f_I2CCLK = 48 MHz, and initializes I2C1 in 400 kHz Fast Mode 
void initI2C(void);

// Sets fI2CCLK to 48 MHz 
void setI2CCLK(void);

// Configures I2C master addressing mode for a 7-bit slave address 
void i2cMasterMode(uint8_t slave_addr);

// Transmits 'size' bytes from 'send' buffer; 'send_stop = false' holds bus for Repeated START 
bool i2cSend(const uint8_t *send, uint32_t size, bool send_stop);

// Receives 'size' bytes from the slave into 'dataIn' and automatically sends STOP 
bool i2cReceive(uint8_t *dataIn, uint32_t size);

#endif


