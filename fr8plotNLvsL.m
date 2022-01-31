function fr8plotNLvsL(M_expe, M_ctrl)
% Makes the figure in Nadine's poster
% Two matrices as inputs, one for experimentals, one for controls.
% Structure of the matrices should be as follows:
%   M(:,1): nostim (5sec)
%   M(:,2): stim (5sec)

SEM = @(x)std(x)./sqrt(length(x));

figure;clf;
for m=1:size(M_ctrl,1)
    plot([0.6,1.4],[M_ctrl(m,1), M_ctrl(m,2)],'m-o','Markersize',10);
    hold on
end
plot([0.6,1.4], [mean(M_ctrl(:,1)), mean(M_ctrl(:,2))], 'k-s', ...
    'Markersize', 10, 'MarkerFaceColor', 'k');
errorbar([0.6,1.4], mean(M_ctrl,1), SEM(M_ctrl),'k-s',...
    'MarkerFaceColor', 'k');

for k = 1:size(M_expe,1)
    plot([2.6,3.4],[M_expe(k,1),M_expe(k,2)],'g-o','Markersize',10);
    hold on
end
plot([2.6,3.4], [mean(M_expe(:,1)), mean(M_expe(:,2))], 'k-s', ...
    'Markersize', 10, 'MarkerFaceColor', 'k');
errorbar([2.6,3.4], mean(M_expe,1), SEM(M_expe), 'k-s',...
    'MarkerFaceColor', 'k');

% for i=1:size(M_ctrl,1)
%     plot([1.8, 2.2],[M_ctrl(i,2), M_ctrl(i,3)], 'm-o', 'Markersize', 10);
%     hold on
% end
% plot([1.8, 2.2], [mean(M_ctrl(:,2)),mean(M_ctrl(:,3))], 'k-s', ...
%     'Markersize', 10, 'MarkerFaceColor', 'k');
% 
% for j = 1:size(M_expe,1)
%     plot([2.8, 3.2],[M_expe(j,2), M_expe(j,3)], 'g-o', 'Markersize', 10);
%     hold on
% end
% plot([2.8, 3.2], [mean(M_expe(:,2)),mean(M_expe(:,3))], 'k-s', ...
%     'Markersize', 10, 'MarkerFaceColor', 'k');
% 
% for p=1:size(M_ctrl,1)
%     plot([3.8, 4.2],[M_ctrl(p,4), M_ctrl(p,5)], 'm-o', 'Markersize', 10);
%     hold on
% end
% plot([3.8, 4.2], [mean(M_ctrl(:,4)),mean(M_ctrl(:,5))], 'k-s', ...
%     'Markersize', 10, 'MarkerFaceColor', 'k');
% 
% for t = 1:size(M_expe,1)
%     plot([4.8, 5.2],[M_expe(t,4), M_expe(t,5)], 'g-o', 'Markersize', 10);
%     hold on
% end
% plot([4.8, 5.2], [mean(M_expe(:,4)),mean(M_expe(:,5))], 'k-s', ...
%     'Markersize', 10, 'MarkerFaceColor', 'k');

xlim([0 4])
xticks([0.6 1.4 2.6 3.4])
xticklabels({'nl','l','nl','l'})
end