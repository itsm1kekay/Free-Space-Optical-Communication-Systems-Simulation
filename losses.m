%% losses function file 


% ---------------------------------------------------------------------
% section 3.2 - losses in channel
% 
% convert to binary and modulate to transmit
%
% Note: my ook modulation function appears to be broken for some
% reason. It runs but it gives higher ber than expected.

function total_losses = losses(Apperture,beam_divergence,link_length,LEO_distance,misaligment,atm_conditions)
        switch transmission_location
        case "Cosmic space only"
            atm_atten=0; 
            scint=0; % case of insterstellar scintillation????
            TurbEff=0; 
            GML=geometrical_losses(Apperture,beam_divergence,link_length);
            PointErr=pointing_error(misaligment,link_length);

        case "Ground only"
            atm_atten=atmosperic_attenuation(link_length,atm_conditions);             
            scint=scintillation("NME VI"); % scintillation model: New Model Equation 5
            TurbEff= turbulence_effect();
            GML=geometrical_losses(Apperture,beam_divergence,link_length);
            PointErr=pointing_error(misaligment,link_length);

        case "Ground via sat relay"
            atm_atten=atmosperic_attenuation(link_length,atm_conditions);
            scint=scintillation("PAMELA");
            TurbEff= turbulence_effect();
            GML=geometrical_losses(Apperture,beam_divergence,LEO_distance);
            PointErr1=pointing_error(misaligment,LEO_distance);
            PointErr1=pointing_error(misaligment,LEO_distance);

            % for round trip
            atm_atten= 2* atm_atten;    
            TurbEff= 2* TurbEff;    
            PointErr = PointErr1 + PointErr2;
            GML = 2* GML; 

        otherwise                           % Cosmic Space from earth
            atm_atten=atmosperic_attenuation(LEO_distance,atm_conditions);
            scint=scintillation("PAMELA");
            TurbEff= turbulence_effect();
            GML1=geometrical_losses(Apperture,beam_divergence,LEO_distance);
            GML2=geometrical_losses(Apperture,beam_divergence,(link_length-LEO_distance));
            PointErr1=pointing_error(misaligment,LEO_distance);
            PointErr1=pointing_error(misaligment,(link_length - LEO_distance));

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
function atm_atten=atmosperic_attenuation(link_length,atm_conditions)
    switch atm_conditions
        % need to add a.k,R values 
        case "Clear Skies"
        case "Light Rain (<2.5 mm/hr)"
        case "Medium Rain (2.7 to 7.5 mm/hr)"
        case "Heavy Rain (7.6 to 50 mm/hr)"
        case "Violent Rain (>50 mm/hr)"
        case "Light Haze"
        case "Haze"
        case "Thin Fog"
        case "Moderate Fog"
        case "Thick Fog"
        case "Dense Fog"
    end
    atm_atten=kappa_atm*Rain_intensity^alpha_atm;
end
function PointErr=pointing_error(misaligment,link_length)
    %need to calculate beam width
end
function TurbEff=turbulence_effect()
    % Rytov variation
end
function scint=scintillation()
    % use scintillation variation
end
% ---------------------------------------------- %