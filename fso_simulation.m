% text_input='THE QUICK BROWN FOX JUMPED OVER THE LAZY DOG. ';
% wavelength = 1550e-9;
% modulation = "QPSK";
% transmission_location = ""
% link_length = 2;
% BitRate = 1e6;

function [text_output,ber_ratio,snr,losses] = fso_simulation(text_input,wavelength,modulation,transmission_location,link_length,BitRate,Apperture,theta,atm_conditions,misaligment)
    % ---------------------------------------------------------------------
    % section 1 - setup
    % 
    % calculations using channel parameters and quantification of losses
    %
    % Note: some lines of code are commented out since they are still in
    % development and the program will break with uncommented!
    
    carrier_frequency= 3e8/wavelength;
    if transmission_location=="Free space only"
        atm_atten=0; % False
        scint=0; % case of insterstellar scintillation????
        TurbEff=0; % False
    else
        atm_atten=0; % need to add this, since i'm not running the function
        scint=0; % need to add this, since i'm not running the function
        TurbEff=0; % need to add this, since i'm not running the function
        % atm_atten=atmosperic_attenuation(link_length,atm_conditions); % True
        % scint=scintillation(); % True
        % TurbEff= turbulence_effect(); % True 
    end
    GML=geometrical_losses(Apperture,theta,link_length); % True in all cases
    PointErr=0; % need to add this, since i'm not running the function
    % PointErr=pointing_error(misaligment,link_length); % True in all cases
    
    losses=[atm_atten,scint,GML,PointErr,TurbEff];

    % losses=["Atmospheric Attenuation: ","0","dB"; 
    %         "Scintillation: ","0","dB";
    %         "Geometric Losses: ",num2str(GML),"dB"; 
    %         "Pointing errors: ","0","dB";
    %         "Turbulance Effect: ","0","dB"];
    % losses = sprintf('%s\n', losses(:).');
    

    % ---------------------------------------------------------------------
    % section 2 - transmitter side
    % 
    % convert to binary and modulate to transmit
    %
    % Note: my ook modulation function appears to be broken for some
    % reason. It runs but it gives higher ber than expected.

    demodulation = modulation; % same modulation/demodulatin technique

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
    
    % ---------------------------------------------------------------------
    % section 3 - channel
    % 
    % Introduction to channel - noise and channel attenuation/losses
    %
    % Note: the channel attenuation/losses haven't been added yet because
    % I'm still figuring them out

    [through_channel_noisy,snr] = channel(modulated);
    
    % ---------------------------------------------------------------------
    % section 4 - receiver side
    % 
    % Filtering with fft, demodulation, thresholding and converting the
    % demodulated binary message back to ascii.
    %
    % Note: the ook modulation - demodulation function appears to be 
    % broken. It runs but gives higher ber than expected.
    
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
    disp(['Output text is: ' text_output]);
    disp(['SNR is: ' num2str(snr) ' dB']);

    % ---------------------------------------------------------------------
    % section 5 - analytics
    % 
    % Bit Error Rate (BER) calculation and plotting
    %
    % Note: the plotting function is commented out, since it's only used 
    % when running the script locally (not through the app). Haven't found
    % a way to subplot into the gui.


    [~,ber_ratio] = biterr(demodulated_signal ,binary_text);
    % plotter(through_channel,demodulated_signal)
end



% ------------------------------ Functions ------------------------------ %

% ------------- Conversions ------------- %
function doubleString = textToBinary(text_input)
    % Convert character to ASCII values & then binary
    binaryCell = cellstr(dec2bin(double(text_input), 8));
    % Concatenate binary strings
    binaryString = strcat(binaryCell{:});
    for i=1:length(binaryString)
        doubleString(i) = str2double(binaryString(i));
    end
end

function textResult = binaryToText(demodulated_signal)
    charString= num2str(demodulated_signal);
    charString= strcat(charString(:))';
    % Split the binary string into 8-bit segments
    binarySegments = reshape(charString, 8, length(charString)/8)';
    binarySegmentsCell = arrayfun(@(row) num2str(binarySegments(row, :)), 1:size(binarySegments, 1), 'UniformOutput', false);
    % Convert each binary segment to decimal
    decimalValues = bin2dec(binarySegmentsCell);
    % Convert decimal values to characters
    textResult = char(decimalValues');
end
% --------------------------------------- %


% ------------- Channel Characteristics ------------- %
function [through_channel_noisy,snr] = channel(modulated)
% h1 = randi([0,1],1,length(modulated));
% through_channel = h1*modulated;
through_channel= modulated;
% Channel noise
through_channel_noisy = awgn(through_channel,10,'measured');
noise = through_channel_noisy-through_channel;
snr=power_and_snr(through_channel,noise);
end 
% --------------------------------------------------- %

% ------------------- Losses ------------------- %
function GML= geometrical_losses(Apperture,theta,link_length)
    GML=10*log10(4*Apperture/pi*(theta*link_length)^2);
end
function atm_atten=atmosperic_attenuation(link_length,atm_conditions)
    switch atm_conditions
        % need to add a.k,R values 
        case "Clear Skies"
        case "Light Rain (<2.5 mm/hr)"
        case "Medium Rain (2.7 to 7.5 mm/hr)"
        case "Heavy Rain (7.6 to 50 mm/hr)"
        case "Violent Rain (>50 mm/hr)"
        case "Light Haze"
        case "Haze"
        case "Thin Fog"
        case "Moderate Fog"
        case "Thick Fog"
        case "Dense Fog"
    end
atm_atten=kappa_atm*Rain_intensity^alpha_atm;
end
function PointErr=pointing_error(misaligment,link_length)
    %need to calculate beam width
end
function TurbEff=turbulence_effect()
    % Rytov variation
end
function scint=scintillation()
    % use scintillation variation
end
% ---------------------------------------------- %

% ------------- Filtering ------------- %
function filteredSignal = fft_filtering(through_channel_noisy)
    % Compute the FFT
    n=length(through_channel_noisy);
    fhat=fft(through_channel_noisy,n);
    PSD=fhat.*conj(fhat)/n;
    % Use PSD to filter out noise
    indices= PSD>0.15;
    % PSDclean=PSD.*indices;
    fhat=indices.*fhat;
    filteredSignal=ifft(fhat);
end
% ------------------------------------- %

% ------------- Modulations ------------- %
function modulated = ook_modulation(binary_text, carrier_frequency)
t=1:length(binary_text);
carrier_signal = cos(2*pi*carrier_frequency*t);
modulated=carrier_signal.*binary_text;
end
% --------------------------------------- %

% ------------- Demodulations ------------- %
function demodulatedSignal = ook_demodulation(filteredSignal,carrier_frequency)
    t = 0:length(filteredSignal);
    matchedFilter = cos(2 * pi * carrier_frequency * t);

    demodulatedSignal = abs(conv(filteredSignal, fliplr(matchedFilter), 'same'));

    threshold = max(demodulatedSignal) / 2; % Adjust the threshold as needed
    demodulatedSignal = demodulatedSignal > threshold;
end
% ----------------------------------------- %


% ------------- Analytics ------------- %
function plotter(through_channel, received)
figure(2);
subplot(3,1,1)
plot(through_channel)
title('Through Channel')
xlabel('Sampling time','FontSize',12)
ylabel('Sending amplitude','FontSize',12)
subplot(3,1,2)
plot(received)
title('Received signal','FontSize',12)
xlabel('Sampling time','FontSize',12)
ylabel('Receiving amplitude','FontSize',12)
subplot(3,1,3)
plot(through_channel,'b')
hold on;
plot(received,'r')
legend('Sent','Received')
title('Sent & received signal','FontSize',12)
xlabel('Sampling time','FontSize',12)
ylabel('Sending amplitude','FontSize',12)
hold off;
end

function snr = power_and_snr(through_channel_noisy,noise)
through_channel_noisy_power_db = pow2db(mean(abs(through_channel_noisy).^2));
noise_power_db = pow2db(mean(abs(noise).^2));
snr = through_channel_noisy_power_db-noise_power_db;
snr=mean(snr);
end
% ------------------------------------- %
% ----------------------------------------------------------------------- %