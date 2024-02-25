function [text_output,ber_ratio,snr,total_losses,thresholded_signal,binary_text] = fso_simulation(text_input,wavelength,modulation,transmission_location,link_length,BR,Apperture,beam_divergence,atm_conditions,misaligment,av_transmitted_power)
    % ---------------------------------------------------------------------
    % section 1 - setup
    carrier_frequency= 3e8/wavelength;
    LEO_distance = 2000;                                                    % leo distance from earth: 2000 km    
    demodulation = modulation;                                              % same modulation/demodulation technique
    h = 6.626e-34;                                                          % Planck's constant
    elemental_charge = 1.60217663e-19;                                      % elemental charge (in Coulombs)
    quantum_efficiency=0;                                                   % quantum efficiency of photodiode receiver
    photodiode_responsivity= quantum_efficiency*elemental_charge/(h*carrier_frequency);
    
    % ---------------------------------------------------------------------
    % section 2 - transmitter side
    [modulated, binary_text]= transmitter(modulation,text_input,carrier_frequency,av_transmitted_power,BR);
    
    % ---------------------------------------------------------------------
    % section 3 - channel
    [through_channel_noisy,snr, total_losses] = channel(modulated, ...
    transmission_location,Apperture,beam_divergence, ...
    link_length,LEO_distance,misaligment,atm_conditions,wavelength);

    % ---------------------------------------------------------------------
    % section 4 - receiver side   
    [text_output, thresholded_signal] = receiver(demodulation,through_channel_noisy,carrier_frequency,BR);
    disp(['Output text is: ' text_output]);
    disp(['SNR is: ' num2str(snr) ' dB']);

    % ---------------------------------------------------------------------
    % section 5 - analytics
    ber_ratio = analytics(thresholded_signal ,binary_text);
    disp(['Ber is: ' ber_ratio]);
    
    % ---------------------------------------------------------------------
    % section 6 - MonteCarlo
    % monte_carlo(thresholded_signal,binary_text);
end

% ------------------------------ Functions ------------------------------ %
% ----------------------------------------------------------------------- %