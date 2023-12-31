function plotSpectrogram (app)
% This function performs the plot in the SPG window.
% Depending on the selected radio button different data are plotted down
% there.

tmp = [];
%axes(handles.spectraWide)      % select the SPG axes
cla(app.spectraWide)

% load in all necessary parameters from the handles structure
freqLow = app.SPGfromFreq.Value;
freqHigh = app.SPGtoFreq.Value;
app.SPGlowDB = app.lowerDB.Value;
app.SPGhighDB = app.upperDB.Value;
flagMd = app.plotMeanFlag.Value;     % plot average trace
flagTr = app.plotTrCk.Value;         % plot single trace
flagFlt = app.filterBPpower.Value;
flagBPgamma_power = app.gammaPower.Value;
flagEI = app.EIbutton.Value;
flagSPG = app.SPG.Value;
flagBP = app.BP.Value;
flagPhase = app.BPphaseButton.Value;
flagLog = app.SPGlogCk.Value;

flagSkip1st = app.skip1trialCk.Value; %gab&enrico 2018/11/02 provvisorio

% A the beginning, the scale must be reset to normal, to prevent errors. ENRICO 11/12/2018
app.spectraWide.YScale = 'linear';

if flagSPG && app.spg_computed
    if flagMd
        temp(1:app.freqN,1:app.spgl) = app.meanSpg(app.currentCh,1:app.freqN,1:app.spgl);
    else
        temp(1:app.freqN,1:app.spgl) = app.spg(app.currentCh,app.currentTrial,1:app.freqN,1:app.spgl);
    end
    % the spectrogram is represented in decibels
    imagesc(app.spectraWide, app.spgt,app.spgw,10*log10(temp))
    axis(app.spectraWide, [app.tmin app.tmax freqLow freqHigh]);
    
    if app.autoCLimSpg_ck.Value
        % Gab 2019/06/01 calculate extremes and set colormap limits
        
        highDB = max(10*log10(temp),[],'all');
        app.upperDB.Value = highDB;
        app.SPGhighDB = highDB;
        
        lowDB = min(10*log10(temp),[],'all');
        app.lowerDB.Value = lowDB;
        app.SPGlowDB = lowDB;
    end
    caxis(app.spectraWide, [app.SPGlowDB app.SPGhighDB]);
    app.spectraWide.YDir = 'normal';
    app.spectraWide.YLabel.String = 'Frequency (Hz)';
    app.lowerDB.Enable = 1;
    app.upperDB.Enable = 1;
    app.spectraWide.Colormap = turbo;
    
elseif flagBP
    hold(app.spectraWide, 'on');
    % BP power data are plotted one at the time
    
    % 2019/05/26 Gab, loop over all the BPs
    for selBP = 1:size(app.frequencyBand,1)
        if app.BP_4_plot(selBP) % if the current BP is selected
            if flagMd
                % plot average of BP power
                tmpX = squeeze(app.BPpower(selBP).time);
                tmpY = squeeze(mean( app.BPpower(selBP).power(app.currentCh,flagSkip1st+1:end,:), 2));
                plot(app.spectraWide, tmpX,tmpY,'Color',app.BP_color(selBP,:),'LineWidth',2);
            end
            if flagTr
                % plot single trial
                tmpX = squeeze(app.BPpower(selBP).time);
                tmpY = squeeze(app.BPpower(selBP).power(app.currentCh,app.currentTrial,:));
                plot(app.spectraWide, tmpX,tmpY,'Color',app.BP_color(selBP,:),'LineWidth',0.5);
            end
        end
    end
    if flagLog
        app.spectraWide.YScale = 'log';
    else
        app.spectraWide.YScale = 'linear';
    end
    app.spectraWide.YLabel.String = 'RMS Power (uV)';
    hold(app.spectraWide, 'off')
    
    app.lowerDB.Enable = 0;
    app.upperDB.Enable = 0;
    
elseif flagPhase % gab, 2022-03-16. Instantaneous phase from the analytical signal
    hold(app.spectraWide, 'on');
    % BP power data are plotted one at the time
    
    % 2019/05/26 Gab, loop over all the BPs
    for selBP = 1:size(app.frequencyBand,1)
        if app.BP_4_plot(selBP) % if the current BP is selected
            if flagMd
                % plot average of BP power
                tmpX = squeeze(app.BPpower(selBP).time);
                tmpY = squeeze(mean( app.BPpower(selBP).phase(app.currentCh,flagSkip1st+1:end,:), 2));
                plot(app.spectraWide, tmpX,tmpY,'Color',app.BP_color(selBP,:),'LineWidth',2);
            end
            if flagTr
                % plot single trial
                tmpX = squeeze(app.BPpower(selBP).time);
                tmpY = squeeze(app.BPpower(selBP).phase(app.currentCh,app.currentTrial,:));
                plot(app.spectraWide, tmpX,tmpY,'Color',app.BP_color(selBP,:),'LineWidth',0.5);
            end
        end
    end    
    
    axis(app.spectraWide, [app.tmin app.tmax -180 180]);
    app.spectraWide.YScale = 'linear';
    app.spectraWide.YLabel.String = 'Phase';
    hold(app.spectraWide, 'off')
    
    app.lowerDB.Enable = 0;
    app.upperDB.Enable = 0;
    
elseif flagBPgamma_power
    if flagMd
        tmp(1:app.spgl) = app.meanSpgPlot(app.currentCh,1:app.spgl);
    else
        
        tmp(1:app.spgl) = app.spgPlot(app.currentCh,app.currentTrial,1:app.spgl);
        if flagFlt
            % adapt the filter frame and order to the length of the data
            frame = int32(app.spgl / 64) * 2 + 1;   % frame must be odd. Thats is why *2+1 !
            if (frame > 3), tmp = sgolayfilt(tmp,3,frame);
            else
                if (frame > 2), tmp = sgolayfilt(tmp,2,frame);
                end
            end
        end
    end
    plot(app.spectraWide, app.spgt,tmp);
    axis(app.spectraWide, [app.tmin app.tmax -inf inf]);
    if flagLog, app.spectraWide.YScale = 'log';
    end
    app.spectraWide.YLabel.String = 'Power';
    app.lowerDB.Enable = 0;
    app.upperDB.Enable = 0;
    
elseif flagEI
    if flagMd
        tmp(1:app.spgl) = app.meanEIrat(app.currentCh,1:app.spgl);
    else
        tmp(1:app.spgl) = app.EIrat(app.currentCh,app.currentTrial,1:app.spgl);
        if flagFlt
            % adapt the filter frame and order to the length of the data
            frame = int32(app.spgl / 64) * 2 + 1;   % frame must be odd. Thats is why *2+1 !
            if (frame > 3), tmp = sgolayfilt(tmp,3,frame);
            else
                if (frame > 2), tmp = sgolayfilt(tmp,2,frame);
                end
            end
        end
    end
    plot(app.spectraWide, app.spgt,tmp);
    axis(app.spectraWide, [app.tmin app.tmax -inf inf]);
    if flagLog, app.spectraWide.YScale = 'log';
    end
    %set(gca,'yscale','log');
    app.lowerDB.Enable = 0;
    app.upperDB.Enable = 0;
end

% set axes limits. Nah, not now!
axis(app.spectraWide, [app.tmin, app.tmax, app.yminTxt_spg.Value, app.ymaxTxt_spg.Value]);

% set axes inner position according to the axes of the LFP plot
app.spectraWide.InnerPosition(1)= app.wide_plot_up.InnerPosition(1);
app.spectraWide.InnerPosition(3)= app.wide_plot_up.InnerPosition(3);
