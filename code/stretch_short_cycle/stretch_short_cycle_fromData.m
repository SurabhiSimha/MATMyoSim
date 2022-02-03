% This is a variation of the force-length demo code written by Ken Campbell

% function stretch_short_cycle_fromData

clear

load A18042-19-18_cell_block1_cell1_kT_aff_trial8_pass1.mat

timeAll = procData.time;
timeRqdInd = find(timeAll>1,1);
time = timeAll(1:timeRqdInd);
Lf = procData.Lf(1:timeRqdInd);
Fmt = procData.Fmt(1:timeRqdInd);
Ymt = procData.Ymt(1:timeRqdInd);
spiketimesAll = procData.spiketimes;
spiketimesRqdInd = find(spiketimesAll>1,1);
spiketimes = spiketimesAll(1:spiketimesRqdInd);
IFR = procData.IFR(1:spiketimesRqdInd);

% Variables for intra- and extra- fusal muscle fibres
model_file = 'sim_input_3state/model_3state_stretch_short.json';
model_file_bag = 'sim_input_3state/model_3state_bag_stretch_short.json';
model_file_chain = 'sim_input_3state/model_3state_chain_stretch_short.json';
options_file = 'sim_input_3state/options.json';
protocol_file = 'sim_input_3state/protocol.txt';
results_base_file = 'sim_output_3state/results';
results_base_file_bag = 'sim_output_3state/results_bag';
results_base_file_chain = 'sim_output_3state/results_chain';
no_of_time_points = length(Lf);
time_step = (time(end)-time(1))/length(time);    
% [0;diff(time)];
% 
% Make sure the path allows us to find the right files
addpath(genpath('../../code'));

% Generate a protocol
generate_stretch_short_cycle_protocol( ...
    'time_step', time_step, ...
    'no_of_points', no_of_time_points, ...
    'during_pCa', 6.5, ...
    'dhsl', [5;diff(Lf)],...
    'output_file_string', protocol_file);

% Create a batch structure

% Set up the results file
results_file = sprintf('%s.myo',results_base_file);
% results_file_bag = sprintf('%s.myo',results_base_file_bag);
% results_file_chain = sprintf('%s.myo',results_base_file_chain);

% Add the job to the batch structure
batch_structure.job{1}.model_file_string = model_file;
batch_structure.job{1}.options_file_string = options_file;
batch_structure.job{1}.protocol_file_string = protocol_file;
batch_structure.job{1}.results_file_string = results_file;

% % Add the job to the batch structure bag
% batch_structure_bag.job{1}.model_file_string = model_file_bag;
% batch_structure_bag.job{1}.options_file_string = options_file;
% batch_structure_bag.job{1}.protocol_file_string = protocol_file;
% batch_structure_bag.job{1}.results_file_string = results_file_bag;
% 
% % Add the job to the batch structure chain
% batch_structure_chain.job{1}.model_file_string = model_file_chain;
% batch_structure_chain.job{1}.options_file_string = options_file;
% batch_structure_chain.job{1}.protocol_file_string = protocol_file;
% batch_structure_chain.job{1}.results_file_string = results_file_chain;

% Now that you have all the files, run the batch jobs in parallel
run_batch(batch_structure);
% run_batch(batch_structure_bag);
% run_batch(batch_structure_chain);

% Load the simulation back in
sim = load(results_file, '-mat');
sim_output = sim.sim_output;
    
% sim_bag = load(results_file_bag, '-mat');
% sim_bag_output = sim_bag.sim_output;
% 
% sim_chain = load(results_file_chain, '-mat');
% sim_chain_output = sim_chain.sim_output;
%%
% [r,rs,rd,F_weighted, Y_weighted] = sarc2spindle_modified(sim_bag_output,sim_chain_output,1,2,1,0,0.01);
t = sim_output.time_s(500:end);
Fs = sim_output.hs_force(500:end);
Fs(Fs<0) = 0;

Y = diff(Fs)./diff(t); %yank
Y(Y<0) = 0; %threshold
Y(end+1) = Y(end); %make Y same length as F
[b,a] = butter(4,(800/(2/(t(2)-t(1)))),'low');
filtY = filtfilt(b,a,Y);
r = Fs*2.5 + filtY*8;
r = r/(10^2);
r(r<0.0) = 0; 
%% Now show the force-length properties
figure(997);title('muscle')
clf;

    % Display the full simulation
%     subplot(411);hold on
%     plot(time, Lmt)
%     xlim([0 max(time)])
% %     ylim([min(data.Lmt) max(data.Lmt)])
%     ylabel('MTU length (mm)', 'FontSize', 8)
% %     xline(time(min_ind))
%     set(gca, 'box', 'off')
    
    subplot(411);hold on;grid on
    title('3 state model, pCa 6.5, starting length stretch by 5; using passive trial sonos length data')
    plot(time(500:end), Lf(500:end)-Lf(1),'r-','LineWidth',2);
    plot(sim_output.time_s(500:end),sim_output.hs_length(500:end)-sim_output.hs_length(1),'b-','LineWidth',2);
    xlim([0.4 1.1])
%     xlim([0 max(time)])
%     ylim([min(data.Lf) max(data.Lf)])
    ylabel({'Sonos muscle length (mm)','Half sarcomere length (nm)'}, 'FontSize', 12)
%     legend('sonos','half-sarcomere')
%     xline(time(min_ind))
    set(gca, 'box', 'off')
    
    subplot(412);hold on;grid on
%     yyaxis left
%     plot(time(2:end), Fmt(2:end),'b-')
%     ylabel('Force mt (N)', 'FontSize', 8)
%     yyaxis right
    plot(sim_output.time_s(500:end),sim_output.hs_force(500:end),'r-','LineWidth',2);
    xlim([0.4 1.1])
%     xlim([0 max(time)])
%     ylim([-.5 max(data.Fmt)])
    ylabel('Half sarcomere stress (N/m^2)', 'FontSize', 12)
%     legend('Expt force','myosim hs')
%     xline(time(min_ind))
    set(gca, 'box', 'off')
    
%     Y_myosim = diff(sim_output.hs_force)./diff(sim_output.time_s);
    xlim([0.4 1.1])
    subplot(413);hold on;grid on
%     yyaxis left
%     plot(time, Ymt,'b-')
%     ylim([0 max(Ymt)])
%     ylabel('Yank mt (N)', 'FontSize', 8)
%     yyaxis right
    plot(t,filtY,'r-','LineWidth',2);
    xlim([0.4 1.1])
%     xlim([0 max(time)])
%     ylim([0 max(Y_myosim)])
    ylabel('Half sarcomere yank (N/m^2s)', 'FontSize', 12)
%     legend('Expt yank','myosim hs yank')
%     xline(time(min_ind))
    set(gca, 'box', 'off')

    subplot(414);hold on;grid on
    plot(t,r,'or','MarkerSize',2,'MarkerFaceColor','r')
    plot(spiketimes, IFR, 'ok','MarkerSize',2,'MarkerFaceColor','k')
    xlim([0.4 1.1])
%     xlim([0 max(time)])
%     ylim([0 500])
    ylabel('IFR (Hz)', 'FontSize', 12)
    legend('myosim','measured')
%     xline(time(min_ind))
    set(gca, 'box', 'off')