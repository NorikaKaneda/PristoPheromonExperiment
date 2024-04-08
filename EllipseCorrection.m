% 撮影ファイル名の入力を受け、楕円の情報を取得しトラッキングデータの補正をする関数

% 前提：Trajectory.fig, position.csvがDataフォルダ中に存在する
% 作成するファイル：EllCirfer.csv, PhotoEllipse.png, EllipseData.xml,
% CorrPosition.csv,TrackingLine.fig, TrackingLine.png


% フォルダからTrajectory.pngの画像を拾ってきて画面に表示
% Trajectory画像を画面に表示、作業者は周上の点を15個クリックする
% クリックされた点の座標をcsvファイルに保存
% クリックされた点の座標から楕円の式のパラメーターを推定。短軸・長軸等のパラメーターとともにxmlに保存
% この情報を使い、トラッキング座標データを楕円と同様に標準化
% 円と7の補正した座標をプロットし、画像として保存

function EllipseCorrection(Filename)

%【重要】既に座標ファイルが存在し座標取得部分を省略する場合はskip=1とすること
skip=1;

%% 1 フォルダからTrajectory.pngの画像を拾ってきて画面に表示

%フォルダ中に既にファイルが存在する場合は省略するか選べるダイアログを表示
answer2 = "No";
while answer2 ~= "Yes" %フィッティングに納得いかない場合はここに戻ってこれる
    
%ファイル名の作成
Traj = append(Filename, "_Trajectory.fig");

% 画面に表示
openfig(Traj)
title("周の決定")
TrajAxes=gca;


%% 2 作業者は周上の点を15個クリックする

%ファイル名の作成
EllCirfer = append(Filename, "_EllCirfer.csv");

if exist(EllCirfer) % 既にクリック座標データファイルがある場合
    if skip==0 % スキップしない場合
        quest1 = append("フォルダ中に既に作成された",EllCirfer, "が見つかりました。このデータを利用しますか？");
        answer1 = questdlg(quest1);
        if answer1=="Yes" % 既にある座標データを利用する場合
            Ellipse_Circumference = readmatrix(EllCirfer);
        else % 座標データの取得をやり直す場合
            Ellipse_Circumference = ginput(15);
            % 注：明瞭な箇所を選んでクリックすること
            writematrix(Ellipse_Circumference, EllCirfer);
        end
    else % スキップする場合
        Ellipse_Circumference = readmatrix(EllCirfer);
    end
else %クリック座標データファイルが存在しない場合
    Ellipse_Circumference = ginput(15);
    % 注：明瞭な箇所を選んでクリックすること
    writematrix(Ellipse_Circumference, EllCirfer);
end



%% 3 クリックされた点の座標から楕円の式のパラメーターを推定

% 別ファイルの関数を使用して楕円の式のパラメータを計算。ellipse_params = [焦点1のx座標, 焦点1のy座標, 焦点2のx座標, 焦点2のy座標, R(長軸の長さの半分)]
ellipse_params = EstimationEllParam(Ellipse_Circumference);
%重ねて表示
hold(TrajAxes, "on")
fimplicit(@(x,y) sqrt((ellipse_params(1) - x).^2 + (ellipse_params(2) - y).^2) + sqrt((ellipse_params(3) - x).^2 + (ellipse_params(4) - y).^2)-2*ellipse_params(5), "LineWidth",3)


%% 4 楕円の情報を求める

EllipseData = struct;
%焦点の座標は
EllipseData.F1 = [ellipse_params(1), ellipse_params(2)];
EllipseData.F2 = [ellipse_params(3), ellipse_params(4)];
%Rは
EllipseData.R = ellipse_params(5)
%中心座標は
EllipseData.center = (EllipseData.F1+EllipseData.F2)./2
%軸の傾きは
EllipseData.theta = angle(EllipseData.F2(1)-EllipseData.F1(1)+EllipseData.F2(2)*1i-EllipseData.F1(2)*1i) %ラジアン
%長軸の長さ(半分)は
EllipseData.L_axis = ellipse_params(5)
%短軸の長さ(半分)は
EllipseData.S_axis = sqrt(ellipse_params(5).^2-norm(EllipseData.F1-EllipseData.center).^2)

% 楕円情報(中心、焦点、楕円の周)を先ほどの画像に重ねて表示
plot(EllipseData.center(1), EllipseData.center(2), 'ko', 'MarkerFaceColor','green', MarkerSize=10)
plot(EllipseData.F1(1), EllipseData.F1(2), 'ko','MarkerFaceColor','blue', MarkerSize=10)
plot(EllipseData.F2(1), EllipseData.F2(2), 'ko', 'MarkerFaceColor','blue', MarkerSize=10)
hold(TrajAxes, "off")
% 重ねた画像を保存
saveas(gcf, append(Filename, "_PhotoEllipseData.png"))

%楕円近似が正確にできているかの確認（クリックがぶれてしまった場合にやり直せるように）
if skip ==0
    quest2 = append("このフィッティング結果でよろしいですか？");
    answer2 = questdlg(quest2);
    if answer2 ~= "Yes"
        close
    end
else
    answer2 ="Yes";
end
end % フィッティング結果が納得いかないのであれば3の最初に戻る

%% 5 楕円の情報をtable形式で保存

writestruct(EllipseData,append(Filename, "_EllipseData.xml"))

%% 6 トラッキングデータを補正し、原点が中心に来るように移動させる

% トラッキングデータを読み込む
data = readmatrix(append(Filename, "-position.csv"));
Tracking = data(:,[2,3]);

%トラッキングデータの表示
%{
figure(3)
plot(Tracking(:,1),Tracking(:,2),'r-','LineWidth',1);
title("元データ")
xlim([0,1400])
ylim([0,750])
hold on
fimplicit(@(x,y) sqrt((ellipse_params(1) - x).^2 + (ellipse_params(2) - y).^2) + sqrt((ellipse_params(3) - x).^2 + (ellipse_params(4) - y).^2)-2*ellipse_params(5))
axis ij
plot(EllipseData.center(1),EllipseData.center(2) , 'o')
daspect([1 1 1])
hold off
%}

% トラッキングデータを原点中心になるように平行移動
O_Tracking = Tracking - EllipseData.center;

%平行移動後の様子を表示
%{
figure(4)
plot(O_Tracking(:,1),O_Tracking(:,2),'r-','LineWidth',1);
title("平行移動後")
xlim([-600,600])
ylim([-600,600])
hold on
fimplicit(@(x,y) x.^2+y.^2-EllipseData.L_axis.^2)
axis ij
plot(0, 0, 'o')
daspect([1 1 1])
hold off
%}

% 長軸がx軸上に来るようにトラッキングデータを回転させる
RotateMat = [cos(-EllipseData.theta),-sin(-EllipseData.theta);
    sin(-EllipseData.theta),cos(-EllipseData.theta)] % 回転行列
O_R_Tracking = zeros(size(O_Tracking,1),2);
for i = 1:size(O_Tracking,1)
    O_R_Tracking(i,:) = RotateMat * O_Tracking(i,:)';
end

%回転後の様子を表示
%{
figure(5)
plot(O_R_Tracking(:,1),O_R_Tracking(:,2),'r-','LineWidth',1);
title("長軸をx軸に合わせた")
xlim([-600,600])
ylim([-600,600])
hold on
fimplicit(@(x,y) x.^2+y.^2-250000)
axis ij
plot(0, 0, 'o')
daspect([1 1 1])
hold off
%}

% 半径500になるように縦横に補正
LSMat = [500/EllipseData.L_axis,0;
    0,500/EllipseData.S_axis]%拡大・縮小行列 
O_R_C_Tracking = zeros(size(O_R_Tracking,1),2);
for i = 1:size(O_R_Tracking,1)
    O_R_C_Tracking(i,:) = LSMat * O_R_Tracking(i,:)';
end

%縦横補正後の様子を表示
%{
figure(6)
plot(O_R_C_Tracking(:,1),O_R_C_Tracking(:,2),'r-','LineWidth',1);
title("縦横を補正")
xlim([-600,600])
ylim([-600,600])
hold on
fimplicit(@(x,y) x.^2+y.^2-250000)
axis ij
plot(0, 0, 'o')
daspect([1 1 1])
hold off
%}

% 回転させてもとの角度に戻す
CanRotateMat = [cos(EllipseData.theta),-sin(EllipseData.theta);sin(EllipseData.theta),cos(EllipseData.theta)] % 回転行列
OK_Tracking = zeros(size(O_R_C_Tracking,1),2);
for i = 1:size(O_R_C_Tracking,1)
    OK_Tracking(i,:) = CanRotateMat * O_R_C_Tracking(i,:)';
end

%元の角度に戻した様子を表示
%{
figure(7)
plot(OK_Tracking(:,1),OK_Tracking(:,2),'r-','LineWidth',1);
title("元の角度に戻す")
xlim([-600,600])
ylim([-600,600])
hold on
fimplicit(@(x,y) x.^2+y.^2-250000)
axis ij
plot(0, 0, 'o')
daspect([1 1 1])
hold off
%}

% 座標データをcsvに保存
writematrix(OK_Tracking, append(Filename, "-CorrPosition.csv"))

%% 7 円と6の補正した座標をプロットし、画像として保存

%半径500の円とあわせてプロット
figure
plot(OK_Tracking(:,1),OK_Tracking(:,2),'k-','LineWidth',1);
title(append(Filename, "のトラッキング記録"),'interpreter','none')
xlim([-600,600])
ylim([-600,600])
hold on
fimplicit(@(x,y) x.^2+y.^2-250000,'k', 'LineWidth', 2)
axis ij
daspect([1 1 1])
hold off

%画像を保存
saveas(gcf, append(Filename,"_TrackingLine.png"))
saveas(gcf, append(Filename,"_TrackingLine.fig"))

disp(append(Filename, ": 終了"))


end