#ifndef USB2_H
#define USB2_H

#include "mmio.h"

// Paramtrized data width
#define DATA_WIDTH 8
// Memory-mapped I/O register addresses
#define USB2_LOOPBACK_W 0x7000  // Deprecated
#define USB2_LOOPBACK_R 0x7004  // Deprecated
#define USB2_RX_BUNDLE 0x7008
#define USB2_TX_READY 0x700C    // TBD
#define USB2_RX_VALID 0x7010    // TBD
#define USB2_UTMI_DIN 0x7018
// Bit masks for extracting specific bits or fields
#define RX_DOUT_MASK  ((1 << DATA_WIDTH) - 1)
#define RX_ACTIVE_BIT (1 << DATA_WIDTH)
#define RX_ERROR_BIT  (1 << (DATA_WIDTH + 1))
#define TX_DIN_MASK   RX_DOUT_MASK

/**
 * Write data to USB2 UTMI Data Input MMIO Register.
 *
 * @param data The data to be written, which is masked by TX_DIN_MASK.
 */
static inline void usb2_write(uint32_t data) {
  while ((reg_read8(USB2_TX_READY)) == 0);  // wait for TX ready
  // Use 32 bit for generalization
  // Be careful of override
  reg_write32(USB2_UTMI_DIN, data & TX_DIN_MASK);
}

/**
 * Read data from the USB2 RX Bundle MMIO Register.
 *
 * @param rxActive Optional pointer to an int to store the RX active status (1 if active, 0 if not).
 * @param rxError Optional pointer to an int to store the RX error status (1 if error, 0 if no error).
 * @return The data read from the USB2_RX_BUNDLE register, masked to the DATA_WIDTH.
 */
static inline uint32_t usb2_read(int *rxActive, int *rxError) {
  while ((reg_read8(USB2_RX_VALID)) == 0);  // wait for RX valid
  uint32_t rx_bundle = reg_read32(USB2_RX_BUNDLE);
  if (rxActive) *rxActive = (rx_bundle & RX_ACTIVE_BIT) ? 1 : 0;
  if (rxError) *rxError = (rx_bundle & RX_ERROR_BIT) ? 1 : 0;
  return rx_bundle & RX_DOUT_MASK;
}

#endif  // USB2_H
