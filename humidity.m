function [humidity] = humidity()
% misst die Feuchtigkeit in der Erde
%   
voltage = readVoltage(arduinoObj, "A0");
humidity=voltage/3.2*100;
end