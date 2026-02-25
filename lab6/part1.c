int main(void) {
  volatile int* LEDR = (int*)0xFF200000;  // LED base
  volatile int* KEY = (int*)0x200050;    // KEY base

  // Clear edge capture bits for all keys
  *(KEY + 3) = 0xF;

  while (1) {
    int edge = *(KEY + 3);  // Read edge capture: offset 12
    if (edge & 0x1)         // If KEY0 pressed
      *LEDR = 0x3FF;        // Turn all LEDs ON
    if (edge & 0x2)         // If KEY1 pressed
      *LEDR = 0x0;          // Turn all LEDs OFF
    *(KEY + 3) = edge;      // Clear edge capture bits
  }
}