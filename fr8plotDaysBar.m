function fr8plotDaysBar(expe, ctrl)
% Makes the figure in Nadine's poster
% Two matrices as inputs, one for experimentals, one for controls.
% Structure of the matrices should be as follows:
%   M(:,1): baseline
%   M(:,2): 300ms
%   M(:,3): 5sec


SEM = @(x)std(x)./sqrt(numel(x));
% get means
m_expe = mean(expe);
m_ctrl = mean(ctrl);
% get sems
e_expe = SEM(expe);
e_ctrl = SEM(ctrl);

figure;clf;
bar([2.2, 2.6, 3.0], m_expe, 'g', 'FaceAlpha', 0.4);
hold on
errorbar([2.2, 2.6, 3.0], m_expe, e_expe, 'g+');

bar([0.8, 1.2, 1.6], m_ctrl, 'm', 'FaceAlpha', 0.4);
errorbar([0.8, 1.2, 1.6], m_ctrl, e_ctrl, 'm+');
for i=1:size(expe,1)
    plot([2.2, 2.6, 3.0],[expe(i,1), expe(i,2), expe(i,3)],...
        'go', 'Markersize', 10);
    hold on
end
for j = 1:size(ctrl,1)
    plot([0.8, 1.2, 1.6],[ctrl(j,1), ctrl(j,2), ctrl(j,3)],...
        'mo', 'Markersize', 10);
    hold on
end

xlim([0.3 3.5])
xticks([0.8, 1.2, 1.6, 2.2, 2.6, 3.0])
end