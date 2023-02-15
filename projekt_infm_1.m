% Projekt Infm_1
% 15.02.2023
% Beat Peter
% Ryan Meyer
% Version 0.1


%Benutzerparameter
humidity_limit = 30;      %Grenzwert für die Feuchtigkeit, Wert 0-100
water_limit =               % Grenzwert für Wasserpegel
light_limit =               % Grenzwert für Lichtintensität
time_limit_h = 12;          % Grenzwert für Sonnenstunden







% Aschlüsse: 
% Input: A0 = Feuchtigkeitssensor, A1 = Lichtsensor, D6 = Ultraschall
% Output: I2C = LCD, D5 = Ventil

% Variablen
time=0;         % timestamp zum Speichern der Laufzeit
moisture=0;       % enthält die gemessene Fechtigkeit
light=0;           % Logisches 1 für Lampe eingeschaltet
brightness=0;       % enthält die gemessene Lichtintensität
water=0;          % enhält Wasserstand

% Anschlüsse definieren
arduinoObj = arduino("COM7", "Leonardo")
configurePin(arduinoObj, "A0", "AnalogInput");
configurePin(arduinoObj, "A1", "AnalogInput");
configurePin(arduinoObj, "D6", "PWM");

%A0_Humidity = readVoltage(arduinoObj, "A0");
%A1_Light = readVoltage(arduinoObj, "A1");

time_limit = time_limit_h*60*60*1000;       %umrechnung von Stunden in millisekunden 

while (1)                        % Main-loop
    while(time<=(24*60*60*1000))      % wird nach 24h zurückgesetzt
        water=waterlevel;       % Auftruf der Wasserstand-Mess-Function
        if water <  % 5%            % Wenn Wasserstand <5% LCD updaten und nicht giessen
            %screen update

        elseif water>= %50%         % Wenn Wasserstand >=50% Feuchtigkeit messen
            moisture=humidity();
            %watering
            
        else                        % Ansonsten LCD updaten und Feuchtigkeit messen
            %screen update
            moisture=humidity();
        end

        if moisture<=humidity_limit     % Wenn die gemessene Feuchtigkeit den Grenzwert unterschreitet -> giessen
            %watering
            moisture=100;               % Feuchtigkeitg auf 100 setzen um ungewolltes giessen zu verhindern
        end

        if light=0                       %überprüft Lichtintensität
            brightness=light_intensity;
            if brightness<light_limit       % betritt die Bedingung wenn die Lichtintensität zu gering ist
                if time<time_limit
                    light=1;                % Licht ein und Merker setzen
                    writeDigitalPin(arduinoObj, "A0",1);
                else
                    light=0;
                    writeDigitalPin(arduinoObj, "A0",0);
                end

    






    end
    time=0;
end
