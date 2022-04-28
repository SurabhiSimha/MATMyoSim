function rate_structure = update_4state_with_SRX_and_3exp(obj,time_step, m_props, delta_hsl)
% Function updates kinetics for thick and thin filaments

% Pull out the myofilaments vector
y = obj.myofilaments.y;

% Deduce some indices
M1_ind = 1;
M2_ind = 2;
M3_ind = 2+(1:obj.myofilaments.no_of_x_bins);
M4_ind = (2+obj.myofilaments.no_of_x_bins) + ...
    (1:obj.myofilaments.no_of_x_bins);
M5_ind = M4_ind(end) + 1;
M6_ind = M4_ind(end) + 2;


% Get the overlap
N_overlap = return_f_overlap(obj);

% Pre-calculate rates
r1 = obj.parameters.k_1 * (1 + obj.parameters.k_force * ...
                            max([0 obj.hs_force]));

r2 = min([obj.parameters.max_rate obj.parameters.k_2]);            

r3 = obj.parameters.k_3 * ...
        exp(-0.5 * obj.parameters.k_cb * (obj.myofilaments.x).^2 / ...
            (1e18 * obj.parameters.k_boltzmann * ...
                obj.parameters.temperature));
r3(r3>obj.parameters.max_rate)=obj.parameters.max_rate;

r4 = obj.parameters.k_4_0 * zeros(1, numel(obj.myofilaments.x));
r4(r4 > obj.parameters.max_rate) = obj.parameters.max_rate;
r4(r4 < 0) = 0;

r5 = obj.parameters.k_5_0 * ...
        exp(-obj.parameters.k_cb * obj.parameters.k_5_1 * ...
                obj.myofilaments.x ./ ...
                            (1e18 * obj.parameters.k_boltzmann * ...
                                obj.parameters.temperature));
r5(r5 > obj.parameters.max_rate) = obj.parameters.max_rate;
r5(r5<0) = 0;

r6 = obj.parameters.k_6_0 * ...
        exp(obj.parameters.k_cb * obj.parameters.k_6_1 * ...
                obj.myofilaments.x ./ ...
                    (1e18 * obj.parameters.k_boltzmann * ...
                        obj.parameters.temperature));
r6(r6 > obj.parameters.max_rate) = obj.parameters.max_rate;
r6(r6<0) = 0;
    
r7 = obj.parameters.k_7_0 + ...
        obj.parameters.k_7_1 * exp(abs(obj.myofilaments.x)) + ...
        obj.parameters.max_rate * (1 ./ ...
            (1 + exp(-obj.parameters.k_7_2 * ...
                (obj.myofilaments.x - obj.parameters.k_7_3)))) + ...
        obj.parameters.max_rate * (1 ./ ...
            (1 + exp(obj.parameters.k_7_2 * ...
                (obj.myofilaments.x + obj.parameters.k_7_4))));                ;
r7(r7>obj.parameters.max_rate)=obj.parameters.max_rate;

r8 = min([obj.parameters.k_8_0 obj.parameters.max_rate]) * ...
        ones(1, obj.myofilaments.no_of_x_bins);

r9 = obj.parameters.k_9_0 + ...
        obj.parameters.k_9_1 * exp(abs(obj.myofilaments.x)) + ...
        obj.parameters.max_rate * (1 ./ ...
            (1 + exp(-obj.parameters.k_9_2 * ...
                (obj.myofilaments.x - obj.parameters.k_9_3)))) + ...
        obj.parameters.max_rate * (1 ./ ...
            (1 + exp(obj.parameters.k_9_2 * ...
                (obj.myofilaments.x + obj.parameters.k_9_4))));   
r9(r9 > obj.parameters.max_rate) = obj.parameters.max_rate;
r9(r9 < 0) = 0;            

r10 = obj.parameters.k__10_0 * zeros(1, numel(obj.myofilaments.x));
r10(r10 > obj.parameters.max_rate) = obj.parameters.max_rate;
r10(r10 < 0) = 0;
            
r11 = obj.parameters.k__11;
r12 = obj.parameters.k__12;
r13 = obj.parameters.k__13;
r14 = obj.parameters.k__14;
            
r_on = obj.parameters.k_on * obj.Ca;

r_off = obj.parameters.k_off;
if (r_off < 0)
    r_off = 0;
end

% Evolve the system
[t,y_new] = ode23(@derivs,[0 time_step],y,[]);

% Update the system
obj.myofilaments.y = y_new(end,:)';

% Catch non-zero elements
zi = find(obj.myofilaments.y < 0);
obj.myofilaments.y(zi) = 0;

% Keep cbs summed to 1
cb = sum(obj.myofilaments.y(1:(end-2)));
obj.myofilaments.y(1) = obj.myofilaments.y(1) + (1-cb);

% Keep actin summed to 1
ac = obj.myofilaments.y(end-1) + obj.myofilaments.y(end);
obj.myofilaments.y(end-1) = obj.myofilaments.y(1) + (1-ac);

obj.f_overlap = N_overlap;
obj.f_on = obj.myofilaments.y(end);
obj.f_bound = sum(obj.myofilaments.y(M3_ind)) + ...
    sum(obj.myofilaments.y(M4_ind)); 

% Store rates
obj.rate_structure.r1 = r1;
obj.rate_structure.r2 = r2;
obj.rate_structure.r3 = r3;
obj.rate_structure.r4 = r4;
obj.rate_structure.r5 = r5;
obj.rate_structure.r6 = r6;
obj.rate_structure.r7 = r7;
obj.rate_structure.r8 = r8;
obj.rate_structure.r9 = r9;
obj.rate_structure.r10 = r10;
obj.rate_structure.r11 = r11;
obj.rate_structure.r12 = r12;
obj.rate_structure.r13 = r13;
obj.rate_structure.r14 = r14;
obj.rate_structure.r_on = r_on;
obj.rate_structure.r_off = r_off;


    % Nested function
    function dy = derivs(time_step,y)
        
        % Set dy
        dy = zeros(numel(y),1);

        % Unpack
        M1 = y(M1_ind);
        M2 = y(M2_ind);
        M3 = y(M3_ind);
        M4 = y(M4_ind);
        M5 = y(M5_ind);
        M6 = y(M6_ind);        
        
        N_off = y(end-1);
        N_on = y(end);
        N_bound = sum(M3)+sum(M4);
        
        % Calculate the fluxes
        J1 = r1 * M1;
        J2 = r2 * M2;
        J3 = r3 .* obj.myofilaments.bin_width * M2 * (N_on - N_bound);
        J4 = r4 .* M3';
        J5 = r5 .* M3';
        J6 = r6 .* M4';
        J7 = r7 .* M4';
        J8 = r8 * obj.myofilaments.bin_width * M6 * (N_on - N_bound);
        J9 = r9 .* M3';
        J10 = r10 * obj.myofilaments.bin_width * M5 * (N_on - N_bound);
        J11 = r11 * M5;
        J12 = r12 * M6;
        J13 = r13 * M6;
        J14 = r14 * M2;
        
        if (N_overlap > 0)
            J_on = obj.parameters.k_on * obj.Ca * (N_overlap - N_on) * ...
                    (1 + obj.parameters.k_coop * (N_on/N_overlap));
            J_off = obj.parameters.k_off * (N_on - N_bound) * ...
                (1 + obj.parameters.k_coop * ((N_overlap - N_on)/N_overlap));
        else
            J_on = 0;
            J_off = obj.parameters.k_off * (N_on - N_bound);
        end
            
        % Calculate the derivs
        dy(M1_ind) = -J1 + J2;
        dy(M2_ind) = (J1 + sum(J4) + J13) - ...
            (J2 + sum(J3) + J14);
        for i=1:obj.myofilaments.no_of_x_bins
            dy(M3_ind(i)) = (J3(i) + J6(i) + J10(i)) - ...
                (J4(i) + J5(i) + J9(i));
            dy(M4_ind(i)) = (J5(i) + J8(i)) - ...
                (J6(i) + J7(i));
        end
        dy(M5_ind) = (sum(J9) + J12) - (sum(J10) + J11);
        dy(M6_ind) = (sum(J7) + J11 + J14) - ...
            (sum(J8) + J12 + J13);
         
        dy(end-1) = -J_on + J_off;
        dy(end) = J_on - J_off;
    end
end