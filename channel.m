%% channel function file

% ---------------------------------------------------------------------
% section 3 - channel
% 
% Introduction to channel - noise and channel attenuation/losses
%
% Note: the channel attenuation/losses haven't been added yet because
% I'm still figuring them out

function [through_channel_noisy,snr, total_losses,av_received_power] = channel(modulated, ...
transmission_location,Apperture,beam_divergence, link_length, ...
LEO_distance, misaligment,atm_conditions,wavelength, ...
av_transmitted_power,BW)
% ---------------------------------------------------------------------
% section 3.1 - losses
    [total_losses,scattering_coefficient] = losses(transmission_location,Apperture,beam_divergence, ...
    link_length,LEO_distance,misaligment,atm_conditions,wavelength);
% ---------------------------------------------------------------------
% section 3.2 - distributions
% ---------------------------------------------------------------------

    if scattering_coefficient <= 0.5 % weak turbulence
        % --------------------------------negative exponential distribution
        through_channel=modulated;
    elseif scattering_coefficient > 0.5 && scattering_coefficient <= 5 % medium-strong turbulence
        % ------------------------------------------log normal distribution
        mean=1;
        variance=2;
        mu=log((mean^2)/sqrt(variance+mean^2));
        sigma = sqrt(log(variance/(mean^2)+1));
        r = lognrnd(mu,sigma,[1 length(modulated)]);
        through_channel=modulated+r;
    elseif scattering_coefficient > 5 && scattering_coefficient <= 25 % strong turbulence - saturation
        % -----------------------------------------gamma gamma distribution
        % gamrnd(x,y).*gamrd(x1,y1)
        through_channel=modulated;
        
    end
    % ---------------------------------------------------------------------
    % section 3.3 noises
    % constants------------------------------------------------------------
    h = 6.626e-34;                                                          % Planck's constant
    elemental_charge = 1.60217663e-19;                                      % elemental charge (in Coulombs)
    boltzman_constant= 1.380649e-23;
    % ---------------------------------------------------------------------
    % receiver characteristics---------------------------------------------
    temperature= 350; %typical value - should make conditional select
    quantum_efficiency=0.95; %should find typical values
    photodiode_responsivity= quantum_efficiency*elemental_charge/(h*3e8/wavelength);
    receiver_resistance=50; %typical value
    % ---------------------------------------------------------------------
    % noises---------------------------------------------------------------
    noise_bandwidth = BW; % how is this defined? i've used bw=rb/log2(m)
    shot_noise=2*elemental_charge*photodiode_responsivity*av_transmitted_power*noise_bandwidth; % transmitted power or received?
    thermal_noise=4*boltzman_constant*temperature*noise_bandwidth/receiver_resistance;
    dark_current_noise=0;
    total_noise=shot_noise+thermal_noise+dark_current_noise;
    % ---------------------------------------------------------------------
    power_losses_dB=pow2db(db2pow(total_losses(1))+db2pow(total_losses(2))+db2pow(total_losses(3))+db2pow(total_losses(4))+db2pow(total_losses(5)));
    av_received_power=db2pow(pow2db(av_transmitted_power)-power_losses_dB);
    irradiance=photodiode_responsivity*av_received_power;
    snr= (irradiance^2)/(total_noise);
    through_channel_noisy = awgn(through_channel,snr,'measured');
end 