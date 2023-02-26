function [humidity] = humidity()
% misst die Feuchtigkeit in der Erde
% Version: 0.1
% Test-cases: 

% Debugging 
% disp("Humidity geöffnet");
% humidity=50;

voltage = readVoltage(arduinoObj, "A0");
humidity=round(voltage/3.2*100,0);

end