function [humidity] = humidity(arduinoObj)
% misst die Feuchtigkeit in der Erde
% Version: 0.1
% Test-cases: 

% Debugging 
% disp("Humidity geöffnet");
% humidity=50;

voltage = readVoltage(arduinoObj, "A0");
humidity=round(voltage/3.2*100,0);
if humidity > 100
humidity = 100;
end

end