#include "rex.h"

void main(){

	int switches = 0;
	int ones, tens, hundreds, thousands;
	//0 = Hex, 1 = Decimal
	int format = 0;
	int buttons = 0;
	WrampParallel->Ctrl = WrampParallel->Ctrl | WRAMP_PAR_HEX_DECODE;

	while(1){
		buttons = WrampParallel->Buttons;
		//hex
		//if(buttons & 7){
			if(buttons == 1){
				format = 0;
			//decimal
			}else if(buttons == 2){
				format = 1;
			//terminate
			}else if(buttons == 4){
				return;
			}
		//}
	
		//read the switches
		switches = WrampParallel->Switches;
		
		
		
		//hex (base 16)
		if(format == 0){
			//ones into lower right
			WrampParallel->LowerRightSSD = switches;
			//tens into upper right
			WrampParallel->LowerLeftSSD = switches>>4;
			//hundreds into lower left
			WrampParallel->UpperRightSSD = switches>>8;
			//thousands into upper right
			WrampParallel->UpperLeftSSD = switches>>12;
			
		}else if(format == 1){
			
			//ones into lower right
			WrampParallel->LowerRightSSD = 0;
			//tens into upper right
			WrampParallel->LowerLeftSSD = 0;
			//hundreds into lower left
			WrampParallel->UpperRightSSD = 0;
			//thousands into upper right
			WrampParallel->UpperLeftSSD = 0;
			
			ones = 0;
			tens = 0;
			hundreds = 0;
			thousands = 0;
			
			//1
			ones = switches%10;
			//10
			tens = switches%100;
			tens -= ones;
			if(tens != 0){
				tens /= 10;
			}
			
			//100
			hundreds = switches%1000;
			hundreds -= ones;
			hundreds -= tens;
			if(hundreds!= 0){
				hundreds /= 100;
			}
			
			//1000
			thousands = switches%10000;
			thousands -= hundreds;
			thousands -= tens;
			thousands -= ones;
			if(thousands != 0){
				thousands /= 1000;
			}
			
			//ones into lower right
			WrampParallel->LowerRightSSD = ones;
			//tens into upper right
			WrampParallel->LowerLeftSSD = tens;
			//hundreds into lower left
			WrampParallel->UpperRightSSD = hundreds;
			//thousands into upper right
			WrampParallel->UpperLeftSSD = thousands;
		}
		
		
		
		//while the wramp switches are still equal to the earlier switches variable, do this loop (it'll break when switch changes)
		while(switches == WrampParallel->Switches && buttons == WrampParallel->Buttons);
	}
}
