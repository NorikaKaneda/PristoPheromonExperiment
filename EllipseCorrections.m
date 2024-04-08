% 順番にファイルをめぐりEllipseCorrectionを実行する

% 前提：FileInformation.csvと各種EllipseCorrection用ファイルの存在
% できるもの：EllipseCorrectionファイル参照

dir0 = pwd;
addpath(dir0)
cd Data\

%% 情報ファイルを読み込む

Info = readtable("FileInformation.csv");

%% 各撮影ファイルでEllipseCorrectionを実行

arrayfun(@EllipseCorrection, Info.FileName)

cd ..\
