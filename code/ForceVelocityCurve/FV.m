
% function FL
clear
% Function illustrates how to run a simulation of a single-half-sarcomere
% with a linear passive elastic component and cycling cross-bridges
% that do not generate active force

dhsl_list = -900:25:900;
% 1170
% (((2600*0.2):100:(2600*1.8))/2)-1300;
len = numel(dhsl_list);

for i=1:len
% Variables
protocol_file_string = strcat('FV_',num2str(i),'_protocol.txt');


model_parameters_json_file_string = 'FV_parameters2States.json';
options_file_string = 'FV_options.json';
model_output_file_string{i} = strcat('FV_',num2str(i),'_output.myo');    


% Make sure the path allows us to find the right files
addpath(genpath('../../../../../code'));

% Run a simulation
sim_output = simulation_driver( ...
    'simulation_protocol_file_string', protocol_file_string, ...
    'model_json_file_string', model_parameters_json_file_string, ...
    'options_json_file_string', options_file_string, ...
    'output_file_string', model_output_file_string{i});

% pause
end
%%
% Load it back up and display to show how that can be done
figure(2);clf; hold on;
subplot(1,3,2);hold on;
title('2 state model')
for i = 1:len
    model_output_file_string{i} = strcat('FV_',num2str(i),'_output.myo');
sim = load(model_output_file_string{i},'-mat');
sim_output_reloaded = sim.sim_output;

hsLength(:,i) = sim_output_reloaded.hs_length;
musLength(:,i) = sim_output_reloaded.muscle_length;
musForce(:,i) = sim_output_reloaded.muscle_force;
musVel(:,i) = diff(musLength(:,i))./diff(sim_output_reloaded.time_s);
hsVel(:,i) = diff(hsLength(:,i))./diff(sim_output_reloaded.time_s);

% avgHsLength(i) = mean(hsLength(5000/2,i));
% avgMusLength(i) = mean(musLength(5000/2,i));
avgMusForce(i) = mean(musForce(5000/2,i));
avgMusVel(i) = musVel(5000/2,i);
avgHsVel(i) = hsVel(5000/2,i);

subplot(1,3,1);hold on;xlim([2.3 2.7])
plot(sim_output_reloaded.time_s,sim_output_reloaded.muscle_force,'-');
ylabel('Force (N m^{-2})');
xlabel('Time (s)');
subplot(1,3,2);hold on;xlim([2.3 2.7])
plot(sim_output_reloaded.time_s,sim_output_reloaded.hs_length,'-');
% ylim([-500 3500])
ylabel('Half-sarcomere length (nm)');
xlabel('Time (s)');
subplot(1,3,3);hold on;xlim([2.3 2.7])
plot(sim_output_reloaded.time_s,sim_output_reloaded.muscle_length,'-');
% ylim([-500 3500])
ylabel('Muscle length (nm)');
xlabel('Time (s)');
% pause
end

% avgMusForce
slack_len=sim_output.myosim_model.hs_props.parameters.passive_hsl_slack;
hs_len = sim_output.myosim_model.hs_props.hs_length;

figure(4);clf;hold on;
subplot(2,1,1);hold on;grid on
% xlim([-500 3000]);ylim([0 12e4])
title('2 state model')
% plot([hs_len hs_len],ylim,'r-')
% plot([slack_len slack_len],ylim,'b-')
plot(avgMusVel,avgMusForce,'k.')
% legend('half sarcomere length','half sarcomere slack length')
ylabel('Force (N m^{-2})');
xlabel('Muscle velocity (nm/s)');

subplot(2,1,2); hold on;grid on
% xlim([-500 3000]);ylim([0 12e4])
% plot([hs_len hs_len],ylim,'r-')
% plot([slack_len slack_len],ylim,'b-')
plot(avgHsVel,avgMusForce,'k.')
% legend('half sarcomere length','half sarcomere slack length')
ylabel('Force (N m^{-2})');
xlabel('Half-sarcomere velocity (nm/s)');