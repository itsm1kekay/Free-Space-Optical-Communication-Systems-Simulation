function [text_output,ber_ratio,snr,total_losses] = fso_simulation(text_input,wavelength,modulation,transmission_location,link_length,BR,Apperture,beam_divergence,atm_conditions,misaligment)
    % ---------------------------------------------------------------------
    % section 1 - setup
    frequency= 3e8/wavelength;
    LEO_distance = 2000;                                                    % leo distance from earth: 2000 km    
    demodulation = modulation;                                              % same modulation/demodulation technique
    av_transmitted_power = 1; 
    h = 6.626e-34;                                                          % Planck's constant
    elemental_charge = 1.60217663e-19;                                      % elemental charge (in Coulombs)
    quantum_efficiency=0;                                                   % quantum efficiency of photodiode receiver
    photodiode_responsivity= quantum_efficiency*elemental_charge/(h*frequency);
    

    % ---------------------------------------------------------------------
    % section 2 - transmitter side
    [modulated, binary_text]= transmitter(modulation,text_input, frequency);
    
    % ---------------------------------------------------------------------
    % section 3.1 - channel
    [through_channel_noisy,snr] = channel(modulated);

    % ---------------------------------------------------------------------
    % section 3.2 - losses
    total_losses = losses(transmission_location,Apperture,beam_divergence,link_length,LEO_distance,misaligment,atm_conditions,wavelength);

    % ---------------------------------------------------------------------
    % section 4 - receiver side   
    [text_output, demodulated_signal] = receiver(demodulation,through_channel_noisy,frequency);
    disp(['Output text is: ' text_output]);
    disp(['SNR is: ' num2str(snr) ' dB']);

    % ---------------------------------------------------------------------
    % section 5 - analytics
    ber_ratio = analytics(demodulated_signal ,binary_text);

end

% ------------------------------ Functions ------------------------------ %
% ----------------------------------------------------------------------- %