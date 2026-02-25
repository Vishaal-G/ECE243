#define AUDIO_BASE 0xff203040

int main() {
	//Create pointer to audio
	volatile int *audio_ptr = (int*)AUDIO_BASE;
	
	//Tells me how full or empty the input and output FIFO's are
	int fifospace;
	
	//Infinite loop
	while(1){
		fifospace = *(audio_ptr+1);
		
		//If RARC > 0 then there is at least one sample in input FIFO
		if((fifospace & 0xff) > 0){
			//Read next sample from left nad right input FIFO
			int left = *(audio_ptr+2);
			int right = *(audio_ptr+3);
			
			//Store into left and right output FIFO
			*(audio_ptr+2) = left;
			*(audio_ptr+3)= right;
		}
	}
}