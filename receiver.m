%% receiver function file
% Author: Michail Kasmeridis
% Last modified: 15/03/2024

% ---------------------------------------------------------------------
% section 4 - receiver side
% 
% Description: Filtering with fft, demodulation, thresholding and converting 
% the demodulated binary message back to ascii.

function binary_output=receiver(demodulation,through_channel_noisy,av_received_power,av_transmitted_power)
    switch demodulation
        case "OOK"
            through_channel_noisy=through_channel_noisy/av_received_power;
            thresholded_signal = threshold(through_channel_noisy,"TRUE",av_received_power);
        case "QPSK"
            demodulated_signal = pskdemod(through_channel_noisy,4,pi/4);
            thresholded_signal = threshold(demodulated_signal,"FALSE",av_received_power);
        case "16 QAM"   
            through_channel_noisy=through_channel_noisy/(2*av_transmitted_power);
            demodulated_signal = qamdemod(through_channel_noisy,16);
            thresholded_signal = threshold(demodulated_signal,"FALSE",av_received_power);
            % thresholded_signal=demodulated_signal;
        otherwise                                                          % no demodulation
            demodulated_signal = through_channel_noisy;
            filteredSignal = fft_filtering(demodulated_signal);
            thresholded_signal = threshold(filteredSignal,"FALSE",av_received_power);
    end
    binary_output=thresholded_signal;
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
function thresholded_signal= threshold(inputSignal,is_ook,av_transmitted_power)
    thresholded_signal=zeros(1,length(inputSignal));
    switch is_ook
        case "FALSE"
            threshold_value= 0.5;
            for i=1:length(inputSignal)
                if inputSignal(i)>=threshold_value
                    thresholded_signal(i)=1;
                else 
                    thresholded_signal(i)=0;
                end
            end
        case "TRUE"
            threshold_value=av_transmitted_power;
            for i=1:length(inputSignal)
                if inputSignal(i) > threshold_value || inputSignal(i) <-threshold_value
                    thresholded_signal(i)=1;
                end
            end
    end
end
% ------------------------------------- %