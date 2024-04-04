%各撮影のデータファイルを結合する

MovieNames = ["20240114_1", "20240116_1", "20240118_1", "20240120_1", "20240209_1", "20240215_1", "20240217_1", "20240222_1", "20240228_1", "20240228_2", "20240228_3", "20240229_1", "20240229_2"];
dir0 = pwd;
cd(fullfile(dir0,"/Data"))
%% 撮影番号ごとにリストを読み取り、PlotTrajectoryを回す

% WholeInfoテーブルの作成
WholeInfo = table;
% 各Infoファイルを回りWholeInfoに情報を付加
for i = 1:length(MovieNames)
    newInfo = readtable(fullfile(dir0, "Data", append(MovieNames(i),"-info.csv")), 'VariableNamingRule', 'preserve');
        newInfo(newInfo.Error==1,:)=[]; % 使えないファイルの除去
        newInfo(:,[5,6])=[]; % エラー列と詳細列の除去
        newInfo.Pheromone = arrayfun(@string, newInfo.Pheromone);
        newInfo.Walker = arrayfun(@string, newInfo.Walker);
        newInfo.PheroPlace = arrayfun(@string, newInfo.PheroPlace);
    SampleName = append(MovieNames(i), "_", string(newInfo.SampleNumber));
    newInfo.FileName = append(MovieNames(i), "_", string(newInfo.SampleNumber));
    newInfo.SDN = arrayfun(@SDN_Check, newInfo.Pheromone, newInfo.Walker);
    WholeInfo =  vertcat(WholeInfo, newInfo);
end

writetable(WholeInfo, "FileInformation.csv")
cd ..\

function SDN = SDN_Check(Pheromone, Walker)
    if ismissing(Pheromone)
        SDN = "N";
    elseif Pheromone == Walker
        SDN = "S";
    elseif Pheromone ~= Walker
        SDN = "D";
    end
end