/*
    ------ Waspmote Pro Code Example --------

    Explanation: This is the basic Code for Waspmote Pro

    Copyright (C) 2016 Libelium Comunicaciones Distribuidas S.L.
    http://www.libelium.com

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

// Put your libraries here (#include ...)

#include <WaspSensorEvent_v30.h>
//Temperatura
float temp;
float humd;
float pres;
float value;

//SIR
uint8_t value2 = 0;
pirSensorClass pir(SOCKET_1);

//Luminosidad
uint32_t luxes = 0;

void setup()
{
  //Temperatura
  
    // Turn on the USB and print a start message
    USB.ON();
    USB.println(F("Start program"));
    
    // Turn on the sensor board
    Events.ON();

  //SIR
    // Turn on the USB and print a start message
    USB.ON();
    USB.println(F("Start program"));
    
    // Turn on the sensor board
    Events.ON();
      
    // Firstly, wait for PIR signal stabilization
    value2 = pir.readPirSensor();
    while (value2 == 1)
    {
      USB.println(F("...wait for PIR stabilization"));
      delay(1000);
      value2 = pir.readPirSensor();    
    }
    
    // Enable interruptions from the board
    Events.attachInt();

  //Luminosidad
    // Turn on the USB and print a start message
    USB.ON();
    USB.println(F("Start program"));  
    
    // Turn on the sensor board
    Events.ON();  

}


void loop()
{
  //Temperatura
  
     ///////////////////////////////////////
    // 1. Read BME280 Values
    ///////////////////////////////////////
    //Temperature
    temp = Events.getTemperature();
    //Humidity
    humd = Events.getHumidity();
    //Pressure
    pres = Events.getPressure();
    
    ///////////////////////////////////////
    // 2. Print BME280 Values
    ///////////////////////////////////////
    USB.println("-----------------------------");
    USB.print("Temperature: ");
    USB.printFloat(temp, 2);
    USB.println(F(" Celsius"));
    USB.print("Humidity: ");
    USB.printFloat(humd, 1); 
    USB.println(F(" %")); 
    USB.print("Pressure: ");
    USB.printFloat(pres, 2); 
    USB.println(F(" Pa")); 
    USB.println("-----------------------------");
    
    ///////////////////////////////////////
    // 3. Go to deep sleep mode
    ///////////////////////////////////////
    USB.println(F("enter deep sleep"));
    PWR.deepSleep("00:00:00:10", RTC_OFFSET, RTC_ALM1_MODE1, ALL_OFF);
    USB.ON();
    USB.println(F("wake up\n"));

  //SIR
    ///////////////////////////////////////
    // 1. Read the sensor level
    ///////////////////////////////////////
    // Read the PIR Sensor
    value2 = pir.readPirSensor();
    
    // Print the info
    if (value == 1) 
    {
      USB.println(F("Sensor output: Presence detected"));
    } 
    else 
    {
      USB.println(F("Sensor output: Presence not detected"));
    }  
    
    ///////////////////////////////////////
    // 2. Go to deep sleep mode
    ///////////////////////////////////////
    USB.println(F("enter deep sleep"));
    PWR.deepSleep("00:00:00:10", RTC_OFFSET, RTC_ALM1_MODE1, SENSOR_ON);
    USB.ON();
    USB.println(F("wake up\n"));  
    
    ///////////////////////////////////////
    // 3. Check Interruption Flags
    ///////////////////////////////////////
      
    // 3.1. Check interruption from RTC alarm
    if (intFlag & RTC_INT)
    {
      USB.println(F("-----------------------------"));
      USB.println(F("RTC INT captured"));
      USB.println(F("-----------------------------"));
  
      // clear flag
      intFlag &= ~(RTC_INT);
    }
    
    // 3.2. Check interruption from Sensor Board
    if (intFlag & SENS_INT)
    {
      // Disable interruptions from the board
      Events.detachInt();
      
      // Load the interruption flag
      Events.loadInt();
      
      // In case the interruption came from PIR
      if (pir.getInt())
      {
        USB.println(F("-----------------------------"));
        USB.println(F("Interruption from PIR"));
        USB.println(F("-----------------------------"));
      }    
      
      // User should implement some warning
      // In this example, now wait for signal
      // stabilization to generate a new interruption
      // Read the sensor level
      value2 = pir.readPirSensor();
      // Print the info
    if (value2 == 1) 
    {
      USB.println(F("Sensor output: Presence detected"));
    } 
    else 
    {
      USB.println(F("Sensor output: Presence not detected"));
    }  
    
      while (value2 == 1)
      {
        USB.println(F("...wait for PIR stabilization"));
        delay(1000);
        value2 = pir.readPirSensor();
      }
      
      // Clean the interruption flag
      intFlag &= ~(SENS_INT);
      
      // Enable interruptions from the board
      Events.attachInt();
    }  

    //Iluminosidad

      // Part 1: Read Values
      // Read the luxes sensor 
      // Options:
      //    - OUTDOOR
      //    - INDOOR
      luxes = Events.getLuxes(INDOOR);  
       
      // Part 2: USB printing
      // Print values through the USB
      USB.print(F("Luxes: "));
      USB.print(luxes);
      USB.println(F(" lux"));
      delay(1000);  

}
