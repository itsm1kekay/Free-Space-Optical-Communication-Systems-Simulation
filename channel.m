%% channel function file

% ---------------------------------------------------------------------
% section 3.1 - channel
% 
% Introduction to channel - noise and channel attenuation/losses
%
% Note: the channel attenuation/losses haven't been added yet because
% I'm still figuring them out

function [through_channel_noisy,snr] = channel(modulated)
    % h1 = randi([0,1],1,length(modulated));
    % through_channel = h1*modulated;
    through_channel= modulated;
    % Channel noise
    through_channel_noisy = awgn(through_channel,10,'measured');
    noise = through_channel_noisy-through_channel;
    snr=power_and_snr(through_channel,noise);
end 


% ------------- Channel Characteristics ------------- %
% --------------------------------------------------- %


% temporarily leaving this here:

function snr = power_and_snr(through_channel_noisy,noise)
    through_channel_noisy_power_db = pow2db(mean(abs(through_channel_noisy).^2));
    noise_power_db = pow2db(mean(abs(noise).^2));
    snr = through_channel_noisy_power_db-noise_power_db;
    snr=mean(snr);
end