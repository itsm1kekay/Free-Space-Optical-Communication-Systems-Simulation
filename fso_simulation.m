function [text_output,ber_ratio,snr,total_losses,thresholded_signal,...
    binary_text,BW] = fso_simulation(text_input,wavelength,modulation, ...
    transmission_location,link_length,BR,Apperture,beam_divergence, ...
    atm_conditions,misaligment,av_transmitted_power)
    % ---------------------------------------------------------------------
    % section 1 - setup
    carrier_frequency= 3e8/wavelength;
    LEO_distance = 2000;                                                    % leo distance from earth: 2000 km    
    demodulation = modulation;                                              % same modulation/demodulation technique
    switch modulation
        case "QPSK"
            BW=BR/log2(4);
        case "16 QAM"
            BW=BR/log2(16);
        otherwise                                                           % OOK and no modulation
            BW=BR/log2(2);
    end
    % ---------------------------------------------------------------------
    % section 2 - transmitter side
    [modulated, binary_text]= transmitter(modulation,text_input,carrier_frequency,av_transmitted_power,BR);
    % ---------------------------------------------------------------------
    % section 3 - channel
    [through_channel_noisy,snr, total_losses] = channel(modulated, ...
    transmission_location,Apperture,beam_divergence, ...
    link_length,LEO_distance,misaligment,atm_conditions,wavelength, ...
    av_transmitted_power,BW);
    % ---------------------------------------------------------------------
    % section 4 - receiver side   
    [text_output, thresholded_signal] = receiver(demodulation,through_channel_noisy,av_transmitted_power);
    disp(['Output text is: ' text_output]);
    disp(['SNR is: ' num2str(snr) ' dB']);
    % ---------------------------------------------------------------------
    % section 5 - analytics
    ber_ratio = analytics(thresholded_signal ,binary_text);
    disp(['Ber is: ' num2str(ber_ratio)]);
    % ---------------------------------------------------------------------
    % section 6 - MonteCarlo
    % monte_carlo(thresholded_signal,binary_text);
end

% ------------------------------ Functions ------------------------------ %
% ----------------------------------------------------------------------- %