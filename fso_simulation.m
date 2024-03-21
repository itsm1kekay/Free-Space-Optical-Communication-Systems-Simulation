%% master function file called by app
% Author: Michail Kasmeridis
% Last modified: 21/03/2024

function [binary_output,ber_ratio,snr,total_losses,BW,distribution,constants,receiver] =...
        fso_simulation(binary_input,modulation,link,transmitter,receiver)
    % ---------------------------------------------------------------------
    % section 1 - setup
    carrier_frequency= 3e8/transmitter.wavelength;    
    demodulation = modulation;                                              % same modulation/demodulation technique
    % constants------------------------------------------------------------
    constants.planck = 6.626e-34;                                                          % Planck's constant
    constants.charge = 1.60217663e-19;                                      % elemental charge (in Coulombs)
    constants.boltzman= 1.380649e-23;
    % ---------------------------------------------------------------------
    % receiver characteristics---------------------------------------------
    receiver.temperature= 300; %typical value - should make conditional select
    receiver.quantum_efficiency=0.876;  % InGaAs-based photodiodes
    receiver.noise_equivalent_power=1e-12; % typical value 
    receiver.photodiode_responsivity= receiver.quantum_efficiency*constants.charge* transmitter.wavelength/(constants.planck*3e8);
    receiver.resistance=50; %typical value
    % ---------------------------------------------------------------------
    switch modulation
        case "QPSK"
            BW=link.BR/log2(4);
        case "16 QAM"
            BW=link.BR/log2(16);
        otherwise                                                           % OOK and no modulation
            BW=link.BR/log2(2);
    end
    % ---------------------------------------------------------------------
    % section 2 - transmitter side
    modulated= modulator(modulation,binary_input,carrier_frequency,...
        transmitter.av_trans_power,link.BR);
    % ---------------------------------------------------------------------
    % section 3 - channel
    [through_channel_noisy,snr, total_losses,av_received_power,distribution] = channel(modulated, ...
        link,transmitter,receiver,constants);
    receiver.av_received_power=av_received_power;
    % ---------------------------------------------------------------------
    % section 4 - receiver side   
    binary_output = demodulator(demodulation,through_channel_noisy,av_received_power,transmitter.av_trans_power);
    % disp(['Output text is: ' text_output]);
    disp(['SNR is: ' num2str(snr) ' dB']);
    % ---------------------------------------------------------------------
    % section 5 - analytics
    [~,ber_ratio] = biterr(binary_output ,binary_input);
    disp(['Ber is: ' num2str(ber_ratio)]);
    % ---------------------------------------------------------------------
end