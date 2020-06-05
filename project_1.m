M = 4; % Modulation order (QPSK)
snr = [0.25,0.5,0.75,1.0,1.25];
numFrames = 15;
ldpcEncoder = comm.LDPCEncoder; %declare a LDPCEncoder object and assign it
ldpcDecoder = comm.LDPCDecoder; %declare a LDPCDecoder object and assign it
pskMod = comm.PSKModulator(M,'BitInput',true);
pskDemod = comm.PSKDemodulator(M,'BitOutput',true,...
    'DecisionMethod','Approximate log-likelihood ratio');
pskuDemod = comm.PSKDemodulator(M,'BitOutput',true,...
    'DecisionMethod','Hard decision');
errRate = zeros(1,length(snr));
uncErrRate = zeros(1,length(snr));


for ii = 1:length(snr)
    ttlErr = 0;
    ttlErrUnc = 0;
    pskDemod.Variance = 1/10^(snr(ii)/10); % Set variance using current SNR
    for counter = 1:numFrames
        data = logical(randi([0 1],32400,1));
        % Transmit and receiver uncoded signal data
        mod_uncSig = pskMod(data);
        rx_uncSig = awgn(mod_uncSig,snr(ii),'measured');
        demod_uncSig = pskuDemod(rx_uncSig);
        numErrUnc = biterr(data,demod_uncSig);
        ttlErrUnc = ttlErrUnc + numErrUnc;
        % Transmit and receive LDPC coded signal data
        encData = ldpcEncoder(data);
        modSig = pskMod(encData);
        rxSig = awgn(modSig,snr(ii),'measured');
        demodSig = pskDemod(rxSig);
        rxBits = ldpcDecoder(demodSig);

        ttlErr = ttlErr + numErr;
    end
    ttlBits = numFrames*length(rxBits);
    uncErrRate(ii) = ttlErrUnc/ttlBits;
    errRate(ii) = ttlErr/ttlBits;
end


plot(snr,uncErrRate,snr,errRate)
legend('Uncoded', 'LDPC coded')
xlabel('SNR (dB)')
ylabel('BER')
