/****************************************************************************
Turing Alarm Clock - Arduino Version
 Adapted from Nick Johnson's Turing Alarm Clock
 by Xiaoyang Kao
 Project Started on August 13 2011
 Project completed on September 9 2011
 For the version without light control download "Turing_Alarm_v1"
 
 Attributed under a Creative Commons Attribution - NonCommercial - ShareAlike license.
 
 ***************************************************************************/

#include <Wire.h> // library for I2C on A4 (SDA) & A5 (SCL)
#include <RTClib.h> // RTC library for RTC1307
#include <Bounce.h> // debounce library


// VARIABLES ============================================================
int alarmSecond = 0; // stores values for alarm
int alarmMinute = 0;
int alarmHour = 0;


int MenuPosition = 0; // remember menu position; 0 for main menu, 1 for select set time/alarm, 2 for set time, 3 for set alarm, 4 for select set time/alar
// , 5 for volume/brightness menu, 6 for 
int timePosition = 0; // remember time position; 0 for second, 1 for minute, 2 for hour for set alarm
int alarmSetting = 0; // alarm on/off variable; 0 = alarm off, 1 = alarm running
int brightnessLCD = 157; // max PWM value for LCD brightness; 128-157
int mathValOne = 0; 
int mathValTwo = 0;
int mathValThree = 0;
int inputAnswer = 100; // 
int realAnswer = 0;

// BUTTONS ==================
int buttonIncrease = 2; // increase button
int buttonDecrease = 3; // decrease button
int moveLeft = 4; // left button
int moveRight = 5; // right button
int buttonOK = 8; // OK button

// OTHER I/O DEVICES ========
const int alarmSpeaker = 9;
int fadeOutput = 11; 

int toneOn = 0;
long previousMillis = 0;
int x = 0;
long interval = 70;
long interval2 = 500;
long millisInitial = 0;
long millisFinal = 0; 
RTC_DS1307 RTC;

Bounce increase = Bounce(buttonIncrease, 10); 
Bounce decrease = Bounce(buttonDecrease, 10); 
Bounce left = Bounce(moveLeft, 50); 
Bounce right = Bounce(moveRight, 50); 
Bounce OK = Bounce(buttonOK, 10); 

void lightingFade() {
  int val = map(analogRead(1), 0, 1023, 0, 255);
  analogWrite(11, val);
  if(val < 20) {
    val = 0;
  }
  if(val > 1015) {
    val = 1023; 
  }
}

void alarmNoiseOn(){  
  unsigned long currentMillis = millis();
  if(currentMillis - previousMillis > interval && x < 8) {
    previousMillis = currentMillis;  
    if (toneOn == 0) {
      toneOn = 2048;

    }
    else
      toneOn = 0;
    tone(9, toneOn);
    if(toneOn == 0)
      noTone(9);
    x++;
  }
  if(currentMillis - previousMillis > interval2 && x == 8) {
    previousMillis = currentMillis;  
    noTone(9);
    x = 0;
  }
}

void displayCurrentTime() {
  DateTime now = RTC.now();
  delay(10);
  Serial.print("      ");
  Serial.print(now.month(), DEC);
  Serial.print("/");
  Serial.print(now.day(), DEC);
  moveLineTwo();
  Serial.print("    ");
  if(now.hour() <= 9) {
    Serial.print("0");
  }
  Serial.print(now.hour(), DEC);
  Serial.print(":");
  if(now.minute() <= 9) {
    Serial.print("0");
  }
  Serial.print(now.minute(), DEC);
  Serial.print(":");
  if(now.second() <= 9) {
    Serial.print("0");
  }
  Serial.print(now.second(), DEC);
  delay(10);
}

void displayCurrentTimeAlarm() {
  DateTime now = RTC.now();
  delay(10);
  Serial.print(now.month(), DEC);
  Serial.print("/");
  Serial.print(now.day(), DEC);
  Serial.print("   ");
  if(now.hour() <= 9) {
    Serial.print("0");
  }
  Serial.print(now.hour(), DEC);
  Serial.print(":");
  if(now.minute() <= 9) {
    Serial.print("0");
  }
  Serial.print(now.minute(), DEC);
  Serial.print(":");
  if(now.second() <= 9) {
    Serial.print("0");
  }
  Serial.print(now.second(), DEC);
  delay(10);
}

void clearLCD(){
  Serial.print(0xFE, BYTE); // command line
  Serial.print(0x01, BYTE); // clear LCD
}

void moveLineOne() {
  Serial.print(0xFE, BYTE); // command line
  Serial.print(128, BYTE); // move cursor to line 1 position 1
}

void moveLineTwo() {
  Serial.print(0xFE, BYTE); // command line
  Serial.print(192, BYTE); // move cursor to line 2 position 1
}

void setup()
{
  Serial.begin(9600);
  RTC.begin();
  Wire.begin();

  // INPUTS ========
  pinMode(buttonIncrease, INPUT);
  pinMode(buttonDecrease, INPUT);
  pinMode(moveLeft, INPUT);
  pinMode(moveRight, INPUT);
  pinMode(buttonOK, INPUT);

  // OUTPUTS =========
  pinMode(alarmSpeaker, OUTPUT);
  pinMode(fadeOutput, OUTPUT);

  // OTHERS ==========
  randomSeed(analogRead(2));
}


void loop()
{
  clearLCD();
  delay(500); // allow LCD time to execute


  while (MenuPosition == 0) {
    lightingFade();
    OK.update();
    int debounceOK = OK.read();
    Serial.print(0x7C, BYTE);
    Serial.print(brightnessLCD, BYTE);
    delay(50);
    moveLineOne();

    delay(50);
    displayCurrentTime();


    if (debounceOK == HIGH) {
      MenuPosition = 1;
      timePosition = 0;
    }


  } // menuposition 0

    // MenuPosition = 1 ======================================== Select change alarm/time or settings
  while (MenuPosition == 1) {
    lightingFade();
    left.update();
    right.update();
    decrease.update();
    OK.update();
    int leftDebounce = left.read();
    int rightDebounce = right.read();
    int okDebounce = OK.read();
    int decreaseDebounce = decrease.read();

    clearLCD();
    moveLineOne();
    Serial.print("time / brghtnss"); 
    moveLineTwo();
    Serial.print(" /IO monitor?");
    delay(100);

    if (leftDebounce == HIGH) {
      MenuPosition = 3;
      timePosition = 0;
    }
    if (rightDebounce == HIGH) {
      MenuPosition = 5;
      timePosition = 0;
    }
    if (decreaseDebounce == HIGH) {
      MenuPosition = 9;
    }
    if(alarmSetting == 1 && okDebounce == HIGH) {
      MenuPosition = 7; 
    }
    if(alarmSetting != 1 && okDebounce == HIGH) {
      MenuPosition = 0; 
    }
  }

  // MenuPosition 3 ====================================================================
  while (MenuPosition == 3) {
    lightingFade();
    if (alarmSetting == 1) { // if alarm is already on, menu to stop alarm
      MenuPosition = 8;
    }
    left.update();
    right.update();
    OK.update();
    increase.update();
    decrease.update();
    int leftDebounce = left.read();
    int rightDebounce = right.read();
    int okDebounce = OK.read();
    int increaseDebounce = increase.read();
    int decreaseDebounce = decrease.read();
    clearLCD();
    moveLineOne();
    Serial.print("Set alarm time");

    moveLineTwo();
    Serial.print(" ");
    Serial.print(alarmHour);
    Serial.print(" : ");
    Serial.print(alarmMinute);
    Serial.print(" : ");
    Serial.print(alarmSecond);
    delay(100);

    if (timePosition < 0) {
      timePosition = 2; 
    }
    if (timePosition > 2) {
      timePosition = 0;
    }

    while(digitalRead(moveLeft) == HIGH) {
      timePosition++;
      delay(200);
    }
    while(digitalRead(moveRight) == HIGH) {
      timePosition--;
      delay(200);
    }

    if (okDebounce == HIGH) {
      alarmSetting = 1; // begin alarm
      timePosition = 0;  // reset time position
      mathValOne = random(11, 20);  // determines math problem
      mathValTwo = random(9, 15);
      mathValThree = random(20, 150);
      inputAnswer = (mathValOne * mathValTwo + mathValThree) - random(-35, 35);
      delay(20);
      MenuPosition = 7;
      delay(100);
      clearLCD();
      delay(500);
    }

    // if timePosition == 0 ======================================================
    if (timePosition == 0) {
      while(digitalRead(buttonIncrease) == HIGH) {
        alarmSecond++;
        delay(100);
      }
      while(digitalRead(buttonDecrease) == HIGH) {
        alarmSecond--;
        delay(100);
      }
    }


    // if timePosition == 1 =====================================================
    if (timePosition == 1) {
      while(digitalRead(buttonIncrease) == HIGH) {
        alarmMinute++;
        delay(100);
      }
      while(digitalRead(buttonDecrease) == HIGH) {
        alarmMinute--;
        delay(100);
      }
    }

    // if timePosition == 2 ====================================================
    if (timePosition == 2) {
      while(digitalRead(buttonIncrease) == HIGH) {
        alarmHour++;
        delay(100);
      }
      while(digitalRead(buttonDecrease) == HIGH) {
        alarmHour--;
        delay(100);
      }
    }

    if (alarmMinute < 0) {
      alarmMinute = 59;
    }
    if (alarmMinute >= 60) {
      alarmMinute = 0;
    }
    if (alarmHour < 0) {
      alarmHour = 23; 
    }
    if (alarmHour >= 24) {
      alarmHour = 0;
    }
    if (alarmSecond < 0) {
      alarmSecond = 59;
    }
    if (alarmSecond >= 60) {
      alarmSecond = 0;
    }
  } // MENUPOSITION 3 CLOSING BRACKET

  while (MenuPosition == 5) {// SETTINGS ===========================================
    lightingFade();
    clearLCD();
    moveLineOne();
    Serial.print("  Brightness");

    moveLineTwo();
    Serial.print(map(brightnessLCD, 128, 157, 0, 100));
    Serial.print("%");
    delay(50);

    while(digitalRead(buttonIncrease) == HIGH) {
      brightnessLCD = brightnessLCD + 2;
      delay(80);
    }
    while(digitalRead(buttonDecrease) == HIGH) {
      brightnessLCD = brightnessLCD - 2;
      delay(80);
    }
    if(brightnessLCD >= 157) {
      brightnessLCD = 157; 
    }
    if(brightnessLCD < 128) {
      brightnessLCD = 128; 
    }
    if(digitalRead(buttonOK) == HIGH && alarmSetting == 0) {
      delay(500);
      MenuPosition = 0;
    }
    if(digitalRead(buttonOK) == HIGH && alarmSetting == 1) {
      delay(500);
      MenuPosition = 7;
    }

    Serial.print(0x7C, BYTE);
    Serial.print(brightnessLCD, BYTE);
    delay(50);
    if(digitalRead(buttonOK) == HIGH) {
      MenuPosition = 0;
    }
  } // MENUPOSITION 5=================================================

  while(MenuPosition == 6) { // MENUPOSITION 6    Alarm ==========================================
    lightingFade();
    clearLCD();
    alarmNoiseOn();
    increase.update();
    decrease.update();
    int debounceIncrease = increase.read();
    int debounceDecrease = decrease.read();

    realAnswer = mathValOne * mathValTwo + mathValThree;
    moveLineOne();
    Serial.print(" Hello!"); // wakeup message

    moveLineTwo();
    Serial.print(mathValOne);
    Serial.print("*");
    Serial.print(mathValTwo);
    Serial.print("+");
    Serial.print(mathValThree);
    Serial.print(" = ");
    Serial.print(inputAnswer);
    Serial.print(" ?");
    delay(100);
    if(debounceIncrease == HIGH) {
      inputAnswer++;
    }
    if(debounceDecrease == HIGH) {
      inputAnswer--; 
    }
    if(digitalRead(buttonOK) == HIGH && inputAnswer != realAnswer) {
      mathValOne = random(11, 20);
      mathValTwo = random(9, 15);
      mathValThree = random(20, 150);
      inputAnswer = (mathValOne * mathValTwo + mathValThree) - random(-35, 35);
    }
    if(digitalRead(buttonOK) == HIGH && inputAnswer == realAnswer) {
      delay(500);
      noTone(9);
      millisFinal = millis();
      clearLCD();
      moveLineOne();
      Serial.print(" Good Morning!");
      moveLineTwo();
      Serial.print((millisFinal - millisInitial) / 1000);
      Serial.print(" seconds");
      delay(5000);
      MenuPosition = 0;
      mathValOne = 0;
      mathValTwo = 0;
      mathValThree = 0;
      alarmSecond = 0;
      alarmMinute = 0;
      alarmHour = 0;
      alarmSetting = 0;
    }
  } // menuposition 6 =============================================

  while(MenuPosition == 7) { // alarm already set
    lightingFade();
    DateTime now = RTC.now();
label:
    moveLineOne();
    delay (20);
    Serial.print("Now     alarm on");

    moveLineTwo();
    displayCurrentTimeAlarm();

    if(digitalRead(moveRight) == HIGH) {
      clearLCD();
      moveLineOne();
      Serial.print("Alarm set at");
      moveLineTwo();
      Serial.print(alarmHour);
      Serial.print(":");
      Serial.print(alarmMinute);
      Serial.print(":");
      Serial.print(alarmSecond);
      delay(4000);
    }
    if (digitalRead(buttonOK) == HIGH) {
      MenuPosition = 1;
      timePosition = 0;
    }
    if(alarmSetting == 1 && alarmSecond == now.second() && alarmMinute == now.minute() && alarmHour == now.hour()) {
      MenuPosition = 6;
      millisInitial = millis();
    }

  } // menuposition 7
  while(MenuPosition == 8) { // menuposition 8
    lightingFade();
    clearLCD();
    moveLineOne();
    Serial.print("Alarm is on");

    moveLineTwo();
    Serial.print("Turn off?  Y/N");
    delay(200);

    if(digitalRead(moveLeft) == HIGH) {
      alarmSetting = 0;
      delay(500);
      MenuPosition = 0;
      alarmSecond = 0;
      alarmMinute = 0;
      alarmHour = 0;
    }
    if(digitalRead(moveRight) == HIGH) {
      delay(500);
      MenuPosition = 0;
    }
  }

  while(MenuPosition == 9) {
    lightingFade();
    clearLCD();
    moveLineOne();
    int val = analogRead(1);
    Serial.print("analog = ");
    Serial.print(val);
    moveLineTwo();
    float voltageIn = map(val, 0, 1023, 0, 1200);
    float voltageOut = voltageIn / 100;
    Serial.print("voltage = ");
    Serial.print(voltageOut);
    delay(20);

    if(digitalRead(buttonOK) == HIGH && alarmSetting == 0) {
      clearLCD();
      delay(500); 
      MenuPosition = 0;
    }
    if(digitalRead(buttonOK) == HIGH && alarmSetting == 1) {
      clearLCD();
      delay(500);
      MenuPosition = 7;
    }
  }
}  // CLOSING BRACKET FOR VOID LOOP

