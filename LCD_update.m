function [] = LCD_update()
% Function zum Update des LCD_Screen 
% Version 0.1
% Test-Cases:

%Scan I2CBus
%devBus=arduinoObj.scanI2CBus;

%Objekte für Screen definieren
LCDobj=device(arduinoObj,'I2CAddress',0X3E);
RGBobj=device(arduinoObj,'I2CAddress',0X62);

end

