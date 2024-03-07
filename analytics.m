%% analytics function file
% Author: Michail Kasmeridis
% Last modified: 07/03/2024

% ---------------------------------------------------------------------
% section 5 - analytics
% 
% Bit Error Rate (BER) calculation and plotting
%
% Note: probably don't need this, but we shall see

function ber_ratio= analytics(thresholded_signal ,binary_text)
    [~,ber_ratio] = biterr(thresholded_signal ,binary_text);
    % plotter(through_channel,demodulated_signal)
    
end

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
% ------------------------------------- %