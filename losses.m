%% losses function file 


% ---------------------------------------------------------------------
% section 3.1 - losses in channel
% 
% convert to binary and modulate to transmit
%
% Note: my ook modulation function appears to be broken for some
% reason. It runs but it gives higher ber than expected.

function [total_losses, scattering_coefficient] = losses(transmission_location,Apperture, ...
beam_divergence,link_length,LEO_distance,misaligment,atm_conditions,wavelength)
        switch transmission_location
        case "Cosmic Space only"
            atm_atten=0;
            scattering_coefficient=0;
            scint=0; % case of insterstellar scintillation????
            TurbEff=0; 
            GML=geometrical_losses(Apperture,beam_divergence,link_length);
            PointErr=pointing_error(misaligment,link_length);

        case "Ground only"
            [atm_atten, scattering_coefficient]=atmosperic_attenuation(link_length,atm_conditions,"KRUSE",wavelength);             
            scint=scintillation("NME VI",link_length,wavelength); % scintillation model: New Model Equation 5
            TurbEff= turbulence_effect();
            GML=geometrical_losses(Apperture,beam_divergence,link_length);
            PointErr=pointing_error(misaligment,link_length);

        case "Ground via sat relay"
            [atm_atten, scattering_coefficient]=atmosperic_attenuation(LEO_distance,atm_conditions,"KIM",wavelength);
            scint=scintillation("HV",LEO_distance,wavelength);
            TurbEff= turbulence_effect();
            GML=geometrical_losses(Apperture,beam_divergence,LEO_distance);
            PointErr1=pointing_error(misaligment,LEO_distance);
            PointErr2=pointing_error(misaligment,LEO_distance);
            % for round trip
            atm_atten= 2* atm_atten;    
            TurbEff= 2* TurbEff;    
            PointErr = PointErr1 + PointErr2;
            GML = 2* GML; 

        otherwise                                                          % Cosmic Space from earth
            [atm_atten, scattering_coefficient]=atmosperic_attenuation(LEO_distance,atm_conditions,"KIM",wavelength);
            scint=scintillation("HV",LEO_distance,wavelength);
            TurbEff= turbulence_effect();
            GML1=geometrical_losses(Apperture,beam_divergence,LEO_distance);
            GML2=geometrical_losses(Apperture,beam_divergence,(link_length-LEO_distance));
            PointErr1=pointing_error(misaligment,LEO_distance);
            PointErr2=pointing_error(misaligment,(link_length - LEO_distance));

            % for whole trip
            GML= GML1 + GML2; 
            PointErr = PointErr1 + PointErr2;

        end
        total_losses=[atm_atten,scint,GML,PointErr,TurbEff];
end

% ------------------- Losses ------------------- %
function GML= geometrical_losses(Apperture,beam_divergence,link_length)
    GML=10*log10(4*Apperture/pi*(beam_divergence*link_length)^2);
end
function [atm_atten, scattering_coefficient]=atmosperic_attenuation(link_length,atm_conditions,model,wavelength)
    switch atm_conditions
        % need to add a.k,R values 
        case "Very clear air"
            visibility = 23;
        case "Clear air"
            visibility = 18;
        case "Very light mist"
            visibility = 5.9;
        case "Light mist"
            visibility = 2.8;
        case "Very light fog"
            visibility = 1.45;
        case "Light fog"
            visibility = 0.635;
        case "Moderate fog"
            visibility = 0.35;
        case "Thick fog"
            visibility = 0.125;
        case "Dense fog"
            visibility = 0.025;
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
                q=0.585*(visibility^(1/3));
            end
    end
    scattering_coefficient=(3.91/visibility)*((wavelength/550e-9)^(-q)); %in dB/km
    atm_atten=scattering_coefficient*link_length;
end

function PointErr=pointing_error(misaligment,link_length)
    %need to calculate beam width
    PointErr=0;
end

function TurbEff=turbulence_effect()
    % Rytov variation
    TurbEff=0;
end

function scint=scintillation(scintillation_model,link_length,wavelength)
    switch scintillation_model
        case "HV"
            cn2 = exp(-link_length/1000) + (2.7e-16)*exp(link_length/1500);
        case "NME VI"
            %       RH  -   relative humidity in %
            %       T   -   Temperature in C°
            %       Ws  -   Wind Speed in m/s
            %       Typical values for Glasgow:
            RH = 79;
            T = 9;
            Ws = 4.222;
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
    si2 = kappa*cn2*((2*pi/wavelength)^(7/6))*(link_length)^(11/6); 
    scint = 10*log10(si2);
end
% ---------------------------------------------- %