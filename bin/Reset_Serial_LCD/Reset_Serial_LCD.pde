//SerLCD FIX v0.1 by Talada
/*Upload with SerLCD attached. Once running, start Serial
  Monitor. Follow instructions in Serial Monitor.*/
 
void setup(){
  Serial.begin(9600);  //Begin serial communication.
}

void lcdReset(){               //New Function
  Serial.print(0xFE, BYTE);  //Command code
  Serial.print(0x72, BYTE);  //Reset code
}

void cls(){                       //New Function
  Serial.print(0xFE, BYTE);  //Command Code
  Serial.print(0x01, BYTE);  //Clear Screen Code
}

void loop(){
  Serial.print("Attach GND now");     //Note: You can attach the GND while Reset is being sent
  delay(1000);
   
     for (int repeater=0; repeater <= 15; repeater++){    //sends Reset Command 15 times
          lcdReset();
          delay(500);
         }

  cls();
  Serial.print("LCD Reset! Remove GND");    //You have 21 seconds to remove GND before Reset is sent again.
  delay(20000);
 
}
