% 順番にファイルをめぐりPheroAreaあるいはNonPheroAreaを実行する

dir0 = pwd;
addpath(dir0)
cd Data\

%% 情報ファイルを読み込む

Info = readtable("FileInformation.csv");

%% 各撮影ファイルでPheroAreaあるいはNonPheroAreaを実行

N = height(Info);
for i = 1:N
    if Info.SDN(i)=="N"
        NonPheroArea(string(Info.FileName(i)))
    else
        PheroArea(string(Info.FileName(i)))
    end
end

cd ..\