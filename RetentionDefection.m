% におい付きエリアへの侵入確立と離脱確率を計算するプログラム

%% 下準備
% FileInformationの読み取り
cd Data\
Info = readtable("FileInformation.csv");
cd ..\
%% 実行
N = 1:height(Info);
[p01, p10, n01, n00, n10, n11, SDN] = arrayfun(@CalcTransition, N');

Info.p01 = p01;
Info.p10 = p10;


%% グラフ化
% 全体
figure
histogram(p01)
title("p01")

figure
histogram(p10)
title("p10")

figure
plot(p01)
title("p01")

figure
plot(p10)
title("p10")



%% データの作成
% Info3を作るためのつなぎのテーブルInfo2
Info2 = table;
info2.Petri = (1:height(Info))';
Info2.FileName = Info.FileName;
Info2.SDN = Info.SDN;
Info2.SDNnum = Info.SDNnum;
Info2.ColonyPairnum = Info.ColonyPairnum;
Info2.Transition = strings(height(Info), 1);
Info2.Status = strings(height(Info), 1);
Info2.Framenum = zeros(height(Info), 1);
Info2.TransitionFnum = zeros(height(Info), 1);
Info2.p_Transition = zeros(height(Info), 1);

% 使わない段の削除
DeleteNum = n01+n00==0 | n10+n11==0;
Info(DeleteNum,:)=[];
Info2(DeleteNum,:)=[];
n01(DeleteNum)=[];
n00(DeleteNum)=[];
n10(DeleteNum)=[];
n11(DeleteNum)=[];
p01(DeleteNum)=[];
p10(DeleteNum)=[];


% Info3の作成
%  Info3に必要な属性：Petri, Filename,  SDN, SDNnum, ColonyPair, Transition, Status, Framenum, Transitionnum, P_Transition
Info3 = table;
for i = 1:height(Info2)
       Info3 =  [Info3; Info2(i,:); Info2(i,:)];
end

 % 各種属性の値を設定
 % 再設定が必要な属性：Transition, Status, Framenum, Transitionnum, P_Transition
for i = 1:height(Info2)
        Info3.Transition(2*i-1) = "01";
        Info3.Transition(2*i)   = "10";

        Info3.Framenum(2*i-1) = n01(i)+n00(i);
        Info3.Framenum(2*i)   = n10(i)+n11(i);

        Info3.TransitionFnum(2*i-1) = n01(i);
        Info3.TransitionFnum(2*i)   = n10(i);

        Info3.p_Transition(2*i-1) = p01(i);
        Info3.p_Transition(2*i)   = p10(i);
        
        if Info2.SDN(i)=="S"
            Info3.Statusnum(2*i-1) = 1;
            Info3.Statusnum(2*i)   = 2;
        elseif Info2.SDN(i)=="D"
            Info3.Statusnum(2*i-1) = 3;
            Info3.Statusnum(2*i)   = 4;
        elseif Info2.SDN(i)=="N"
            Info3.Statusnum(2*i-1) = 5;
            Info3.Statusnum(2*i)   = 6;
        end
end
Info3.Status = append(Info3.SDN, "\_p", Info3.Transition);



%% 箱ひげ図

% Info3.Statusをcategoricalに
StatusOrder = {'S\_p01', 'S\_p10', 'D\_p01', 'D\_p10','N\_p01', 'N\_p10'};
Info3.Status = categorical(Info3.Status, StatusOrder);

% データを対数に（箱ひげ図を描いてから対数化するとエラーが出るため）
Info3.LOGp_Transition = log10(Info3.p_Transition);

% 箱ひげ図
figure
boxchart(Info3.Status, Info3.LOGp_Transition,'BoxFaceColor','black', 'MarkerStyle','none')
hold on


% シャーレごとの平均をつなぐ
for i = 1:height(Info3)/2
        if Info3.SDN{2*i}=='S'
            plot([1,2],[Info3.LOGp_Transition(2*i-1), Info3.LOGp_Transition(2*i)], '-', 'MarkerSize', 5, 'Color',[0.8,0.8,0.8])
        elseif Info3.SDN{2*i}=='D'
            plot([3,4],[Info3.LOGp_Transition(2*i-1), Info3.LOGp_Transition(2*i)], '-', 'MarkerSize', 5, 'Color',[0.8,0.8,0.8])
        elseif Info3.SDN{2*i}=='N'
            plot([5,6],[Info3.LOGp_Transition(2*i-1), Info3.LOGp_Transition(2*i)], '-', 'MarkerSize', 5, 'Color',[0.8,0.8,0.8])

        end
end

% バブルチャートの作成
bubblechart(Info3, "Status", "LOGp_Transition", "Framenum",'MarkerFaceAlpha',0.10)
bubblesize([2 20])

% 平均値を+で表示
plot([1;2;3;4;5;6], [log10(mean(Info3.p_Transition(Info3.Status=="S\_p01")));...
                     log10(mean(Info3.p_Transition(Info3.Status=="S\_p10")));...
                     log10(mean(Info3.p_Transition(Info3.Status=="D\_p01")));...
                     log10(mean(Info3.p_Transition(Info3.Status=="D\_p10")));...
                     log10(mean(Info3.p_Transition(Info3.Status=="N\_p01")));...
                     log10(mean(Info3.p_Transition(Info3.Status=="N\_p10")))], 'k+')

% 軸の調整
xlabel("")
ylabel("移行確率")

yticks([-4 -3 -2 -1])
yticklabels({'10^{-4}' '10^{-3}' '10^{-2}' '10^{-1}'})

title("個体がにおい境界をまたぐ確率")

hold off

%% バブルプロットの作成
figure
hold on

% 中央値の表示
med = zeros(6,1);
for i = 1:6
    med(i) = [median(Info3.p_Transition(Info3.Statusnum==i))];
    plot([i-0.4;i+0.4],[med(i);med(i)], 'k', 'LineWidth',2)
end

% シャーレごとの平均をつなぐ
for i = 1:height(Info3)/2
        if Info3.SDN{2*i}=='S'
            plot([1,2],[Info3.p_Transition(2*i-1), Info3.p_Transition(2*i)], '-', 'MarkerSize', 5, 'Color',[0.8,0.8,0.8])
        elseif Info3.SDN{2*i}=='D'
            plot([3,4],[Info3.p_Transition(2*i-1), Info3.p_Transition(2*i)], '-', 'MarkerSize', 5, 'Color',[0.8,0.8,0.8])
        elseif Info3.SDN{2*i}=='N'
            plot([5,6],[Info3.p_Transition(2*i-1), Info3.p_Transition(2*i)], '-', 'MarkerSize', 5, 'Color',[0.8,0.8,0.8])

        end
end

% バブルプロット
bc = bubblechart(Info3, "Statusnum", "p_Transition", "Framenum",'MarkerFaceAlpha',0.10);
bc.MarkerFaceColor = [0.3 0.3 0.3];
bc.MarkerEdgeColor = [0.3 0.3 0.3];
Axes = gca;
Axes.YScale = "log";
bubblesize([2 30])




% 軸の設定
xlim([0,7])
xlabel("")
xticks([1 2 3 4 5 6])
xticklabels(StatusOrder)

ylabel("移行確率")

title("個体がにおい境界をまたぐ確率")
hold off

%% GLMM

% データの作成
InfoGLMM = Info;
InfoGLMM.n01 = n01;
InfoGLMM.n0 = n01+n00;
InfoGLMM.p01 = p01;
InfoGLMM.n10 = n10;
InfoGLMM.n1 = n10+n11;
InfoGLMM.p10 = p10;

% SN(01)
InfoSN = InfoGLMM(InfoGLMM.SDNnum ~=1,:);
InfoSN.SDNnum = InfoSN.SDNnum./2;
glmeSN01_1 = fitglme(InfoSN,'n01 ~ 1 + SDNnum + (1|ColonyPairnum)','Distribution', 'Binomial','BinomialSize',InfoSN.n0, 'FitMethod', 'ApproximateLaplace');
glmeSN01_2 = fitglme(InfoSN,'n01 ~ 1 +          (1|ColonyPairnum)','Distribution', 'Binomial','BinomialSize',InfoSN.n0, 'FitMethod', 'ApproximateLaplace');
resultSN01 = compare(glmeSN01_2, glmeSN01_1)

% SN(10)
glmeSN10_1 = fitglme(InfoSN,'n10 ~ 1 + SDNnum + (1|ColonyPairnum)','Distribution', 'Binomial','BinomialSize',InfoSN.n1, 'FitMethod', 'ApproximateLaplace');
glmeSN10_2 = fitglme(InfoSN,'n10 ~ 1 +          (1|ColonyPairnum)','Distribution', 'Binomial','BinomialSize',InfoSN.n1, 'FitMethod', 'ApproximateLaplace');
resultSN10 = compare(glmeSN10_2, glmeSN10_1)

% DN(01)
InfoDN = InfoGLMM(InfoGLMM.SDNnum ~=2,:);
glmeDN01_1 = fitglme(InfoDN,'n01 ~ 1 + SDNnum + (1|ColonyPairnum)','Distribution', 'Binomial','BinomialSize',InfoDN.n0, 'FitMethod', 'ApproximateLaplace');
glmeDN01_2 = fitglme(InfoDN,'n01 ~ 1 +          (1|ColonyPairnum)','Distribution', 'Binomial','BinomialSize',InfoDN.n0, 'FitMethod', 'ApproximateLaplace');
resultDN01 = compare(glmeDN01_2, glmeDN01_1)

% DN(10)
glmeDN10_1 = fitglme(InfoDN,'n10 ~ 1 + SDNnum + (1|ColonyPairnum)','Distribution', 'Binomial','BinomialSize',InfoDN.n1, 'FitMethod', 'ApproximateLaplace');
glmeDN10_2 = fitglme(InfoDN,'n10 ~ 1 +          (1|ColonyPairnum)','Distribution', 'Binomial','BinomialSize',InfoDN.n1, 'FitMethod', 'ApproximateLaplace');
resultDN10 = compare(glmeDN10_2, glmeDN10_1)

%SD(01)
InfoSD = InfoGLMM(InfoGLMM.SDNnum ~=0,:);
InfoSN.SDNnum = InfoSN.SDNnum-1;
glmeSD01_1 = fitglme(InfoSD,'n01 ~ 1 + SDNnum + (1|ColonyPairnum)','Distribution', 'Binomial','BinomialSize',InfoSD.n0, 'FitMethod', 'ApproximateLaplace');
glmeSD01_2 = fitglme(InfoSD,'n01 ~ 1 +          (1|ColonyPairnum)','Distribution', 'Binomial','BinomialSize',InfoSD.n0, 'FitMethod', 'ApproximateLaplace');
resultSD01 = compare(glmeSD01_2, glmeSD01_1)

%SD(10)
glmeSD10_1 = fitglme(InfoSD,'n10 ~ 1 + SDNnum + (1|ColonyPairnum)','Distribution', 'Binomial','BinomialSize',InfoSD.n1, 'FitMethod', 'ApproximateLaplace');
glmeSD10_2 = fitglme(InfoSD,'n10 ~ 1 +          (1|ColonyPairnum)','Distribution', 'Binomial','BinomialSize',InfoSD.n1, 'FitMethod', 'ApproximateLaplace');
resultSD10 = compare(glmeSD10_2, glmeSD10_1)

cd Data\
writetable(InfoGLMM,"InfoForRD.csv")
cd ../

%% 以下関数

function [p01, p10, n01, n00, n10, n11, SDN] = CalcTransition(i)
    cd Data\
    Info = readtable("FileInformation.csv");
    SDN = Info.SDNnum(i);
    Data = readmatrix(append(Info.FileName(i), "-JumpCorrPosition.csv"));
    Transition = zeros(height(Data)-1,1);
    for j = 1:height(Data)-1
        if     Data(j,1) > 0 && Data(j+1,1) < 0 % 01
                Transition(j) = 1;
        elseif Data(j,1) > 0 && Data(j+1,1) > 0 % 00
                Transition(j) = 2;
        elseif Data(j,1) < 0 && Data(j+1,1) > 0 % 10
                Transition(j) = 3;
        elseif Data(j,1) < 0 && Data(j+1,1) < 0 % 11
                Transition(j) = 4;
        end
    end
    n01 = sum(Transition==1);
    n00 = sum(Transition==2);
    n10 = sum(Transition==3);
    n11 = sum(Transition==4);
    p01 = n01./(n01+n00);
    p10 = n10./(n10+n11);
    cd ..\
end