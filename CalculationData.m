% アリの行動について各種の数値を計算し一つのファイルにまとめる関数

% main: FileInformationの読み込みと各撮影データにおけるCalcDataの実行
%   CalcData: 各種計算とデータの付加、保存(計算は下位関数に任せる)
%       ThinOutFrame: 24フレームに1フレームだけ取り出し
%       CalcDist: 中央からの距離を計算
%       CalcSpeed: 移動速度を計算

% 作成するファイル
%   _CalcData.csv: もろもろの計算結果をまとめたファイル
%   _ThinOutxy.csv: 1/24に間引いただけの座標情報。角度など他の項目の計算に使う



%% FileInformation.csvの読み込み、CalcData関数の実行

cd Data\
Info = readtable("FileInformation.csv");
arrayfun(@CalcData, Info.FileName)
cd ..\


function CalcData(Filename)
    Filename = string(Filename);

    % JumpCorrPosition, の読み込み
    Position = readmatrix(append(Filename, "-JumpCorrPosition.csv"));

    % 各種計算
    Position1s1f = ThinOutFrame(Position,1);
    Phero01 = (Position1s1f(:,1) < 0);
    Distance = CalcDist(Position1s1f);
    Speed = CalcSpeed(Position1s1f);


    %データの長さをそろえる
    Position1s1f_cut = Position1s1f(2:(length(Position1s1f)-1),:);
    Phero01_cut = Phero01(2:length(Phero01)-1);
    Distance_cut = Distance(2:(length(Distance)-1),:);
    Speed_cut = Speed(1:(length(Speed)-1),:);

    % 各種情報の付加
    Data = table;
    Data.x = Position1s1f_cut(:,1);
    Data.y = Position1s1f_cut(:,2);
    Data.Phero01 = Phero01_cut;
    Data.Distance = Distance_cut(:,1);
    Data.InOut = Distance_cut(:,2);
    Data.Speed = Speed_cut(:,1);
    Data.GoStop = Speed_cut(:,2);
    %Data.TurnAngle = Turn(:,1);
    %Data.Turn = Turn(:,2);

    % ファイルの保存
    writetable(Data, append(Filename, "_CalcData.csv"));
    writematrix(Position1s1f, append(Filename, "_ThinOutxy.csv"))

end

function ThinnedOutData = ThinOutFrame(Data,Rem)
    %Dataファイルからfpsで割った余りが1になる行のみ取り出して返す関数

    % 1秒1フレームだけ抜き出し
    fps = 24;

    ThinnedOutData = zeros(fix(length(Data)/fps)+1,size(Data,2));
    k=1;
    for i = 1:length(Data)
        if rem(i,fps)==Rem
            ThinnedOutData(k,:) = Data(i,:);
            k = k+1;
        end
    end

end

function Dist = CalcDist(Data)
    % 列方向の座標ファイルDataについて、原点からの距離を計算しInOut判定とともに返す

    % 中央からの距離の計算
    Dist = zeros(length(Data),1);
    for i = 1:length(Data)
        Dist(i) = norm(Data(i,:));
    end

    % 距離情報とInOut情報を結合
    % シャーレの内側何割を利用するか？
    a = 5.5/7; 
    %a = 27.5/35; %外側3.75mmを除去する場合
    %a = 1/4 
    InOutTS = a*500;

    InOut01 = (Dist<InOutTS);
    Dist = [Dist,InOut01];

end

function Speed = CalcSpeed(Data)
    % 列方向の座標ファイルDataについて、各データ間の距離（移動速度）を計算しGoStop判定とともに返す

    % 移動速度を計算する
    Speed = zeros(length(Data)-1, 1);
    for i = 1:length(Data)-1
        MoveVector = Data(i+1,:)-Data(i,:);
        Speed(i) = norm(MoveVector);
    end

    % 移動速度情報とGoStop情報を結合
    GoStopTS = 71.4;
    GoStop01 = (Speed>GoStopTS);
    Speed = [Speed, GoStop01];
end