function [Lwing,twing,nwing,zsens] = position2distance(wing,i0,xsens)
% [Lwing,twing,nwing,zsens] = position2distance(wing,i0,xsens)
% position2distance gives the distance between the points given as input.
% the leading edge (0,0) must be present, as well as the trailing edge
% (1,0). chord=1.
% wing must start at the trailing edge, pressure side, goes at leading edge and finishes at
% trailing edge via upper side.
% input: 
%       - wing in complex coordinate
%       - i0 if we don't want to calculate distance from leading edge
%       - if xsens is an input, we have the x coordinate of the sensors
%       and we want to know their distance from i0. 
% 
% output: 
%        Lwing: curvilinear length of the points from the trailing edge
%        lwing: distance between each point
%        nwing: normal of each point given in wing
%        twing: tangent of each point given in wing
%        if sensors placed, wing is replaced by sensors!
%
% written by Julien Deparday 
%
%%%  
   
    
    %find leading edge
     if ~exist('i0') || isempty(i0)
         ile = knnsearch(real(wing),0);
     else
         ile=i0;
     end

    %first side (should be lower side)
    dwing_l = diff(wing(ile:-1:1));%ile:-1:1));
    lwing_l = abs(dwing_l);
    Lwing_l = flipud(cumsum(lwing_l));

    %second side (should be upper side)
    dwing_u = diff(wing(ile:end));
    lwing_u = abs(dwing_u);
    Lwing_u = cumsum([0; lwing_u]);
    
%     dwing = [flipud(dwing_l);dwing_u];
    lwing = [-flipud(lwing_l);0;lwing_u];
    Lwing = [-Lwing_l;Lwing_u];
    
    Ww = [wing; wing(end)];
    twing = mean([diff(Ww)./abs(diff(Ww)),circshift(diff(Ww)./abs(diff(Ww)),1)],2);
    twing(isnan(real(twing)))=0;
    nwing = twing.*exp(1i*pi/2);

    zsens = wing;

    if exist('xsens')
        isen_le = knnsearch(xsens,0); % It was before: isen_le = find(xsens == 0) and we needed a strict zero value.
        si_sen = ones(size(xsens));
        si_sen(1:isen_le-1) = -si_sen(1:isen_le-1);
%         xsens_sign = 
        Lsens = interp1(sign(Lwing).*real(wing),Lwing,si_sen.*xsens);
      
        [zsens,tsens,nsens] = distance2position(Lsens,wing(ile),wing);

        Lwing = Lsens;
        twing = tsens;
        nwing = nsens;
    end
end