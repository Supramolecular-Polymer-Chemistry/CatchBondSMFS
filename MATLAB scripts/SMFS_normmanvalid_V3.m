% Change fron V1: using M instead of N for range (compatible with partial
% import)
% Change from V2: automatically saves figures and dataset
Diag = 1; % Set to 0 to not plot diag graphs
filtop.hsmooth1 = 21;       % Smoothing is applied over this range of datapoints before determining first derivative
filtop.hsmooth2 = 21;       % Smoothing is applied over this range of datapoints before determining second derivative
filtop.sm2cutoff = 41;      % After determining first derivative, these points are cut off on each side to remove artifacts at start and end
filtop.d2hprom = 2e-6;    % If a peak in height acceleration (in m/s^2) with this prominence is found, a debonding event is assumed

%% Normalizes validated data in first 90% of approach to remove F-h baseline
k = 1;
for i = 1:M
    if strcmp(manvalid(i),'Valid single event')
      FHlin(i,:) = polyfit(Data{i,1}(1:floor(0.9*size(Data{i,1},1)),7),Data{i,1}(1:floor(0.9*size(Data{i,1},1)),2),1);
      for j = 1:6
          Datcorr{k,j} = Data{i,j};
          Datcorr{k,j}(:,2) = Data{i,j}(:,2)-Data{i,j}(:,datop.nCol(j)-2)*FHlin(i,1)-FHlin(i,2);
      end
      k = k+1;
    end
end

%% Diagnostic figure of all blocks
if Diag == 1
    figure
    tiledlayout(1,6)
    for j = 1:6
        nexttile
        hold on
            for i = 1:size(Datcorr,1)
            plot(Datcorr{i,j}(:,datop.nCol(j)),Datcorr{i,j}(:,2),'LineWidth',plotop.linewidth)
            end
        xlabel('Segment time (s)','FontSize',plotop.axfontsize)
        ylabel('Force (N)','FontSize',plotop.axfontsize)
        title(sprintf('Block %d',j))
        ax = gca;
        ax.FontSize = plotop.tickfontsize;
    end
    saveas(gcf,append(datop.saveas,'_d1.fig'))
end

%% Plot smoothed data in block 4
 figure
    tiledlayout(1,2)
    j = 4;
        nexttile
        hold on
        for i = 1:size(Datcorr,1)
        plot(Datcorr{i,j}(:,datop.nCol(j)),smooth(Datcorr{i,j}(:,2),filtop.hsmooth1),'LineWidth',plotop.linewidth)
        end
        xlabel('Segment time (s)','FontSize',plotop.axfontsize)
        ylabel('Force (N)','FontSize',plotop.axfontsize)
        title(sprintf('Block %d',j))
        ax = gca;
        ax.FontSize = plotop.tickfontsize;
        nexttile
        hold on
        for i = 1:size(Datcorr,1)
        plot(Datcorr{i,j}(:,datop.nCol(j)),smooth(Datcorr{i,j}(:,datop.nCol(j)-2),filtop.hsmooth1),'LineWidth',plotop.linewidth)
        end
        xlabel('Segment time (s)','FontSize',plotop.axfontsize)
        ylabel('height (m)','FontSize',plotop.axfontsize)
        title(sprintf('Block %d',j))
        ax = gca;
        ax.FontSize = plotop.tickfontsize;
        saveas(gcf,append(datop.saveas,'_d2.fig'))
        
%% Save
        save(datop.saveas);