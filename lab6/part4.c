#define AUDIO_BASE 0xFF203040
#define DELAY 3200  // 0.4s delay
#define DAMP_DIV 2  // Damping factor

int main(void) {
  volatile int* audio_ptr = (int*)AUDIO_BASE; 
  int fifospace; // Variable to hold FIFO space information

  // Echo buffers for left and right channels
  static int echoL[DELAY] = {0}; 
  static int echoR[DELAY] = {0};
  int idx = 0;

  while (1) {
    fifospace = *(audio_ptr + 1); // Read the audio port fifospace register

    if ((fifospace & 0x000000FF) > 0) {  // Read from fifo if there is at least one sample
      int inL = *(audio_ptr + 2); // Read left input sample
      int inR = *(audio_ptr + 3); // Read right input sample

      // Echo formula
      int outL = inL + (echoL[idx] / DAMP_DIV); 
      int outR = inR + (echoR[idx] / DAMP_DIV);

      *(audio_ptr + 2) = outL; // Write left output sample
      *(audio_ptr + 3) = outR; // Write right output sample

      // Store current output in echo buffer
      echoL[idx] = outL; 
      echoR[idx] = outR; 

      idx++;
      if (idx >= DELAY) idx = 0; // Circular buffer for index reset
    }
  }
}