function [brightness] = light_intensity()
% misst die Lichtintensität
% Version 0.1
% Test-Parameter:

while valid==0
    for i=1, i<=6, i++
voltage[i,1] = readVoltage(arduinoObj, "A1");
    end

    i=1;
    referenz=voltage(6,1)

    for i=1, i<6, i++
        diff=abs(referenz-voltage(i,1));
        if diff>0.3
            valid=0;
        end
    end
end

brightness=voltage/3.75*100;
end

