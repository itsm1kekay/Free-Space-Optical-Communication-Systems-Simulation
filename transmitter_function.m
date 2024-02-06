%% transmitter function file


% ---------------------------------------------------------------------
% section 2 - transmitter side
% 
% convert to binary and modulate to transmit
%
% Note: my ook modulation function appears to be broken for some
% reason. It runs but it gives higher ber than expected.
function [modulated, binary_text]= transmitter_function(modulation, text_input, carrier_frequency)

    binary_text = textToBinary(text_input); % ascii to binary conversion
    
    switch modulation
    case "OOK"
        modulated = ook_modulation(binary_text,carrier_frequency);
    case "QPSK"
        % modulated= qpsk_modulation(binary_text,carrier_frequency);
        modulated = pskmod(binary_text,4,pi/4);
    otherwise
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
% ------------- Modulations ------------- %
function modulated = ook_modulation(binary_text, carrier_frequency)
t=1:length(binary_text);
carrier_signal = cos(2*pi*carrier_frequency*t);
modulated=carrier_signal.*binary_text;
end
% --------------------------------------- %