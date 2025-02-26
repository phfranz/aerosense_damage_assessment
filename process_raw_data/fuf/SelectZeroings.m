function [Z0,Z0_before,Z0_after,stats,name_before,name_after] = SelectZeroings(expe_name,LB,root)
% SelectZeroings finds the runs set as zeroing runs (no wind, no oscillation).
% Usually one is done before and after a series of runs. Both are found.
% either one or the other or both can be used as a zero package:
% INPUT: 
%       - LB: the labbook table with a column called "Zeroing" as boolean
%       as variables
%       - root: structure to load correct data
%
% OUTPUT:
%        Z0: Zeros from run before and after that one
%        Z0_before: Zeroing run before that one
%        Z0_after: Zeroing run after that one
%        stats: table showing mean and standard deviation to check if
%        zeros before and after are similar or not
%        name_before: name of the experimenal run for the zeroing before that one
%        name_after: name of the experimenal run for the zeroing AFTER that one
%
%   written by Julien Deparday
%
%%%


irow_exp = find(strcmp(expe_name,LB.Properties.RowNames));
izeroing = find(LB.Zeroing(:));
nzero_rank=[izeroing(find(izeroing-irow_exp<0,1,'last')), izeroing(find(izeroing-irow_exp>0,1,'first'))];
nzero = [LB.Experiment_number(nzero_rank(1)) LB.Experiment_number(nzero_rank(2))];

aoa = str2num(expe_name(5)); %!! Does not deal with AoA with 2 digits or with commas.

Z0_before = root.readPressures2(aoa,nzero(1)); 
Z0_after = root.readPressures2(aoa,nzero(2));

stats.mean_zero_before = mean(Z0_before{200:end-5,2:end},'omitnan').'; 
stats.std_zero_before = std(Z0_before{200:end-5,2:end},'omitnan').'; 
stats.mean_zero_after = mean(Z0_after{200:end-5,2:end},'omitnan').'; 
stats.std_zero_after = std(Z0_after{200:end-5,2:end},'omitnan').'; 
stats = struct2table(stats);
stats.difference_mean = stats.mean_zero_before - stats.mean_zero_after;

Z0 = cat(1,Z0_before(5:end-5,:),Z0_after(5:end-5,:));

name_before = root.file_name(aoa,nzero(1));
name_after = root.file_name(aoa,nzero(2));
end