%% Stimulus_Responses
% =======================================================================================
% This is an example script to do basic visualization of simulus-triggered
% averaged FIP responses. This script is designed to work with the data
% output from the master-branch FIP multifiber GUI: 
% >> https://github.com/deisseroth-lab/multifiber
% 
% This script was written with MATLAB R2017a.
%
% ------------------- Outputs -------------------
% >> stim_trig_responses
%   type: struct
%   size: {#analog inputs(ai) x 1}
%   contents: within each cell is an array of size [#fibers x trial length
%   x # trials] that stores the calcium activity aligned to the detected
%   stimulus onsets (trials)
%   e.g.: squeeze(stim_trig_responses{1}(3,:,:)) will return an
%   array containing the calcium activity recorded from fiber 3 aligned to
%   the stimulus recorded in analog input 1 across all detected trials.
%   
% >> time_trial
%   type: vector
%   size: [1 x trial length]
%   contents: time vector corresponding to trial length, defined by 
%   "plot_pre" and "plot_post" inputs.
%   e.g.: if plot_pre=2 and plot_post=5, time_trial returns a time vector
%   from -2 to 5 s, sampled at the same rate of the calcium recording.
%
% >> all_stimuli_fp
%   type: array
%   size: [#fibers x recording length]
%   contents: each row corresponds to one analog input (ai), subsampled at
%   the same frequency as the FP recording
%
% ------------------- References -------------------
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
% ------------------- Change log -------------------
%
% 2018-08-23 Deposited
%
% ------------------- Contact -------------------
%
% For questions, contact Christina Kim (kimck@stanford.edu)
% =======================================================================================

function [stim_trig_responses,time_trial,all_stimuli_fp]=Stimulus_Responses(filepath,filename,plot_pre,plot_post,ai_plotflag,ai_labels)

% This loads the log file
try
    currentfile=strcat(filepath,filename);
    data=load(strrep(currentfile,'.mat','_logAI.csv'));
    load(strrep(currentfile,'.mat','_processed.mat'));
    load(currentfile,'framerate','labels');
    savefile=strrep(currentfile,'.mat','_aligned.mat');
catch
    f = msgbox('Error: Data file or log file cannot be found.');
    return
end

% Determine number of fibers from data structure 
numfibers=size(sig_norm,1);

% Parse the logfile. data = [timepoints x 9] vector. Column 1 = time,
% Column 2 = camera frames, Columns 3-9 = AI1-AI7.
t_stimulus=data(:,1); % Save the timestamp for stimulus data.
cam_frames=data(:,2); % Save the camera frame TTLs

% Create time vector from camera frames TTLs
cam_ttls=find(diff(cam_frames)>2.5)+1;
time=t_stimulus(cam_ttls);
check_framerate=framerate-1/mean(diff(time)); % Make sure no camera triggers were missed
if check_framerate>1
    figure(500);
    plot(diff(time),'o');
    xlabel('Frame number');
    ylabel('Time between detected frames');
end
cam_ttls=cam_ttls(1:2:end); % Take every other camera frame (remove 405).
cam_ttls(length(sig_norm)+1:end)=[]; % Delete any extra triggers at the end.
time=t_stimulus(cam_ttls);

% Select which columns of "data" to plot, and assign to new variable "data_plot".
ai_plot=find(ai_plotflag==1);
ai_labels=ai_labels(ai_plot);
data_plot=data(:,ai_plot+2);
data_plot(data_plot<2.5)=0; % binarize TTL traces
data_plot(data_plot>=2.5)=1;
data_plot=logical(data_plot); % convert TTLs into logical
num_stimuli=size(ai_plot,2);

% Get the plotting indices for stim-triggered responses
plot_pre_ind=find(time>=plot_pre,1,'first')-1;
plot_post_ind=find(time>=plot_post,1,'first')-1;
time_trial=time(1:plot_pre_ind+plot_post_ind+1)-time(plot_pre_ind+1);

% Create vectors for each stimulus on same timescale as FP data
all_stimuli_fp=zeros(num_stimuli,length(time));
for a=1:num_stimuli
    stim_on=find(data_plot(:,a)); % find indices of each stimuli TTL pulse
    stim_on_cam=arrayfun(@(x) find(cam_ttls<=x,1,'last'),stim_on); % find closest cam_TTL to each stimulus TTL pulse
    all_stimuli_fp(a,stim_on_cam)=1;
end

% Detect onset of each stimulus TTL
all_stimuli_start=[];
for a=1:num_stimuli
    stimulus_starts=find(diff(all_stimuli_fp(a,:))>=1)+1;
    
    % Delete any stimuli that fall outside the range of plot_pre/plot_post
    stimulus_starts(stimulus_starts<=plot_pre_ind | stimulus_starts>length(sig_norm)-plot_post_ind)=[];
    all_stimuli_start{a}=stimulus_starts;
end

% Calculate stimulus-triggered responses for each stimulus
% Shape is [numfibers x timepoints x trials]
stim_trig_responses=[];
for a=1:num_stimuli
    trials=[];
    for b=1:length(all_stimuli_start{a})
        temp=sig_norm(:,all_stimuli_start{a}(b)-plot_pre_ind:all_stimuli_start{a}(b)+plot_post_ind);
        trials=cat(3,trials,temp);
    end
    stim_trig_responses{a}=trials;
end

% Plot each stimulus with each fiber overlaid
stimuli_colors=jet(7);
for b=1:numfibers
    figure(50);
    subplot(numfibers,1,b);
    plot(time,sig_norm(b,:),'k');
    hold on;
    for a=1:num_stimuli
        plot(time',all_stimuli_fp(a,:)*max(max(sig_norm(b,:))),'color',stimuli_colors(a,:));
    end
    legend([labels(b) ai_labels]);
    xlabel('Time (s)');
    if output_flag==1
        ylabel('dF/F');
    else
        ylabel('Zscore');
    end
    xlim([0 time(end)]);
    title(['Fiber',num2str(b),': ',labels{b}]);
    hold off;
end

% Plot each stimulus-triggered response for each fiber
activity=[];
for a=1:num_stimuli
    figure(a+100);
    current_stimulus=stim_trig_responses{1,a};
    mean_activity=zeros(numfibers,length(time_trial));
    for b=1:numfibers
        activity=squeeze(current_stimulus(b,:,:))';
        mean_activity(b,:)=mean(activity);
        sem_activity=std(activity)./sqrt(size(activity,1));
        shadedErrorBar(time_trial,mean_activity(b,:),sem_activity,[],1);
        hold on;
    end
    labeldata=plot(time_trial,mean_activity,'linewidth',2);
    legend(labeldata,labels);
    xlabel(['Time relative to', ' ',ai_labels{a},' (s)']);
    if output_flag==1
        ylabel('dF/F');
    else
        ylabel('Zscore');
    end
    xlim([-plot_pre plot_post]);
    hold off;
end

% save data
save(savefile,'time_trial','stim_trig_responses','all_stimuli_fp');