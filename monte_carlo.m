%% Monte Carlo Function File
% Author: Michail Kasmeridis
% Last modified: 21/03/2024

% -------------------------------------------------------------------------
% section 5 - Monte Carlo simulation
% 
% Description: performing Monte Carlo simulation on the system

function mc = monte_carlo(binary_input,link,modulation,transmitter,receiver,constants)
    % setup----------------------------------------------------------------
    demodulation= modulation;
    mc.powa_dbm=linspace(-30,17,50);
    mc.powa_linear=10.^(mc.powa_dbm/10)*1e-3;
    powa=mc.powa_linear;
    carrier_frequency = 3e8/transmitter.wavelength;
    iterations=1e3;                                                        % for speed
    mc_bit_error_rate=zeros(1,length(powa));
    %----------------------------------------------------------------------
    % MC-------------------------------------------------------------------
    for j=1:length(powa)
        bit_error_number=zeros(1,iterations);
        snr=zeros(1,iterations);
        for i=1:iterations
            modulated= modulator(modulation,binary_input,carrier_frequency,powa(j),link.BR);
            transmitter.av_trans_power=powa(j);
            [through_channel_noisy,snr(i), ~,av_received_power] = channel(modulated, ...
                link,transmitter,receiver,constants);
            binary_output = demodulator(demodulation, through_channel_noisy,...
                av_received_power,powa(j));
            bit_error_number(i)=biterr(binary_input,binary_output); %% take the avaerage snr for all the iterations
        end
        if av_received_power<0
            snr_temp(j)=0;
        else
            snr_temp(j)=mean(snr);
        end
        mc_bit_error_rate(j)=sum(bit_error_number)/(length(binary_output)*iterations);
    end
    %----------------------------------------------------------------------
    mc.snr=snr_temp;
    mc.ber=mc_bit_error_rate;
end