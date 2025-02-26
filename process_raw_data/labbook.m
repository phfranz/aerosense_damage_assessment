%% Load labbook for wind tunnel experiments
%
%  written by Julien Deparday
%%%
%% Built root structure with locations where the data are stored
% Be sure we have all folders accessible
addpath(genpath(pwd))
currentFolder  = pwd;
idcs   = strfind(currentFolder,'\');
parentdir = currentFolder(1:idcs(end-1)-1);

root.raw = fullfile(currentFolder,'aerosense_data'); % Raw data location
root.proc = currentFolder;
root.matfiles = fullfile(root.proc,'matfiles'); % where the processed data will be stored
root.datfig = fullfile(root.proc,'datandfig'); % where the figures and data to be plotted will be stored
root.import = fullfile(root.proc,'import'); % where other data than the experimental data should be stored (like the airfoil shape)

root.file_name = @(nr1,nr2) sprintf('aoa_%.1ideg_Exp_%.3i',nr1,nr2);
root.file_name_aerosense = @(nr1,nr2) [root.file_name(nr1,nr2),'_aerosense'];

% To correctly load the right csv file,
% keep them in root structure.
root.ival = '1';
root.sensor_type = 'baros_p';
root.readPressures2 = @(nr1,nr2) readtable([fullfile(root.raw,root.file_name_aerosense(nr1,nr2)),'.csv']);

%% Parameters that are the same for all tested cases

% parameters of the blade
param.chord = 0.16;    % chorch length in m
param.span = 0.45;      % span in m

% parameters of the flow
param.rho = 1.25; %kg.m^-3
param.mu = 1.8.*10^(-5); %N.s.m^-2
param.nu = param.mu./param.rho;
param.p_ref_ac = 20*1e-6;

% fudge factor to correct for wind speed out of the wind tunnel
param.wind_correction_factor = 1.2;

% Load the blade shape and get more info
%Idea: everything should be dimensionless (from 0 to 1)
datnaca = readtable('naca633418_thick_te.dat','ReadVariableNames',false); %should be in 
param.wing = flipud(complex(datnaca{:,1},datnaca{:,2})); %It helps a lot if a z=0+i0 point is here.
% And it should start from TE Pressure side -> LE -> TE suction side

[param.Lwing,param.twing,param.nwing] = position2distance(param.wing); %Get curvilinear axis of the wing, tangential and normal of the wing


%% parameters for Aerosense sensors
%%%%%%%%%%%% Baros %%%%%%%%%
% position of the barometers have been calculated already. But it might be
% good to recalculate here in order to allow a shift of the sensors if we
% want to reposition them (not perfectly glued)
ibaro0 = 14; % Sensor at leading edge
shift_ibaro0 = 1*(0.5*10^-3)./param.chord; %if not exactly at leading edge
datbaros = readtable('baros.csv','ReadVariableNames',true);
param.datbaros = datbaros(:,1:3);
param.datbaros.length = sign(param.datbaros.i_side).*param.datbaros.length./param.chord;
param.datbaros.i_side = param.datbaros.i_side-param.datbaros.i_side(param.datbaros.ibaro==ibaro0);
param.datbaros.length = param.datbaros.length-param.datbaros.length(param.datbaros.ibaro==ibaro0)-shift_ibaro0;
[param.datbaros.zsens,param.datbaros.tangsens ,param.datbaros.normsens]= distance2position(param.datbaros.length,0,param.wing);

param.var.baros = ['time',strcat('P',string([0:39]))];

%% LABBOOK 
LB = readtable(fullfile(currentFolder,'Labbook_Aerosense_Dynamic_Experiments_EPFL.csv'),'PreserveVariableNames',true);
for i = 1:height(LB)
    rowname{i} = root.file_name(LB.AoA(i),LB.Experiment_number(i));
end
LB.Properties.RowNames = rowname;


clearvars -except ...
    param ...
    msmpt_name ...
    root ...
    LB ...