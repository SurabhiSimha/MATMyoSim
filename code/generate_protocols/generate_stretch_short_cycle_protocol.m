function generate_stretch_short_cycle_protocol(varargin)

p = inputParser;
addOptional(p, 'time_step', 0.001);
addOptional(p, 'no_of_points', 5000);
addOptional(p, 't_start_s', 0.1);
addOptional(p, 't_stop_s', 4.0);
addOptional(p, 'pre_pCa', 9);
addOptional(p, 'during_pCa', 4.5);
addOptional(p, 'dhsl', 1);
addOptional(p,'output_file_string','protocol\stretch_short_pas.txt');
parse(p,varargin{:});
p=p.Results;

% Code
output.dt = p.time_step * ones(p.no_of_points,1);
output.Mode = -2 * ones(p.no_of_points,1);
output.dhsl = p.dhsl;

% Generate pCa profile
t = cumsum(output.dt);
output.pCa = p.pre_pCa * ones(p.no_of_points,1);
output.pCa(t > p.t_start_s) = p.during_pCa;
output.pCa(t > p.t_stop_s) = p.pre_pCa;

% Output
output_table = struct2table(output);
writetable(output_table,p.output_file_string,'delimiter','\t');
