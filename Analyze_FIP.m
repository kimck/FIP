%% Analyze_FIP
% =======================================================================================
% This is an example script to do basic visualization, 405 subtraction, and
% dF/F or z-score calculation of FIP data. This script is designed to work
% with the data output from the master-branch FIP multifiber GUI: 
% >> https://github.com/deisseroth-lab/multifiber
% 
% This script was written with MATLAB R2017a.
%
%
% ------------------- References -------------------
%
% Original manscript:
% Kim, Yang, Pichamoorthy, Young, Kauvar, Jennings, Lerner, Berndt, Lee,
% Ramakrishnan, Davidson, Inoue, Bito, & Deisseroth. Simultaneous fast
% measurement of circuit dynamics at multiple sites across the mammalian
% brain. Nature Methods, 13: 325-328 (2016).
% 
% >> https://web.stanford.edu/group/dlab/media/papers/kimNMeth2016.pdf
%
% More information:
% https://sites.google.com/view/multifp/
%
% % ------------------- Change log -------------------
%
% 2018-08-23 Deposited
%
% ------------------- Contact -------------------
%
% For questions, contact Christina Kim (kimck@stanford.edu)
% =======================================================================================

function [time,sig_norm,output_flag]=Analyze_FIP(filepath,filename,output_flag,bleach_flag,lowpass_filt,smooth_points)

% This loads the reference and signal channel
try
    currentfile=strcat(filepath,filename);
    load(currentfile)
catch
    f = msgbox('Error: Data file cannot be found.');
    return
end
savefile=strrep(currentfile,'.mat','_processed.mat');

% Determine number of fibers from data structure 
numfibers=size(sig,2);

% Get sample rate of each channel (camera framerate/2)
samplingrate=framerate/2;

% Transpose the signal and reference to be [numfiber x time points]
sig=sig';
ref=ref';

% Delete last 5 data points (sometimes last few frames the LED drops)
sig(:,end-5:end,:)=[];
ref(:,end-5:end,:)=[];

% Create a time vector based on framerate
dt=1/samplingrate;
time=[0:dt:(length(sig)-1)*dt];

% If bleaching_flag is 1, then subtract exponential fit to both sig and ref
% prior to normalization
if(bleach_flag==1)
    for a=1:numfibers
        curve = fit(time', sig(a,:)', 'exp1');
        sig_fit=curve.a*exp(curve.b*time);
        sig(a,:)=sig(a,:)-sig_fit+sig(a,1);
        curve = fit(time', ref(a,:)', 'exp1');
        ref_fit=curve.a*exp(curve.b*time);
        ref(a,:)=ref(a,:)-ref_fit+ref(a,1);
    end
end

% For each fiber, calculate best fit reference using polyfit, and subtract.
% Plot scaling/subtraction results
% Calculate either dF/F or Zscore based on output_flag
sig_sub=zeros(size(sig,1),size(sig,2));
sig_norm=zeros(size(sig,1),size(sig,2));
for a=1:numfibers
    p=polyfit(ref(a,:),sig(a,:),1); % do a linear regression between the reference and signal
    ref_scaled=ref(a,:)*p(1)+p(2); % calculate best-fit reference. might need to smooth if noisy.
    
    % Plot the reference scaling results
    figure(a);
    subplot(3,1,1);
    plot(time,sig(a,:));
    hold on
    plot(time,ref_scaled,'r');
    ylabel('Fluorescence (A.U.)');
    legend('Signal','Scaled control');
    title(strcat('Signal and scaled reference for Fiber ',num2str(a),': ',labels{a}));
    xlim([0 time(end)]);
    
    % Plot the reference subtraction results
    sig_sub(a,:)=sig(a,:)-ref_scaled+sig(a,1);
    subplot(3,1,2);
    plot(time,sig_sub(a,:));
    ylabel('Fluorescence (A.U.)');
    title('Reference-subtracted signal');
    xlim([0 time(end)]);
    
    % Calculate either dF/F or zscore
    if output_flag==1 % calculate dF/F
        sig_norm(a,:)=(sig_sub(a,:)-median(sig_sub(a,:))) / median(sig_sub(a,:));
        ylabel_txt='Activity (dF/F)';
    else % calculate zscore
        sig_norm(a,:)=zscore(sig_sub(a,:));
        ylabel_txt='Activity (Zscore)';
    end
    
    % Perform filtering or smoothing
    if ~isempty(lowpass_filt)
        [b,z] = butter(4,lowpass_filt/(samplingrate/2)); % create a 4th order low-pass filter
        sig_norm(a,:)=filtfilt(b,z,sig_norm(a,:));
    end
    if ~isempty(smooth_points)
       sig_norm(a,:)=smooth(sig_norm(a,:),smooth_points); 
    end
    
    % Plot normalized dF/F or zscored data
    subplot(3,1,3);
    plot(time,sig_norm(a,:));
    xlabel('Time (s)');
    xlim([0 time(end)]);
    ylabel(ylabel_txt);
    title('Normalized signal');
    
    hold off;
end

% save data
save(savefile,'time','sig_norm','output_flag');