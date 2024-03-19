%% Monte Carlo Function File
% Author: Michail Kasmeridis
% Last modified: 07/03/2024

% -------------------------------------------------------------------------
% section 5 - Monte Carlo simulation
% 
% Description: performing Monte Carlo simulation on the system

function mc = monte_carlo(binary_input,link,BW,modulation,transmitter,receiver,constants)
    % setup----------------------------------------------------------------
    demodulation= modulation;
    av_transmitted_power=linspace(1e-3,transmitter.av_trans_power,10);
    carrier_frequency = 3e8/transmitter.wavelength;
    iterations=1e2;                                                        % for speed
    mc_bit_error_rate=zeros(1,length(av_transmitted_power));
    % bit_rate=link.BR;
    %----------------------------------------------------------------------
    % MC-------------------------------------------------------------------
    for j=1:length(av_transmitted_power)
        bit_error_number=zeros(1,iterations);
        snr=zeros(1,iterations);
        for i=1:iterations
            modulated= modulator(modulation,binary_input,carrier_frequency,av_transmitted_power(j),link.BR);
            transmitter.av_trans_power=av_transmitted_power(j);
            [through_channel_noisy,snr(i), ~,av_received_power] = channel(modulated, ...
                link,transmitter,BW,receiver,constants);
            binary_output = demodulator(demodulation, through_channel_noisy,...
                av_received_power,av_transmitted_power(j));
            bit_error_number(i)=biterr(binary_input,binary_output); %% take the avaerage snr for all the iterations
        end
        snr_temp(j)=mean(snr);
        mc_bit_error_rate(j)=sum(bit_error_number)/(length(binary_output)*iterations);
    end
    %----------------------------------------------------------------------
    mc.snr=snr_temp;
    mc.ber=mc_bit_error_rate;
end