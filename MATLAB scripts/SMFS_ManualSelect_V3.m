function SMFS_ManualSelect_V3
%Change from V2: guiN is now evaluating M
% UI to select which curves are suitable
%% Defining parts of interface
fig = uifigure;
fig.Name = "selection window";
gl = uigridlayout(fig,[2 6]);
gl.RowHeight = {'1x',50};
gl.ColumnWidth = {'1x','1x','1x','1x','1x','1x'};
ax1 = uiaxes(gl);
ax2 = uiaxes(gl);
ax3 = uiaxes(gl);
bt1 = uibutton(gl);
bt2 = uibutton(gl);
bt3 = uibutton(gl);
bt4 = uibutton(gl);
bt5 = uibutton(gl);
wtb = uislider(gl);
%% Layouts
ax1.Layout.Row = 1;
ax1.Layout.Column = [1 2];
ax2.Layout.Row = 1;
ax2.Layout.Column = [3 4];
ax3.Layout.Row = 1;
ax3.Layout.Column = [5 6];
bt1.Layout.Row = 2;
bt1.Layout.Column = 1;
bt2.Layout.Row = 2;
bt2.Layout.Column = 2;
bt3.Layout.Row = 2;
bt3.Layout.Column = 3;
bt4.Layout.Row = 2;
bt4.Layout.Column = 4;
bt5.Layout.Row = 2;
bt5.Layout.Column = 5;
wtb.Layout.Row = 2;
wtb.Layout.Column = 6;
%% Initial plots
guiplotop = evalin('base','plotop');
guiData = evalin('base','Data');
guidatop = evalin('base','datop');
guiN = evalin('base','M');
guiManvalid = strings(guiN,1);
i = 1;
hold(ax1,'on');
hold(ax2,'on');
hold(ax3,'on');
ax1.FontSize = guiplotop.axfontsize;
ax1.XLabel.String = 'height (m)';
ax1.YLabel.String = 'force (N)';
ax2.FontSize = guiplotop.axfontsize;
ax2.XLabel.String = 'time (s)';
ax2.YLabel.String = 'force (N)';
ax3.FontSize = guiplotop.axfontsize;
ax3.XLabel.String = 'time (s)';
ax3.YLabel.String = 'height (m)';
for j = 1:length(guidatop.nCol)
    plot(ax1,guiData{i,j}(:,guidatop.nCol(j)-2),guiData{i,j}(:,2))
    plot(ax2,guiData{i,j}(:,guidatop.nCol(j)-1),guiData{i,j}(:,2))
    plot(ax3,guiData{i,j}(:,guidatop.nCol(j)-1),guiData{i,j}(:,guidatop.nCol(j)-2))
end
%% Programming buttons and waitbar
wtb.Limits = [0 guiN];
wtb.Value = i;
bt1.Text = 'Valid single event';
bt2.Text = 'No bond formed';
bt3.Text = 'Single bond broke in retraction';
bt4.Text = 'Multiple bonds formed';
bt5.Text = 'Other or unknown';

bt1.ButtonPushedFcn = {@isvalid,guiN,guiData,guidatop,ax1,ax2,ax3,wtb};
bt2.ButtonPushedFcn = {@isvalid,guiN,guiData,guidatop,ax1,ax2,ax3,wtb};
bt3.ButtonPushedFcn = {@isvalid,guiN,guiData,guidatop,ax1,ax2,ax3,wtb};
bt4.ButtonPushedFcn = {@isvalid,guiN,guiData,guidatop,ax1,ax2,ax3,wtb};
bt5.ButtonPushedFcn = {@isvalid,guiN,guiData,guidatop,ax1,ax2,ax3,wtb};

function isvalid(src,event,guiN,guiData,guidatop,ax1,ax2,ax3,wtb)
    guiManvalid(i) = src.Text;
    if i == guiN
        assignin('base','manvalid',guiManvalid);
        close(fig)
    else
       i = i + 1;
       wtb.Value = i;
       cla(ax1);
       cla(ax2);
       cla(ax3);
        hold(ax1,'on');
        hold(ax2,'on');
        hold(ax3,'on');
        for j = 1:length(guidatop.nCol)
            plot(ax1,guiData{i,j}(:,guidatop.nCol(j)-2),guiData{i,j}(:,2))
            plot(ax2,guiData{i,j}(:,guidatop.nCol(j)-1),guiData{i,j}(:,2))
            plot(ax3,guiData{i,j}(:,guidatop.nCol(j)-1),guiData{i,j}(:,guidatop.nCol(j)-2))
        end
    end
end

end