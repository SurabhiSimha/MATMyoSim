function generate_constant_velocity_protocol(varargin)

initial_len_list = -900:25:900;

% (((2600*0.2):100:(2600*1.8))/2)-1300;
% ((1300*0.2):100:(1300*1.8))-1300;
len = numel(initial_len_list);

for i=1:len
    clear p
    
    p = inputParser;
    addOptional(p,'time_step',0.001);
    addOptional(p,'activating_pCa',4.5);

    addOptional(p,'output_file_string',strcat('FV_',num2str(i),'_protocol.txt'));


    parse(p,varargin{:});
    p=p.Results;
    
    durationLen = 5/p.time_step;
    
    dhsl_increments = (2*initial_len_list(i))/175;
    
    % Generate hsl
    output.dhsl = [initial_len_list(i);zeros(((durationLen-176)/2),1);-dhsl_increments*ones(175,1);zeros(((durationLen-176)/2),1)];
    
    % Generate dt
    output.dt = p.time_step * ones(durationLen,1);
    
    % Generate mode
    output.Mode = -2 * ones(durationLen,1);
    
    % Generate pCa
    output.pCa = p.activating_pCa * ones(durationLen,1);
    % output.pCa(cumsum(output.dt)>p.pre_Ca_s) = p.activating_pCa;
    
    % Output
    output_table = struct2table(output);
    writetable(output_table,p.output_file_string,'delimiter','\t');
end
