#include "mmio.h"
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

// Paramtrized data width
#define DATA_WIDTH 8
// Memory-mapped I/O register addresses
#define USB2_LOOPBACK_W 0x7000
#define USB2_LOOPBACK_R 0x7004
#define USB2_RX_BUNDLE 0x7008
#define USB2_UTMI_DIN 0x7018
// Bit masks for extracting specific bits or fields
#define RX_DOUT_MASK  ((1 << DATA_WIDTH) - 1)
#define RX_ACTIVE_BIT (1 << DATA_WIDTH)
#define RX_ERROR_BIT  (1 << (DATA_WIDTH + 1))
#define TX_DIN_MASK   RX_DOUT_MASK

int current_test = 1;
const int TOTAL_TESTS = 8;

void test_loopback(uint32_t test_value) {
  printf("[Test %d/%d]: Testing with value: 0x%08X - ", current_test, TOTAL_TESTS, test_value);
  reg_write32(USB2_LOOPBACK_W, test_value);
  uint32_t read_value = reg_read32(USB2_LOOPBACK_R);
  printf("Read value: 0x%08X - ", read_value);

  if (read_value == test_value) {
      printf("PASSED\n");
  } else {
      printf("FAILED (Expected: 0x%08X, Got: 0x%08X)\n", test_value, read_value);
  }
  current_test++;
}

int main(void) {
  test_loopback(0x1);
  test_loopback(0x00000000);
  test_loopback(0xFFFFFFFF);
  test_loopback(0xDEADBEEF);

  srand(time(NULL));
  while (current_test <= TOTAL_TESTS)
    test_loopback(rand());

  // TODO: write a library to read and write
  // use 32 bit type for data width agnostic
  
  // Write to TX
  // Assume USB_STATUS = [TX_READY, 
  // while ((reg_read8(USB_STATUS) & 0x2) == 0); // wait for TX ready
  reg_write32(USB2_UTMI_DIN, 0x114514 & TX_DIN_MASK);

  // Read from RX
  uint32_t rx_bundle = reg_read32(USB2_RX_BUNDLE);
  uint32_t rxDataOut = rx_bundle & RX_DOUT_MASK;
  int rxActive = (rx_bundle & RX_ACTIVE_BIT) ? 1 : 0;
  int rxError = (rx_bundle & RX_ERROR_BIT) ? 1 : 0;

  return 0;
}
