function fr8rasterROI(dataT)
% Runs through the whole data table
%
%
% raster plot of lever presses +
% histogram of presses in all trials combined
%
mytable = dataT(:,:); % copy the data table

GREEN = [102/255 204/255 0]; % experimentals
PURPLE = [204/255 51/255 1]; % controls

 for rowNr=1:length(mytable.normCatEntries)
    
    if mytable.condition(rowNr) == 'll5' || mytable.condition(rowNr) == 'roi5'
        dim2 = [0.13,0.584,0.193,0.34]; % for 5sec
    elseif mytable.condition(rowNr) == 'll300' || mytable.condition(rowNr) == 'roi300'
        dim2 = [0.1309,0.587,0.013,0.338]; % for 300ms
    else
        dim2 = [0 0 0 0];
    end
%     nanFilled = mytable.catEntries{rowNr};
    % separate trials as laser and non-laser trials, put them in variables
    % named laserON and laserOFF
    laserIx = logical(mytable.L{rowNr});
    noLaserIx = mytable.NL{rowNr};
%     laserON = nanFilled(laserIx,:);
%     laserOFF = nanFilled(noLaserIx,:);
%     if mytable.condition(rowNr) == 'baseline'
%         laserIx(:) = false;
%     end

    % get the timestamps of each press normalized to the roi entry (1st
    % column of nanFilled) of each trial and put them in the variables:
    % normLaser and normNoLaser
%     normLaser = laserON - laserON(:,1);
%     normNoLaser = laserOFF - laserOFF(:,1);
    normLaser = mytable.normCatEntries{rowNr}(laserIx,:);
    normNoLaser = mytable.normCatEntries{rowNr}(noLaserIx,:);    

    % % % THIS PART DOESN'T WORK YET % % % 
    % highlight (make red dots) the rewarded presses, so that the successful
    % trials are visible
    % [rewardIx] = ismember(nanFilled(:,8),rewardTimestamps); % laser on ve
    % laser off'u ayirmak lazim
    % % % -------------------------- % % %
    
%    bigger = max(size(normLaser,1),size(normNoLaser,1));
%     if bigger > 59
%         yAxLimL = bigger + 5;
%     else
%         yAxLimL = 60;
%     end
    yAxLimL = 120;
    yAxLimR = 400;
    
    if mytable.group(rowNr) == 0
        clr = PURPLE;
    else
        clr = GREEN;
    end
    fig = figure(rowNr);
    clf;
    leftClr = [0 0 0]; % left axis color (trials #s)
    rightClr = [0.6 0.5 0.5]; % right axis color (histogram)
    set(fig,'defaultAxesColorOrder',[leftClr; rightClr]);
    fig.PaperPositionMode = 'manual';
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [.25 .25 5 8];
    
    subplot(2,1,1); % subplot1 Laser ON trials
    gL = ndgrid(1:size(normLaser,1), 1:size(normLaser,2));
    yyaxis left
    plot(normLaser, gL, 'LineStyle', 'none', 'Marker', '.', 'Color', clr);
    ylabel('Trials');
    hold on
    las = [0.30 0.75 0.93];
    r = annotation('rectangle',dim2,'FaceColor',las,'FaceAlpha',.2);
    r.Color = 'none';
    ylim([0 yAxLimL]);
    yyaxis right
    histogram(normLaser,'BinWidth',1,'DisplayStyle','stairs');
    ylabel('Press count (bin width = 1)');
    ylim([0 yAxLimR]);
    xlabel('Time (s)');
    xlim([0 20]);
    ax1 = gca;
%     grid minor; ax1.XMinorGrid = 'off';
%     ax1.MinorGridLineStyle = '-';
%     ax1.MinorGridAlphaMode = 'manual';
%     ax1.MinorGridAlpha = 0.1;
    hold off
    title(mytable.animal(rowNr));
    
    subplot(2,1,2); % subplot2 Laser OFF trials
    gNL = ndgrid(1:size(normNoLaser,1), 1:size(normNoLaser,2));
    yyaxis left
    plot(normNoLaser, gNL, 'LineStyle', 'none', 'Marker', '.', 'color',clr);
    ylabel('Trials');
    ylim([0 yAxLimL]);
    hold on
    yyaxis right
    histogram(normNoLaser,'BinWidth', 1,'DisplayStyle','stairs');
    ylabel('Press count (bin width = 1)');
    ylim([0 yAxLimR]);
    xlabel('Time (s)');
    xlim([0 20]);
    ax2 = gca;
%     grid minor; ax2.XMinorGrid = 'off';
%     ax2.MinorGridLineStyle = '-';
%     ax2.MinorGridAlphaMode = 'manual';
%     ax2.MinorGridAlpha = 0.1;
    hold off
    figurename = sprintf('ROI_no%d_%s_forPaper', mytable.animal(rowNr), mytable.condition(rowNr));
%     figurename = sprintf('ROI_no%d_baseline', mytable.animal(rowNr));
%   print(fig, figurename, '-dpdf');

 end
end