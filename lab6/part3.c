#include "address_map.h"

#define FS 8000.0
#define HIGH 0x007FFFFF
#define LOW (-0x00800000)

int main(void) {
  volatile int* SW = (int*)SW_BASE;
  volatile int* audio_ptr = (int*)AUDIO_BASE;

  int count = 0;

  while (1) {
    int sw = (*SW) & 0x3FF;  // Read 10-bit switch value
    double f =
        100.0 + (1900.0 * sw) / 1023.0;  // Compute frequency from switch value

    // Compute half period
    int period = (int)(FS / f);
    int half = period / 2;
    if (half < 1) half = 1;

    // Check if there is space in the output FIFO
    int fifospace = *(audio_ptr + 1);
    int wslc = (fifospace >> 16) & 0xFF;
    int wsrc = (fifospace >> 24) & 0xFF;

    // Only generate samples if there is space in the output FIFO
    if (wslc > 0 && wsrc > 0) {
      // Generate square wave
      if (count < half) {
        sample = HIGH;
      } else {
        sample = LOW;
      }

      *(audio_ptr + 2) = sample;  // Left out
      *(audio_ptr + 3) = sample;  // Right out
      count++;

      if (count >= 2 * half) count = 0;  // Reset count after one full period
    }
  }
}
