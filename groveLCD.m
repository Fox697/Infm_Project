classdef groveLCD
    %
    % Aufruf: groveLCD(Arduino_Instanz)
    %         z.B.:   Arduino_Instanz = arduino();
    %
    % Autor:  Norbert Hofmann, 13.7.2021, 
    %         Fachhochschule Nordwestschweiz (FHNW), Institut ITFE
    %
    % Zweck:  Grove-LCD RGB Backlight 4.0 ansteuern mit Text in 2 Zeilen und
    %         Hintergrundfarbe einstellen
    %
    % Quelle: rgb_lcd.cpp und rgb_lcd.cpp der Arduino C++ Bibliothek von Grove
    %         CGROM	10880 bit
    %         CGRAM	64x8 bit
    %         LCD I2C Address	0X3E   LCD Eingabe
    %         RGB I2C Address	0X62   Backlight Color
    %
    % Funktionen:
    %         - groveLCD(<Arduino-Objekt>)         Erstellen LCD-Instanz
    %         - <LCD> = groveLCD(Arduino_Instanz) <LCD-Objekt zum 
    %                                             Initialisieren und
    %                                             Starten des LCD und Backlight
    %         - writeLCD(<LCD>,CharVektor)        Schreiben des CharVektors
    %         - clearLCD(<LCD>)                   Löschen des LCD-Displays
    %         - homeLCD(<LCD>)                    Cursor nach links oben setzen
    %         - setCursorLCD(<LCD>, Reihe,Spalte) Cursor in Reihe und Spalte setzen
    %         - setRGBLCD(<LCD>, r,g,b)           Hintergrundlicht setzen
    %
    %
    % Programmier-Hinweis: 
    %         - Achtung immer "uint8" beim Schreiben auf I2C-Bus verwenden!
    %         - Object obj muss übergeben werden, damit das <Arduino-Objekt> referenziert ist
    % 
    %         - Zeitaufwand ca. 30 Stunden mit Testen 
    %           - C++ (wire.cpp,rgb_lcd.cpp) nach MATLAB
    %           - Umstellung OO, Tests, Dokumentation
    %           - Fehlerabfrage
    %   
    %         - Singleton Pattern nicht implementiert. Es können zwei Instanzen erzeugt werden.
    %           Dies generiert einen "Error".
    

        %% Definition der Background Colors    
        properties (Constant)
            % PWM (Puls Width Modulate) für Farben
            REG_RED                 = uint8(hex2dec('0x04')); % pwm2
            REG_GREEN               = uint8(hex2dec('0x03')); % pwm1
            REG_BLUE                = uint8(hex2dec('0x02')); % pwm0
            % Darstellungsmoden für die Initialisierung
            REG_MODE1               = uint8(hex2dec('0x00'));
            REG_MODE2               = uint8(hex2dec('0x01'));
            REG_OUTPUT              = uint8(hex2dec('0x08'));
        end

        %% Kommandos für den LCD-Display
        properties (Constant)
            LCD_CLEARDISPLAY        = uint8(hex2dec('0x01'));
            LCD_RETURNHOME          = uint8(hex2dec('0x02'));
            LCD_ENTRYMODESET        = uint8(hex2dec('0x04'));
            LCD_DISPLAYCONTROL      = uint8(hex2dec('0x08'));
            % LCD_CURSORSHIFT 0x10
            LCD_FUNCTIONSET         = uint8(hex2dec('0x20'));
            LCD_DISPLAYON           = uint8(hex2dec('0x04'));
            LCD_CURSOROFF           = uint8(hex2dec('0x00'));
            LCD_BLINKOFF            = uint8(hex2dec('0x00'));
            % LCD_SETDDRAMADDR 0x80
        end

        %% Flags für LCD Mode
        properties (Constant)
            % Flags für LCD Entry Mode
            LCD_ENTRYLEFT           = uint8(hex2dec('0x02'));
            LCD_ENTRYSHIFTDECREMENT = uint8(hex2dec('0x00'));
            % 
            % Flags für die Funktion des LCD  
            LCD_8BITMODE            = uint8(hex2dec('0x10'));
            LCD_2LINE               = uint8(hex2dec('0x08'));
            LCD_5x8DOTS             = uint8(hex2dec('0x00'));    
        end

        %% Variablen für LCD und Back-Light
        properties 
            dev1LCD 
            dev2Light 
            LCD_ADDRESS     {mustBeNumeric}
            RGB_ADDRESS     {mustBeNumeric}   
            %% Alternativ: Device I2C fixe Adresse setzen
            % LCD_ADDRESS = bitshift(hex2dec('0x7c'),-1); %(0x7c>>1) = 62 (Dec)
            % RGB_ADDRESS = bitshift(hex2dec('0xc4'),-1); %(0xc4>>1) = 98 (Dec)
            displayfunction {mustBeNumeric}
            displaycontrol  {mustBeNumeric}
            displaymode     {mustBeNumeric}
            
            arduinoInstanz % ?
        end

    %% Initialisierung für den Start des Displays    

        methods % Konstruktor und Testabfragen
            %% Constructor
            function obj = groveLCD(arduinoOBJ)
                fprintf('\n\n DEN ANSCHLUSS D2 oder D3 NICHT VERWENDEN, anstonst läuft der LCD NICHT! \n \n');
                
                if nargin == 0
                    disp(' Keine Arduino Object übergeben!'); disp('Aufruf groveLCD(arduinoOBJ)');
                elseif isempty(arduinoOBJ)
                    disp(' Arduino Object ist leer!');        disp('Aufruf groveLCD(arduinoOBJ)');
                elseif ~strcmp(arduinoOBJ.Libraries{1},'I2C') % Achtung: Könnte auch an Pos 2 stehen
                   disp(' Arduino hat kein I2C Interface;');
                else
                    % I2C Bus lesen
                    I2CBusAdresse = scanI2CBus(arduinoOBJ,0);

                    %% Device LCD und Licht Adressieren bestimmen und belegen
                    obj.dev1LCD     = device(arduinoOBJ,'I2CAddress',I2CBusAdresse{1});
                    obj.LCD_ADDRESS = obj.dev1LCD.I2CAddress;
                    obj.dev2Light   = device(arduinoOBJ,'I2CAddress',I2CBusAdresse{2});
                    obj.RGB_ADDRESS = obj.dev2Light.I2CAddress;     

                    if obj.LCD_ADDRESS ~= 62
                       disp(' LCD Display hat ein anderes I2C Interface');
                    elseif obj.RGB_ADDRESS ~= 98
                       disp(' LCD Display Backlight hat ein anderes I2C Interface');
                    else
                        % Haupt-Fehler abgefangen
                        % Initialisierung für den Start des Displays
                        obj.displayfunction = obj.LCD_2LINE;
                        obj.displaycontrol  = bitor(obj.LCD_DISPLAYON,bitor(obj.LCD_CURSOROFF,obj.LCD_BLINKOFF));
                    end % Ende LCD_ADDRESS ~= 62
                end % Ende nargin == 0
            end % Ende des Constructors groveLCD
        end % Ende Methode 1


        methods % Grove-LCD initialsieren
            %% LCD und Background starten und initialisieren
            function obj = switchON(obj)
                %% LCD einschalten
                commandLCD(obj, bitor(obj.LCD_FUNCTIONSET,obj.displayfunction));    % 1. LCD_FUNCTIONSET 
                % pause(0.1); % Dauert lange
                commandLCD(obj, bitor(obj.LCD_FUNCTIONSET,obj.displayfunction));    % 2. LCD_FUNCTIONSET 
                % pause(0.1); % Dauert lange

                %% Display einstellen
                % Setting displaycontrol: turn the display on with no cursor or blinking default
                obj.displaycontrol = displayLCD(obj, obj.LCD_DISPLAYCONTROL, obj.displaycontrol);  
                clearLCD(obj);                     % Einstellungen des Display zurücksetzen
                % Textrichtung festlegen (Links nach rechts)      
                obj.displaymode = bitor( obj.LCD_ENTRYLEFT , obj.LCD_ENTRYSHIFTDECREMENT) ;
                commandLCD(obj, bitor(obj.LCD_ENTRYMODESET,obj.displaymode));
                homeLCD(obj);                      % LCD RETURN HOME
                commandLCD(obj, obj.LCD_8BITMODE); % LCD 8BIT MODE
                commandLCD(obj, obj.LCD_5x8DOTS);  % LCD 5x8 DOTS

                %% Hintergrundbeleuchtung einstellen
                setRegLCD(obj, obj.REG_MODE1, 0);
                %set LEDs controllable by both PWM and GRPPWM registers
                setRegLCD(obj, obj.REG_OUTPUT, uint8(hex2dec('0xFF')));
                % set MODE2 values
                % 0010 0000 -> 0x20  (DMBLNK to 1, ie blinky mode)
                setRegLCD(obj, obj.REG_MODE2, uint8(hex2dec('0x20')));
                % LCD aus Weiss einstellen
                setRGBLCD(obj, 100,100,100);

 %               blinkLCD(obj); % Lässt LCD blinken
 %               pause(3); noblinkLCD(obj); % Blinken stoppen

            end % Ende function switchON

        end % Ende methods switchON


    methods % Funktionsaufrufe
        % Befehlskommandos LCD absetzen
        function commandLCD(obj,DecBefehl)
            write(obj.dev1LCD,[uint8(hex2dec('0x80')),DecBefehl]);
        end % Ende commandLCD

        function i2c_send_byteLCD(obj,CharBefehl)
            write(obj.dev1LCD,[obj.LCD_ADDRESS,CharBefehl]);
        end % Ende i2c_send_byteLCD
 
        % Schreiben auf das LCD-Display
        function writeLCD(obj,CharBefehl) % Alternative Command Befehl
            write(obj.dev1LCD,[uint8(hex2dec('0x40')),CharBefehl]);
        end % Ende writeLCD

        % Display initialisieren und einschalten
        function displaycontrol = displayLCD(obj, LCD_DISPLAYCONTROL, displaycontrol)
            displaycontrol = bitor(LCD_DISPLAYCONTROL, uint8(displaycontrol));
            commandLCD(obj,displaycontrol);
        end % Ende display

        function displaycontrol = noDisplayLCD(obj, LCD_DISPLAYCONTROL, displaycontrol)
            displaycontrol=bitand(bitcmp(uint8(obj.LCD_DISPLAYON)), uint8(displaycontrol));
            commandLCD(obj, bitand(LCD_DISPLAYCONTROL, displaycontrol) );
        end % Ende noDisplayLCD

        function clearLCD(obj)
            commandLCD(obj,obj.LCD_CLEARDISPLAY);
            pause(0.002); % 2 ms Pause
        end % Ende clearLCD

        function homeLCD(obj)
            commandLCD(obj,obj.LCD_RETURNHOME);
            pause(0.001); % 1 ms Pause
        end % Ende homeLCD

        function setCursorLCD(obj, row,col) 
            if row==1 % Achtung kann auch "0" sein
               col = bitor(col-1,uint8(hex2dec('0x80')));
            else
               col = bitor(col-1,uint8(hex2dec('0xc0')));
            end
            i2c_send_byteLCD(obj,col);
        end % Ende setCursorLCD

        function setRegLCD(obj, Mode, DecValue)
            writeRegister(obj.dev2Light, Mode, DecValue);  
            write(obj.dev2Light,1); % ACHTUNG: 1 sollte Stop sein
        end % Ende setRegLCD

        function setRGBLCD(obj, r,g,b)
            setRegLCD(obj, obj.REG_RED,r);
            setRegLCD(obj, obj.REG_GREEN,g);
            setRegLCD(obj, obj.REG_BLUE,b);
        end % Ende setRGBLCD

        function blinkLCD(obj)
            % blink period in seconds = (<reg 7> + 1) / 24, on/off ratio = <reg 6> / 256
            setRegLCD(obj, uint8(hex2dec('0x07')), uint8(hex2dec('0x17')));  % blink every second
            setRegLCD(obj, uint8(hex2dec('0x06')), uint8(hex2dec('0x7f')));  % half on, half off
        end % Ende blinkLCD

        function noblinkLCD(obj)
            % End Blinking
            setRegLCD(obj, uint8(hex2dec('0x07')), uint8(hex2dec('0x00')));  
            setRegLCD(obj, uint8(hex2dec('0x06')), uint8(hex2dec('0xff')));  
        end % Ende noblinkLCD

        function displaymode = autoscrollLCD(obj,displaymode) % Nicht getestet
            % Autoscroll on
            displaymode = bitor( displaymode, obj.LCD_ENTRYSHIFTDECREMENT ) ;
            commandLCD(objD, bitor(obj.LCD_ENTRYMODESET,uint8(displaymode)));
        end % Ende autoscrollLCD

        function displaymode = noautoscrollLCD(obj,displaymode) % Nicht getestet
            % Autoscroll off
            displaymode = bitand( uint8(displaymode), bitcmp(uint8(obj.LCD_ENTRYSHIFTDECREMENT)) );
            commandLCD(obj, bitor(obj.LCD_ENTRYMODESET,displaymode));
         end % Ende noautoscrollLCD
    end  % Ende der Funktionsaufrufe     

end % Ende der Class groveLCD