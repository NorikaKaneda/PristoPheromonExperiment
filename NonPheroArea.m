% においなしエリアの左側歩行率を出すプログラム

% 1 Trajectoryデータと縦線をプロット
% 2 左側エリアへの滞在の有無を01で保存
% 3 左側エリアへの滞在率を導出、グラフ化
% 4 RotPositionファイルの作成

function NonPheroArea(Filename)

%% 1 Trajectoryデータと縦線をプロット
Tracking = readmatrix(append(Filename, "-CorrPosition.csv"));
%半径500の円とあわせてプロット
figure
hold on
plot(Tracking(:,1),Tracking(:,2),'k-','LineWidth',1);
xlim([-510,510])
ylim([-510,510])

fimplicit(@(x,y) x.^2+y.^2-250000,'k', 'LineWidth', 2)
% x=zeros(1,1201);
% y=-600:600;
%plot(x,y, '--', 'Color',[0.2, 0.2, 0.2])
xline(0,'--', 'Color',[0.2, 0.2, 0.2],'LineWidth',2)
axis ij
daspect([1 1 1])
ax = gca;
ax.XAxis.Visible = 'off';
ax.YAxis.Visible = 'off';
exportgraphics(gca,append(Filename, "_PheroBoundary_rot.png"))
saveas(gca, append(Filename, "_PheroBoundary_rot.svg"))
saveas(gca, append(Filename, "_PheroBoundary_rot.fig"))
xlim([-600,600])
ylim([-600,600])
t=text(-580,-500,"においなし");
title(append(Filename, "のトラッキング記録"),'interpreter','none')
t.FontSize = 20;
saveas(gca, append(Filename, "_PheroBoundary.png"))
saveas(gca, append(Filename, "_PheroBoundary.fig"))

hold off

%% 2 左側エリアへの滞在の有無を01で保存

TrackPhero = Tracking(:,1)<0;
writematrix(TrackPhero, append(Filename, "_TrackPhero.csv"));

%% 3 左側エリアへの滞在率を導出、グラフ化

StayRate(TrackPhero)

%% 4 RotPositionファイルの作成
writematrix(Tracking, append(Filename, "-RotPosition.csv"));

end




function StayRate(TrackPhero)
    Size = length(TrackPhero);
    figure
    plot(TrackPhero)
    ylim([-0.5,1.5])
    xlim([0,Size])
    disp("滞在率は")
    sum(TrackPhero)/Size
end