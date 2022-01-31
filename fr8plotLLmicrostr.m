% fr8plotmicrostr

function fr8plotLLmicrostr(presses,rewards,laser, head)
    n = length(presses);
    pressno = 1:n;
    [~,las] = intersect(presses,laser);
    [~,rew] = intersect(presses,rewards);
    g = ones(n,1);
    g(las) = 2;
    g(rew) = 3;
    
    gscatter(presses,pressno,g,'kbr','...',6);
    hold on
    stem(head, 20.*ones(size(head)), 'Marker', 'none');
    xlim([0 3605])
end