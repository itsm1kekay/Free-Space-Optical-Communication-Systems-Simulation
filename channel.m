%% channel function file
% Author: Michail Kasmeridis
% Last modified: 21/03/2024

% ---------------------------------------------------------------------
% section 3 - channel
% 
% Description: Introduction to channel - noise and losses
% -------------------------------------------------------------------------

function [through_channel_noisy,snr_db, total_losses,av_received_power,distribution] = channel(modulated, ...
    link,transmitter,receiver,constants)
    av_transmitted_power=transmitter.av_trans_power;
    LEO_distance = 2000;                                                    % leo distance from earth: 2000 km
% ---------------------------------------------------------------------
% section 3.1 - losses
    [total_losses,rytov] = losses(link,LEO_distance,transmitter,receiver);
% ---------------------------------------------------------------------
% section 3.2 - distributions
% ---------------------------------------------------------------------
    if rytov <= 0.5 % weak turbulence
        % --------------------------------negative exponential distribution
        through_channel=modulated;
        distribution='Negative Exponential distribution (weak turbulence)';
    elseif rytov > 0.5 && rytov <= 5 % medium-strong turbulence
        % ------------------------------------------log normal distribution
        mean=1;
        variance=rytov;
        mu=log((mean^2)/sqrt(variance+mean^2));
        sigma = sqrt(log(variance/(mean^2)+1));
        through_channel=modulated.*lognrnd(mu,sigma,[1 length(modulated)]);
        distribution='Log Normal distribution (medium turbulence)';
    elseif rytov > 5 && rytov <= 25 % strong turbulence - saturation
        % -----------------------------------------gamma gamma distribution
        a=(exp((0.49*rytov^2)/(1+0.56*rytov^(12/6))^(7/6))-1)^-1;
        b=(exp((0.51*rytov^2)/(1+0.69*rytov^(12/6))^(5/6))-1)^-1;
        gamma1=gamrnd(a,b,[1,length(modulated)]);
        gamma2=gamrnd(a,b,[1,length(modulated)]);
        through_channel=modulated.*gamma1.*gamma2;
        distribution='Gamma Gamma distribution (strong turbulence)';
    end
    % ---------------------------------------------------------------------
    % section 3.3 noises
    % noise_bandwidth = 3e16; % typical value for receivers
    % shot_noise_current=2*constants.charge*receiver.photodiode_responsivity*av_transmitted_power*noise_bandwidth; % transmitted power or received?
    % thermal_noise_current=4*constants.boltzman*receiver.temperature*noise_bandwidth/receiver.resistance;
    % dark_noise_current=2*constants.charge*noise_bandwidth*300e-9; % 300 nA is typical for Germanium APDs
    % total_noise_current=shot_noise_current+thermal_noise_current+dark_noise_current;

    % attempt 2
    noise_bandwidth=1.25*link.BR;
    receiver.gain=10^(receiver.gain/10);
    NEP_noise_power=receiver.noise_equivalent_power*sqrt(noise_bandwidth);
    background_power=0.01e-3; % background light power, assumed to be a constant
    background_noise_power=(receiver.gain^2)*(2*constants.charge*receiver.photodiode_responsivity*background_power*noise_bandwidth/receiver.resistance);
    shot_noise_power=(receiver.gain^2)*(2*constants.charge*receiver.photodiode_responsivity*transmitter.av_trans_power*1*noise_bandwidth/receiver.resistance);
    total_noise_power=NEP_noise_power+background_noise_power+shot_noise_power;
    % ---------------------------------------------------------------------
    % power_losses_linear=10^(total_losses.geometrical/10)+10^(total_losses.atmospheric/10)+10^(total_losses.pointing/10);
    power_losses_linear=db2pow(total_losses.gml)+db2pow(total_losses.atm)+db2pow(total_losses.pe);
    % av_received_power=(10^(receiver.gain/10))*av_transmitted_power-power_losses_linear;
    av_received_power=((receiver.gain*receiver.photodiode_responsivity)^2*av_transmitted_power/receiver.resistance)/power_losses_linear*10^(receiver.NF/10);
    % snr=((receiver.photodiode_responsivity*av_received_power)^2)/total_noise_current;
    snr=av_received_power/(total_noise_power);
    snr_db=pow2db(snr);
    through_channel_noisy = awgn(through_channel,snr_db,'measured');
end 