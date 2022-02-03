function generate_constant_lengths_protocol(varargin)

dhsl_list = -900:25:900;
% 1170;
% (((2600*0.2):100:(2600*1.8))/2)-1300;
% ((1300*0.2):100:(1300*1.8))-1300;
len = numel(dhsl_list);

for i=1:len
    clear p
    
    p = inputParser;
    addOptional(p,'time_step',0.001);
    addOptional(p,'activating_pCa',5.5);

    addOptional(p,'output_file_string',strcat('FL_',num2str(i),'_protocol.txt'));


    parse(p,varargin{:});
    p=p.Results;
    
    durationLen = 5/p.time_step;
    
    % Generate hsl
    output.dhsl = [dhsl_list(i); zeros(durationLen-1,1)];
    
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
