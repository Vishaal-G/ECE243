#define AUDIO_BASE 0xff203040

#define DELAY 3200  // 0.4s delay 8khz
#define DAMP_DIV 2  // Damping factor

int main(void) {
  volatile int* audio_ptr = (int*)AUDIO_BASE; 
  int fifospace; // Variable to hold FIFO space information

  // Echo buffers for left and right channels (storing echoed output)
  static int echo_Left[DELAY] = {0}; 
  static int echo_Right[DELAY] = {0};
  int index = 0;

  while (1) {
    fifospace = *(audio_ptr + 1); // Read the audio port fifospace register

    if ((fifospace & 0x000000FF) > 0) {  // Read from fifo if there is at least one sample
      int input_Left = *(audio_ptr + 2); // Read left input sample
      int input_Right = *(audio_ptr + 3); // Read right input sample

      // Echo formula
      int outL = input_Left + (echo_Left[index] / DAMP_DIV); 
      int outR = input_Right + (echo_Right[index] / DAMP_DIV);

      *(audio_ptr + 2) = outL; // Write left output sample
      *(audio_ptr + 3) = outR; // Write right output sample

      // Store current output in echo buffer
      echo_Left[index] = outL; 
      echo_Right[index] = outR; 

      index++;
      if (index >= DELAY) index = 0; // Wrap back to 0 for Circular buffer storage
    }
  }
}
