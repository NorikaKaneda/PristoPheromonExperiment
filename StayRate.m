% 滞在率に関する処理をするプログラム

%% 前処理

% 滞在率の数値を計算する
cd Data\
Info = readtable("FileInformation.csv");
[Framenum_array, Snum_array,SR_array] = arrayfun(@CalcStayRate, Info.FileName);

% GLMM用にSDN情報とコロニーペア情報を数値に変換
% SDN情報をcategoricalに（グラフ用）
SDN_NameOrder = {'S', 'D', 'N'};
Info.SDN = categorical(Info.SDN, SDN_NameOrder);

% SDN情報を数値に置き換え
Info.SDNnum(Info.SDN=='S')=2;
Info.SDNnum(Info.SDN=='D')=1;
Info.SDNnum(Info.SDN=='N')=0;

% コロニーペア情報を数値に変換
ColonyPairs = strings(height(Info),1);
for i = 1:height(Info)
    ColonyPairs(i) = append(Info.Pheromone{i}, Info.Walker{i});
end
ColonyPairList = unique(ColonyPairs);
ColonyPairnum = zeros(height(Info),1);
for i = 1:height(Info)
    ColonyPairnum(i) = find(ColonyPairList == ColonyPairs(i));
end


% FileInformationへの書き込み
Info.ColonyPairnum = ColonyPairnum;
Info.Framenum = Framenum_array;
Info.Staynum = Snum_array;
Info.StayRate = SR_array;
writetable(Info, "FileInformation.csv")

% 滞在率が1か0のものは除く
Info((Info.StayRate==1 | Info.StayRate==0), :)=[];

%% テーブルを使った箱ひげ図
figure
boxchart(Info.SDN, Info.StayRate,  'BoxFaceColor','black', 'MarkerStyle','none')
hold on
x = categorical(Info.SDN, SDN_NameOrder);
y = Info.StayRate;
swarmchart(x,y ,20, 'k')
plot([1;2;3], [mean(Info.StayRate(Info.SDN=='S')), mean(Info.StayRate(Info.SDN=='D')), mean(Info.StayRate(Info.SDN=='N'))], 'k+')
yline(0.5, '--r');
ylabel("エリア滞在率")
title("各条件でのにおい付きエリア滞在率")
xticklabels(categorical({'同巣', '異巣', 'においなし'}))
hold off

%% GLMM（SvsD）

% InfoSDの作成
InfoSD =Info(Info.SDNnum~=0,:); % Nのデータを削除
InfoSD.SDNnum = InfoSD.SDNnum-1; % InfoSD.SDNnumがSで1, Dで0になるようにする
glmeSD0 = fitglme(InfoSD, 'Staynum ~  1 +          (1|ColonyPairnum) ', 'Distribution', 'Binomial','BinomialSize',InfoSD.Framenum, 'FitMethod', 'ApproximateLaplace');
glmeSD1 = fitglme(InfoSD, 'Staynum ~  1 + SDNnum + (1|ColonyPairnum) ', 'Distribution', 'Binomial','BinomialSize',InfoSD.Framenum, 'FitMethod', 'ApproximateLaplace');
resultsSD = compare(glmeSD0, glmeSD1);

% 等分散検定
h = vartest2(InfoSD.StayRate(InfoSD.SDNnum==1),InfoSD.StayRate(InfoSD.SDNnum==0));

%% GLMM（SvsN, DvsN）

% SN
InfoSN = Info(Info.SDNnum~=1,:); % Dのデータを削除
InfoSN.SDNnum = InfoSN.SDNnum./2;
glmeSN0 = fitglme(InfoSN, 'Staynum ~  -1 +          (1|ColonyPairnum) ', 'Distribution', 'Binomial','BinomialSize',InfoSN.Framenum, 'FitMethod', 'ApproximateLaplace');
glmeSN1 = fitglme(InfoSN, 'Staynum ~  -1 + SDNnum + (1|ColonyPairnum) ', 'Distribution', 'Binomial','BinomialSize',InfoSN.Framenum, 'FitMethod', 'ApproximateLaplace');
resultsSN = compare(glmeSN0, glmeSN1);

% DN
InfoDN = Info(Info.SDNnum~=2,:);
glmeDN0 = fitglme(InfoDN, 'Staynum ~  -1 +          (1|ColonyPairnum) ', 'Distribution', 'Binomial','BinomialSize',InfoDN.Framenum, 'FitMethod', 'ApproximateLaplace');
glmeDN1 = fitglme(InfoDN, 'Staynum ~  -1 + SDNnum + (1|ColonyPairnum) ', 'Distribution', 'Binomial','BinomialSize',InfoDN.Framenum, 'FitMethod', 'ApproximateLaplace');
resultsDN = compare(glmeDN0, glmeDN1);

% データの保存
writetable(Info, "InfoForStayRate.csv");



cd ..\


%% 以下関数

function [Framenum, Snum,SR] = CalcStayRate(Filename)
% Snum: エリア内にいるフレーム数、SR: エリア滞在率
    Filename = string(Filename);

    % _CalcDataの読み込み
    Data = readtable(append(Filename, "_CalcData.csv"));
    Phero01 = Data.Phero01;

    % 滞在率の計算
    Framenum = height(Phero01);
    Snum = sum(Phero01);
    SR = Snum ./ Framenum;
end