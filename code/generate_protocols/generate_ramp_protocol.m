function generate_ramp_protocol(varargin)

p = inputParser;
addOptional(p,'time_step',0.001);
addOptional(p,'output_file_string','protocol\ramp.txt');
addOptional(p,'ramp_amp_nm',50);
addOptional(p,'pre_ramp_s',2);
addOptional(p,'ramp_rise_time_s',0.2);
addOptional(p,'ramp_hold_time_s',0.5);
addOptional(p,'pre_Ca_s',0.1);
addOptional(p,'initial_pCa',9.0);
addOptional(p,'activating_pCa',6.0);
addOptional(p,'mode',-2);
parse(p,varargin{:});
p=p.Results;

% Generate hsl
output.dhsl = zeros(round(p.pre_ramp_s/p.time_step),1);

no_of_ramp_steps = round(p.ramp_rise_time_s / p.time_step);
dx = p.ramp_amp_nm / no_of_ramp_steps
output.dhsl = [output.dhsl ; dx * ones(no_of_ramp_steps,1)];
output.dhsl = [output.dhsl ; 0 * ones((p.ramp_hold_time_s / p.time_step),1)];

% Generate dt
output.dt = p.time_step * ones(numel(output.dhsl),1);

% Generate mode
output.Mode = p.mode * ones(numel(output.dhsl),1);

% Generate pCa
output.pCa = p.initial_pCa * ones(numel(output.dhsl),1);
output.pCa(cumsum(output.dt)>p.pre_Ca_s) = p.activating_pCa;

% Output
output_table = struct2table(output);
writetable(output_table,p.output_file_string,'delimiter','\t');
