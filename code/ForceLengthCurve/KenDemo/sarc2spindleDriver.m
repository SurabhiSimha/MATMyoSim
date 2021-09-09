hs_lengths = linspace(700, 2000, 20);

options_file = 'sim_input_SRS/options.json';
protocol_file = 'sim_input_SRS/protocol.txt';

results_base_file_bag = 'Sim_output_SRS_2state_bag/results';
results_base_file_chain = 'Sim_output_SRS_2state_chain/results';

for i = 1 : numel(hs_lengths)
    model_file_bag = fullfile(cd, 'sim_input_SRS', 'hs_models_2state_bag', ...
        sprintf('model_%i.json', i));
    model_file_chain = fullfile(cd, 'sim_input_SRS', 'hs_models_2state_chain', ...
        sprintf('model_%i.json', i));
    
    % Set up the results file
    results_file_bag{i} = sprintf('%s_%i.myo',results_base_file_bag, i);
    results_file_chain{i} = sprintf('%s_%i.myo',results_base_file_chain, i);
    
    % Add the job to the batch structure
    batch_structure_bag.job{i}.model_file_string = model_file_bag;
    batch_structure_bag.job{i}.options_file_string = options_file;
    batch_structure_bag.job{i}.protocol_file_string = protocol_file;
    batch_structure_bag.job{i}.results_file_string = results_file_bag{i};
    
        % Add the job to the batch structure
    batch_structure_chain.job{i}.model_file_string = model_file_chain;
    batch_structure_chain.job{i}.options_file_string = options_file;
    batch_structure_chain.job{i}.protocol_file_string = protocol_file;
    batch_structure_chain.job{i}.results_file_string = results_file_chain{i};
end

% Now that you have all the files, run the batch jobs in parallel
run_batch(batch_structure_bag);
run_batch(batch_structure_chain);

figure(99);clf; hold on;
cm = jet(numel(hs_lengths));

for i = 1 : numel(hs_lengths)
    
    % Load the simulation back in
    sim_bag = load(results_file_bag{i}, '-mat');
    sim_bag_output = sim_bag.sim_output;
    
    sim_chain = load(results_file_chain{i}, '-mat');
    sim_chain_output = sim_chain.sim_output;
    
    [r,rs,rd] = sarc2spindle_modified(sim_bag_output,sim_chain_output,1,2,0.15,0.5,0.01);
    
    figure(99);hold on
    subplot(3,1,1);hold on;title('total');ylabel('current');xlabel('time (s)');
    plot(sim_bag_output.time_s,r,'-', 'Color', cm(i,:),'LineWidth',2);
    subplot(3,1,2);hold on;title('static-chain(force) component');ylabel('current');xlabel('time (s)');
    plot(sim_bag_output.time_s,rs,'-', 'Color', cm(i,:),'LineWidth',2);
    subplot(3,1,3);hold on;title('dynamic-bag(force+yank) component');ylabel('current');xlabel('time (s)');
    plot(sim_bag_output.time_s,rd,'-', 'Color', cm(i,:),'LineWidth',2);
%     ylim([0 0.25])
%     ylabel('current');xlabel('time (s)');
%     legend('total','static-chain(force) component','dynamic-bag(force+yank) component')

end