% 順番にファイルをめぐりEllipseCorrectionを実行する
addpath("C:\Users\no5ri\OneDrive - The University of Tokyo\フォルダ\大学\授業課題等\卒業研究\実験記録\フェロモン\UMAtracker\撮影2\")
%% 下位フォルダの名前を取得
Folders = dir('202*');
%% フォルダごとにループ
Save = 1; %Save番目のフォルダから始める。途中からやりたい場合に2以上を設定する

for i = Save:size(Folders,1)
    Movienum = {Folders.name};
    Movienum = string(Movienum(i));
    % フォルダに移動
    cd(Movienum)
    % 情報を読み取る
    Info = readtable(append(Movienum, "-info.csv"));
        Info(Info.Error==1,:)=[];
    %エラーじゃない場合のみループ
    for j = 1:size(Info)
        num = Info.SampleNumber(j);
        Filename = append(Movienum, "_", string(num));
        EllipseCorrection(Filename);
    end
    cd ..\
    close all
end