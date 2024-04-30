#include "mmio.h"
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define USB2_LOOPBACK_W 0x7000
#define USB2_LOOPBACK_R 0x7004

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

  return 0;
}
