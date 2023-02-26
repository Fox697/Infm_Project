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
humiditiy_upper_limit = 50;      % oberer Grentwert für die Feuchtigkeit
reservoir_height = 2;   % Höhe von Behälter (in Meter)
light_limit = 8;          % Grenzwert für Lichtintensität
time_limit_h = 0.05;        % Grenzwert für Sonnenstunden in Stunden
water_time = 5;           % Zeitdauer eines "Giess-Intervalls" in Sekunden
time_delay = 5;


% GUI-Parameter
% humidity_lower_limit = app.untererGrenzwertistEditField.Value;     
% humidity_upper_limit = app.obererGrenzwertistEditField.Value;      
% reservoir_height = app.BehlterhoeheEditField.Value;   
% light_limit = app.DmmerungEditField.Value;          
% time_limit_h = app.tglicheSonnenstundenistEditField.Value;        
% water_time = app.ZeitdauerBewaesserungEditField.Value; 


% Debugging;
% disp("humidity lower limit: "+humidity_lower_limit);
% disp("humidity upper limit: "+humiditiy_upper_limit);
% disp("reservoir height: "+reservoir_height);
% disp("light limit: "+light_limit);
% disp("time limit: "+time_limit_h);
% disp("water time: "+water_time);

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
%arduinoObj = 1;
arduinoObj = arduino("COM7", "Leonardo");
configurePin(arduinoObj, "A0", "AnalogInput");
configurePin(arduinoObj, "A1", "AnalogInput");
configurePin(arduinoObj, "D6", "PWM");
configurePin(arduinoObj, "D2", "DigitalOutput");

% Umrechnung der Benutzerparameter
time_limit = time_limit_h*60*60;       % Umrechnung von Stunden in Sekunden 
water_limit_1 = reservoir_height*0.5;  % erster Grenzwert für 50% Füllstand
water_limit_2 = reservoir_height*0.05; % zweiter Grenzwert für 5% Füllstand
disp("water limit 1: "+water_limit_1);
disp("water limit 2: "+water_limit_2);


while (1)                        % Main-loop
    disp("Main loop geöffnet");
    %while(run_time<=(24*60*60))      % wird nach 24h zurückgesetzt
        water=waterlevel(arduinoObj);       % Auftruf der Wasserstand-Mess-Function
        if water < water_limit_2            % Wenn Wasserstand <5% LCD updaten und nicht giessen
            LCD_update(reservoir_height,water,moisture,light_time,arduinoObj);

        elseif water>=water_limit_1         % Wenn Wasserstand >=50% Feuchtigkeit messen
            moisture=humidity();
            if moisture <= humidity_lower_limit     % Wenn Feuchtigkeit unter dem unteren Grentwert liegt Bewässern
                run_time=watering(humiditiy_upper_limit,water_time,run_time);
            end
            
        else                        % Ansonsten LCD updaten und Feuchtigkeit messen
            moisture=humidity();
            if moisture <= humidity_lower_limit     % Wenn Feuchtigkeit unter dem unteren Grentwert liegt Bewässern
                run_time=watering(humiditiy_upper_limit,water_time,run_time);
            end
            LCD_update(reservoir_height,water,moisture,light_time,arduinoObj);
        end

        if light==0                       %überprüft Lichtintensität wenn die Lampe aus ist
            [brightness, run_time]=light_intensity(run_time);
            if brightness<light_limit && run_time<time_limit     % betritt die Bedingung wenn die Lichtintensität zu gering ist
                  light=1;                % Licht ein und Merker setzen
                  writeDigitalPin(arduinoObj, "A0",1);
                  disp("Lampe ein");
            end
        end

         if light==1 && run_time>time_limit
             light=0;                % Licht aus und Merker setzen
                  writeDigitalPin(arduinoObj, "A0",0);
                  disp("Lampe aus");
        end
        
        disp("Main loop Ende erreicht");
        pause(time_delay);
        run_time=run_time+time_delay;
        LCD_update(reservoir_height,water,moisture,light_time,arduinoObj);
       
    %end
    %writeDigitalPin(arduinoObj, "D2",1);        % D2 auf "reset" Pin verbinden, reseted den Arduino nach einem Tag
end
