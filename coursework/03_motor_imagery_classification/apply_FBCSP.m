function [features, W] = apply_FBCSP(class1, class2, num_filters, fs)
    % INPUT:
    % class1: Cell array {N_trials x 1}, each cell contains EEG matrix [channels x samples]
    % class2: Cell array {N_trials x 1}, each cell contains EEG matrix [channels x samples]
    % num_filters: Number of CSP filters per band (default = 3)
    % fs: Sampling frequency (e.g., 100 Hz)
    %
    % OUTPUT:
    % features: Feature matrix [N_trials x (2*num_filters*bands)]
    % W: CSP spatial filters for each band

    if nargin < 3
        num_filters = 3; % Default: Use 3 filters from each side
    end

    % Define frequency bands (Hz)
    freq_bands = [4 8; 8 12; 13 30; 30 40]; % Theta, Alpha, Beta, Gamma
    num_bands = size(freq_bands, 1);

    % Filter design (FIR bandpass)
    fir_order = 50; % Order of FIR filter

    % Initialize feature matrix
    num_trials = length(class1) + length(class2);
    features = zeros(num_trials, 2*num_filters*num_bands);
    
    % Initialize CSP filter storage
    W = cell(num_bands, 1);

    % Process each frequency band separately
    for b = 1:num_bands
        % Bandpass filtering
        band = freq_bands(b, :);
        fir_coeff = fir1(fir_order, band/(fs/2), 'bandpass');

       class1_filtered = cellfun(@(x) filter(fir_coeff, 1, x), class1, 'UniformOutput', false);
       class2_filtered = cellfun(@(x) filter(fir_coeff, 1, x), class2, 'UniformOutput', false);


        % Apply CSP to filtered signals
        [csp_features, W{b}] = apply_CSP(class1_filtered, class2_filtered, num_filters);

        % Store features for this band
        features(:, (b-1)*2*num_filters+1 : b*2*num_filters) = csp_features;
    end
end
