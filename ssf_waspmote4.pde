#include <WaspSensorEvent_v30.h>

// Variables globales
float temp;
uint8_t pirValue = 0;
uint32_t luxes = 0;
pirSensorClass pir(SOCKET_1);

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
    
    // Habilita las interrupciones
    Events.attachInt();
}

void loop() {
    //temperatura
    temp = Events.getTemperature();
    USB.println("-----------------------------");
    USB.print("La temperatura es de: ");
    USB.printFloat(temp, 2);
    USB.println(F(" Celsius"));
    USB.print("Hace ");
    if (temp > 25) {
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
