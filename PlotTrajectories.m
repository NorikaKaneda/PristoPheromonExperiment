% PlotTrajectoryを連続で回すことでTrajectoryを一気に作成するプログラム

% 前提：下位のDataフォルダ中に動画あるいはLastFlameファイルと-positionファイルとFileInformation.csvがある
% やること：撮影番号とシャーレ番号からSampleNameを作成し、エラーでない場合にPlotTrajectoryを実行する

dir0 = pwd;
addpath(dir0)

%% 情報ファイルを読み込む

Info = readtable(fullfile(dir0, "Data", "FileInformation.csv"));

%% 各撮影ファイルでPlotTrajectoryを実行

arrayfun(@PlotTrajectory, Info.FileName)

