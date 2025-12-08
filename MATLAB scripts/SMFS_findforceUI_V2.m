function [Fres,tau] = SMFS_findforceUI_V2(Datcorr,Fs,Fpass,datop)
%Uses a UI to check if the event is detected correctly
%Fs = 16384/30; % sampling frequency
%Fpass = 10; % lowpass filter frequency in Hz
Fres = zeros(size(Datcorr,1),1);
tau = zeros(size(Datcorr,1),1);
%% Window setup
fig = uifigure;
fig.Name = "Is this the event?";
gl = uigridlayout(fig,[2 6]);
gl.RowHeight = {'1x',50};
gl.ColumnWidth = {'1x','1x','1x','1x','1x','1x'};
ax1 = uiaxes(gl);
ax2 = uiaxes(gl);
ax3 = uiaxes(gl);
bt1 = uibutton(gl);
bt2 = uibutton(gl);
lbl = uilabel(gl);
wtb = uislider(gl);
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
wtb.Layout.Row = 2;
wtb.Layout.Column = [5 6];
wtb.Limits = [1 size(Datcorr,1)];
wtb.Value = 1; %initial value; changes with k
lbl.Layout.Row = 2;
lbl.Layout.Column = [3 4];

%% Initial plots
k = 1;
plotop = evalin('base','plotop');
hold(ax1,'on');
hold(ax2,'on');
hold(ax3,'on');
ax1.FontSize = plotop.axfontsize;
ax1.XLabel.String = 'time (s)';
ax1.YLabel.String = 'force (N)';
ax2.FontSize = plotop.axfontsize;
ax2.XLabel.String = 'time (s)';
ax2.YLabel.String = 'force (N)';
ax3.FontSize = plotop.axfontsize;
ax3.XLabel.String = 'time (s)';
ax3.YLabel.String = 'height (m)';

ydat = Datcorr{k,4}(:,2);
hdat = Datcorr{k,4}(:,datop.nCol(4)-2);
tdat = Datcorr{k,4}(:,datop.nCol(4));
[Fauto,i] = autofind(ydat,Fpass,Fs);
tauto = tdat(i);
autoplot (ydat,hdat,tdat,i,Fauto,tauto,ax1,ax2,ax3,lbl)

%% Programming buttons, graph, waitbar
bt1.Text = 'Accept event';
bt2.Text = 'Manually select zone';
bt1.ButtonPushedFcn = {@acceptevent};
bt2.ButtonPushedFcn = {@brushbefore};

    function acceptevent(~,~)    
    Fres(k)=Fauto;
    tau(k)=tauto;
        if k < size(Datcorr,1)
        k = k+1;
        wtb.Value = k;
        cla(ax1);
        cla(ax2);
        cla(ax3);
        ydat = Datcorr{k,4}(:,2);
        hdat = Datcorr{k,4}(:,datop.nCol(4)-2);
        tdat = Datcorr{k,4}(:,datop.nCol(4));
        [Fauto,i] = autofind(ydat,Fpass,Fs);
        tauto = tdat(i);
        autoplot(ydat,hdat,tdat,i,Fauto,tauto,ax1,ax2,ax3,lbl)
        bt1.Text = 'Accept event';
        bt2.Text = 'Manually select zone';
        bt1.ButtonPushedFcn = {@acceptevent};
        bt2.ButtonPushedFcn = {@brushbefore};
        else
            uiresume(fig)
        end
    end
    function brushbefore(~,~)
        brush(ax1,'on')
        bt1.Text = 'Cancel';
        bt2.Text = 'Select data points before event and click here';
        bt1.ButtonPushedFcn = {@cancelrange};
        bt2.ButtonPushedFcn = {@brushafter};
    end
    function brushafter(~,~)
        brushed = ax1.Children.BrushData;
        ibs = find(brushed,1,'First');
        ibe = find(brushed,1,'Last');
        ybav = mean(ydat(ibs:ibe));
        cla(ax2);
        cla(ax3);
        manbefore(ydat,hdat,tdat,ybav,ibs,ibe,ax1,ax2,ax3)
        brush(ax1,'on')
        bt1.Text = 'Cancel';
        bt2.Text = 'Select data points after event and click here';
        bt1.ButtonPushedFcn = {@cancelrange};
        bt2.ButtonPushedFcn = {@rangeselected,ibe,ybav};
    end
    function cancelrange(~,~)
            brush(ax1,'off')
            cla(ax1);
            cla(ax2);
            cla(ax3);
            autoplot(ydat,hdat,tdat,i,Fauto,tauto,ax1,ax2,ax3,lbl)
            bt1.Text = 'Accept event';
            bt2.Text = 'Manually select zone';
            bt1.ButtonPushedFcn = {@acceptevent};
            bt2.ButtonPushedFcn = {@brushbefore};
    end
    function rangeselected(~,~,ibe,ybav)
            brush(ax1,'off')
            brushed = ax1.Children.BrushData;
            ias = find(brushed,1,'First');
            iae = find(brushed,1,'Last');
            if ias < ibe
                msgbox('Range after event must start after range before event ends')
                cancelrange(NaN,NaN)
            else
                yaav = mean(ydat(ias:iae));
                [Fauto,i] = manafter(ydat,hdat,tdat,ybav,yaav,ibe,ias,iae,ax1,ax2,ax3);
                tauto = tdat(i);
                lbl.Text = sprintf("Force: %.3G N \n Lifetime: %.3G s",Fauto,tauto);
                bt1.Text = 'Accept event';
                bt2.Text = 'Cancel';
                bt1.ButtonPushedFcn = {@acceptevent};
                bt2.ButtonPushedFcn = {@cancelrange};
            end

    end
uiwait(fig)
end


%% Autofind: finds maximum derivative of denoised force curve and returns force difference and index
function [Fauto,i] = autofind(ydat,Fpass,Fs)
    yfilt = lowpass(ydat,Fpass,Fs);
    yfpr = gradient(yfilt(:));
    [~,i] = max(yfpr(1:length(yfpr)-10)); % cut off last ten data points because the lowpass filter will cause artificial maximum
    if (i>15) && (i<length(yfpr)-15)
        Fauto = mean(ydat(i+5:i+15))-mean(ydat(i-15:i-5));
    elseif (i <= 15) && (i>5)
        Fauto = mean(ydat(i+5:i+15))-mean(ydat(1:i-5));
    elseif (i >= length(yfpr)-15) && (i < length(yfpr)-5)
        Fauto = mean(ydat(i+5:length(ydat)))-mean(ydat(i-15:i-5));
    else 
        Fauto = NaN;
    end
end

%% Autoplot: plot the three axes and update label
function autoplot(ydat,hdat,tdat,i,Fauto,tauto,ax1,ax2,ax3,lbl)
plot(ax1,tdat(:),ydat(:))
plot(ax2,tdat(max(i-15,1):min(i+15,length(ydat))),ydat(max(i-15,1):min(i+15,length(ydat))),tdat(i),ydat(i),'o')
plot(ax3,tdat(max(i-15,1):min(i+15,length(ydat))),hdat(max(i-15,1):min(i+15,length(ydat))),tdat(i),hdat(i),'o')
lbl.Text = sprintf("Force: %.3G N \n Lifetime: %.3G s",Fauto,tauto);
end

%% Manbefore: update axes
function manbefore(ydat,hdat,tdat,ybav,ibs,ibe,ax1,ax2,ax3)
xlim(ax1,[tdat(ibs) tdat(max(ibe+4*(ibe-ibs),length(ydat)))])
plot(ax2,tdat(max(ibs-15,1):min(ibe+15,length(ydat))),ydat(max(ibs-15,1):min(ibe+15,length(ydat))),[tdat(ibs) tdat(ibe)],[ybav ybav])
plot(ax3,tdat(max(ibs-15,1):min(ibe+15,length(ydat))),hdat(max(ibs-15,1):min(ibe+15,length(ydat))))
end
%% Manafter: update axes and label
function [Fauto, i] = manafter(ydat,hdat,tdat,ybav,yaav,ibe,ias,iae,ax1,ax2,ax3)
Fauto = yaav-ybav;
yfpr = gradient(ydat(ibe:ias));
[~,ind] = max(yfpr);
i = ind + ibe - 1;
plot(ax1,tdat(i),ydat(i),'o')
plot(ax2,[tdat(ias) tdat(iae)],[yaav yaav],tdat(i),ydat(i),'o')
plot(ax3,tdat(i),hdat(i),'o')
end