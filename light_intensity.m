function [brightness] = light_intensity()
%misst die Lichtintensität

voltage = readVoltage(arduinoObj, "A1");
brightness=voltage/3.75*100;
end

