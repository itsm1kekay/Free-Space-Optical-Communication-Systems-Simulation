% Monte Carlo Simulation
% for i=1:

function monte_carlo(received_binary,sent_binary)
    for i=1:length(received_binary)
        if received_binary(i)==sent_binary(i)
            bit_error_counter(i)=0;
        elseif received_binary(i)~= sent_binary(i)
            bit_error_counter(i)=1;
        end
    end
    x=find(bit_error_counter);
    the_actual_rate=x/length(received_binary);
    snrdb=1:9/length(received_binary):10-(9/length(received_binary));
    snrlin=10.^(snrdb./10);
    tber=0.5.*erfc(sqrt(snrlin));
    figure('Name','BERvsSNR');
    semilogy(snrdb,bit_error_counter,'-bo',snrdb,tber,'-mh')
    grid on;
    legend("measured","expected");
    title('Some modulation with AWGN');
    xlabel('Signal to noise ratio');
    ylabel('Bit error rate');
end