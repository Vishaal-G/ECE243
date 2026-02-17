/**********************************************************************
 * This program performs the following:
 * 1. checks if there is a sample ready to be read.
 * 2. reads that sample from microphone channels.
 * 3. writes that sample to the audio output channels.
 *********************************************************************/
#define AUDIO_BASE 0xFF203040
int main(void) {
  // Audio codec Register address
  volatile int* audio_ptr = (int*)AUDIO_BASE;
  // intermediate values
  int fifospace;
  // This is an infinite loop checking the RARC to see if there is at least one
  // entry in the input FIFOs. If there is, just copy it over to the output
  // fifo. The timing of the input FIFO controls the timing of the output, which
  // makes this easier than the other parts of the lab.
  while (1) {
    fifospace = *(audio_ptr + 1);      // read the audio port fifospace register
    if ((fifospace & 0x000000FF) > 0)  // check RARC to see if there is at least
    // one sample input
    {
      // load both input microphone channels - just get one sample from each
      int left = *(audio_ptr + 2);   // read the leftdata register - input FIFO
      int right = *(audio_ptr + 3);  // same for rightdata
      // note that these removes the samples from the FIFO
      //  store both of those samples to output channels
      *(audio_ptr + 2) = left;  // storing to the leftdata adds to output FIFO
      *(audio_ptr + 3) = right;
    }
  }
}