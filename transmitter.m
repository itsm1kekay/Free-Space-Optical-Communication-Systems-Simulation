%% transmitter function file
% Author: Michail Kasmeridis
% Last modified: 07/03/2024

% -------------------------------------------------------------------------
% section 2 - transmitter side
% 
% Description: convert to binary and modulate to transmit
function [modulated, binary_text]= transmitter(modulation, text_input, carrier_frequency,av_transmitted_power,BR)
    binary_text = textToBinary(text_input); % ascii to binary conversion
    square_wave = pulse_shaping(binary_text,BR);
    switch modulation
    case "OOK"
        modulated = av_transmitted_power*ook_modulation(binary_text,carrier_frequency,BR);
    case "16 QAM"
        modulated = av_transmitted_power*qammod(binary_text,16);
    case "QPSK"
        % modulated= qpsk_modulation(binary_text,carrier_frequency);
        modulated = av_transmitted_power*pskmod(binary_text,4,pi/4);
        otherwise                                                          % no modulation
        modulated = binary_text;
    end
end 

% ------------- Conversion -------------- %
function doubleString = textToBinary(text_input)
    % Convert character to ASCII values & then binary
    binaryCell = cellstr(dec2bin(double(text_input), 8));
    % Concatenate binary strings
    binaryString = strcat(binaryCell{:});
    for i=1:length(binaryString)
        doubleString(i) = str2double(binaryString(i));
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