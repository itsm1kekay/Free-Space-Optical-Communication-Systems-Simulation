% text_input='THE QUICK BROWN FOX JUMPED OVER THE LAZY DOG. ';
% wavelength = 1550e-9;
% modulation = "QPSK";
% transmission_location = ""
% link_length = 2;
% BitRate = 1e6;

function [text_output,ber_ratio,snr,total_losses] = fso_simulation(text_input,wavelength,modulation,transmission_location,link_length,BitRate,Apperture,beam_divergence,atm_conditions,misaligment)
    % ---------------------------------------------------------------------
    % section 1 - setup
    % 
    % calculations using channel parameters and quantification of losses
    %
    % Note: some lines of code are commented out since they are still in
    % development and the program will break with uncommented!


    carrier_frequency= 3e8/wavelength;
    LEO_distance = 2000; % leo distance from earth: 2000 km    
    demodulation = modulation; % same modulation/demodulation technique

    % ---------------------------------------------------------------------
    % section 2 - transmitter side
    [modulated, binary_text]= transmitter(modulation,text_input, carrier_frequency);
    
    % ---------------------------------------------------------------------
    % section 3.1 - channel
    [through_channel_noisy,snr] = channel(modulated);

    % ---------------------------------------------------------------------
    % section 3.2 - losses
    total_losses = losses(Apperture,beam_divergence,link_length,LEO_distance,misaligment,atm_conditions);

    % ---------------------------------------------------------------------
    % section 4 - receiver side   
    [text_output, demodulated_signal] = receiver_function(demodulation,through_channel_noisy,carrier_frequency);
    disp(['Output text is: ' text_output]);
    disp(['SNR is: ' num2str(snr) ' dB']);

    % ---------------------------------------------------------------------
    % section 5 - analytics
    ber_ratio = analytics(demodulated_signal ,binary_text);

end

% ------------------------------ Functions ------------------------------ %


% ----------------------------------------------------------------------- %