% においつきエリアを特定し、そこに個体がいるかどうかを判定する関数（修正版）

% 1 においの境界線を確定させる
%   1.1 フォルダからTrajectory.pngの画像を拾ってきて画面に表示
%   1.2 作業者はにおいの境界上の点をクリック×3、平均を取る
%   1.3 においの線をひく
%       1.3.1 円の情報のファイルを読み取り、においの境界の線を導出
%       1.3.2 情報ファイルからにおいの境界の情報を抽出、におい有の条件を式にする
%   1.4 OKなら線の確定
% 2 Trajectoryデータと境界線を補正してプロット
%   2.1 楕円の歪みにあわせて線の傾きを補正する
%   2.2 あわせてプロットする
% 3 においつきエリアへの滞在の有無を01で保存
% 4 においつきエリアへの滞在率を導出、グラフ化
% 5 軌跡データを回す
%   5.1 抽象化データを回す
%   5.2 回したものを表示、図として保存
%   5.3 回したプロットデータも保存

%このプログラムで必要なファイル: 
% _Trajectory.fig
% _PheroBoundary.csv(あれば)
% _EllipseData.xml
% -CorrPosition.csv

% このプログラムで保存されるファイル：
% _PheroBoundary.csv(境界を確定させるのに利用したクリックデータ) 
% _TrackPhero.csv（においつきエリアへの滞在を01で表したファイル）
% _LineData.xml
% _PheroBoundary.png/fig(トラッキングデータににおいエリアの境界を重ねて描いた図)
% _PheroBoundary_rot.png/fig（回転させたもの）
% -RotPosition.csv


function PheroArea(Filename)


Info = readinfo(Filename);


%【重要】既に座標ファイルが存在し座標取得部分を省略する場合はskip=1とすること
skip=1;

%% 1 においの境界線を確定させる

% 1.1 フォルダからTrajectory.pngの画像を拾ってきて画面に表示

answer1 = "No";

while(answer1) ~= "Yes"

 %名前の作成
Traj = append(Filename, "_Trajectory.fig");
 % 画面に表示
openfig(Traj);
title("境界の決定")
TrajAxes=gca;


% 1.2 作業者はにおいの境界上の点をクリック×3、平均を取る

 %初期設定
PheroN = 5; %クリックの数
PheroBoun = append(Filename, "_PheroBoundary.csv"); %ファイル名
PheroPoint = zeros(PheroN,2); %座標値


%フォルダ中に既にファイルが存在する場合は省略するか選べるダイアログを表示
if exist(PheroBoun) % PheroBoundary.csvが既にあるならば
    if skip==0 % スキップしないならば
        quest = append("フォルダ中に既に作成された",PheroBoun, "が見つかりました。このデータを利用しますか？");
        answer = questdlg(quest);
        if answer=="Yes" % 既にあるデータを利用するならば
            PheroPoint = readmatrix(PheroBoun);
        else % データを破棄して作り直すならば
            for i = 1:PheroN
                PheroPoint(i,:) = ginput(1);
            end
            writematrix(PheroPoint, PheroBoun);
        end
    else % スキップするならば
        PheroPoint = readmatrix(PheroBoun);
    end
else % 座標データが無いならば
    for i = 1:PheroN
        PheroPoint(i,:) = ginput(1);
    end
    writematrix(PheroPoint, PheroBoun);
end

 %平均をとる
PheroPoint = mean(PheroPoint,1);


% 1.3 においの線を引く
% 1.3.1 円の情報のファイルを読み取り、においの境界の線を導出

 %ファイルの読み取り
EllipseData = readstruct(append(Filename, "_EllipseData.xml"));
 %においの境界上の点を標準化(これと原点を繋げば切片0の直線に)
NormPheroPoint = PheroPoint-EllipseData.center;

LineData = struct; % 画像上に線を引くための変数

LineData.PheroPoint = NormPheroPoint;
LineData.incline = NormPheroPoint(2)/NormPheroPoint(1);
LineData.section = PheroPoint(2) - LineData.incline*PheroPoint(1);

%線を表示
x = 0:1500;
y = LineData.incline.*x + LineData.section;
hold(TrajAxes,"on")
plot(x,y)
hold off


% 1.3.2 情報ファイルからにおいの境界の情報を抽出、におい有の条件を式にする

%情報ファイルの読み取り
PArea = string(Info.PheroPlace);

%不等号の向きの設定
LineData.Ineq = 0; % 不等号の向きを表す。1は線より下（数値が大きいこと）、2は線より上（数値が小さいこと）を意味する。0はエラー
Inequality = ['>','<'];
if PArea =='UP'
    LineData.Ineq = 2; %UPであれば線より上
elseif PArea == 'DOWN'
    LineData.Ineq = 1; %DOWNであれば線より下
elseif PArea == 'LEFT' %以下ディスプレイ座標系注意
    if LineData.incline < 0
        LineData.Ineq = 2; %LEFTで傾きが負であれば線より上
    else
        LineData.Ineq = 1; %LEFTで傾きが正であれば線より下
    end
elseif PArea == 'RIGHT'
    if LineData.incline < 0
        LineData.Ineq = 1; %RIGHTで傾きが負であれば線より下
    else
        LineData.Ineq = 2; %RIGHTで傾きが正であれば線より上
    end
end
disp("においのある場所が満たす条件は")
disp(append("y ",Inequality(LineData.Ineq)," ", string(LineData.incline), "*x" ))

%画像ににおいのある側を表示
hold(TrajAxes, "on")
if abs(LineData.incline)<1 %傾きが小さい→横線→UPかDOWN
    if PArea == "UP"
        plot(650, 200, 'pentagram','MarkerSize',20)
    else % つまりDOWNのとき
        plot(650, 500, 'pentagram','MarkerSize',20)
    end
else % 傾きが大きい→縦線→LEFTかRIGHT
    if PArea == "LEFT"
        plot(500, 350, 'pentagram','MarkerSize',20)
    else %つまりRIGHTのとき
        plot(800, 350, 'pentagram','MarkerSize',20)
    end
end


hold off

% 1.4 OKなら線の確定
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

end % クリック結果が不満ならここまでをループ


% 2 Trajectoryデータと境界線を補正してプロット

% 2.1 楕円の歪みにあわせて線の傾きを補正する

LineData = CorrLine(Filename, LineData);

writestruct(LineData, append(Filename, "_LineData.xml"));

%% 2.2 あわせてプロットする
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


%% 3 においつきエリアへの滞在の有無を01で保存

TrackPhero = Phero01Check(Tracking, LineData);

writematrix(TrackPhero, append(Filename, "_TrackPhero.csv"))


%% 4 においつきエリアへの滞在率を導出、グラフ化

StayRate(TrackPhero)


%% 5 軌跡データを回す

% 5.1 半径500のデータを回す

R_Tracking = RotDataL(Tracking, LineData); % においエリアが左に来るよう回す


% 5.2 回したものを表示、図として保存

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
exportgraphics(gca,append(Filename, "_PheroBoundary_rot.png")) %余白を狭くして保存
hold off

%SDNも参照して保存
if Info.SDN == "S"
    exportgraphics(gca,append("同巣\",Filename, "_PheroBoundary_rot.png"))
else
    exportgraphics(gca,append("異巣\",Filename, "_PheroBoundary_rot.png"))
end


% 5.3 回したプロットデータを保存

writematrix(R_Tracking, append(Filename, "-RotPosition.csv"))

end




%% 以下関数

function Info = readinfo(Filename)
    WholeInfo = readtable("FileInformation.csv");
Info = WholeInfo(find(WholeInfo.FileName==Filename),:);
end


function LineData = CorrLine(Filename, LineData)
    %楕円情報を読み取る
    EllipseData = readstruct(append(Filename, "_EllipseData.xml"));

    Datapoint = [1;LineData.incline]; %回転・拡大縮小前のデータ点（補正前の直線は[0,0]とこれを通る）
    %回転行列の作成
    RotateMat = MakeRotMat(-EllipseData.theta); % x軸にあわせるための回転行列
    CanRotateMat = MakeRotMat(EllipseData.theta); % もとの角度に戻すための回転行列

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
end

function TrackPhero =  Phero01Check(Tracking, LineData)
    if LineData.Ineq ==1
        TrackPhero = Tracking(:,2)>LineData.CorrIncline*Tracking(:,1);
    elseif LineData.Ineq==2
        TrackPhero = Tracking(:,2)<LineData.CorrIncline*Tracking(:,1);
    end
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

function R_Tracking = RotDataL(Tracking, LineData) % においエリアが左に来るように回す関数
    % 傾きからθを出す
    theta = atan(LineData.CorrIncline);
    % 方向性データから回す方向を決定する（ディスプレイ座標系注意！！）
    if LineData.Ineq==1 %線より下ににおい
        RotTheta = pi/2-theta;
    elseif LineData.Ineq==2 % 線より上ににおい
        RotTheta = 3*pi/2-theta;
    end
    % 回転行列を作る
    RotateMat =MakeRotMat(RotTheta);
    % 回す
    R_Tracking = zeros(size(Tracking,1), 2);
    for i = 1:size(Tracking, 1)
        R_Tracking(i,:) = RotateMat*Tracking(i,:)';
    end
end

function RotMat = MakeRotMat(theta)
    % ディスプレイ座標系だと時計回りに回るため注意
    RotMat = [cos(theta),-sin(theta);sin(theta),cos(theta)];
end