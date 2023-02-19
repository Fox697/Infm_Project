% Projekt Infm_1
% 15.02.2023
% Beat Peter
% Ryan Meyer
% Version 0.1

% Das Programm überwacht die Feuchtigkeit und die Sonnenstunden einer
% Pflanze. Bei zu geringer Feuchtigkeit in der Erde wird eine automatische
% Bewässerung gestartet. Parallel werden die Sonnenstunden gezählt. Wird es
% zu dunkel und die voreingestellten Stunden sind noch nicht erreicht, wird
% eine Lampe aktiviert. Nach jeweils 24h wird der Arduino zurückgesetzt.


%Benutzerparameter
humidity_lower_limit = 30;      % unterer Grenzwert für die Feuchtigkeit, Wert 0-100
humidtiy_upper_limit = 50;      % oberer Grentwert für die Feuchtigkeit
reservoir_height = 0.5;   % Höhe von Behälter (in Meter)
light_limit = 8;          % Grenzwert für Lichtintensität
time_limit_h = 12;        % Grenzwert für Sonnenstunden in Stunden
water_time = 5;           % Zeitdauer eines "Giess-Intervalls" in Sekunden



% Aschlüsse: 
% Input: A0 = Feuchtigkeitssensor, A1 = Lichtsensor, D6 = Ultraschall
% Output: I2C = LCD, D5 = Ventil, D2 Ausgang für Reset

% Variablen
run_time=0;         % timestamp zum Speichern der Laufzeit
light_time=0;        % Zeit wie lange Licht vorhanden war 
moisture=0;       % enthält die gemessene Fechtigkeit
light=0;           % Logisches 1 für Lampe eingeschaltet
brightness=0;       % enthält die gemessene Lichtintensität
water=0;          % enhält Wasserstand

% Anschlüsse definieren
arduinoObj = arduino("COM7", "Leonardo");
configurePin(arduinoObj, "A0", "AnalogInput");
configurePin(arduinoObj, "A1", "AnalogInput");
configurePin(arduinoObj, "D6", "PWM");
configurePin(arduinoObj, "D2", "DigitalOutput");

% Umrechnung der Benutzerparameter
time_limit = time_limit_h*60*60;       % Umrechnung von Stunden in Sekunden 
water_limit_1 = reservoir_height*0.5;  % erster Grenzwert für 50% Füllstand
water_limit_2 = reservoir_height*0.05; % zweiter Grenzwert für 5% Füllstand


while (1)                        % Main-loop
    while(run_time<=(24*60*60))      % wird nach 24h zurückgesetzt
        water=waterlevel(arduinoObj);       % Auftruf der Wasserstand-Mess-Function
        if water < water_limit_2            % Wenn Wasserstand <5% LCD updaten und nicht giessen
            LCD_update(reservoir_height,water,moisture,light_time,arduinoObj);

        elseif water>=water_limit_1         % Wenn Wasserstand >=50% Feuchtigkeit messen
            moisture=humidity(arduinoObj);
            watering(humidity_lower_limit,water_time);
            
        else                        % Ansonsten LCD updaten und Feuchtigkeit messen
            LCD_update(reservoir_height,water,moisture,light_time,arduinoObj);
            watering(humidity_lower_limit,water_time,arduinoObj);
        end

        if light==0                       %überprüft Lichtintensität
            brightness=light_intensity;
            if brightness<light_limit || light==1       % betritt die Bedingung wenn die Lichtintensität zu gering ist
                if run_time<time_limit
                    light=1;                % Licht ein und Merker setzen
                    writeDigitalPin(arduinoObj, "A0",1);
                else
                    light=0;
                    writeDigitalPin(arduinoObj, "A0",0);
                end
            end
        end
        
        pause(3600);
        run_time=temporalCount(sec);
        LCD_update(reservoir_height,water,moisture,light_time,arduinoObj);
       
    end
    writeDigitalPin(arduinoObj, "D2",1);        % D2 auf "reset" Pin verbinden, reseted den Arduino nach einem Tag
end
