% ファイル名(撮影番号_シャーレ番号)の入力を受け、画像にトラッキング結果のプロットを重ねて表示・保存する
% 動画ファイル・トラッキングファイルの名前はYYYYMMDD_N1_N2.mp4(.csv)とすること（N1:その日の何番目の撮影か、N2:サンプルナンバー）
% 情報ファイルの名前はYYYYMMDD_N1.csvとすること

% 前提：下位のDataフォルダ中に動画あるいはLastFlameファイルと-positionファイルと-infoファイルがある ※WholeInfoは不要
% やること：DataからFilenameのデータを探し、最後のフレームにトラッキング結果を重ねて表示・保存する

function PlotTrajectory(Filename)

%Filename = "20240114_1_1"

dir0 = pwd;
addpath(fullfile(dir0,"/Data"))
MovieNum = extractBefore(Filename,11);


Info = readtable(append("\Data\",MovieNum, "-info.csv"), 'VariableNamingRule', 'preserve');
Pheromone = string(Info.Pheromone);
    Pheromone(ismissing(Pheromone)) = "なし";
Walker = string(Info.Walker);
PheroPlace = string(Info.PheroPlace);
    PheroPlace(ismissing(PheroPlace))="なし";
i = str2double(extractAfter(Filename, 11));




%% それぞれのサンプルごとに回すプログラム
    %最後のフレームのファイルがあるなら省略
    if exist(fullfile(dir0, "Data", append(Filename, "_LastFlame.png")))==0
        %動画から最後のフレームを抽出
        Movie = VideoReader("\Data\",append(Filename, ".mp4"));
        % 動画のフレーム数を取得
        num_frames = Movie.NumFrames;
        % 最後のフレームを読み込む
        last_frame = read(Movie, num_frames);
        % 最後のフレームを保存
        imwrite(last_frame, fullfile(dir0, "Data", append(Filename, "_LastFlame.png")));
    else
        last_frame = imread(fullfile(dir0, "Data", append(Filename, "_LastFlame.png")));
    end


    if Pheromone(i)==Walker(i)
        SDN="(同巣)";
    elseif Pheromone(i)=="なし"
        SDN="";
    else
        SDN="(異巣)";
    end
    PositionFile = fullfile(dir0, "Data", append(Filename, "-position.csv"));    
    position = readmatrix(string(PositionFile));
    
    F=figure(i);
    imshow(last_frame);
    hold on
    plot(position(:,2),position(:,3),'r-','LineWidth',1);
    txt = append(Filename, "  ",SDN );
    txtcell = {txt, append("Pheromone: ", Pheromone(i), ", ", PheroPlace(i)), append("Walker: ", Walker(i)),};
    t=text(10,100,txtcell,'interpreter','none');
    t.FontSize = 20;
    t.Color = [0.9,0.9,0.9];
    
    
    PhotoFile = fullfile(dir0, "Data", append(Filename, "_Trajectory.png"));
    FigFile = fullfile(dir0, "Data", append(Filename, "_Trajectory.fig"));
    %exportgraphics(gcf,PhotoFile) 
    saveas(F, PhotoFile)
    saveas(F, FigFile) 
    % pngで保存したものは画素数が変わってしまうため別プログラムで使用する際はfigファイルを利用すること。
    % ※MATLABの画像上の座標はピクセル基準であるため、画素数が変わると座標もずれる
    
    hold off
end