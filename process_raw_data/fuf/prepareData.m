function [Sensor] = prepareData(S,type,param,options)
% input:
%       - S: Sensor, a table with no variable names with 1 column as time and rest as sensors
%       - type: a string variable to determine which type of sensor we
%       will deal with
%       - param: the parameter structure made when launching the
%       labbook
%       - options: if needed you can add a few options like:
%                   options.rem_data: an array 2x1 providing the amount
%                   of rows to delete at start and finish.
%                   options.t0: time where zero was made with other
%                   sensors from wind tunnel
%                   options.T = Temperature for baros. Automatically the
%                   calibration of the sensor will be taken into account.
%                   options.S0 = Sensor with no wind speed to make the zero. 
%                   Automatically the zero will be done.
%                   options.T0 = temperature for baros when no wind speed
%                   for zero, to calibrate zero values...
%
%
% output:
%        Sensor: the table S with name and values not needed
%
%   written by Julien Deparday
%
%%%
remd = [200 height(S)-5];


if ~exist('options','var')
    options.rem_data = remd;
else
    if ~isfield(options,'rem_data')
        options.rem_data = remd;
    elseif length(options.rem_data)~=2
        warning('It seems like you gave me bullshit with the options, I''ll take some decision by myself then.')
        options.rem_data = remd;
    end
    if isfield(options,'S0')
        S0 = options.S0;
        type = 'baros_p_0';
    end

end


switch type

    %%%%%%%%%%%%% AEROSENSE BAROS %%%%%%%%%%%%%%%%%%%%%%
    case 'baros_p'
        S.Properties.VariableNames = param.var.baros;
        Sensor = S(options.rem_data(1):options.rem_data(2),:); %Remove first and last values that might not be correct

        if isfield(options,'T')
            T = options.T;
            T.Properties.VariableNames = param.var.baros;
            Temp = options.T{options.rem_data(1):options.rem_data(2),2:end};
            % We assume the sensors are in the right order: P0 T0 P1 T1
            % etc...
            t00 = repmat(param.coeff_baros{"p00",2:2:end},length(Temp),1);
            t10 = repmat(param.coeff_baros{"p10",2:2:end},height(Temp),1);
            t01 = repmat(param.coeff_baros{"p01",2:2:end},height(Temp),1);
            t11 = repmat(param.coeff_baros{"p11",2:2:end},height(Temp),1);
            t20 = repmat(param.coeff_baros{"p20",2:2:end},height(Temp),1);
            t02 = repmat(param.coeff_baros{"p02",2:2:end},height(Temp),1);

            Temp = t00 + Sensor{:,2:end}.*t10 + Temp.*t01+...
           Sensor{:,2:end}.^2.*t20 + Temp.^2.*t02 + Sensor{:,2:end}.*Temp.*t11;
            
            %After updating the temperature, let's calibrate the pressures
            p00 = repmat(param.coeff_baros{"p00",1:2:end},length(Temp),1);
            p10 = repmat(param.coeff_baros{"p10",1:2:end},height(Temp),1);
            p01 = repmat(param.coeff_baros{"p01",1:2:end},height(Temp),1);
            p11 = repmat(param.coeff_baros{"p11",1:2:end},height(Temp),1);
            p20 = repmat(param.coeff_baros{"p20",1:2:end},height(Temp),1);
            p02 = repmat(param.coeff_baros{"p02",1:2:end},height(Temp),1);

            Sensor{:,2:end} = p00 + Sensor{:,2:end}.*p10 + Temp.*p01+...
           Sensor{:,2:end}.^2.*p20 + Temp.^2.*p02 + Sensor{:,2:end}.*Temp.*p11;
            Sensor{:,2:end} = Sensor{:,2:end}*100; %Conversion from hPa to Pa

        else
            Sensor{:,2:end} = Sensor{:,2:end}./4096*100; %conversion to hPa and to Pa then to nondim values
        end

        Sensor = addprop(Sensor,'Position','variable');
        Sensor.Properties.CustomProperties.Position = [nan param.datbaros.zsens'];
        Sensor = addprop(Sensor,'Length','variable');
        Sensor.Properties.CustomProperties.Length = [nan; param.datbaros.length];



    case 'baros_p_0'

        %%%% DEAL WITH INTERESTING MEASUREMENTS%%%%%%%%%%%
        optionsB = options;
        optionsB = rmfield(optionsB,'S0');
        if isfield(optionsB,'T')
            if height(optionsB.T)>height(S)
                %We assume both sensors started at the same time, just one has stopped
                %before the other...
                optionsB.T(height(S)+1:end,:)=[];
                optionsB.rem_data = [200 height(S)-5];
            elseif height(optionsB.T)<height(S)
                S(height(optionsB.T)+1:end,:)=[];
            end
        end
        optionsB.rem_data = [200 height(S)-5];
        Sensor = prepareData(S,'baros_p',param,optionsB);

        %%%% DEAL WITH ZERO VALUES %%%%%%%%%%%%%%%%%%%%
        optionsB0 = options;
        optionsB0 = rmfield(optionsB0,'S0');
        if isfield(optionsB0,'T0')
           optionsB0.T = optionsB0.T0;
            if height(optionsB0.T)>height(S0)
                %We assume both sensors started at the same time, just one has stopped
                %before the other...
                optionsB0.T(height(S0)+1:end,:)=[];
            elseif height(optionsB0.T)<height(S0)
                S0(height(optionsB0.T)+1:end,:)=[];
            end
        end
        optionsB0.rem_data = [200 height(S0)-5];
        Sensor0 = prepareData(S0,'baros_p',param,optionsB0);

        SensorZ0_m = repmat(mean(Sensor0{:,2:end},'omitnan'),height(Sensor),1);
        Sensor{:,2:end} = Sensor{:,2:end}-SensorZ0_m;

    otherwise
        error('I''m not sure I can deal with this type of sensor %s',type)
end


end