function [] = LCD_update(reservoir_height,water,moisture,light_time,arduinoObj)
%reservoir_height,water,moisture,light_time,

% Function zum Update des LCD_Screen 
% Version 0.1
% Test-Cases:

%Testparamet
% reservoir_height=0.6;
% water=0.3;
% moisture=40;
% light_time=7200;
% arduinoObj=arduino();

% Debugging
disp("LCD update geöffnet");

%{
%Füllstand in % berechnen und als String
str_filling=num2str(round(water/reservoir_height*100,0))+"%";

%Lichtzeit in h und als String
str_light=num2str(round(light_time/3600,0)) +"h";

%Feuchtigkeit als string
str_moisture=num2str(moisture)+"%";

%Strings für zweite Zeile basteln
%Feuchtigkeit als string und immer gleich lang (4 chars)
% str_moisture=num2str(moisture);
% if strlength(str_moisture) == 1
%     str_moisture = str_moisture + " % ";
% elseif strlength(str_moisture) == 2
%     str_moisture = str_moisture + " %";
% end
% 
% %Immer gleich langer String generieren (4 chars)
% if strlength(str_filling) == 1
%     str_filling = str_filling + " % ";
% elseif strlength(str_filling) == 2
%     str_filling = str_filling + " %";
% end
% %Immer gleich langer String generieren (4 chars)
% if strlength(str_light) == 1
%     str_light = str_light + " h ";
% elseif strlength(str_light) == 2
%     str_light = str_light + " h";
% end
% 
% str_values=str_filling + "  " + str_moisture + "   " + str_light


%Objekte LCD-Screen definieren
LCD_Screen=groveLCD(arduinoObj);
switchON(LCD_Screen);
clearLCD(LCD_Screen);

%Schreiben auf erste Linie (Titel)
homeLCD(LCD_Screen);
str_titles='H20   Soil   Sun';
writeLCD(LCD_Screen,convertStringsToChars(str_titles))

%Schreiben der Werte auf die zweite Linie
setCursorLCD(LCD_Screen,2,1)
writeLCD(LCD_Screen,convertStringsToChars(str_filling))
setCursorLCD(LCD_Screen,2,7)
writeLCD(LCD_Screen,convertStringsToChars(str_moisture))
setCursorLCD(LCD_Screen,2,14)
writeLCD(LCD_Screen,convertStringsToChars(str_light))

clear LCD_Screen
%}
end

