function [brightness] = light_intensity()
% misst die Lichtintensität
% Version 0.1
% Test-Parameter:

% Debugging
disp("light_intensity geöffnet");

%{
while valid==0
    valid=1;            % Bedingung zum verlassen des Loops setzen
    for i=1, i<=6, i++
        voltage[i,1] = readVoltage(arduinoObj, "A1");       %Sensor auslesen und in Matrix speichern
        pause(10);      % Delay
    end

    i=1;
    referenz=voltage(6,1)           % Referenzspannung bestimmen
    for i=1, i<6, i++
        diff=abs(referenz-voltage(i,1));        % Alle gemessenen Spannungen mit der Referenz vergleichen
        if diff>0.3             % wenn eine Spannung zu stark abweicht wird die Messung wiederholt
            valid=0;
        end
    end
end

brightness=referenz/3.75*100;       % Umrechnen in Prozent

%}
end

