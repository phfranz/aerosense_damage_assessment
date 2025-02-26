function [matrixval] = c2m(complexval,coord)
%c2m stands for complex to matrix
% input:
% the complex matrix to be convertved as a matrix with 2 rows or columns
% coord (facultative) as strings to indicate if you want cartesian or polar
% output:
% the 2 rows or columns with either real or imaginary or r and theta
%
% written by Julien Deparday 
%
%%%

if ~exist('coord')
    if size(complexval,1)> size(complexval,2)
            matrixval = [real(complexval),imag(complexval)];
    else
            matrixval = [real(complexval);imag(complexval)];
    end
else
    if strcmp(coord,'cartesian')
        if size(complexval,1)> size(complexval,2)
            matrixval = [real(complexval),imag(complexval)];
        else
            matrixval = [real(complexval);imag(complexval)];
        end
    elseif strcmp(coord,'polar')
         if size(complexval,1)> size(complexval,2)
            matrixval = [abs(complexval),angle(complexval)];
        else
            matrixval = [abs(complexval);angle(complexval)];
         end
    else 
        if size(complexval,1)> size(complexval,2)
            matrixval = [real(complexval),imag(complexval)];
        else
            matrixval = [real(complexval);imag(complexval)];
        end
    end
end


end