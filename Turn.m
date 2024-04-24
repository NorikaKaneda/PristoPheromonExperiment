% 時間当たりの方向転換頻度についての計算を行うプログラム

%% 前処理
% FileInformationの読み取り
cd Data\
Info = readtable("FileInformation.csv");
% 方向転換コマ数の計算
[InPheroGoTurn_array, InNonPheroGoTurn_array] = arrayfun(@CalcTurn, Info.FileName);
Info.InPheroGoTurn = InPheroGoTurn_array;
Info.InNonPheroGoTurn = InNonPheroGoTurn_array;
writetable(Info, "FileInformation.csv");
% 使わない段の削除
Info(Info.SDN=="N",:) = [];
Info(Info.StayRate == 1 | Info.StayRate == 0, :) = [];
Info(Info.InPheroGo==0 | Info.InNonPheroGo==0,:) = [];
% グラフ・GLMM用テーブルの作成
Info2 = table; % Info3を作るためのつなぎのテーブル
Info2.Petri = (1:height(Info))';
Info2.FileName = Info.FileName;
Info2.SDN = Info.SDN;
Info2.SDNnum = Info.SDNnum;
Info2.ColonyPair = Info.ColonyPairnum;
Info2.StayRate = Info.StayRate;

Info3 = table;
for i = 1:height(Info2) % まずはにおいありとにおいなしで2段ずつ作る
    Info3 = [Info3;Info2(i,:);Info2(i,:)];
end
for i = 1:height(Info2) % 各種属性の追加
    Info3.Phero01(2*i-1) = 1;
    Info3.Phero01(2*i)   = 0;

    Info3.Framenum(2*i-1) = Info.InPheroGo(i);
    Info3.Framenum(2*i)   = Info.InNonPheroGo(i);

    Info3.Turnnum(2*i-1) = Info.InPheroGoTurn(i);
    Info3.Turnnum(2*i)   = Info.InNonPheroGoTurn(i);
end
Info3.status = append(Info3.SDN, string(Info3.Phero01));
Info3.TurnRate = Info3.Turnnum ./ Info3.Framenum;

%% グラフ化
% Info3.statusをcategoricalに
statusOrder = {'S1', 'S0', 'D1', 'D0'};
Info3.status = categorical(Info3.status, statusOrder);

figure
%箱ひげ図
boxchart(Info3.status, Info3.TurnRate,  'BoxFaceColor','black', 'MarkerStyle','none')

hold on

% シャーレごとの平均をつなぐ
for i = 1:height(Info3)/2
    if Info3.SDN{2*i}=='S'
        plot([1,2],[Info3.TurnRate(2*i-1), Info3.TurnRate(2*i)], '-', 'MarkerSize', 5, 'Color',[0.6,0.6,0.6])
    elseif Info3.SDN{2*i}=='D'
        plot([3,4],[Info3.TurnRate(2*i-1), Info3.TurnRate(2*i)], '-', 'MarkerSize', 5, 'Color',[0.6,0.6,0.6])
    end
end
% バブルチャートの作成
bubblechart(Info3, "status", "TurnRate", "Framenum",'MarkerFaceAlpha',0.10)

% 平均値を+で表示
plot([1;2;3;4], [mean(Info3.TurnRate(Info3.status=="S1")), mean(Info3.TurnRate(Info3.status=="S0")), mean(Info3.TurnRate(Info3.status=="D1")), mean(Info3.TurnRate(Info3.status=="D0"))], 'k+')

% 各種情報
ylabel("転向頻度")
title("歩行エリアと転向頻度の関係")
xticklabels(categorical({'同巣においあり', '同巣においなし', '異巣においあり', '異巣においなし'}))
hold off

%% バブルプロット

% データの準備
for i = 1:height(Info3)
    if Info3.status(i)=='S1'
        Info3.statusnum(i) = 1;
    elseif Info3.status(i)=="S0"
        Info3.statusnum(i) = 2;
    elseif Info3.status(i)=="D1"
        Info3.statusnum(i) = 3;
    elseif Info3.status(i)=="D0"
        Info3.statusnum(i) = 4;
    end
end

figure
hold on

% 中央値の表示
med = zeros(4,1);
for i = 1:4
    med(i) = median(Info3.TurnRate(Info3.statusnum==i));
    plot([i-0.4;i+0.4],[med(i);med(i)], 'k', 'LineWidth',2)
end

% シャーレごとの平均をつなぐ
for i = 1:height(Info3)/2
    if Info3.SDN{2*i}=='S'
        plot([1,2],[Info3.TurnRate(2*i-1), Info3.TurnRate(2*i)], '-', 'MarkerSize', 5, 'Color',[0.8, 0.8, 0.8])
    elseif Info3.SDN{2*i}=='D'
        plot([3,4],[Info3.TurnRate(2*i-1), Info3.TurnRate(2*i)], '-', 'MarkerSize', 5, 'Color',[0.8, 0.8, 0.8])
    end
end
% バブルプロット
bc = bubblechart(Info3, "statusnum", "TurnRate", "Framenum",'MarkerFaceAlpha',0.10);
bc.MarkerFaceColor = [0.3 0.3 0.3];
bc.MarkerEdgeColor = [0.3 0.3 0.3];
bubblesize([2 30])

% 軸の設定
xlim([0,5])
xlabel("")
xticks([1 2 3 4])
xticklabels(categorical({'同巣においあり', '同巣においなし', '異巣においあり', '異巣においなし'}))
ylabel("転向頻度")
title("歩行エリアと転向頻度の関係")

hold off

%% GLMM

% GLMM(Phero1vsPhero0)
glme1 = fitglme(Info3, 'Turnnum ~ 1 + Phero01 + SDNnum + (1|Petri) + (1|ColonyPair)','Distribution', 'Binomial','BinomialSize',Info3.Framenum, 'FitMethod', 'ApproximateLaplace');
glme2 = fitglme(Info3, 'Turnnum ~ 1           + SDNnum + (1|Petri) + (1|ColonyPair)','Distribution', 'Binomial','BinomialSize',Info3.Framenum, 'FitMethod', 'ApproximateLaplace');
glme3 = fitglme(Info3, 'Turnnum ~ 1 + Phero01          + (1|Petri) + (1|ColonyPair)','Distribution', 'Binomial','BinomialSize',Info3.Framenum, 'FitMethod', 'ApproximateLaplace');
%glme4 = fitglme(GLMM_Speed_inner_Nonzero, 'GoNum ~ 1 + Area + SorD + (1|petri) + (1|ColonyPair) + (1 | Area:SorD)','Distribution', 'Binomial','BinomialSize',GLMM_Speed_inner_Nonzero.N, 'FitMethod', 'ApproximateLaplace')
resultPhero = compare(glme2,glme1);
resultSDN = compare(glme3,glme1);

% データの保存
writetable(Info3, "InfoForTurn.csv")



cd ..\
%% 以下関数

function [InPheroGoTurn, InNonPheroGoTurn] = CalcTurn(Filename)
    Filename = string(Filename);

    % _CalcDataの読み込み
    Data = readtable(append(Filename, "_CalcData.csv"));
    % _anglesの読み込み
    TurnData = readtable(append(Filename, "_angles.csv"));
    % InGoのデータのみ取り出し
    TurnData = TurnData((Data.InOut==1 & Data.GoStop==1),:);
    Data = Data((Data.InOut==1 & Data.GoStop==1),:);
    % 各値の計算
    InPheroGoTurn = height(TurnData(Data.Phero01==1 & TurnData.Turn==1,:));
    InNonPheroGoTurn = height(TurnData(Data.Phero01==0 & TurnData.Turn==1,:));
end