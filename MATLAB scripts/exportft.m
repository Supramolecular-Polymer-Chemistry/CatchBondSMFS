function [edges,values,frac,time] = exportft(F_ev,tau_ev,binsize)
%% Discretizes force data
edges = [0:binsize:max(F_ev)+binsize];
values = [0.5*binsize:binsize:max(edges)];
Fbin = discretize(F_ev,edges,values);

hold on
legend('show')
for k = 1:length(values)
    ind = Fbin == values(k);
    lifetimes = tau_ev(ind);
    if ~isempty(lifetimes)
        lifetimes = sort(lifetimes);
        for i = 1:length(lifetimes)
            frac(i,k) = 1-(i/(length(lifetimes)+1));
            time(i,k) = lifetimes(i);
        end
        scatter(time(:,k),frac(:,k),'DisplayName',sprintf("%.0f - %.0f pN",edges(k)*10.^12,edges(k+1)*10.^12))
    end
end
ax = gca;
set(ax,'xscale','log')
ax.FontSize = 14;
set(ax.Legend,'FontSize',14)
set(ax,'LineWidth',1)
xlabel('Time (s)','FontSize',14)
ylabel('Fraction intact','FontSize',14)