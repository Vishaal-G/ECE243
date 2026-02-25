int main() {
	//Storing the base registers for LED and KEY
    volatile int *KEY_BASE = (int *)0xFF200050;
	volatile int *LED_BASE = (int*)0xFF200000;
	
	//Clear any stale edge capture values at startup
	*(KEY_BASE + 3) = 0xF;

	//Polling loop
    while (1) {
        //Access edge capture register of key
    	int edge_cap = *(KEY_BASE + 3);
		
		//Only process if a key event occurred
		if (edge_cap != 0) {

			//Tells me if key 0 is pressed
			if (edge_cap & 0x1){
				//Turns all LED's on
				*(LED_BASE) = 0x3FF;
			}

			//Tells me if key 1 is pressed
			if (edge_cap & 0x2){
				//Turns all LED's off
				*(LED_BASE) = 0x0;
			}
			
			//Turn off edge capture register by writing same value back to it
			*(KEY_BASE + 3) = edge_cap;
		}
    }
}