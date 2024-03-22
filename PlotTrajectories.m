%% 事前準備
MovieNames = ["20240114_1", "20240116_1", "20240118_1", "20240120_1", "20240209_1", "20240215_1", "20240217_1", "20240222_1", "20240228_1", "20240228_2", "20240228_3", "20240229_1", "20240229_2"];
dir0 = pwd;
addpath(fullfile(dir0,"/Data"))
%% 撮影番号ごとにリストを読み取り、PlotTrajectoryを回す
for i = 1:length(MovieNames)
    %Info = readtable(append("\Data\",MovieNames(i), "-info.csv"), 'VariableNamingRule', 'preserve');
    Info = readtable(fullfile(dir0, "Data", append(MovieNames(i),"-info.csv")), 'VariableNamingRule', 'preserve');
        Info(Info.Error==1,:)=[];
    SampleName = append(MovieNames(i), "_", string(Info.SampleNumber));
    N = height(Info);
    for j = 1:N
        PlotTrajectory(SampleName(j))
    end
    close all
end


