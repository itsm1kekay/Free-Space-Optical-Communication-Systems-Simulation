%% receiver function file

% ---------------------------------------------------------------------
    % section 4 - receiver side
    % 
    % Filtering with fft, demodulation, thresholding and converting the
    % demodulated binary message back to ascii.
    %
    % Note: the ook modulation - demodulation function appears to be 
    % broken. It runs but gives higher ber than expected.
    function [text_output, thresholded_signal]=receiver(demodulation,through_channel_noisy,carrier_frequency,BR)
    
    switch demodulation
    case "OOK"
        demodulated_signal = ook_demodulation(through_channel_noisy,carrier_frequency,BR);
    case "QPSK"
        demodulated_signal = pskdemod(through_channel_noisy,4,pi/4);
    case "16 QAM"
        demodulated_signal = qamdemod(through_channel_noisy,16);
        otherwise                                                          % no demodulation
        demodulated_signal = through_channel_noisy;
    end
    
    filteredSignal = fft_filtering(demodulated_signal);
    
    thresholded_signal = threshold(demodulated_signal);
    
    text_output = binaryToText(thresholded_signal);
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
function filteredSignal = fft_filtering(demodulated_signal)
    n=length(demodulated_signal);
    fhat=fft(demodulated_signal,n);
    PSD=fhat.*conj(fhat)/n;
    indices= PSD>0.15;
    fhat=indices.*fhat;
    filteredSignal=ifft(fhat);
end
% ------------------------------------- %
% ----------- Thresholding ------------ %
function thresholded_signal= threshold(filteredSignal)
    threshold_value= max(filteredSignal)/2;
    thresholded_signal=zeros(1,length(filteredSignal));
    for i=1:length(filteredSignal)
        % if demodulated_signal(i) >= threshold_value
        %     demodulated_signal(i) = 1;
        % elseif demodulated_signal(i) < threshold_value
        %     demodulated_signal(i)=0;
        % end
        if filteredSignal(i)>=threshold_value
            thresholded_signal(i)=1;
        else
            thresholded_signal(i)=0;
        end
    end
    % thresholded_signal=filteredSignal;
end
% ------------------------------------- %
% ------------- Demodulations ------------- %
function demodulatedSignal = ook_demodulation(through_channel_noisy,carrier_frequency,BR)
    % t = 0:1/BR:(length(filteredSignal)-1)/BR;
    % matchedFilter = 0.2*cos(2 * pi * carrier_frequency * t);
    % % demodulatedSignal = abs(conv(filteredSignal, fliplr(matchedFilter), 'same'));
    % demodulatedSignal = abs(conv(filteredSignal, matchedFilter, 'same'));
    % % threshold = max(demodulatedSignal) / 2; 
    % % demodulatedSignal = demodulatedSignal > threshold;
    demodulatedSignal = abs(hilbert(through_channel_noisy));
    
end
% ----------------------------------------- %