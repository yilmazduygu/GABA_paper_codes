function fr8plotSEM(M_expe, M_ctrl)

SEM = @(x)std(x)./sqrt(length(x));

figure;clf;
cols = size(M_expe,2);
% e_pos = [1.2, 2.8, 3.2, 4.8, 5.2];
% c_pos = [0.8, 1.8, 2.2, 3.8, 4.2];
pos = [0.6,1.4,2.6,3.4];
for i=1:size(M_expe,1)
    plot(pos(1:cols),M_expe(i,:), 'go', 'Markersize', 10);
    hold on
end
errorbar(pos(1:2), mean(M_expe(:,1:2),1), SEM(M_expe(:,1:2)), 'g-s',...
    'MarkerFaceColor', 'g');
errorbar(pos(3:cols), mean(M_expe(:,3:4),1), SEM(M_expe(:,3:4)), 'g-s',...
    'MarkerFaceColor', 'g');


for j = 1:size(M_ctrl,1)
    plot(pos(1:cols),M_ctrl(j,:), 'mo', 'Markersize', 10);
    hold on
end

errorbar(pos(1:2), mean(M_ctrl(:,1:2),1), SEM(M_ctrl(:,1:2)),'m-s',...
    'MarkerFaceColor', 'm');
errorbar(pos(3:cols), mean(M_ctrl(:,3:4),1), SEM(M_ctrl(:,3:4)),'m-s',...
    'MarkerFaceColor', 'm');

xlim([0 4])
xticks([0.6,1.4,2.6,3.4])
end