function power = custom_bandpower(signal, fs, freq_range)
    % Compute FFT of the signal
    N = length(signal);  
    fft_signal = fft(signal);  
    Pxx = abs(fft_signal / N).^2;  % Power Spectral Density (PSD)

    % Frequency vector
    freqs = (0:N-1) * (fs / N);  

    % Find indices corresponding to the desired frequency range
    idx_band = (freqs >= freq_range(1)) & (freqs <= freq_range(2));

    % Compute total power within the frequency band
    power = sum(Pxx(idx_band));
end


