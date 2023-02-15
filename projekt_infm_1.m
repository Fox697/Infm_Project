% Projekt Infm_1
% 15.02.2023
% Beat Peter
% Ryan Meyer
% Version 0.1


% Aschlüsse: 
% Input: A0 = Feuchtigkeitssensor, A1 = Lichtsensor, D6 = Ultraschall
% Output: I2C = LCD, D5 = Ventil

% Variablen

time;         % timestamp zum Speichern der Laufzeit
moisture;       % enthält die gemessene Fechtigkeit
light;           % enthält die gemessene Lichtintensität
water;          % enhält Wasserstand


while (1)        % Main-loop
    while(time<=(24*60*60))      % wird nach 24h zurückgesetzt
        water=waterlevel;       % Auftruf der Wasserstand-Mess-Function
        if water<  % 50%            % Wenn Wasserstand >50% Ventil ansteuern, <50% LCD update und giessen
            %screen update

        if




    end
    time=0;
end
