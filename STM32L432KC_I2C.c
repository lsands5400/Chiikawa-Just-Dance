// Lindsey Sands
// lsands@g.hmc.edu
// STM32L432KC_I2C.c
// Source code for I2C functions

#include "STM32L432KC.h"
#include "STM32L432KC_GPIO.h"
#include "STM32L432KC_RCC.h"
#include "STM32L432KC_I2C.h"

volatile uint32_t numBytesTX = 0; 
volatile char* dataIn = 0; 

void initI2C(void){
  // Initial settings

  // Enable peripheral's clock
  RCC->APB1ENR1 |= RCC_APB1SMENR1_I2C1SMEN;

  // Clear PE bit in I2C_CR1
  I2C1->CR1 &= ~I2C_CR1_PE;

  // Configure ANFOFF and DNF[3:0] in I2C_CR1
  // Enable analog noise filter
  I2C1->CR1 |= (1 << I2C_CR1_ANFOFF_Pos);
  // Disable digital noise filter
  I2C1->CR1 &= ~(0b1111 << I2C_CR1_DNF_Pos);

  // Configure PRESC[3:0], SDADEL[3:0], SCLDEL[3:0],
    // SCLH[7:0], SCLL[7:0] in I2C_TIMINGR
  // These values are based on Table 183 in the MCU 
  // reference manual. It has example timing seeting for 
  // fI2CCLK = 48MHz with fast-mode on
  // TODO: Fix this values to fit in the required ranges
  // in 6 of the LSM6DSOX datasheet 
  I2C1->TIMINGR |= (5 << I2C_TIMINGR_PRESC_Pos);
  I2C1->TIMINGR |= (0x9 << I2C_TIMINGR_SCLL_Pos);
  I2C1->TIMINGR |= (0x3 << I2C_TIMINGR_SCLH_Pos);
  I2C1->TIMINGR |= (0x3 << I2C_TIMINGR_SDADEL_Pos);
  I2C1->TIMINGR |= (0x3 << I2C_TIMINGR_SCLDEL_Pos);
  
  // Configure NOSTRETCH in I2C_CR1
  // Clear clock stretching because of master mode
  I2C1->CR1 &= ~(1 << I2C_CR1_NOSTRETCH_Pos); 

  // Set PE bit in I2C_CR1
  // Enables I2C (DO THIS LAST)
  I2C1->CR1 |= I2C_CR1_PE; 
}

void setI2CCLK(void){
  // Set fI2CCLK to 48MHz
  // TODO: implement this
}

void i2cMasterMode(void){
  // Master initialization
  // Addrssing mode (7-bit or 10-bit): ADD10
  // The IMU has a 7-bit address
  I2C1->CR2 &= ~I2C_CR2_ADD10;

  // Slave address to be sent
  I2C1->CR2 &= ~(0b1111111 << I2C_CR2_SADD_Pos);
  // "The slave address (SAD) associated to the LSM6DSOX
  // is 110101xb...If the SDO/SA0 pin is connected to ground
  // the LSb value is 0 (address 1101010b)" 
  // (LSM6DSOX datasheet, 18)
  I2C1->CR2 |= (0b1101010 << I2C_CR2_SADD_Pos);

  // Initial settings

  // Enable interrupts and/or DMA in I2C_CR1
  // Enable TXIS flag for transmissions
  I2C1->CR1 |= I2C_CR1_TXIE;
  // Enable RXNE flag for receiving
  I2C1->CR1 |= I2C_CR1_RXIE;

}

// NOTE: This is written to only handle size <= 255
// Master transmission protocol based on Figure 369 in 
// MCU reference manual
void i2cSend(char send, uint32_t size) {
  // Transfer direction
  // 0: write
  I2C1->CR2 &= ~I2C_CR2_RD_WRN;

  // Number of bytes to be transferred
  I2C1->CR2 |= (size << I2C_CR2_NBYTES_Pos);

  // Set START bit
  I2C1->CR2 |= I2C_CR2_START;

  while (1) {
    if (((I2C1->ISR >> I2C_ISR_NACKF_Pos) & 1) == 1) {
      break;
    }

    if (((I2C1->ISR >> I2C_ISR_TXIS_Pos) & 1) == 1) {
      I2C1->TXDR = send;
      numBytesTX += 1;
      if (numBytesTX == size) {
        if (((I2C1->ISR >> I2C_ISR_TC_Pos) & 1) == 1) {
            I2C1->CR2 |= I2C_CR2_START;
            // Set I2C_CR2.START with slave address NBYTES
            // TODO: Finish this/ is this it?
        }
        else {
          break;
        }
      }
    }
  }
}

// NOTE: This is written to only handle size <= 255
// Master receiver protocol based on Figure 372 in 
// MCU reference manual
char* i2cReceive(uint32_t size) {
  // Transfer direction
  // 1: read
  I2C1->CR2 |= I2C_CR2_RD_WRN;

  // Number of bytes to be transferred
  I2C1->CR2 |= (size << I2C_CR2_NBYTES_Pos);

  // Set START bit
  I2C1->CR2 |= I2C_CR2_START;

  while (1) {
    if (((I2C1->ISR >> I2C_ISR_RXNE_Pos) & 1) == 1) {
      // Store each byte in a char array
      dataIn[numBytesTX] = (I2C1->RXDR << I2C_RXDR_RXDATA_Pos); 
      numBytesTX += 1;
      if (numBytesTX == size) {
        if (((I2C1->ISR >> I2C_ISR_TC_Pos) & 1) == 1) {
            I2C1->CR2 |= I2C_CR2_START;
            // Set I2C_CR2.START with slave address NBYTES
            // TODO: Finish this/ is this it?
        }
        else {
          break;
        }
      }
    }
  }
  return dataIn;
}