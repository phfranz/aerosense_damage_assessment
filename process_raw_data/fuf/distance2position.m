 function [zsens,tsens,nsens] = distance2position(Lsens,zsens0,wing)
% distance2position gives the positions of the sensors on the given wing
% the leading edge (0,0) must be present, as well as the trailing edge
% (1,0). chord=1.
% wing must start at the trailing edge goes at leading edge and finishes at
% trailing edge
% input: 
%       Lsens: distance from sensor isen0 positionned at zsens0. we
%       should have Lsens(isen0)=0.
%       isens0: number of the sensor where we know the position zsens0
%       (start at 1 as in Matlab)
%       wing: points defining the blade in complex coordinate
% output: 
%        zsensor: position of the sensor on the wing
%        nsens normal of each sensor
%        tsens: tangent of each sensor
%
% written by Julien Deparday 
%
%%%
  
if isreal(zsens0)
     if size(zsens0,1) > size(zsens0,2)
       i0 = knnsearch(c2m(wing.')',zsens0');
     elseif size(zsens0,1) < size(zsens0,2)
       i0 = knnsearch(c2m(wing.')',zsens0');
     else 
      i0 = knnsearch(c2m(wing.')',[zsens0 zsens0]);
   end
else
    i0 = knnsearch(c2m(wing.')',c2m(zsens0)');    
end
     
    [Lwing,twing] = position2distance(wing,i0(1));

    zsens = interp1(Lwing,wing,Lsens);
    tsens = interp1(Lwing,twing,Lsens);
    tsens = tsens./abs(tsens);
    nsens = tsens.*exp(1i*pi/2);
    nsens = nsens./abs(nsens);
end