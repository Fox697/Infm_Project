%
% Aufruf: groveLCD_Demo
%
% Autor:  Norbert Hofmann, 4.1.2023, 
%         Fachhochschule Nordwestschweiz (FHNW), Institut ITFE
%
% Zweck:  Grove-LCD RGB Backlight 4.0 ansteuern mit Text in 2 Zeilen und
%         Hintergrundfarbe einstellen
% Tests:  4.1.2023 mit MATLAB 2022b und groveLCD vom 4.1.2023
%
% Class: groveLCD (Datei: groveLCD.m)
%
% Funktionen:
%         - groveLCD(<Arduino-Objekt>)         Erstellen LCD-Instanz
%         - <LCD> = groveLCD(Arduino_Instanz)  <LCD-Objekt> zum Initialisieren und Starten des LCD und Backlight
%         - writeLCD(<LCD>,CharVektor)         Schreiben des CharVektors
%         - clearLCD(<LCD>)                    Löschen des LCD-Displays
%         - homeLCD(<LCD>)                     Cursor nach links oben setzen
%         - setCursorLCD(<LCD>, Reihe,Spalte)  Cursor in Reihe und Spalte setzen
%
%         - setRGBLCD(<LCD>, r,g,b)           Hintergrundlicht setzen
%
% Hardware Anschlüsse
%         - LCD an I2C-Bus
%         - Thermistor an A1

% Hinweis: Die Datei groveLCD.m muss im Suchpfad ausfindbar sein

%% Programmstart
clear;                      % Alte Arduino-Objekte löschen

%% Überprüfung, ob groveLCD im Suchpfad ist
if isempty( which('groveLCD') )
    disp(' ERROR: MATLAB Klasse/Function groveLCD befindet sich nicht im Suchverzeichnis oder aktuellen Verzeichnis!')
    disp(' ')
    disp([' 1. Variante: Kopieren Sie groveLCD.m in das aktuelle Verzeichnis: ',pwd])
    disp( ' 2. Variante: Setzen Sie mit Home -> Button Set Path -> Add Folder ->  auf das Verzeichnis mit groveLCD.m')
    disp(' ');    disp(' '); disp(' Das Program wird gestoppt');    disp(' ');
    return
end

%% Initialisierung des Arduino Boards
try
    ArduinoLeo = arduino( ); % Ohne diese Variable ist das Arduino nicht ansprechbar
catch
    disp('Eine Arduino Instanz ist vorhanden'); disp('Bitte Workspace Variabel für Arduino löschen!')
    return
end % Ende von try


%% LCD initialisieren und starten
LCD = groveLCD(ArduinoLeo); % Grove-LCD initialsieren
switchON(LCD);              % Grove-LCD und Back-Light starten
setRGBLCD(LCD,255,0,255); % Hintergrundfarbe auf (r,g,b) weiss setzen

%% Eigenes Programm für LCD beschreiben
tic;

while toc < 10
    Val=1024/5*readVoltage(ArduinoLeo, 'A1');         % Thermischer Widerstand an Pin A0 auslesen
    Widerstand=(1023-Val)*10000/(Val);                % Elektrischer Widerstand
    B=3975;                                           % B Wert des Thermistor
    Temp=1/(log(Widerstand/10000)/B+1/298.15)-273.15; % Berechnete Temperatur

    setCursorLCD(LCD,1,1);      % Cursor in Zeile 2 und Spalte 4 positionieren
    writeLCD( LCD, num2str(Temp,'Temp = %4.1f [C]') ); 
    setCursorLCD(LCD,2,1);      % Cursor in Zeile 2 und Spalte 4 positionieren
    writeLCD( LCD, num2str(toc, 'Zeit = %4.1f [s]') ); 
end

% Messung beenden
setCursorLCD(LCD,2,1);          % Cursor in Zeile 2 und Spalte 4 positionieren
writeLCD( LCD, 'Ende der Messung' ); 

clear;                          % Alte Arduino-Objekte löschen 



