%%  Code to postprocess the data from the Aerosense sensing node 
%
%   Convert the raw Aeronsense sensor data into absolute pressure values 
%   or normalized and non-dimensionalized pressure coefficient values
%   considering the zeroing measurements 
%
%   written by Julien Deparday
%%%

% Prepare data
clear
close all
clc

run labbook;

%%

non_zero_experiments = [3, 4, 5, 7, 8, 9, 12, 13, 14, 16, 17, 18, 22, ...
    23, 24, 26, 27, 28, 31, 32, 33, 35, 36, 37, 41, 42, 43, 45, 46, ...
    47, 50, 51, 52, 54, 55, 56, 60, 61, 62, 64, 65, 66, 69, 70, 71, ...
    73, 74, 75, 79, 80, 81, 83, 84, 85, 88, 89, 90, 92, 93, 94, 98, ...
    99, 100, 102, 103, 104, 107, 108, 109, 111, 112, 113]; 

aoa = 0;

for exp =1:1:length(non_zero_experiments)

    iexp = non_zero_experiments(exp);
    expe_name = root.file_name(aoa,iexp);
    
    S = root.readPressures2(aoa,iexp);
    
    % Find the zeroing runs. Can choose both, before or after. See help from
    % SelectZeroings
    [Z0,~,~,stats] = SelectZeroings(expe_name,LB,root);

    % Get actual meaningful value
    options.S0 = Z0; %for more options in structure options: see help in prepareData
    Baros = prepareData(S,root.sensor_type,param,options);

    % Remove sensors that don't work
    Baros=removevars(Baros,{'P22','P36'});

    % let's get rid of unecessary data
    clear S Z0 
    
    % Compute Cps
    Uinfty = LB{(expe_name),'Wind_speed'}*param.wind_correction_factor; %factor 1.2 because the measured wind was faster than the set wind
    q = 0.5*param.rho*Uinfty.^2;
    Cp = Baros; % quasi-absolute pressure data
    Cp{:,2:end} = Baros{:,2:end}./q; % pressure coefficient values
    
    % SAVE BAROS DATA INTO MAT FILES
    writetable(Cp,[expe_name,'_cp_aerosense','.csv'],'Delimiter',' ') 

end

