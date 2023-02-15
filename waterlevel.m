function [water] = waterlevel(resevior_height)
% misst den Wasserstand im Behälter
% Version 0.1
% Test-Cases:

%Misst die Distanz zum Wasserspiegel & gibt höhe vom Wasser aus
distance=readDistance(ultrasonicObj);
water=resevior_height-distance;

end