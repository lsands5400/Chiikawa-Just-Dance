// STM32L432KC_I2C.c
// Source code for I2C functions

#include "STM32L432KC.h"
#include "STM32L432KC_GPIO.h"
#include "STM32L432KC_RCC.h"
#include "STM32L432KC_I2C.h"

volatile uint32_t numBytesTX = 0; 
volatile char* dataIn = 0; 

// Clock & GPIO configuration constants
#define MSI_RANGE_48MHZ       0xB      // MSIRANGE = 0b1011 selects 48 MHz MSI clock
#define I2C1_CLK_SRC_SYSCLK   0x1      // I2C1SEL  = 0b01 routes SYSCLK to I2C1
#define GPIO_AF4_I2C1         4        // AF4 maps PA9/PA10 to I2C1_SCL/I2C1_SDA
#define I2C_TIMEOUT           100000  // Loop guard to prevent infinite hangs on bus errors
#define I2C_MAX_TRANSFER_SIZE 255      // Hardware NBYTES[7:0] register limit is 255 bytes

// I2C_TIMINGR parameters for f_I2CCLK = 48 MHz, Fast Mode (400 kHz):
// Derived from RM0394 Table 183 and adjusted to meet LSM6DSOX Datasheet Table 6:
//   t_PRESC  = (PRESC + 1) / 48 MHz = (5 + 1) / 48 MHz = 125 ns
//   t_SCLL   = (SCLL + 1)  * 125 ns = (10 + 1) * 125 ns = 1375 ns (>= 1300 ns min in Table 6)
//   t_SCLH   = (SCLH + 1)  * 125 ns = (4 + 1)  * 125 ns = 625 ns  (>= 600 ns min in Table 6)
//   t_SDADEL = SDADEL      * 125 ns = 3        * 125 ns = 375 ns  (within 0..900 ns in Table 6)
//   t_SCLDEL = (SCLDEL + 1)* 125 ns = (3 + 1)  * 125 ns = 500 ns  (>= 100 ns min in Table 6)
#define I2C_PRESC_48MHZ       5
#define I2C_SCLL_48MHZ        0xA
#define I2C_SCLH_48MHZ        0x4
#define I2C_SDADEL_48MHZ      0x3
#define I2C_SCLDEL_48MHZ      0x3

void setI2CCLK(void) {
  // 1. Turn on the internal MSI oscillator and wait until it stabilizes
  RCC->CR |= RCC_CR_MSION;
  while (!(RCC->CR & RCC_CR_MSIRDY));

  // 2. Set MSI frequency range to 48 MHz (MSIRANGE = 0b1011) and set MSIRGSEL so RCC_CR is used
  RCC->CR &= ~RCC_CR_MSIRANGE_Msk;
  RCC->CR |= (MSI_RANGE_48MHZ << RCC_CR_MSIRANGE_Pos) | RCC_CR_MSIRGSEL;
  while (!(RCC->CR & RCC_CR_MSIRDY));

  // 3. Switch the CPU system clock (SYSCLK) to use the 48 MHz MSI clock
  RCC->CFGR &= ~RCC_CFGR_SW_Msk;
  RCC->CFGR |= RCC_CFGR_SW_MSI;
  while ((RCC->CFGR & RCC_CFGR_SWS_Msk) != RCC_CFGR_SWS_MSI);
  SystemCoreClockUpdate(); // Update the CMSIS global SystemCoreClock variable to 48,000,000

  // 4. Select SYSCLK (0b01) as the I2C1 kernel clock source -> f_I2CCLK = 48 MHz
  RCC->CCIPR &= ~RCC_CCIPR_I2C1SEL_Msk;
  RCC->CCIPR |= (I2C1_CLK_SRC_SYSCLK << RCC_CCIPR_I2C1SEL_Pos);
}

void initI2C(void) {
  // Initial settings
  // 1. Enable peripheral clocks for GPIO Port A and I2C1
  gpioEnable(GPIO_PORT_A);
  RCC->APB1ENR1 |= RCC_APB1ENR1_I2C1EN;

  // 2. Configure PA9 (SCL) and PA10 (SDA) as Alternate Function pins
  pinMode(I2C_SCL, GPIO_ALT);
  pinMode(I2C_SDA, GPIO_ALT);

  // I2C requires Open-Drain outputs so devices only pull lines LOW (pull-ups pull them HIGH)
  GPIOA->OTYPER  |= (GPIO_OTYPER_OT9 | GPIO_OTYPER_OT10);
  // Set Very High output slew rate for crisp 400 kHz clock/data edges
  GPIOA->OSPEEDR |= (GPIO_OSPEEDR_OSPEED9 | GPIO_OSPEEDR_OSPEED10);
  // Select Alternate Function 4 (I2C1) in AFRH 
  GPIOA->AFR[1] &= ~(GPIO_AFRH_AFSEL9_Msk | GPIO_AFRH_AFSEL10_Msk);
  GPIOA->AFR[1] |=  _VAL2FLD(GPIO_AFRH_AFSEL9, GPIO_AF4_I2C1) |
                    _VAL2FLD(GPIO_AFRH_AFSEL10, GPIO_AF4_I2C1);

  // 3. Set LSM6DSOX mode/address pins: CS = HIGH (I2C mode), SA0 = LOW (address = 0x6A)
  pinMode(I2C_CS, GPIO_OUTPUT);
  pinMode(I2C_SA0, GPIO_OUTPUT);
  digitalWrite(I2C_CS, PIO_HIGH);
  digitalWrite(I2C_SA0, PIO_LOW);

  // 4. Configure f_I2CCLK = 48 MHz before enabling I2C1
  setI2CCLK();

  // 5. Clear PE bit in I2C_CR1
  I2C1->CR1 &= ~I2C_CR1_PE;

  // Enable analog noise filter (ANFOFF = 0) and disable digital filter (DNF = 0)
  I2C1->CR1 &= ~(I2C_CR1_ANFOFF | I2C_CR1_DNF);

  // Load 400 kHz Fast Mode timing values into I2C_TIMINGR
  // Configure PRESC[3:0], SDADEL[3:0], SCLDEL[3:0], SCLH[7:0], SCLL[7:0] in I2C_TIMINGR
  // These values are based on Table 183 in the MCU reference manual. It has example timing setting for 
  // fI2CCLK = 48MHz with fast-mode on. Set these values to fit in the required ranges in Table 6 of the LSM6DSOX datasheet 
  I2C1->TIMINGR = (I2C_PRESC_48MHZ  << I2C_TIMINGR_PRESC_Pos)  |
                  (I2C_SCLL_48MHZ   << I2C_TIMINGR_SCLL_Pos)   |
                  (I2C_SCLH_48MHZ   << I2C_TIMINGR_SCLH_Pos)   |
                  (I2C_SDADEL_48MHZ << I2C_TIMINGR_SDADEL_Pos) |
                  (I2C_SCLDEL_48MHZ << I2C_TIMINGR_SCLDEL_Pos);

  // Clear NOSTRETCH (must be 0 in master mode)
  // Clear clock stretching because of master mode
  I2C1->CR1 &= ~I2C_CR1_NOSTRETCH;

  // Finally set PE = 1 to activate the I2C1 peripheral
  // Set PE bit in I2C_CR1
 // Enables I2C (DO THIS LAST)
  I2C1->CR1 |= I2C_CR1_PE;
}

void i2cMasterMode(uint8_t slave_addr) {
  // Master initialization
  // Addressing mode (7-bit or 10-bit): ADD10
  // NOTE: The IMU has a 7-bit address
  I2C1->CR2 &= ~I2C_CR2_ADD10;

  // Slave address to be sent
  I2C1->CR2 &= ~(0b1111111 << I2C_CR2_SADD_Pos);
  // "The slave address (SAD) associated to the LSM6DSOX
  // is 110101xb...If the SDO/SA0 pin is connected to ground
  // the LSb value is 0 (address 1101010b)" 
  // (LSM6DSOX datasheet, 18)
  // Add note: In 7-bit mode, the hardware places the 7-bit address in SADD[7:1] (bit 0 is ignored),
  // so we shift 'slave_addr' left by 1 bit before writing to CR2
  I2C1->CR2 &= ~I2C_CR2_SADD_Msk;
  I2C1->CR2 |= (((uint32_t)slave_addr << 1) & I2C_CR2_SADD_Msk);
}

// Master transmitter protocol 
bool i2cSend(const uint8_t *send, uint32_t size, bool send_stop) {
  if ((send == 0) || (size == 0) || (size > I2C_MAX_TRANSFER_SIZE)) {
    return false;
  }

  uint32_t numBytesTX = 0;
  uint32_t timeout = I2C_TIMEOUT;

  // Set transfer direction to Write (RD_WRN = 0)
  I2C1->CR2 &= ~I2C_CR2_RD_WRN;

  // AUTOEND = 1 sends STOP automatically after 'size' bytes;
  // AUTOEND = 0 holds SCL low after 'size' bytes so a Repeated START can follow
  if (send_stop) {
    I2C1->CR2 |= I2C_CR2_AUTOEND;
  } else {
    I2C1->CR2 &= ~I2C_CR2_AUTOEND;
  }

  // Load number of bytes to transmit into NBYTES[7:0]
  I2C1->CR2 &= ~I2C_CR2_NBYTES_Msk;
  I2C1->CR2 |= (size << I2C_CR2_NBYTES_Pos);

  // Generate START condition and transmit the slave address + Write bit
  I2C1->CR2 |= I2C_CR2_START;

  // Transmit each byte as TXIS (Transmit Interrupt Status / TXDR empty) asserts
  while (numBytesTX < size) {
    // Abort immediately if the slave did not acknowledge (NACKF = 1)
    if (I2C1->ISR & I2C_ISR_NACKF) {
      I2C1->ICR = I2C_ICR_NACKCF; // Clear NACK flag
      return false;
    }

    // When TXDR is ready for the next byte, write it to the transmit data register
    if (I2C1->ISR & I2C_ISR_TXIS) {
      I2C1->TXDR = send[numBytesTX];
      numBytesTX += 1;
      timeout = I2C_TIMEOUT;
    }

    if (--timeout == 0) {
      return false;
    }
  }

  // Complete the write phase:
  timeout = I2C_TIMEOUT;
  if (send_stop) {
    // Wait for hardware to finish sending the automatic STOP condition, then clear STOPF
    while (!(I2C1->ISR & I2C_ISR_STOPF)) {
      if (--timeout == 0) {
        return false;
      }
    }
    I2C1->ICR = I2C_ICR_STOPCF;
  } else {
    // Wait for Transfer Complete (TC = 1), indicating all bytes shifted out and bus is ready
    // for i2cReceive() to issue a Repeated START
    while (!(I2C1->ISR & I2C_ISR_TC)) {
      if (--timeout == 0) {
        return false;
      }
    }
  }

  return true;
}

// Master receiver protocol 
bool i2cReceive(uint8_t *dataIn, uint32_t size) {
  if ((dataIn == 0) || (size == 0) || (size > I2C_MAX_TRANSFER_SIZE)) {
    return false;
  }

  uint32_t numBytesRX = 0;
  uint32_t timeout = I2C_TIMEOUT;

  // Set transfer direction to Read (RD_WRN = 1) and enable AUTOEND to send NACK + STOP
  // automatically after receiving the final byte
  I2C1->CR2 |= (I2C_CR2_RD_WRN | I2C_CR2_AUTOEND);

  // Load number of bytes to receive into NBYTES[7:0]
  I2C1->CR2 &= ~I2C_CR2_NBYTES_Msk;
  I2C1->CR2 |= (size << I2C_CR2_NBYTES_Pos);

  // Generate START (or Repeated START if preceded by i2cSend with send_stop = false)
  I2C1->CR2 |= I2C_CR2_START;

  // Read each incoming byte as RXNE (Receive Data Register Not Empty) asserts
  while (numBytesRX < size) {
    if (I2C1->ISR & I2C_ISR_NACKF) {
      I2C1->ICR = I2C_ICR_NACKCF;
      return false;
    }

    if (I2C1->ISR & I2C_ISR_RXNE) {
      dataIn[numBytesRX] = (uint8_t)I2C1->RXDR;
      numBytesRX += 1;
      timeout = I2C_TIMEOUT;
    }

    if (--timeout == 0) {
      return false;
    }
  }

  // Wait for the automatic STOP condition to complete and clear STOPF
  timeout = I2C_TIMEOUT;
  while (!(I2C1->ISR & I2C_ISR_STOPF)) {
    if (--timeout == 0) {
      return false;
    }
  }
  I2C1->ICR = I2C_ICR_STOPCF;

  return true;
}


