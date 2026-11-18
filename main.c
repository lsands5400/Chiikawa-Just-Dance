// Lindsey Sands
// lsands@g.hmc.edu
// main.c

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

int main(void) {
  
  // I2C test 

  // GPIO set up
  gpioEnable(GPIO_PORT_A);
  pinMode(I2C_CS, GPIO_OUTPUT); 
  pinMode(I2C_SCL, GPIO_ALT); 
  pinMode(I2C_SDA, GPIO_ALT); 
  pinMode(I2C_SA0, GPIO_ALT);
  setAltFunc(I2C_SCL, AF4);
  setAltFunc(I2C_SDA, AF4);
  digitalWrite(I2C_CS, HIGH);
  digitalWrite(I2C_SA0, LOW);

  // initialize I2C in master mode
  initI2C();
  i2cMasterMode(); 

  // read data from IMU
  i2cReceive(uint32_t size);
}

/*************************** End of file ****************************/
