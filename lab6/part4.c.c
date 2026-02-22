#define AUDIO_BASE 0xff203040

int main() {
	//Create pointer to audio and buffer arrays to store past 3200 samples
	volatile int *audio_ptr = (int*)AUDIO_BASE;
	
	int bufferLeft[3200];
	int bufferRight[3200];
	
	//Two arrays are needed to store last 3200 samples of each channel
	for (int i = 0; i < 3200; i++) {
    	bufferLeft[i] = 0;
    	bufferRight[i] = 0;
	} //Prevents garbage values in the arrays
	
	//Create index to track position of buffer
	int index = 0;
	
	//CPULator has 8kHZ sampling rate, meaning 8000 samples per second
	//Calculate how many samples it should delay by for echo for 0.4 seconds
	//0.4 * 8000 = 3200
	int numSamples = 3200;
	
	//Tells me how full or empty the input and output FIFO's are
	int fifospace;
	
	//Infinite loop
	while(1){
		fifospace = *(audio_ptr+1);
		
		//If RARC > 0 and WSRC > 0 then there is at least one sample in right input FIFO and space available to send sample in right output FIFO
		if ((fifospace & 0x00FF0000) > 0 && (fifospace & 0x000000FF) > 0){
			//Read next sample from left and right input FIFO
			int left = *(audio_ptr+2);
			int right = *(audio_ptr+3);
			
			//Get delayed sample from buffer and calculate output for left and right channels 
			int outputLeft = left + (0.4*bufferLeft[index]);
			bufferLeft[index] = left;
			
			int outputRight = right + (0.4*bufferRight[index]);
			bufferRight[index] = right;
			
			//Increment index but if its greater than 3200 loop back to start
			index++;
			if (index == 3200){
				index = 0;
			}
			
			
			//Store into left and right output FIFO
			*(audio_ptr+2) = outputLeft;
			*(audio_ptr+3)= outputRight;
		}
	}
}