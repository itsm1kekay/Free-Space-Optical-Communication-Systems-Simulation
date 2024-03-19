%% losses function file 
% Author: Michail Kasmeridis
% Last modified: 15/03/2024


% -------------------------------------------------------------------------
% section 3.1 - losses in channel
% 
% Description: calculate the losses in the channel for the given parameters

function [total_losses,rytov] = losses(link,LEO_distance,transmitter,receiver)
    atm_conditions=link.atm_conditions;
    wavelength=transmitter.wavelength;
    max_length_for_scattering=20;
        switch link.location
        case "Cosmic Space only"
            atm_atten=0;
            cn2=0;
            rytov=0;
            [GML,PE]=GML_and_PE_losses(transmitter,link,receiver,transmitter.misalignment(1),transmitter.misalignment(2),cn2);
        case "Ground only"
            scattering_coefficient=scattering(atm_conditions,"KIM",wavelength);             
            [scint,rytov,cn2]=scintillation("NME VI",link.length,wavelength,0); % scintillation model: New Model Equation 5
            [GML,PE]=GML_and_PE_losses(transmitter,link,receiver,transmitter.misalignment(1),transmitter.misalignment(2),cn2);
            atm_atten=pow2db(db2pow(scattering_coefficient*link.length)+db2pow(scint));
        case "Ground via sat relay"
            scattering_coefficient=scattering(atm_conditions,"KIM",wavelength);
            [scint,rytov,cn2]=scintillation("MHV",2*LEO_distance,wavelength,2*LEO_distance);
            link.length=LEO_distance;
            [GML1,PE1]=GML_and_PE_losses(transmitter,link,receiver,transmitter.misalignment(1),transmitter.misalignment(2),cn2);
            [GML2,PE2]=GML_and_PE_losses(transmitter,link,receiver,transmitter.misalignment(3),transmitter.misalignment(4),cn2);
            % for round trip
            atm_atten=pow2db(db2pow(scattering_coefficient*2*max_length_for_scattering)+db2pow(scint));
            GML=pow2db(db2pow(GML1)+db2pow(GML2));
            PE=pow2db(db2pow(PE1)+db2pow(PE2));
        otherwise                                                          % Cosmic Space from earth
            scattering_coefficient=scattering(atm_conditions,"KIM",wavelength);
            [scint,rytov,cn2]=scintillation("MHV",LEO_distance,wavelength,LEO_distance);
            link.length=LEO_distance;
            [GML1,PE1]=GML_and_PE_losses(transmitter,link,receiver,transmitter.misalignment(1),transmitter.misalignment(2),cn2);
            [GML2,PE2]=GML_and_PE_losses(transmitter,link,receiver,transmitter.misalignment(3),transmitter.misalignment(4),cn2);
            atm_atten=pow2db(db2pow(scattering_coefficient*max_length_for_scattering)+db2pow(scint));
            % for whole trip
            GML=pow2db(db2pow(GML1)+db2pow(GML2));
            PE=pow2db(db2pow(PE1)+db2pow(PE2));
        end
        total_losses.gml=GML;
        total_losses.atm=atm_atten;
        total_losses.pe=PE;
end

% ------------------- Losses ------------------- %
function [GML,PE]= GML_and_PE_losses(transmitter,link,receiver,deviation_x,deviation_y,cn2)
    % geometrical losses
    beam_waist_at0=sqrt(2)*receiver.radius/pi;  
    theta_rad=transmitter.wavelength*1e3*pi/(pi*beam_waist_at0*180); 
    GML=10*log10(receiver.apperture/pi*(theta_rad*link.length*1e3)^2);
    % % pointing error losses
    % omega_at_0=transmitter.apperture*sqrt(2)/pi;               % D/(sqrt(2)*pi) where D=2*sqrt(transmitter.apperture/pi)
    % coherence_length=1; % integral from h0 to H of (0.55*cn2(l)*(2*pi/wavelength)^2*l)^(-3/5)dl
    % e= (1+2*omega_at_0^2/coherence_length^2);
    % omega_at_z=omega_at_0*(1+ e*(transmitter.wavelength*link.length/...
    %     (pi*omega_at_0^2))^2)^0.5;
    % rho=1;
    % light_beam.irradiance=2*exp(-2*abs(rho)^2/omega_at_z^2)/pi*omega_at_z^2;
    % second approach to pointing error losses
    cartesian_x=sin(deviation_x*pi/180)*link.length;
    cartesian_y=sin(deviation_y*pi/180)*link.length;
    radial_distance_from_receiver=sqrt((cartesian_x^2)+(cartesian_y^2));
    omega_at_0= transmitter.apperture*sqrt(2)/pi;               % D/(sqrt(2)*pi) where D=2*sqrt(transmitter.apperture/pi)
    wave_number=2*pi/transmitter.wavelength;
    rho_0_at_z=(0.55*cn2*(wave_number^2)*link.length)^(-3/5);
    epsilon=(1+2*(omega_at_0^2)/rho_0_at_z^2);
    omega_at_z= omega_at_0*(1+epsilon*(transmitter.wavelength*link.length/(pi*omega_at_0^2))^2)^0.5;
    vi=(sqrt(pi)*receiver.radius)/(sqrt(2)*omega_at_z);
    A0=(erf(vi))^2;
    omega_at_z_eq_squared=(omega_at_z^2)*(sqrt(pi)*erf(vi))/(2*vi*exp(-(vi^2)));
    fraction_of_power_collected=A0*exp(-(2*radial_distance_from_receiver^2)/omega_at_z_eq_squared);
    PE=10*log10(fraction_of_power_collected);
end
function scattering_coefficient=scattering(atm_conditions,model,wavelength)
    switch atm_conditions
        % need to add a.k,R values 
        case "Very clear air"
            visibility = 23;
        case "Clear air"
            visibility = 18.1;
        case "Very light mist"
            visibility = 5.9;
        case "Light mist"
            visibility = 2;
        case "Very light fog"
            visibility = 1;
        case "Light fog"
            visibility = 0.77;
        case "Moderate fog"
            visibility = 0.5;
        case "Thick fog"
            visibility = 0.200;
        case "Dense fog"
            visibility = 0.05;
    end
    switch model
        case "KIM"
            if visibility>=50
                q=1.6;
            elseif visibility<50 && visibility>6
                q=1.3;
            elseif visibility<=6 && visibility>1
                q=0.16*visibility+ 0.34;
            elseif visibility<=1 && visibility>0.5
                q=visibility-0.5;
            elseif visibility <=0.5
                q=0;
            end
        case "KRUSE"
            if visibility>=50
                q=1.6;
            elseif visibility <50 && visibility>6
                q=1.3;
            elseif visibility<=6
                q=0.585*(visibility^0.333);
            end
    end
    scattering_coefficient=(13/visibility)*((wavelength/550e-9)^(-q)); %in dB/km
end

function [scint,rytov,cn2]=scintillation(scintillation_model,link_length,wavelength,altitude)
        %       RH  -   relative humidity in %
        %       T   -   Temperature in C°
        %       Ws  -   Wind Speed in m/s
        %       Typical values for Glasgow:
        RH = 79;
        T = 9;
        Ws = 4.222;
    switch scintillation_model
        case "SLC-Day"
            if altitude <19*e-3 && altitude >=0
                cn2=0;
            elseif altitude<230e-3 && altitude >=19e-3
                cn2=(4.008e-13)*altitude^-1.054;
            elseif altitude<850e-3 && altitude>=250e-3
                cn2=1.3*altitude*1e-15;
            elseif altitude<7 && altitude>=850e-3
                cn2=(6.352e-7)*altitude^-2.966;
            elseif altitude<20 && altitude>=7
                cn2=(6.209e-16)*altitude^-0.6229;
            end
        case "MHV"
            % cn2 = (8.16e-54)*((altitude*1e3)^10)*exp(-(altitude*1e3)/1000)+...
            %     (3.02e-17)*exp(-(altitude*1e3)/1500)+(1.90e-15)*exp(-(altitude*1e3)/100);
            cn2 = (8.16e-54)*((altitude)^10)*exp(-(altitude)/1000)+...
                (3.02e-17)*exp(-(altitude)/1500)+(1.90e-15)*exp(-(altitude)); % using km instead of m works!
        case "NME VI"
            
            cn2 = 1e-14*(5360.63+21.0442*Ws ...
                -281.763*T-63.5576*RH-0.0431099*(Ws^2) ...
                -0.101587*Ws*T-0.271695*Ws*RH ... 
                +2.19559*T*RH-0.26449*(Ws^3) ...
                +0.199294*(T^3)+0.0168798*T*(RH^2) ...
                +0.000579369*(RH^3)-0.001449*(Ws^4) ...
                +0.0101365*(Ws^3)*T+0.00092494*(Ws^3)*RH ...
                -0.00159949*(Ws^2)*(T^2) +0.000118693*(Ws^2)*(RH^2) ...
                -0.00265882*(T^4)-0.000436822*(T^3)*RH ...
                -0.000335601*(T^2)*(RH^2)+7.60425e-6*(RH^3)*Ws ...
                -6.82247e-5*(RH^3)*T+1.65979e-6*(RH^4));
    end 
    % if gaussian_plane==1
    %     kappa =1.23;
    % elseif spherical_plane==1 
    %     kappa =0.5;
    % end
    kappa = 1.23;
    rytov = kappa*cn2*((2*pi/wavelength)^(7/6))*(link_length)^(11/6); 
    scint=sqrt(23.12*((2*pi*1e-9)/wavelength)^(7/6)*cn2*(link_length*1e3)^(11/6));
end
% ---------------------------------------------- %