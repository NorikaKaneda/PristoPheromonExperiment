%% FileInformationファイルの読み込み、CompensJump関数の実行

cd Data\
Info = readtable("FileInformation.csv");
arrayfun(@CompensJump, Info.FileName)
cd ..\





function CompensJump(Filename)

Filename = string(Filename);

% ジャンプの基準の閾値を設定
TS = 50;

% position.csvの読み込み
Position = readmatrix(append(Filename, "-RotPosition.csv"));

% 補正の実行
flag = 1; %ジャンプがあるときは1
while flag==1 % ジャンプがある間は回り続ける
    flag =0;
    for j = 1:size(Position,1)-1 % position中のすべてのフレームを巡回
        %このif内部を一度も通らなければflag==0となり脱出できる
        if norm(Position(j,:)-Position(j+1,:))>TS %ジャンプが存在すれば
            Position(j,:)=(Position(j-1,:)+Position(j+1,:))./2; %Position(j,:)を補正
            flag = 1;
        end
    end
end

% データの保存
writematrix(Position, append(Filename, "-JumpCorrPosition.csv"))

% 終了表示
disp(append(Filename, ": ジャンプ補正終了"))

end
