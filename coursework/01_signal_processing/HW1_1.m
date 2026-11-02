%% question 1-1
% Load data
data = load('BCICIV_calib_ds1a_100Hz.mat');
data=double(data.cnt);
eeg_data=data';
eeg_band=[0.5 40];
%% filter
channels = 59;
sample= 190594; 
fir_order = 10000;   
fs_original = 100;
fir_coeff = fir1(fir_order, eeg_band/(fs_original/2), 'bandpass');
counter=1;
while counter <= channels
   eeg_filter(counter,:) = filtfilt(fir_coeff, 1, eeg_data(counter,:)); 
   counter=counter+1;
end

n_fft = 2^nextpow2(sample);
freq_vector = fs_original/2*linspace(0,1,n_fft/2);
%%
orig_fft = fft(eeg_data(5,:),n_fft); 
filt_fft = fft(eeg_filter(5,:),n_fft);

%% plot the frequency spectrum of channel 5

figure;  
subplot(2,1,1); 
plot(freq_vector, abs(orig_fft(1:end/2)));
title('Original Spectrum');
xlim([0 100]);

subplot(2,1,2);
plot(freq_vector, abs(filt_fft(1:end/2)));  
title('Filtered Spectrum');
time_vector = (1:length(eeg_data(5,:)))/fs_original;

figure;
subplot(2,1,1);
plot(time_vector, eeg_data(5,:));
title('Original Signal');  

subplot(2,1,2);
plot(time_vector, eeg_filter(5,:));
title('Filtered Signal');



%% question 2
notch_Freq = 50; 
bandwidth = 2; 
f_nyq = fs_original/2+1;
notch_freq_2 = notch_Freq/f_nyq; 
bandwidth_2 = 2/f_nyq;
[c, d] = iirnotch(notch_freq_2, bandwidth_2);

filtered = zeros(size(data));  % Initialize filtered data array
for channel = 1:size(data, 2)  % Loop through each channel
    filtered(:, channel) = filtfilt(c, d, data(:, channel));  % Apply the notch filter
end

% Time vector
time = (0:size(data, 1) -1) / fs_original; % Based on time samples (rows)

% Plot time-domain signals
figure(1);
subplot(2, 1, 1);
plot(time, data(:, 5)); 
title('EEG Signal');
xlabel('T');
ylabel('Amp');

subplot(2, 1, 2);
plot(time, filtered(:, 5)); 
title('Filtered EEG');
xlabel('T');
ylabel('Amp');

%% Frequency analysis
orig_fft = fft(data(:, 5),n_fft); 
filt_fft = fft(filtered(:, 5),n_fft); 


% Plot frequency-domain signals
figure(2);
subplot(2, 1, 1);
freq = linspace(0, fs_original, length(orig_fft)); % Frequency vector
plot(freq, abs(orig_fft)); % Magnitude of the FFT
title('Frequency Domain');
xlabel('Frequency');
ylabel('Magnitude');

subplot(2, 1, 2);
plot(freq, abs(filt_fft)); 
title(' Frequency Domain filtered');
xlabel('Frequency');
ylabel('Magnitude');

%% question 3
%%                  
% Apply filters  
eeg = double(D.cnt);
eeg_delta =apply_bandpass_filter(eeg_data,[0.5 4]);
eeg_theta=apply_bandpass_filter(eeg_data, [4 8]);
eeg_alpha =apply_bandpass_filter(eeg_data, [8 12]);
eeg_beta = apply_bandpass_filter(eeg_data, [12 30]);
eeg_gamma = apply_bandpass_filter(eeg_data, [30 40]);
% Plot
figure;
subplot(6,1,1); plot(eeg(:,5)); title('Original Signal');  
subplot(6,1,2); plot(eeg_delta(5,:)); title('Delta');  
ylim([-2000 2000])
subplot(6,1,3); plot(eeg_theta(5,:)); title('Theta');
subplot(6,1,4); plot(eeg_alpha(5,:)); title('Alpha');
subplot(6,1,5); plot(eeg_beta(5,:)); title('Beta'); 
subplot(6,1,6); plot(eeg_gamma(5,:)); title('Gamma');

%% question 4
orig_fft = fft(eeg_data(5,:),n_fft); 

deltaFFT = fft(eeg_delta(5,:),n_fft);
thetaFFT = fft(eeg_theta(5,:),n_fft);
alphaFFT = fft(eeg_alpha(5,:),n_fft);
betaFFT  =  fft(eeg_beta (5,:),n_fft);
gammaFFT = fft(eeg_gamma (5,:),n_fft);

freq_vector = fs_original/2*linspace(0,1,n_fft/2);

%plot
figure;
subplot(6,1,1);
plot(freq_vector, abs(orig_fft)); 
title('Original Signal'); 
subplot(6,1,2);
plot(freq_vector, abs(deltaFFT));
title('Delta '); 
subplot(6,1,3);
plot(freq_vector, abs(thetaFFT));
title('Theta ');
subplot(6,1,4);
plot(freq_vector, abs(alphaFFT));
title('Alpha '); 
subplot(6,1,5); 
plot(freq_vector, abs(betaFFT));
title('Beta');
subplot(6,1,6);
plot(freq_vector, abs(gammaFFT));
title('Gamma ');
%% question 5
clc;
clear;
close all;

% Load the dataset
data = load('BCICIV_calib_ds1a_100Hz.mat');
eeg_data = double(data.cnt)';
num_channels = 59;
num_samples = 190594;

% Delta band frequency range
delta_band = [0.5, 4];
f_max_delta = delta_band(2);

% Original and new sampling frequencies
fs_original = 100;
fs_new = 2 * f_max_delta;  % Nyquist frequency for delta band

% Validate the shape of the EEG data
if size(eeg_data) ~= [num_channels, num_samples]
    error('EEG data shape mismatch.');
end

% Filter parameters
filter_order = 15;
cutoff_freq = f_max_delta;

% Low-pass Butterworth filter design to remove high-frequency components
[b, a] = butter(filter_order, cutoff_freq / (fs_original / 2), 'low');
eeg_filtered = filtfilt(b, a, eeg_data);

% Calculate downsampling factor
downsampling_ratio = fs_original / fs_new;
[p, q] = rat(downsampling_ratio, 0.0001);

% Resample the data to the new sampling frequency
eeg_resampled = resample(eeg_data, p, q);

% Plot original vs resampled signals (channel 20)
clip_length = 10 * fs_original;

figure;
subplot(2,1,1);
plot(eeg_data(5, 1:clip_length));
title('Original EEG Signal (Channel 5 )');

subplot(2,1,2);
plot(eeg_resampled(5, 1:clip_length));
title('Resampled EEG Signal (Delta Band)');

% Frequency domain visualization
orig_freq = (fs_original / 2) * linspace(0, 1, 1024);
new_freq = (fs_new / 2) * linspace(0, 1, 1024);

% Calculate FFT of original and resampled signals
orig_spectrum = abs(fft(eeg_data(1, :), 1024));
new_spectrum = abs(fft(eeg_resampled(1, :), 1024));

% Plot frequency spectra
figure;
subplot(2,1,1);
plot(orig_freq, orig_spectrum);
title('Original Signal Spectrum');
xlabel('Frequency (Hz)');
ylabel('Magnitude');

subplot(2,1,2);
plot(new_freq, new_spectrum);
title('Resampled Signal Spectrum (Delta Band)');
xlabel('Frequency (Hz)');
ylabel('Magnitude');

%% question 6
%3 channel
reference_channel = 29; %%cz

% Get 3 neighboring channels for small Laplacian
ch1 = reference_channel - 1; %28 C1
ch2 = reference_channel + 1; %30 C2
ch3 = reference_channel - 16; %13 FCz

CZ = [0, 0]; 
C1 = [-0.207737565050372, 0];
C2 = [0.207737565050372, 0]; 
FCz =[0, 0.207737565050372];


% Input data
input = [eeg_data(reference_channel, :) ;  eeg_data(ch1, :) ; eeg_data(ch2, :) ; eeg_data(ch3, :)];

% Apply laplacian filter         
output = laplacianFilter(input);
% Get input and output channels 
ref_ch = eeg_data(reference_channel, :);
out_ch = output;
%% 4 channel
reference_channel = 29; %%cz

% Get 3 neighboring channels for small Laplacian
ch1 = reference_channel - 1; %28 C1
ch2 = reference_channel + 1; %30 C2
ch3 = reference_channel - 16; %13 FCz
ch4 =  reference_channel +16; % CPz

CZ = [0, 0]; 
C1 = [-0.207737565050372, 0];
C2 = [0.207737565050372, 0]; 
FCz =[0, 0.207737565050372];
CPz= [0, 0.207737565050372];

 

% Input data
input = [eeg_data(reference_channel, :) ;  eeg_data(ch1, :) ; eeg_data(ch2, :) ; eeg_data(ch3, :) ;eeg_data(ch4, :)];

% Apply laplacian filter         
output = laplacianFilter(input);
% Get input and output channels 
ref_ch = eeg_data(reference_channel, :);
out_ch = output;
%% 4 channel plot
figure(1);
subplot(6,1,1); 
plot(ref_ch); 
title('CZ');
subplot(6,1,2); 
plot(eeg_data(ch1,:));
title('C1'); 
subplot(6,1,3);
plot(eeg_data(ch2,:));
title('C2');
subplot(6,1,4); 
plot(eeg_data(ch3,:)); 
title('FCz');
subplot(6,1,5); 
plot(eeg_data(ch4,:)); 
title('CPz');

subplot(6,1,6);
plot(out_ch); 
title('Laplacian Filter'); 
ylim([-1000 1500])

%%
% Frequency domain

figure(2);
subplot(6,1,1);
xlim([0 100]);
fft_main = fft(ref_ch); 
fft_out = fft(out_ch); 
plot(abs(fft_main)); 
title('Main Channel:Cz');

xlim([0 100]);
subplot(6,1,2); 
plot(abs(fft(eeg_data(ch1,:))));
title('C1'); 

xlim([0 100]);
subplot(6,1,3); 
plot(abs(fft(eeg_data(ch2,:))));
title('C2');


xlim([0 100]);
subplot(6,1,4); 
plot(abs(fft(eeg_data(ch3,:)))); 
title('FCz');
xlim([0 100]);

xlim([0 100]);
subplot(6,1,5); 
plot(abs(fft(eeg_data(ch3,:)))); 
title('CPz');
xlim([0 100]);

subplot(6,1,6);
plot(abs(fft_out)); 
title('Laplacian Filter Output');
xlim([0 100]); % 0 to 50 Hz
%%



