%% Monte Carlo Function File

% -------------------------------------------------------------------------
% section 5 - Monte Carlo simulation
% 
% Description: performing Monte Carlo simulation on the system

function [mc_bit_error_rate,snr] = monte_carlo(text_input, ...
            transmission_location,Apperture,beam_divergence, ...
            link_length,misaligment,...
            atm_conditions,wavelength,BW,...
            modulation,BR,av_transmitted_power)
    % setup----------------------------------------------------------------
    demodulation= modulation;
    LEO_distance =2000;
    av_transmitted_power=linspace(1e-6,av_transmitted_power,20);
    carrier_frequency = 3e8/wavelength;
    iterations=100;                                                        % for speed
    mc_bit_error_rate=zeros(1,length(av_transmitted_power));
    %----------------------------------------------------------------------
    % MC-------------------------------------------------------------------
    for j=1:length(av_transmitted_power)
        bit_error_rate=zeros(1,iterations);
        for i=1:iterations
            [modulated, binary_text]= transmitter(modulation,text_input,...
            carrier_frequency,av_transmitted_power(j),BR);
            [through_channel_noisy,snr, ~,av_received_power] = channel(modulated, ...
                transmission_location,Apperture,beam_divergence, ...
            link_length,LEO_distance,misaligment,atm_conditions,wavelength, ...
            av_transmitted_power(j),BW);
            [~, thresholded_signal] = receiver(demodulation, ...
                through_channel_noisy,av_received_power,av_transmitted_power(j));
            [~,bit_error_rate(i)]=biterr(binary_text,thresholded_signal);
        end
        snr_temp(j)=snr;
        mc_bit_error_rate(j)=mean(bit_error_rate);
    end
    %----------------------------------------------------------------------
    snr=snr_temp;
end