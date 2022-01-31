function fr8rasterAS(dataT)
% 
%
%
% raster plot of lever presses +
% histogram of presses in all trials combined
%
mytable = dataT(:,:); % copy the data table
% make sure it's not the ll300 data file:
% mytable.trials = dataT.trials(:,:);
GREEN = [102/255 204/255 0];
PURPLE = [204/255 51/255 1];

 for rowNr=1:length(mytable.animal)

    if mytable.condition(rowNr) == 'll5' || mytable.condition(rowNr) == 'roi5'
        dim2 = [0.13,0.584,0.193,0.34]; % for 5sec
    elseif mytable.condition(rowNr) == 'll300' || mytable.condition(rowNr) == 'roi300'
        dim2 = [0.1309,0.587,0.013,0.338]; % for 300ms
    else
        dim2 = [0 0 0 0];
    end

%     sz = length(mytable.trials{rowNr});
%         for i = 1:sz
%         if numel(mytable.trials{rowNr}{i}) < 3
%             mytable.trials{rowNr}{i} = [];
%         end
%     end
    
%     % ---
%     sq = length(mytable.trials{rowNr});
%     nanFilled = nan(sq,18); % make a nan array to fill
%     for j = 1:sq % put all trials inside the nan array
%         currenttrial = mytable.trials{rowNr}{j};
% %         if numel(currenttrial)>8
% %             currenttrial = currenttrial(1:8);
% %         end
%         nanFilled(j,1:length(currenttrial)) = currenttrial;
%     end
%     
    nanFilled = mytable.normAll{rowNr};
    
    % separate trials as laser and non-laser trials, put them in variables
    % named laserON and laserOFF

    laserIx = logical(mytable.L{rowNr});
%     if mytable.condition(rowNr) == 'baseline'
%         laserIx(:) = false;
%     end
    %
    % logiLaser = zeros(sq,1); % problem with sq vs sz !!!!!!!
    % logiLaser(laserIx) = 1
    laserON = nanFilled(laserIx,:);
    laserOFF = nanFilled(~laserIx,:);

    % get the timestamps of each press normalized to the first press of each
    % trial and put them in the variables: normLaser and normNoLaser
    normLaser = laserON - laserON(:,1);
    normNoLaser = laserOFF - laserOFF(:,1);
       
    bigger = max(size(normLaser,1),size(normNoLaser,1));
%     if bigger > 79
%         yAxLimL = bigger + 10;
%     else
%         yAxLimL = 80;
%     end
    yAxLimR = 400;
    yAxLimL = 120;
    if mytable.group(rowNr) == 0
        clr = PURPLE;
    else
        clr = GREEN;
    end
    fig = figure(1);
    clf;
    
    leftClr = [0 0 0];
    rightClr = [0.6 0.5 0.5];
    set(fig,'defaultAxesColorOrder',[leftClr; rightClr]);
    fig.PaperPositionMode = 'manual';
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [.25 .25 5 8];
    
    subplot(2,1,1); % subplot1 Laser ON trials
    gL = ndgrid(1:size(normLaser,1), 1:24);
    yyaxis left
    plot(normLaser, gL, 'LineStyle', 'none', 'Marker', '.', 'Color', clr);
    ylabel('Trials');
    hold on
%     dim1 = [0.13,0.145,0.193,0.34]; % for 5 sec
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
    gNL = ndgrid(1:size(normNoLaser,1), 1:24);
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
%     ax2 = gca;
%     grid minor; ax2.XMinorGrid = 'off';
%     ax2.MinorGridLineStyle = '-';
%     ax2.MinorGridAlphaMode = 'manual';
%     ax2.MinorGridAlpha = 0.1;
    hold off

    figurename = sprintf('LL_no%d_%s_forPaper', mytable.animal(rowNr), mytable.condition(rowNr));
    print(fig, figurename, '-dpdf');

 end
end