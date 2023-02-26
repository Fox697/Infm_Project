function [brightness, run_time] = light_intensity(arduinoObj,run_time)
% misst die Lichtintensität
% Version 0.1
% Test-Parameter:

% Debugging
%disp("light_intensity geöffnet");
%brightness = 50;
%run_time=run_time+5;

valid=0;
while valid==0
    % Bedingung zum verlassen des Loops setzen
    valid=1;
i=1;
    while i<=6
        %Sensor auslesen und in Matrix speichern
        voltage(i,1) = readVoltage(arduinoObj, "A1");
        %pause(10);
        run_time=run_time+10;
        i=i+1;
    end

    i=1;
    % Referenzspannung bestimmen
    referenz=voltage(6,1);
    while i<=6
        % Alle gemessenen Spannungen mit der Referenz vergleichen
        diff=abs(referenz-voltage(i,1));
        if diff>0.1
            % wenn eine Spannung zu stark abweicht wird die Messung wiederholt
            valid=0;
        end
        i=i+1;
    end
    i=1;
end

% Umrechnen in Prozent
brightness=referenz/3.75*100;



end

