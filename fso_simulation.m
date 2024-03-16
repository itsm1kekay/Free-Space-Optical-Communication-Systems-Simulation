%% master function file called by app
% Author: Michail Kasmeridis
% Last modified: 15/03/2024

function [binary_output,ber_ratio,snr,total_losses,BW] =...
        fso_simulation(binary_input,modulation,link,transmitter)
    % ---------------------------------------------------------------------
    % section 1 - setup
    carrier_frequency= 3e8/transmitter.wavelength;    
    demodulation = modulation;                                              % same modulation/demodulation technique
    switch modulation
        case "QPSK"
            BW=link.BR/log2(4);
        case "16 QAM"
            BW=link.BR/log2(16);
        otherwise                                                           % OOK and no modulation
            BW=link.BR/log2(2);
    end
    % ---------------------------------------------------------------------
    % section 2 - transmitter side
    modulated= modulator(modulation,binary_input,carrier_frequency,...
        transmitter.av_trans_power,link.BR);
    % ---------------------------------------------------------------------
    % section 3 - channel
    [through_channel_noisy,snr, total_losses,av_received_power] = channel(modulated, ...
        link,transmitter,BW);
    % ---------------------------------------------------------------------
    % section 4 - receiver side   
    binary_output = receiver(demodulation,...
        through_channel_noisy,av_received_power,transmitter.av_trans_power);
    % disp(['Output text is: ' text_output]);
    disp(['SNR is: ' num2str(snr) ' dB']);
    % ---------------------------------------------------------------------
    % section 5 - analytics
    ber_ratio = analytics(binary_output ,binary_input);
    disp(['Ber is: ' num2str(ber_ratio)]);
    % ---------------------------------------------------------------------
end