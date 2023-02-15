function [] = watering(humidity_limit)
% Function für das Bewässern
% Version 0.1
% Test cases:

% öffnet das Bewässerungsventil wenn die Feuchtigkeit unter dem Grenzwert
% liegt, bewässert 5 Sekunden, wartet 60 um das Wasser zu verteilen, 
% führt eine erneute Messung durch und wiederholt das bis der Grenzwert
% erreicht wurde
moisture=0;
while(moisture<humidity_limit)
    writeDigitalPin(arduinoObj, "A0",1);
    pause(5);
    writeDigitalPin(arduinoObj, "A0",0)
    pause(60);
    moisture=humidity();
end

end

