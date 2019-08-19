#include "rex.h"

//100 = 1 second | 1000 = 10 seconds | 6000 = 1 minute
int counter = 32456;
int format = 1;

void print(int c){
	while(!(WrampSp2->Stat & 2));
	WrampSp2->Tx = 48 + c;
}

void minuteSecond(){

	int seconds, minutes, minutesOne, minutesTen, secondsOne, secondsTen, splitSeconds;

	seconds = (counter % 6000);
	splitSeconds = (seconds%100);
	seconds = (seconds - splitSeconds)/100;
	minutes = counter - seconds*100 - splitSeconds;
	minutes /= 6000;
	
	
	minutesOne = minutes % 10;
	minutesTen = (minutes - minutesOne);
	if(minutesTen != 0){
	minutesTen /= 10;
	}
	secondsOne = seconds % 10;
	secondsTen = (seconds - secondsOne);
	if(secondsTen != 0){
	secondsTen /= 10;
	}
	
	//return
	print(-35);
	print(minutesTen);
	print(minutesOne);
	print(10);
	print(secondsTen);
	print(secondsOne);
	
}

void seconds(){

	int seconds, secOne, secTen, secHund, secThous, splitSeconds, splitTenth, splitHund;

	seconds = (counter % 6000);
	splitSeconds = (seconds%100);
	seconds = (counter - splitSeconds)/100;
	
	splitHund = splitSeconds%10;
	splitTenth = splitSeconds - splitHund;
	if(splitTenth != 0){
		splitTenth /= 10;
	}

	secOne = seconds % 10;
	secTen = (seconds - secOne);
	if(secTen != 0){
		secTen /= 10;
		secTen %= 10;
	}
	secHund = (seconds - secTen*10 - secOne);
	if(secHund != 0){
		secHund /= 100;
		secHund %= 10;
	}
	secThous = (seconds - secHund*100 - secTen*10 - secOne);
	if(secThous != 0){
		secThous /= 1000;
		secThous %= 10;
	}
	
	
	//return
	print(-35);
	print(secThous);
	print(secHund);
	print(secTen);
	print(secOne);
	print(-2);
	print(splitTenth);
	print(splitHund);
	
}

void listenForFormat(){

	if(WrampSp2->Stat & 1){
		int input;
		//clearSerial();
		input = WrampSp2->Rx;
		switch(input){
		
		case 49:
			format = 1;
			break;
		case 50:
			format = 2;
			break;
		case 51:
			format = 3;
			break;
		case 113:
			format = 4;
			break;
		}
	}

}

void timerInterrupts(){

	int interOne, interTen, interHund, interThous, interTThous, interHThous;
	
	interOne = counter % 10;
	
	interTen = counter - interOne;
	if(interTen != 0){
		interTen /= 10;
		interTen %= 10;
	}
	interHund = counter - interTen*10 - interOne;
	if(interHund != 0){
		interHund /= 100;
		interHund %= 10;
	}
	interThous = counter - interHund*100 - interTen*10 - interOne;
	if(interThous != 0){
		interThous /= 1000;
		interThous %= 10;
	}
	interTThous = counter - interThous*1000 - interHund*100 - interTen*10 - interOne;
	if(interTThous != 0){
		interTThous /= 10000;
		interTThous %= 10;
	}
	interHThous = counter - interTThous*10000 - interThous*1000 - interHund*100 - interTen*10 - interOne;
	if(interHThous != 0){
		interHThous /= 100000;
		interHThous %= 10;
	}
	
	//return
	print(-35);
	print(interHThous);
	print(interTThous);
	print(interThous);
	print(interHund);
	print(interTen);
	print(interOne);
}

void clearSerial(){
	
	int count;
	
	for(count = 1; count <= 8; count++){
		print(-16);
	}
	
}


void serial_main(){

	while(1){
		//clearSerial();
		listenForFormat();
		switch(format){
			//Minutes and Seconds
			case 1:
				minuteSecond();
				break;
			case 2:
				seconds();
				break;
			case 3:
				timerInterrupts();
				break;
			case 4:
				return;
		}
		
	}
}
