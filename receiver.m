%% receiver function file

% ---------------------------------------------------------------------
    % section 4 - receiver side
    % 
    % Filtering with fft, demodulation, thresholding and converting the
    % demodulated binary message back to ascii.
    %
    % Note: the ook modulation - demodulation function appears to be 
    % broken. It runs but gives higher ber than expected.
    function [text_output, thresholded_signal]=receiver(demodulation,through_channel_noisy,BR,av_transmitted_power)

    switch demodulation
    case "OOK"
        demodulated_signal = ook_demodulation(through_channel_noisy,BR);
        filteredSignal=fft_filtering(demodulated_signal);
        thresholded_signal = threshold(filteredSignal);
    case "QPSK"
        demodulated_signal = pskdemod(through_channel_noisy,4,pi/4);
        thresholded_signal = threshold(demodulated_signal);
    case "16 QAM"
        demodulated_signal = qamdemod(through_channel_noisy,16);
        filteredSignal = fft_filtering(demodulated_signal);
        thresholded_signal = threshold(filteredSignal);
        otherwise                                                          % no demodulation
        demodulated_signal = through_channel_noisy;
        filteredSignal = fft_filtering(demodulated_signal);
        thresholded_signal = threshold(filteredSignal);
    end
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
    fhat=fft(demodulated_signal,length(demodulated_signal));
    PSD=fhat.*conj(fhat)/length(demodulated_signal);
    indices= PSD>0.15;
    fhat=indices.*fhat;
    filteredSignal=ifft(fhat); 
    % y=.15*ones(1,length(demodulated_signal));
    % plot(PSD);
    % hold on;
    % plot(y);
    % hold off;
end
% ------------------------------------- %
% ----------- Thresholding ------------ %
function thresholded_signal= threshold(filteredSignal)
    threshold_value= max(peak2peak(filteredSignal))/2;
    thresholded_signal=zeros(1,length(filteredSignal));
    for i=1:length(filteredSignal)
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
function demodulatedSignal = ook_demodulation(through_channel_noisy,BR)
    % -------------------------------------------------------------attempt1
    % t = 0:1/BR:(length(through_channel_noisy)-1)/BR;
    % matchedFilter = fft(cos(2 * pi * carrier_frequency * t));
    % demodulatedSignal = abs(conv(through_channel_noisy, fliplr(matchedFilter), 'same'));
    % -------------------------------------------------------------attempt2
    through_channel_noisy_FD = fft(through_channel_noisy);
    demodulatedSignal=ifft(conj(through_channel_noisy_FD).*through_channel_noisy_FD);
    % demodulatedSignal = max(matched_filter_output) / 2; 
    % demodulatedSignal = demodulatedSignal > threshold;
    % -------------------------------------------------------------attempt3
    % demodulatedSignal = abs(hilbert(through_channel_noisy));
        
end
% ----------------------------------------- %