#include <WaspSensorEvent_v30.h>
#include <WaspWIFI_PRO_V3.h>

// Variables
float tempe;
uint8_t pirValue = 0;
uint32_t luxes = 0;
pirSensorClass pir(SOCKET_1);
uint8_t socket = SOCKET0;
uint8_t error;
uint8_t status;
unsigned long previous;

// WiFi AP settings (CHANGE TO USER'S AP)
char SSID[] = "G203";
char PASSW[] = "test1234";



void setup() {
    // Inicializa la comunicación USB
    USB.ON();
    USB.println(F("Programa empezando..."));
    
    // Enciende la placa de sensores
    Events.ON();

    //PIR
    pirValue = pir.readPirSensor();
    while (pirValue == 1) {
        USB.println(F("...esperando a la estabilización del PIR"));
        delay(1000);
        pirValue = pir.readPirSensor();
    }
    
  

    //WIFI 1
    error = WIFI_PRO_V3.ON(socket);
    if (error == 0){
      USB.println(F("1. WiFi switched ON"));
    }else{
      USB.println(F("1. WiFi did not initialize correctly"));
    }


    // 2. Reset to default values
    error = WIFI_PRO_V3.resetValues();
  
    if (error == 0){
      USB.println(F("2. WiFi reset to default"));
    }else{
      USB.print(F("2. WiFi reset to default error: "));
      USB.println(error, DEC);
    }
  
//    //3. Configure mode (Station or AP)
    error = WIFI_PRO_V3.configureMode(WaspWIFI_v3::MODE_STATION);
  
    if (error == 0){
      USB.println(F("3. WiFi configured OK"));
    }else{
      USB.print(F("3. WiFi configured error: "));
      USB.println(error, DEC);
    }
  
    // get current time
    previous = millis();
  
    // 4. Configure SSID and password and autoconnect
    error = WIFI_PRO_V3.configureStation(SSID, PASSW, WaspWIFI_v3::AUTOCONNECT_ENABLED);
  
    if (error == 0){
      USB.println(F("4. WiFi configured SSID OK"));
    }else{
      USB.print(F("4. WiFi configured SSID error: "));
      USB.println(error, DEC);
    }
  
  
    if (error == 0){
      USB.println(F("5. WiFi connected to AP OK"));
  
      USB.print(F("SSID: "));
      USB.println(WIFI_PRO_V3._essid);
      
      USB.print(F("Channel: "));
      USB.println(WIFI_PRO_V3._channel, DEC);
  
      USB.print(F("Signal strength: "));
      USB.print(WIFI_PRO_V3._power, DEC);
      USB.println("dB");
  
      USB.print(F("IP address: "));
      USB.println(WIFI_PRO_V3._ip);
  
      USB.print(F("GW address: "));
      USB.println(WIFI_PRO_V3._gw);
  
      USB.print(F("Netmask address: "));
      USB.println(WIFI_PRO_V3._netmask);
  
      WIFI_PRO_V3.getMAC();
  
      USB.print(F("MAC address: "));
      USB.println(WIFI_PRO_V3._mac);
    }else{
      USB.print(F("5. WiFi connect error: "));
      USB.println(error, DEC);
  
      USB.print(F("Disconnect status: "));
      USB.println(WIFI_PRO_V3._status, DEC);
  
      USB.print(F("Disconnect reason: "));
      USB.println(WIFI_PRO_V3._reason, DEC);
    }
       // Habilita las interrupciones
    Events.attachInt();    
}




void loop() {
    //temperatura
    tempe = Events.getTemperature();
    USB.println("-----------------------------");
    USB.print("La temperatura es de: ");
    USB.printFloat(tempe, 2);
    USB.println(F(" Celsius"));
    USB.print("Hace ");
    if (tempe > 25) {
        USB.println("mucho calor");
    } else {
        USB.println("mucho frio");
    }

    //luminosidad
    luxes = Events.getLuxes(INDOOR);
    USB.println("-----------------------------");
    USB.print(F("Cantidad de Luxes: "));
    USB.print(luxes);
    USB.println(F(" lux"));
    
    // Mensaje que devuleve según los luxes
    if (luxes > 300) {
        USB.println(F("Apagar las luces, hay alta luminosidad"));
    } else {
        USB.println(F("Encender las luces, hay baja luminosidad"));
    }

    //PIR
    pirValue = pir.readPirSensor();
    USB.println("-----------------------------");
    if (pirValue == 1) {
        USB.println(F("Output del sensor: Presencia detectada"));
    } else {
        USB.println(F("Output del sensor: Presencia no detectada"));
    }
    
    // Entra en modo de sueño profundo
    USB.println(F("Entrando en modo de sueño profundo"));
    PWR.deepSleep("00:00:00:10", RTC_OFFSET, RTC_ALM1_MODE1, ALL_OFF);
    USB.ON();
    USB.println(F("Despertando\n"));
    
    // Comprueba las banderas de interrupción
    if (intFlag & RTC_INT) {
        USB.println(F("RTC INT capturada"));
        intFlag &= ~(RTC_INT);
    }
    if (intFlag & SENS_INT) {
        Events.detachInt();
        Events.loadInt();
        if (pir.getInt()) {
            USB.println(F("Interrupción desde PIR"));
        }
        pirValue = pir.readPirSensor();
        while (pirValue == 1) {
            USB.println(F("...esperando a que el PIR se estabilice"));
            delay(1000);
            pirValue = pir.readPirSensor();
        }
        intFlag &= ~(SENS_INT);
        Events.attachInt();
    }
    
    delay(1000);
    
}
