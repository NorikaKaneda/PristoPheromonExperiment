% においつきエリアを特定し、そこに個体がいるかどうかを判定する関数

% 1 フォルダからTrajectory.pngの画像を拾ってきて画面に表示
% 2 作業者はにおいの境界上の点をクリック×3、平均を取る
% 3 円の情報のファイルを読み取り、におい境界の点を標準化
% 4 においの境界の線を導出
% 5 情報ファイルからにおいの境界の情報を抽出、におい有の条件を式にする
% 6 Trajectoryデータと境界線をプロット
% 7 においつきエリアへの滞在の有無を01で保存
% 8 においつきエリアへの滞在率を導出、グラフ化

% このプログラムで保存されるファイル：
% _PheroBoundary.csv(境界を確定させるのに利用したクリックデータ) 
% _TrackPhero.csv（においつきエリアへの滞在を01で表したファイル）
% _PheroBoundary.png(トラッキングデータににおいエリアの境界を重ねて描いた図)
% _PheroBoundary.fig(同上)
% _ PheroBoundary_rot.png/fig（回転させたもの）


function PheroArea(Filename)

Info = readtable(append(extractBefore(Filename, 11), "-info.csv"));
%addpath("C:\Users\no5ri\OneDrive - The University of Tokyo\フォルダ\大学\授業課題等\卒業研究\実験記録\フェロモン\UMAtracker\撮影2\")
%Filename = "20240116_1_2";
%cd("C:\Users\no5ri\OneDrive - The University of Tokyo\フォルダ\大学\授業課題等\卒業研究\実験記録\フェロモン\UMAtracker\撮影2\20240116_2")

%【重要】既に座標ファイルが存在し座標取得部分を省略する場合はskip=1とすること
skip=1;

%% 1 フォルダからTrajectory.pngの画像を拾ってきて画面に表示

answer1 = "No";

while(answer1) ~= "Yes"

%名前の作成
Traj = append(Filename, "_Trajectory.fig");
% 画面に表示
openfig(Traj);
TrajAxes=gca;

%% 2 作業者はにおいの境界上の点をクリック×3、平均を取る

%初期設定
PheroN = 5; %クリックの数
PheroBoun = append(Filename, "_PheroBoundary.csv"); %ファイル名
PheroPoint = zeros(PheroN,2); %座標値


%フォルダ中に既にファイルが存在する場合は省略するか選べるダイアログを表示
if exist(PheroBoun)
    if skip==0
        quest = append("フォルダ中に既に作成された",PheroBoun, "が見つかりました。このデータを利用しますか？");
        answer = questdlg(quest);
        if answer=="Yes"
            PheroPoint = readmatrix(PheroBoun);
        else
            for i = 1:PheroN
                %openfig(Traj);
                title("境界の決定")
                PheroPoint(i,:) = ginput(1);
                %close
            end
            writematrix(PheroPoint, PheroBoun);
        end
    else
        PheroPoint = readmatrix(PheroBoun);
    end
else
    for i = 1:PheroN
        %openfig(Traj);
        title("境界の決定")
        PheroPoint(i,:) = ginput(1);
        %close
    end
    writematrix(PheroPoint, PheroBoun);
end

%平均をとる
PheroPoint = mean(PheroPoint,1);

%% 3 円の情報のファイルを読み取り、におい境界の点を標準化

%ファイルの読み取り
EllipseData = readstruct(append(Filename, "_EllipseData.xml"));
%においの境界上の点を標準化
NormPheroPoint = PheroPoint-EllipseData.center;

%% 4 においの境界の点を導出、表示
LineData = struct;

LineData.PheroPoint = NormPheroPoint;
LineData.incline = NormPheroPoint(2)/NormPheroPoint(1);
LineData.section = PheroPoint(2) - LineData.incline*PheroPoint(1);

%線を表示
x = 0:1500;
y = LineData.incline.*x + LineData.section;
hold(TrajAxes,"on")
plot(x,y)
hold off


%% 5 情報ファイルからにおいの境界の情報を抽出、におい有の条件を式にする

%情報ファイルの読み取り
number = str2double(extractAfter(Filename,11));
InfoFile = append(extractBefore(Filename, 11),"-info.csv");
Info = readtable(InfoFile);
PArea = string(Info.PheroPlace(number));

%不等号の向きの設定
Ineq = 0; % 不等号の向きを表す。1は線より下（数値が大きいこと）、2は線より上（数値が小さいこと）を意味する。0はエラー
Inequality = ['>','<'];
if PArea =='UP'
    Ineq = 2;
elseif PArea == 'DOWN'
    Ineq = 1;
elseif PArea == 'LEFT'
    if LineData.incline < 0
        Ineq = 2;
    else
        Ineq = 1;
    end
elseif PArea == 'RIGHT'
    if LineData.incline < 0
        Ineq = 1;
    else
        Ineq = 2;
    end
end
disp("においのある場所が満たす条件は")
disp(append("y ",Inequality(Ineq)," ", string(LineData.incline), "*x" ))

%画像ににおいのある側を表示
hold(TrajAxes, "on")

if abs(LineData.incline)<1
    if PArea == "UP"
        plot(650, 200, 'pentagram','MarkerSize',20)
    else
        plot(650, 500, 'pentagram','MarkerSize',20)
    end
else
    if PArea == "LEFT"
        plot(500, 350, 'pentagram','MarkerSize',20)
    else
        plot(800, 350, 'pentagram','MarkerSize',20)
    end
end

%{
if Ineq ==1
    plot(800, 500, 'pentagram','MarkerSize',20)
elseif Ineq==2
    plot(500, 200, 'pentagram','MarkerSize',20)
end
%}
hold off

%チェック（ダメなら最初に戻る）
if skip ==0
    quest1 = "境界線はこれでいいですか？";
    answer1 = questdlg(quest1);
    if answer1~="Yes"
        close
    end
else
    answer1 = "Yes";
end

end

%% 5.5 楕円の歪みにあわせて線の傾きを補正する

%楕円情報を読み取る
EllipseData = readstruct(append(Filename, "_EllipseData.xml"));

Datapoint = [1;LineData.incline]; %回転・拡大縮小前のデータ点（補正前の直線は[0,0]とこれを通る）
%回転行列の作成
RotateMat = [cos(-EllipseData.theta),-sin(-EllipseData.theta);sin(-EllipseData.theta),cos(-EllipseData.theta)];
CanRotateMat = [cos(EllipseData.theta),-sin(EllipseData.theta);sin(EllipseData.theta),cos(EllipseData.theta)];
%縦横補正行列の作成
LSMat = [500/EllipseData.L_axis,0;
    0,500/EllipseData.S_axis];
%回転
Datapoint = RotateMat*Datapoint;
%縦横補正
Datapoint = LSMat * Datapoint;
%回転して戻す
Datapoint = CanRotateMat*Datapoint;
%補正後の点からaを再定義
LineData.CorrIncline = Datapoint(2)/Datapoint(1);

writestruct(LineData, append(Filename, "_LineData.xml"));

%% 6 Trajectoryデータと境界線をプロット
Tracking = readmatrix(append(Filename, "-CorrPosition.csv"));

a = LineData.CorrIncline;

%半径500の円とあわせてプロット
figure
hold on
plot(Tracking(:,1),Tracking(:,2),'k-','LineWidth',1);
title(append(Filename, "のトラッキング記録"),'interpreter','none')
xlim([-600,600])
ylim([-600,600])

fimplicit(@(x,y) x.^2+y.^2-250000,'k', 'LineWidth', 2)
x=-600:600;
y = a.*x;
plot(x,y, '--', 'Color',[0.2, 0.2, 0.2])
ax = gca;
ax.XAxis.Visible = 'off';
ax.YAxis.Visible = 'off';
axis ij
daspect([1 1 1])
t=text(-550,-500,PArea);
t.FontSize = 20;
saveas(gca, append(Filename, "_PheroBoundary.png"))
saveas(gca, append(Filename, "_PheroBoundary.fig"))
hold off

%% 7 においつきエリアへの滞在の有無を01で保存

if Ineq ==1
    TrackPhero = Tracking(:,2)>LineData.CorrIncline*Tracking(:,1);
elseif Ineq==2
    TrackPhero = Tracking(:,2)<LineData.CorrIncline*Tracking(:,1);
end

writematrix(TrackPhero, append(Filename, "_TrackPhero.csv"))

%% 8 においつきエリアへの滞在率を導出、グラフ化
Size = length(TrackPhero);
figure
plot(TrackPhero)
ylim([-0.5,1.5])
xlim([0,Size])
disp("滞在率は")
sum(TrackPhero)/Size

%% 9 軌跡データを回す
% 傾きからθを出す
theta = atan(LineData.CorrIncline);
% 方向性データから回す方向を決定する
if Ineq==1
    RotTheta = pi/2-theta;
elseif Ineq==2
    RotTheta = 3*pi/2-theta;
end
% 回転行列を作る
RotateMat2 = [cos(RotTheta), -sin(RotTheta);sin(RotTheta), cos(RotTheta)];
% 回す
R_Tracking = zeros(size(Tracking,1), 2);
for i = 1:size(Tracking, 1)
    R_Tracking(i,:) = RotateMat2*Tracking(i,:)';
end

% 表示
% 半径500の円とあわせてプロット
figure
hold on
plot(R_Tracking(:,1),R_Tracking(:,2),'k-','LineWidth',1);
%title(append(Filename, "のトラッキング記録"),'interpreter','none')
xlim([-510,510])
ylim([-510,510])

fimplicit(@(x,y) x.^2+y.^2-250000,'k', 'LineWidth', 2)
xline(0, '--', 'Color',[0.2, 0.2, 0.2],'LineWidth', 2)
ax = gca;
ax.XAxis.Visible = 'off';
ax.YAxis.Visible = 'off';
axis ij
daspect([1 1 1])
% グラフと画像を保存
saveas(gca, append(Filename, "_PheroBoundary_rot.fig"))
saveas(gca, append(Filename, "_PheroBoundary_rot.svg"))
exportgraphics(gca,append(Filename, "_PheroBoundary_rot.png")) %余白を狭くして保存
hold off

%SorDも参照して保存
SampleNumber = double(extractAfter(Filename, 11));
if Info.Pheromone{SampleNumber} == Info.Walker{SampleNumber}
    exportgraphics(gca,append("..\同巣\",Filename, "_PheroBoundary_rot.png"))
else
    exportgraphics(gca,append("..\異巣\",Filename, "_PheroBoundary_rot.png"))
end
