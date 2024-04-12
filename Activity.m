% 時間当たりの活動性についての計算を行うプログラム

%% 下準備
% FileInformationの読み取り
cd Data\
Info = readtable("FileInformation.csv");
% 全体フレーム数と活動コマ数の計算
[In_Phero_array, In_NonPhero_array, In_Phero_Go_array, In_NonPhero_Go_array] = arrayfun(@CalcActivity, Info.FileName);
Info.InPhero = In_Phero_array;
Info.InNonPhero = In_NonPhero_array;
Info.InPheroGo = In_Phero_Go_array;
Info.InNonPheroGo = In_NonPhero_Go_array;

% 使わない段の削除
Info(Info.SDN=="N",:) = [];% においなしのもの
Info(Info.StayRate == 1 | Info.StayRate == 0, :) = [];% StayRateが1あるいは0のもの
%Info(Info.InPheroGo == Info.InPhero | Info.InNonPheroGo == Info.InNonPhero, :) = [];% すべてGoのもの
%Info(Info.InPheroGo == 0 | Info.InNonPheroGo == 0, :) = [];% すべてStopのもの

% グラフ・GLMM用テーブルの作成
Info2 = table; % Info3を作るためのつなぎのテーブル
Info2.Petri = Info.SampleNumber;
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

    Info3.Framenum(2*i-1) = Info.InPhero(i);
    Info3.Framenum(2*i)   = Info.InNonPhero(i);

    Info3.Gonum(2*i-1) = Info.InPheroGo(i);
    Info3.Gonum(2*i)   = Info.InNonPheroGo(i);
end
Info3.status = append(Info3.SDN, string(Info3.Phero01));
Info3.GoRate = Info3.Gonum ./ Info3.Framenum;


%% グラフ化

% Info3.statusをcategoricalに
statusOrder = {'S1', 'S0', 'D1', 'D0'};
Info3.status = categorical(Info3.status, statusOrder);

figure
%箱ひげ図
boxchart(Info3.status, Info3.GoRate,  'BoxFaceColor','black', 'MarkerStyle','none')

hold on

% シャーレごとの平均をつなぐ
for i = 1:height(Info3)/2
    if Info3.SDN{2*i}=='S'
        plot([1,2],[Info3.GoRate(2*i-1), Info3.GoRate(2*i)], '-o', 'MarkerSize', 5, 'Color',[0.6, 0.6, 0.6])
    elseif Info3.SDN{2*i}=='D'
        plot([3,4],[Info3.GoRate(2*i-1), Info3.GoRate(2*i)], '-o', 'MarkerSize', 5, 'Color',[0.6, 0.6, 0.6])
    end
end

% 平均値を+で表示
plot([1;2;3;4], [mean(Info3.GoRate(Info3.status=="S1")), mean(Info3.GoRate(Info3.status=="S0")), mean(Info3.GoRate(Info3.status=="D1")), mean(Info3.GoRate(Info3.status=="D0"))], 'k+')

% 各種情報
ylabel("歩行時間/滞在時間")
title("滞在時間に占める歩行時間の割合")
xticklabels(categorical({'同巣においあり', '同巣においなし', '異巣においあり', '異巣においなし'}))
hold off



%% GLMM

% GLMM(Phero1vsPhero0)
glme1 = fitglme(Info3, 'Gonum ~ 1 + Phero01 + SDNnum + (1|Petri) + (1|ColonyPair)','Distribution', 'Binomial','BinomialSize',Info3.Framenum, 'FitMethod', 'ApproximateLaplace');
glme2 = fitglme(Info3, 'Gonum ~ 1           + SDNnum + (1|Petri) + (1|ColonyPair)','Distribution', 'Binomial','BinomialSize',Info3.Framenum, 'FitMethod', 'ApproximateLaplace');
glme3 = fitglme(Info3, 'Gonum ~ 1 + Phero01          + (1|Petri) + (1|ColonyPair)','Distribution', 'Binomial','BinomialSize',Info3.Framenum, 'FitMethod', 'ApproximateLaplace');
%glme4 = fitglme(GLMM_Speed_inner_Nonzero, 'GoNum ~ 1 + Area + SorD + (1|petri) + (1|ColonyPair) + (1 | Area:SorD)','Distribution', 'Binomial','BinomialSize',GLMM_Speed_inner_Nonzero.N, 'FitMethod', 'ApproximateLaplace')
resultPhero = compare(glme2,glme1);
resultSDN = compare(glme3,glme1);

cd ..\


%% 以下関数


function [InPhero, InNonPhero, InPheroGo, InNonPheroGo] = CalcActivity(Filename)
    Filename = string(Filename);

    % _CalcDataの読み込み
    Data = readtable(append(Filename, "_CalcData.csv"));
    % Inのデータのみ取り出し
    Data = Data(Data.InOut==1,:);

    % 各値の計算
    InPhero = height(Data(Data.Phero01==1,:));
    InNonPhero = height(Data(Data.Phero01==0,:));
    InPheroGo = height(Data((Data.Phero01==1 & Data.GoStop ==1),:));
    InNonPheroGo = height(Data((Data.Phero01==0 & Data.GoStop==1),:));

end
