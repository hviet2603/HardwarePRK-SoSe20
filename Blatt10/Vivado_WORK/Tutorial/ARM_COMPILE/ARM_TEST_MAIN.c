int main () {
	//Speicheradresse des RS232-Senderegisters
	char *RS232_TRM = (char *) 0x80000004;
	//Speicheradresse des RS232-Statusregisters
	volatile int *RS232_STATUS = (int *) 0x80000008;
	//Maske zum Ausfiltern des Busy-Bits des RS232-Senders
	const int RS232_BUSY_MASK = 0x00000010;
	//String der ausgegeben werden soll
	const char *TEXT=" Hallo Welt ";
	int i;

	//Programmschleife, permanent ausgefuehrt	
	while(1){
	//Vollstaendigen String inkl. \0 ausgeben
		for(i=0; i<13; i++){
			//warten, bis das Busy-Bit nicht mehr gesetzt ist
		 	while(*RS232_STATUS & RS232_BUSY_MASK){			
				; //warten
	 		}
			//Character in Senderegister schreiben
			*RS232_TRM = TEXT[i];			
		}
	} 
  return 0;
}
