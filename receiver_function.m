%% receiver function file

% ---------------------------------------------------------------------
    % section 4 - receiver side
    % 
    % Filtering with fft, demodulation, thresholding and converting the
    % demodulated binary message back to ascii.
    %
    % Note: the ook modulation - demodulation function appears to be 
    % broken. It runs but gives higher ber than expected.
    function [text_output, demodulated_signal]=receiver_function(demodulation, through_channel_noisy,carrier_frequency)
    filteredSignal = fft_filtering(through_channel_noisy);

    switch demodulation
    case "OOK"
        demodulated_signal = ook_demodulation(filteredSignal,carrier_frequency);
    case "QPSK"
        demodulated_signal = pskdemod(filteredSignal,4,pi/4);
    otherwise 
        demodulated_signal = filteredSignal;
    end

    for i=1:length(demodulated_signal)
        if demodulated_signal(i) >= 1
            demodulated_signal(i)=1;
        else
            demodulated_signal(i)=0;
        end
    end
    
    text_output = binaryToText(demodulated_signal);
end

% ------------- Conversions ------------- %
function textResult = binaryToText(demodulated_signal)
    charString= num2str(demodulated_signal);
    charString= strcat(charString(:))';
    binarySegments = reshape(charString, 8, length(charString)/8)';
    binarySegmentsCell = arrayfun(@(row) num2str(binarySegments(row, :)), 1:size(binarySegments, 1), 'UniformOutput', false);
    decimalValues = bin2dec(binarySegmentsCell);
    textResult = char(decimalValues');
end
% --------------------------------------- %
% ------------- Filtering ------------- %
function filteredSignal = fft_filtering(through_channel_noisy)
    n=length(through_channel_noisy);
    fhat=fft(through_channel_noisy,n);
    PSD=fhat.*conj(fhat)/n;
    indices= PSD>0.15;
    fhat=indices.*fhat;
    filteredSignal=ifft(fhat);
end
% ------------------------------------- %
% ------------- Demodulations ------------- %
function demodulatedSignal = ook_demodulation(filteredSignal,carrier_frequency)
    t = 0:length(filteredSignal);
    matchedFilter = cos(2 * pi * carrier_frequency * t);
    demodulatedSignal = abs(conv(filteredSignal, fliplr(matchedFilter), 'same'));
    threshold = max(demodulatedSignal) / 2; 
    demodulatedSignal = demodulatedSignal > threshold;
end
% ----------------------------------------- %