function update_2state_with_poly(obj,time_step);
% Function updates kinetics for thick and thin filaments based on
% a simple two state model

% Pull out the myofilaments vector
y = obj.myofilaments.y;

% Get the overlap
N_overlap = return_f_overlap(obj);
% N_overlap


% Pre-calculate rate
%% new rate functions added for IOMM tutorial
%%
switch obj.parameters.rate_func
    case 'default'
        r1 = 20 * ...
            exp(-obj.parameters.k_cb * (obj.myofilaments.x).^2 / ...
            (2*1e18 * obj.parameters.k_boltzmann * ...
            obj.parameters.temperature));
        r1(r1>obj.parameters.max_rate)=obj.parameters.max_rate;
        
        r2 = 2 + (0.01 * ((obj.myofilaments.x).^4));
        r2(r2>obj.parameters.max_rate)=obj.parameters.max_rate;
    case 'huxley'
        r1 = zeros(size(obj.myofilaments.x));
        r1(obj.myofilaments.x>0) = 3 * ...
            obj.myofilaments.x(obj.myofilaments.x>0);
        r1(obj.myofilaments.x>8) = 0;
        r1(r1>obj.parameters.max_rate)=obj.parameters.max_rate;
        
        r2 = zeros(size(obj.myofilaments.x));
        r2(obj.myofilaments.x<0) = 100;
        r2(obj.myofilaments.x>=0) = 1 * ...
            obj.myofilaments.x(obj.myofilaments.x>=0);
        r2(r2>obj.parameters.max_rate)=obj.parameters.max_rate;
    case 'asymIOMM'
        r1 = 20 * ...
            exp(-obj.parameters.k_cb * (obj.myofilaments.x-1).^2 / ...
            (2*1e18 * obj.parameters.k_boltzmann * ...
            obj.parameters.temperature));
        r1(r1>obj.parameters.max_rate)=obj.parameters.max_rate;
        
        r2 = 30 * ...
            exp(-(obj.parameters.k_cb * obj.myofilaments.x * ...
            0.5) ./ ...
            (1e18 * obj.parameters.k_boltzmann * ...
            obj.parameters.temperature));
        r2 = r2 + ...
            350 * ...
            (1 ./ (1 + exp(-5 * ...
            (obj.myofilaments.x - 10))));
        r2(r2>obj.parameters.max_rate)=obj.parameters.max_rate;
    case 'asym'
        r1 = obj.parameters.k_1 * ...
            exp(-obj.parameters.k_cb * (obj.myofilaments.x+1).^2 / ...
            (2*1e18 * obj.parameters.k_boltzmann * ...
            obj.parameters.temperature));
        r1(r1>obj.parameters.max_rate)=obj.parameters.max_rate;
        
        r2 = obj.parameters.k_2_0 * ...
            exp(-(obj.parameters.k_cb * obj.myofilaments.x * ...
            obj.parameters.k_2_1) ./ ...
            (1e18 * obj.parameters.k_boltzmann * ...
            obj.parameters.temperature));
        r2 = r2 + ...
            obj.parameters.max_rate * ...
            (1 ./ (1 + exp(-obj.parameters.k_2_2 * ...
            (obj.myofilaments.x - obj.parameters.k_2_3))));
        r2(r2>obj.parameters.max_rate)=obj.parameters.max_rate;
        
    case 'orig'
        r1 = obj.parameters.k_1 * ...
            exp(-obj.parameters.k_cb * (obj.myofilaments.x).^2 / ...
                (2 * 1e18 * obj.parameters.k_boltzmann * ...
                    obj.parameters.temperature));
        r1(r1>obj.parameters.max_rate)=obj.parameters.max_rate; 
        
        r2 = obj.parameters.k_2_0 + ...
                (obj.parameters.k_2_1 * ...
                    ((obj.myofilaments.x + obj.parameters.x_ps).^4));
        r2(r2>obj.parameters.max_rate)=obj.parameters.max_rate;
        
    case 'kyleBag'
        r1 = zeros(size(obj.myofilaments.x));
        r1 = obj.parameters.k_1 * ...
            exp(-obj.parameters.k_cb * 10 * (obj.myofilaments.x).^2 / ...
            (1e18 * obj.parameters.k_boltzmann * ...
            obj.parameters.temperature));
        r1(r1>obj.parameters.max_rate)=obj.parameters.max_rate;
        
        r2 = zeros(size(obj.myofilaments.x));
        r2(obj.myofilaments.x<-6) = obj.parameters.k_2_0 + ...
            abs(0.2*((obj.myofilaments.x(obj.myofilaments.x<-6)+6).^3));
        r2(obj.myofilaments.x>=-3) = obj.parameters.k_2_0 + ...
            0.3*((obj.myofilaments.x(obj.myofilaments.x>=-3)+3).^3);
        r2 = r2 + 1;
        r2(r2>obj.parameters.max_rate)=obj.parameters.max_rate;
        
    case 'kyleChain'
        r1 = zeros(size(obj.myofilaments.x));
        r1 = obj.parameters.k_1 * ...
            exp(-obj.parameters.k_cb * 5 * (2*(obj.myofilaments.x).^2) / ...
            (1e18 * obj.parameters.k_boltzmann * ...
            obj.parameters.temperature));
        r1(r1>obj.parameters.max_rate)=obj.parameters.max_rate;
        
        r2 = zeros(size(obj.myofilaments.x));
        r2(obj.myofilaments.x<-6) = obj.parameters.k_2_0 + ...
            abs(0.2*((obj.myofilaments.x(obj.myofilaments.x<-6)+6).^3));
        r2(obj.myofilaments.x>=-3) = obj.parameters.k_2_0 + ...
            0.5*((obj.myofilaments.x(obj.myofilaments.x>=-3)+3).^3);
        r2 = r2 + 3;
        r2(r2>obj.parameters.max_rate)=obj.parameters.max_rate;
        
    case 'newSpindleBag'
        r1 = zeros(size(obj.myofilaments.x));
        r1 = obj.parameters.k_1 * ...
            exp(-obj.parameters.k_cb * 10 * (obj.myofilaments.x).^2 / ...
            (1e18 * obj.parameters.k_boltzmann * ...
            obj.parameters.temperature));
        r1(r1>obj.parameters.max_rate)=obj.parameters.max_rate;
        
        r2 = zeros(size(obj.myofilaments.x));
        r2(obj.myofilaments.x<-6) = obj.parameters.k_2_0 + ...
            abs(0.2*((obj.myofilaments.x(obj.myofilaments.x<-6)+6).^3));
        r2(obj.myofilaments.x>=-3) = obj.parameters.k_2_0 + ...
            0.3*((obj.myofilaments.x(obj.myofilaments.x>=-3)+3).^3);
        r2 = r2 + 0.5;
        r2(r2>obj.parameters.max_rate)=obj.parameters.max_rate;
        
    case 'newSpindleChain'
        r1 = zeros(size(obj.myofilaments.x));
        r1 = obj.parameters.k_1 * ...
            exp(-obj.parameters.k_cb * 5 * (2*(obj.myofilaments.x).^2) / ...
            (1e18 * obj.parameters.k_boltzmann * ...
            obj.parameters.temperature));
        r1(r1>obj.parameters.max_rate)=obj.parameters.max_rate;
        
        r2 = zeros(size(obj.myofilaments.x));
        r2(obj.myofilaments.x<-6) = obj.parameters.k_2_0 + ...
            abs(0.2*((obj.myofilaments.x(obj.myofilaments.x<-6)+6).^3));
        r2(obj.myofilaments.x>=-3) = obj.parameters.k_2_0 + ...
            0.5*((obj.myofilaments.x(obj.myofilaments.x>=-3)+3).^3);
        r2 = r2 + 10;
        r2(r2>obj.parameters.max_rate)=obj.parameters.max_rate;
        
    case 'newSpindleBag1'
        r1 = zeros(size(obj.myofilaments.x));
        r1 = obj.parameters.k_1 * ...
            exp(-obj.parameters.k_cb * 10 * (obj.myofilaments.x).^2 / ...
            (1e18 * obj.parameters.k_boltzmann * ...
            obj.parameters.temperature));
        r1(r1>obj.parameters.max_rate)=obj.parameters.max_rate;
        
        r2 = zeros(size(obj.myofilaments.x));
        r2(obj.myofilaments.x<-5) = obj.parameters.k_2_0 + ...
            abs(0.2*((obj.myofilaments.x(obj.myofilaments.x<-5)+5).^3));
        r2(obj.myofilaments.x>=-5) = obj.parameters.k_2_0 + ...
            0.3*((obj.myofilaments.x(obj.myofilaments.x>=-5)+5).^3);
        r2 = r2 + 0.5;
        r2(r2>obj.parameters.max_rate)=obj.parameters.max_rate;
        
    case 'newSpindleChain1'
        r1 = zeros(size(obj.myofilaments.x));
        r1 = obj.parameters.k_1 * ...
            exp(-obj.parameters.k_cb * 5 * (2*(obj.myofilaments.x).^2) / ...
            (1e18 * obj.parameters.k_boltzmann * ...
            obj.parameters.temperature));
        r1(r1>obj.parameters.max_rate)=obj.parameters.max_rate;
        
        r2 = zeros(size(obj.myofilaments.x));
        r2(obj.myofilaments.x<-5) = obj.parameters.k_2_0 + ...
            abs(0.2*((obj.myofilaments.x(obj.myofilaments.x<-5)+5).^3));
        r2(obj.myofilaments.x>=-5) = obj.parameters.k_2_0 + ...
            0.5*((obj.myofilaments.x(obj.myofilaments.x>=-5)+5).^3);
        r2 = r2 + 10;
        r2(r2>obj.parameters.max_rate)=obj.parameters.max_rate;
end

% r2 = obj.parameters.k_2_0 * ...
%             exp(-(obj.parameters.k_cb * obj.myofilaments.x * ...
%                         obj.parameters.k_2_1) ./ ...
%             (1e18 * obj.parameters.k_boltzmann * ...
%                                 obj.parameters.temperature));
% r2 = r2 + ...
%     obj.parameters.max_rate * ...
%         (1 ./ (1 + exp(-obj.parameters.k_2_2 * ...
%             (obj.myofilaments.x - obj.parameters.k_2_3))));
% 
% r2(r2>obj.parameters.max_rate)=obj.parameters.max_rate;
% r2(r2 < 0) = 0;

% Evolve the system
[t,y_new] = ode23(@derivs,[0 time_step],y,[]);

% Update the system
obj.myofilaments.y = y_new(end,:)';
obj.f_overlap = N_overlap;
obj.f_on = obj.myofilaments.y(end);
obj.f_bound = sum(obj.myofilaments.y(1+(1:obj.myofilaments.no_of_x_bins))); 

% Store rate structure
obj.rate_structure.r1 = r1;
obj.rate_structure.r2 = r2;

    % Nested function
    function dy = derivs(time_step,y)
        
        % Set dy
        dy = zeros(numel(y),1);

        % Unpack
        M1 = y(1);
        M2 = y(1+(1:obj.myofilaments.no_of_x_bins));
        N_off = y(end-1);
        N_on = y(end);
        N_bound = sum(M2);
        
        % Calculate the fluxes
        J1 = r1 .* obj.myofilaments.bin_width * M1 * (N_on - N_bound);
        J2 = r2 .* M2';
        J_on = obj.parameters.k_on * obj.Ca * (N_overlap - N_on) * ...
                (1 + obj.parameters.k_coop * (N_on/N_overlap));
        J_off = obj.parameters.k_off * (N_on - N_bound) * ...
                (1 + obj.parameters.k_coop * ((N_overlap - N_on)/N_overlap));
            
        % Calculate the derivs
        dy(1) = sum(J2) - sum(J1);
        for i=1:obj.myofilaments.no_of_x_bins
            dy(1+i) = J1(i) - J2(i);
        end
        dy(end-1) = -J_on + J_off;
        dy(end) = J_on - J_off;
    end
end
