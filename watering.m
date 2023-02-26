function [run_time] = watering(arduinoObj,humidity_upper_limit,water_time,run_time)
% Function für das Bewässern
% Version 0.1
% Test cases:

% öffnet das Bewässerungsventil wenn die Feuchtigkeit unter dem Grenzwert
% liegt, bewässert 5 Sekunden, wartet 60 um das Wasser zu verteilen, 
% führt eine erneute Messung durch und wiederholt das bis der Grenzwert
% erreicht wurde

% Debugging
% disp("watering geöffnet");
% run_time=run_time+120;

moisture=0;
while(moisture<humidity_upper_limit)
    writeDigitalPin(arduinoObj, "D5",1);
    pause(water_time);
    writeDigitalPin(arduinoObj, "D5",0)
    pause(60);
    moisture=humidity(arduinoObj);
    run_time=run_time+60;
end

end

