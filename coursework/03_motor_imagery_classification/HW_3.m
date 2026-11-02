%% question 1
data = load('BCICIV_calib_ds1b_100Hz.mat');
data=double(data.cnt);
% %% Fast ICA
% [icasig, A, W] = fastica(data, 'numOfComponents', channels, 'g', 'tanh', 'stabilization', 'on');
% 
% % icasig will be the independent components, A is the mixing matrix, and W is the unmixing matrix.
% 
% % Save independent components to a .mat file for further analysis
% save('ica_components.mat', 'icasig');
eeg_data=data';
eeg_band=[0.5 40];
%% 1-filter
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
%% 1-fft
orig_fft = fft(eeg_data(5,:),n_fft); 
filt_fft = fft(eeg_filter(5,:),n_fft);

%% 1-plot the frequency spectrum of channel 5

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

%% 1-CAR
avg_ref = mean(eeg_filter,1);
chans=size(eeg_filter,1);
rep=repmat(avg_ref, chans, 1);
eeg_filter=eeg_filter-rep;
%%
numIC = 10;       % Number of Independent Components
maxIter = 1000;   % Maximum iterations
tol = 1e-6;       % Convergence tolerance

[S, A, W] = myFastICA(eeg_filter, numIC, maxIter, tol);
%%
S_clean = S;
S_clean([3, 5], :) = 0;  % Set artifact components to zero
EEG_clean = A * S_clean;  % Reconstruct EEG without artifacts

%% Normalizarion
% Z-score normalization 
for i = 1:size(EEG_clean, 1) % Loop over channels
    eeg_Normalized(i, :) = (eeg_filter(i, :) - mean(eeg_filter(i, :))) / std(eeg_filter(i, :));
end
%%
channel_index=[26,27,28,30,31,32]; %{'C5','C3','C1','Cz','C2','C4','C6'}
pos=D.mrk.pos;
labels=D.mrk.y;
frequency_rate=100;

new_eeg_origin = eeg_filter(channel_index,:);
new_eeg = eeg_Normalized(channel_index,:);


class1_number=length(find(labels==1));
class2_number=length(find(labels==-1));
class1=cell(class1_number,1);
class2=cell(class2_number,1);
counter1=1;
cunter2=1;

%% segmentation
for trial=1:length(pos)
    start_idx=pos(trial);
    if trial<length(pos)
        end_idx=pos(trial+1)-1;
    else
        end_idx=size(new_eeg,2);
    end
    
    if (labels(trial)==1)
        class1{counter1}=new_eeg(:,start_idx:end_idx);
        counter1=counter1+1;
    else
     class2{cunter2}=new_eeg(:,start_idx:end_idx);   
      cunter2=cunter2+1;
    end
end
%%
%% question 2
%% 2- finding the shortest length
shortest_trial = Inf;  % Start with a large number

% Check all trials in Class 1 (sig1)
for i = 1:length(class1)
    trial_length = length(class1{i});
    if trial_length < shortest_trial
        shortest_trial = trial_length;
    end
end

% Check all trials in Class 2 (sig2)
for i = 1:length(class2)
    trial_length = length(class2{i});
    if trial_length < shortest_trial
        shortest_trial = trial_length;
    end
end


% Adjust the trials for class1 (keeping all channels, only trimming time dimension)
for i = 1:length(class1)
    class1{i} = class1{i}(:,1:shortest_trial);  % Trim to shortest trial length for each trial
end

% Adjust the trials for class2 (keeping all channels, only trimming time dimension)
for i = 1:length(class2)
    class2{i} = class2{i}(:,1:shortest_trial);  % Trim to shortest trial length for each trial
end

% Proceed with feature extraction after adjusting trial lengths


%%
%% 2-variance and kortosis
feature1=zeros(length(class1),size(new_eeg,1));
feature2=zeros(length(class2),size(new_eeg,1));
feature1_1=zeros(length(class1),size(new_eeg,1));
feature2_2=zeros(length(class2),size(new_eeg,1));
%Variance
for trial = 1:class2_number
    feature2(trial, :) = var(class2{trial}, 0, 2);  % Variance along time for each channel
end
for trial = 1:class1_number
    feature1(trial, :) = var(class1{trial}, 0, 2);
end


%kurtosis
for trial = 1:class1_number
    feature1_1(trial,:) = kurtosis(class1{trial},0,2); 
end

for trial = 1:class2_number
   feature2_2(trial,:) = kurtosis(class2{trial},0,2);
end
%% Scatter plot for Variance and kortosis
figure;

% Class 1 Variance Scatter Plot
subplot(1, 2, 1); % 1 row, 2 columns, plot 1
scatter(1:class1_number, feature1(:, 4), 'r', 'filled');
hold on;
scatter(1:class2_number, feature2(:, 4), 'b', 'filled');
title('Variance Scatter Plot');
xlabel('Trial Number');
ylabel('Variance');
legend('Class 1', 'Class 2');
grid on;

% Class 2 Variance Scatter Plot (for comparison in the same figure)
subplot(1, 2, 2); % 1 row, 2 columns, plot 2
scatter(1:class1_number, feature1_1(:, 4), 'r', 'filled');
hold on;
scatter(1:class2_number, feature2_2(:, 4), 'b', 'filled');
title('Kurtosis Scatter Plot');
xlabel('Trial Number');
ylabel('Kurtosis');
legend('Class 1', 'Class 2');
grid on;


%% 2-power :%% modifying the classess
Fs=100;
% Define alpha band frequency range
alpha_band = [8 12]; % Alpha band frequency range (Hz)
beta_band=[13 30];
tetha_band = [4 8];  % Theta band (Hz)


%
feature_class1_alpha=zeros(length(class1),size(new_eeg,1));
feature_class2_alpha=zeros(length(class2),size(new_eeg,1));
feature_class1_beta=zeros(length(class1),size(new_eeg,1));
feature_class2_beta=zeros(length(class2),size(new_eeg,1));
feature_class1_tetha=zeros(length(class1),size(new_eeg,1));
feature_class2_tetha=zeros(length(class2),size(new_eeg,1));




for i = 1:length(class1) % Loop through trials
    class1_extra = class1{i}; % Extract trial (7xN)
    class2_extra = class2{i};
    
    for ch = 1:size(class1_extra,1) % Loop through channels (1:7)
        % Compute power for each channel separately
        feature_class1_alpha(i, ch) = custom_bandpower(class1_extra(ch, :), 100, alpha_band);
        feature_class2_alpha(i, ch) = custom_bandpower(class2_extra(ch, :), 100, alpha_band);
        
        feature_class1_beta(i, ch)  = custom_bandpower(class1_extra(ch, :), 100, beta_band);
        feature_class2_beta(i, ch)  = custom_bandpower(class2_extra(ch, :), 100, beta_band);
        
        feature_class1_tetha(i, ch)  = custom_bandpower(class1_extra(ch, :), 100, tetha_band);
        feature_class2_tetha(i, ch)  = custom_bandpower(class2_extra(ch, :), 100, tetha_band);
        
        
    end
end
%% CSP
num_filters = 3; % Select top 3 filters per class
[features_csp, W] = apply_CSP(class1, class2, num_filters);
%% FBCSP
fs=100;
num_filters = 3; % Number of CSP filters per band
[features_FBCSP, W] = apply_FBCSP(class1, class2, num_filters, fs);

%% 
% Compute mean power across channels for each trial
mean_feature_class1_alpha = mean(feature_class1_alpha, 2); % (100 x 1)
mean_feature_class2_alpha = mean(feature_class2_alpha, 2); % (100 x 1)
mean_feature_class1_beta  = mean(feature_class1_beta, 2);  % (100 x 1)
mean_feature_class2_beta  = mean(feature_class2_beta, 2);  % (100 x 1)
mean_feature_class1_tetha  = mean(feature_class1_beta, 2);  % (100 x 1)
mean_feature_class2_tetha  = mean(feature_class2_beta, 2);  % (100 x 1)
% Create scatter plots
figure;

% Scatter plot for Alpha band
subplot(1,3,1);
scatter(1:length(class1), mean_feature_class1_alpha, 'bo', 'filled');
hold on;
scatter(1:length(class2), mean_feature_class2_alpha, 'ro', 'filled');
xlabel('Trial Number');
ylabel('Mean Alpha Power');
legend('Class 1', 'Class 2');
title('Alpha Band Power Across Trials');

% Scatter plot for Beta band
subplot(1,3,2);
scatter(1:length(class1), mean_feature_class1_beta, 'bo', 'filled'); hold on;
scatter(1:length(class2), mean_feature_class2_beta, 'ro', 'filled');
xlabel('Trial Number');
ylabel('Mean Beta Power');
legend('Class 1', 'Class 2');
title('Beta Band Power Across Trials');

subplot(1,3,3);
scatter(1:length(class1), mean_feature_class1_tetha, 'bo', 'filled'); hold on;
scatter(1:length(class2), mean_feature_class2_tetha, 'ro', 'filled');
xlabel('Trial Number');
ylabel('Mean Beta Power');
legend('Class 1', 'Class 2');
title('tetha Band Power Across Trials');

%% 2-corrolation

%%
num_trials = length(class1); % 100 trials
num_channels = 6; % Assume we only use 6 channels
corr_matrices = zeros(num_trials, num_channels, num_channels); % 100 × 6 × 6
corr_matrices2 = zeros(num_trials, num_channels, num_channels); % 100 × 6 × 6
for i = 1:num_trials
    % Extract EEG data for current trial
    trial_data_class1 = class1{i}; % Shape: 7×780
    trial_data_class2 = class2{i};
    
    % Select first 6 channels (if needed, modify this to use different channels)
    trial_data_class1 = trial_data_class1(1:6, :);
    trial_data_class2 = trial_data_class2(1:6, :);
    
    % Compute correlation matrix (6×6)
    corr_matrices(i, :, :) = corrcoef(trial_data_class1');
    corr_matrices2(i, :, :) = corrcoef(trial_data_class2');
end

% Reshape from 100 × 6 × 6 → 100 × 36
corr_features1 = reshape(corr_matrices, num_trials, []);
corr_features2 = reshape(corr_matrices2, num_trials, []);
corr_features = [corr_features1;corr_features2]
% Display output size
disp(size(corr_features)); % Should be [100, 36]
%%
num_trials = length(class1); % 100 trials
num_channels = 6; % Use first 6 channels
fs = 100; % Sampling frequency
alpha_band = [8 12]; % Alpha band range (Hz)

plv_matrices = zeros(num_trials, num_channels, num_channels); % Store PLV matrices

for i = 1:num_trials
    % Extract EEG data for the current trial
    trial_data_class1 = class1{i}; % Shape: 7×780
    % Select first 6 channels (if needed, modify this to use different channels)
    trial_data_class1 = trial_data_class1(1:6, :);
    
    % Bandpass filter to extract alpha band (8-12 Hz)
    trial_data_class1 = bandpass(trial_data_class1', alpha_band, fs)';
    
    % Compute Hilbert Transform to get instantaneous phase
    phase_data1 = angle(hilbert(trial_data_class1')); % Phase angles (6×780)
    % Compute PLV between channel pairs
    for ch1 = 1:num_channels
        for ch2 = 1:num_channels
            phase_diff = phase_data1(ch1, :) - phase_data1(ch2, :);
            plv_matrices(i, ch1, ch2) = abs(mean(exp(1j * phase_diff))); % Compute PLV
        end
    end
    
end

% Reshape from 100 × 6 × 6 → 100 × 36
plv_features1 = reshape(plv_matrices, num_trials, []);
% Display output size

%%
plv_matrices = zeros(num_trials, num_channels, num_channels); % Store PLV matrices

for i = 1:num_trials
    % Extract EEG data for the current trial
    trial_data_class2 = class2{i};
    % Select first 6 channels (if needed, modify this to use different channels)
    trial_data_class2 = trial_data_class2(1:6, :);
    % Bandpass filter to extract alpha band (8-12 Hz)
    trial_data_class2 = bandpass(trial_data_class2', alpha_band, fs)';
    % Compute Hilbert Transform to get instantaneous phase
    phase_data2 = angle(hilbert(trial_data_class2')); % Phase angles (6×780)
    % Compute PLV between channel pairs
    for ch1 = 1:num_channels
        for ch2 = 1:num_channels
            phase_diff = phase_data2(ch1, :) - phase_data2(ch2, :);
            plv_matrices(i, ch1, ch2) = abs(mean(exp(1j * phase_diff))); % Compute PLV
        end
    end
end

% Reshape from 100 × 6 × 6 → 100 × 36
plv_features2 = reshape(plv_matrices, num_trials, []);
% Display output size


%%
%% question 3

labels=[ones(class1_number,1);-ones(class2_number,1)];

feat1=[feature_class1_alpha;feature_class2_alpha];
feat2=[feature_class1_beta;feature_class2_beta];
feat6=[feature_class1_tetha;feature_class2_tetha];
feat3=[feature1;feature2]; %var
feat4=[feature1_1;feature2_2]; %cor

plv_feature=[plv_features1;plv_features2];
feature=[features_FBCSP,plv_feature];
feature = zscore(feature); % Normalize each column (feature) separately

Data=[feature,labels];
%% Data shuffling
num_rows= size(Data, 1);  
random_permute = randperm(num_rows);  
Shuffled = Data(random_permute, :);  
Labels = Shuffled(:, 61);  
Feature = Shuffled(:, 1:60); 
%% train-test split
%% 70% and 30%
train_ratio = 0.7;  
num_samples = length(Labels);  % Total number of samples

% Generate random indices for splitting
random_indices = randperm(num_samples);

% Calculate the split point
train_size = floor(train_ratio * num_samples);
test_size = num_samples - train_size;

% Split the indices into training and testing
train_idx = random_indices(1:train_size);
test_idx = random_indices(train_size+1:end);

% Assign training and testing sets
feature_train = Feature(train_idx, :);  
feature_test = Feature(test_idx, :);  
label_train = Labels(train_idx);  
label_test = Labels(test_idx);  

% Train SVM Model
svm_model = fitcsvm(feature_train, label_train);

% Predict on Test Data
y_pred = predict(svm_model, feature_test);

% Compute Accuracy
Accuracy_svm = sum(y_pred == label_test) / numel(label_test) * 100;

% Display Accuracy
disp(['SVM Accuracy: ', num2str(Accuracy_svm), '%']);  
%% cross val
K = 10;
inds = crossvalind('kfold', Labels, K);  
Accuracy_svm = [];
Accuracy_knn = [];
y_pred = [];
Label_test = [];
%%
%svm
%train-test with cross validation
for i_fold = 1:K
    test = (inds == i_fold);  % Create test set (true for the current fold)[4,10,14,13,11,12,4,1...]
    train = ~test;            % Create train set (false for the current fold)
    
    feature_train = Feature(train, :);  % Features for training
    feature_test = Feature(test, :);    % Features for testing
    label_train = Labels(train);       % Labels for training 180
    label_test = Labels(test);         % Labels for testing   20  200%10=20
    
    svm_model = fitcsvm(feature_train, label_train);  % Train SVM model
    y_pred_new = predict(svm_model, feature_test);         % Predict using the trained model
    y_pred = [y_pred; y_pred_new];  % Store predictions for all permute
    Label_test = [Label_test; label_test];  % Store true labels
end
%% Accuracy
Accuracy_svm = sum(y_pred == Label_test) / numel(Label_test) * 100;   % Overall accuracy
disp(['Accuracy: ', num2str(Accuracy_svm), '%']);  % Display overall accuracy
%%
% Create confusion matrix if lengths match
if length(Label_test) == length(y_pred)
    C = confusionmat(Label_test, y_pred);  % Compute confusion matrix
    disp('Confusion Matrix:');
    disp(C);  % Display confusion matrix
    
    % Plot confusion matrix
    figure;
    confusionchart(C);
else
    error('Mismatch between the number of true labels and predictions');
end

%%
%knn

Accuracy_knn = [];
y_pred = [];
Label_test = [];
for i_fold=1:K
    test = (inds == i_fold);
    train = ~test;
    
    feature_train = Feature(train, :);
    feature_test = Feature(test, :);
     
    label_train = Labels(train);
    label_test = Labels(test);
    
    % Train KNN classifier
    Model = fitcknn(feature_train, label_train, 'NumNeighbors', 7,'Standardize',1);
   
    % Predict labels for the test set

    
    
    y_pred_new = predict(Model, feature_test);      % Predict using the trained model
    y_pred = [y_pred; y_pred_new];  % Store predictions for all permute
    Label_test = [Label_test; label_test];  % Store true labels
    % Compute accuracy
   
end
Accuracy_knn = sum(y_pred == Label_test) / numel(Label_test) * 100;   % Overall accuracy
disp(['Accuracy: ', num2str(Accuracy_svm), '%']);  % Display overall accuracy
%%

