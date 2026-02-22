#define AUDIO_BASE 0xff203040
#define SW_BASE 0xFF200040

int main() {
	//Create pointer to audio and Switches
	volatile int *audio_ptr = (int*)AUDIO_BASE;
	volatile int *sw_ptr = (int*)SW_BASE;
	
	
	//Tells me how full or empty the input and output FIFO's are
	int fifospace;
	
	//Get current sign either High or Low of square wave
	int current_sample = 3000;
	
	//Have counter to track # cycles
	int counter = 0;
	
	//Infinite loop
	while(1){
		//Read switches first and keep first 10 bits
		int switch_value = *sw_ptr;
		switch_value = switch_value & 0x3FF;
		
		
		
		//Conver this switch number to a frequency
		//Formula is min + (current value * range / max )
		int frequency = 100 + (switch_value * 1900 / 1023);
		
		//To create square wave and know how long to hold high and low, we calculate it
		int samples_per_half_cycle = 8000 / (2 * frequency);
		
		//Get the fifospace to check if samples are in input or output FIFO
		fifospace = *(audio_ptr+1);
		
		//Check WALC and WARC to see if there is even space to output the sample in the FIFO
		int walc = (fifospace >> 16) & 0xFF;
		int warc = (fifospace >> 24) & 0xFF;
		
		//If WALC and WARC > 0 then there is at least one sample space available in output FIFO
		if(walc > 0 && warc > 0){
			//Store into left and right output FIFO
			*(audio_ptr+2) = current_sample;
			*(audio_ptr+3)= current_sample;
			
			//Update counter
			counter += 1;
			
			//If our half cycle is up, change amplitude and reset counter
			if (counter >= samples_per_half_cycle){
				current_sample = -current_sample;
				counter = 0;
			}
			
		}
	}
}