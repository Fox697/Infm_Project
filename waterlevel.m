function [water] = waterlevel(arduinoObj,resevior_height)
% misst den Wasserstand im Behälter
% Version 0.1
% Test-Cases:

%Misst die Distanz zum Wasserspiegel & gibt höhe vom Wasser aus

% Debugging
% disp("waterlevel geöffnet");
% water = 1;
% disp(water);

ultrasonicObj=ultrasonic(arduinoObj,"D6");
distance=readDistance(ultrasonicObj);
water=resevior_height-distance;

end