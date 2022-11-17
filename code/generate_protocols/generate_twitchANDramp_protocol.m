function generate_twitchANDramp_protocol(varargin)

p = inputParser;
addOptional(p,'time_step',0.001);
addOptional(p,'output_file_string','protocol\twitch.txt');
addOptional(p,'no_of_points',2000);
addOptional(p,'stimulus_times',[0.1 0.4 0.7 0.85 1.0:0.05:1.4]);
addOptional(p,'stimulus_duration',0.03);
addOptional(p,'Ca_content',1e-3);
addOptional(p,'k_leak',2e-2);
addOptional(p,'k_act',3e-1);
addOptional(p,'k_serca',20);
addOptional(p,'mode',-2);
addOptional(p,'ramp_amp_nm',50);
addOptional(p,'pre_ramp_s',2);
addOptional(p,'ramp_rise_time_s',0.2);
addOptional(p,'ramp_hold_time_s',0.5);
addOptional(p,'activating_pCa',6.0);
parse(p,varargin{:});
p=p.Results;

% Generate activation pattern
activation = zeros(p.no_of_points,1);
for i=1:numel(p.stimulus_times)
    start_index = round(p.stimulus_times(i)/p.time_step);
    stop_index = round((p.stimulus_times(i)+p.stimulus_duration)/p.time_step);
    activation(start_index:stop_index)=1;
end
activation(activation>1)=1;

% Solve 2 compartment differential equation to give fake calcium transients
y=[0 p.Ca_content];
for i=2:p.no_of_points
    act = activation(i);
    [t,y_temp]=ode45(@derivs,[0 p.time_step],y(i-1,:));
    y(i,:) = y_temp(end,:);
end
pCa_trace = -log10(y(:,1));

    function dydt = derivs(t,y)
        dydt=zeros(2,1);
        dydt(1) = (p.k_leak + act * p.k_act)*y(2) - p.k_serca*y(1);
        dydt(2) = -dydt(1);
    end

% Generate the rest of the protocol

% Generate dhsl
output.dhsl = [zeros(p.no_of_points,1); zeros(round(p.pre_ramp_s/p.time_step),1)];

% Generate ramp hsl
no_of_ramp_steps = round(p.ramp_rise_time_s / p.time_step);
dx = p.ramp_amp_nm / no_of_ramp_steps
output.dhsl = [output.dhsl ; dx * ones(no_of_ramp_steps,1)];
output.dhsl = [output.dhsl ; 0 * ones((p.ramp_hold_time_s / p.time_step),1)];

% Generate mode
output.Mode = p.mode * ones(numel(output.dhsl),1);

% Generate dt
output.dt = p.time_step * ones(numel(output.dhsl),1);

% Generate pCa
output.pCa = [pCa_trace; ones(numel(output.dhsl)-numel(pCa_trace),1)*p.activating_pCa];

% Output
output_table = struct2table(output);
writetable(output_table,p.output_file_string,'delimiter','\t');

end