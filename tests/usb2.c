#include "mmio.h"
#include <stdio.h>

#define USB2_LOOPBACK_W 0x7000
#define USB2_LOOPBACK_R 0x7004

int main(void)
{
  int res = 0;
  printf("res before reading=%d\n", res);
  reg_write32(USB2_LOOPBACK_W, 1);
  res = reg_read32(USB2_LOOPBACK_R);
  printf("res after reading=%d\n", res);

  return 0;
}