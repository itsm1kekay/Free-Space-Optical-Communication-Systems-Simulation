%% transmitter function file
% Author: Michail Kasmeridis
% Last modified: 21/03/2024

% -------------------------------------------------------------------------
% section 2 - transmitter side
% 
% Description: convert to binary and modulate to transmit
function [modulated, binary_input]= modulator(modulation, binary_input, carrier_frequency,av_transmitted_power,BR)
    square_wave = pulse_shaping(binary_input,BR);
    switch modulation
        case "OOK"
            % modulated = 2*av_transmitted_power*ook_modulation(binary_input,carrier_frequency,BR);
            modulated = 2*av_transmitted_power*pammod(binary_input,2);
        case "16 QAM"
            modulated = 2*av_transmitted_power*qammod(binary_input,16);
        case "QPSK"
            % modulated= qpsk_modulation(binary_text,carrier_frequency);
            modulated = 2*av_transmitted_power*pskmod(binary_input,4,pi/4);
        otherwise                                                          % no modulation
            modulated = square_wave;
    end
end 

% ------------- Pulse shaping ------------%
function square_wave= pulse_shaping(binary_text,BR)
    t=0:1/BR:(length(binary_text)-1)/BR;
    square_waveform=square(BR*t);
    for i=1:length(square_waveform)
        if square_waveform(i)==-1
            square_waveform(i)=0;
        end
    end
    square_wave=square_waveform.*binary_text;
end

% ----------------------------------------%
% ------------- Modulations ------------- %
function modulated = ook_modulation(binary_text, carrier_frequency,BR)
    t=0:1/BR:(length(binary_text)-1)/BR;
    carrier_signal = cos(2*pi*carrier_frequency*t);
    modulated=carrier_signal.*binary_text;
end
% --------------------------------------- %