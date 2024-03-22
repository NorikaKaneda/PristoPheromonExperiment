%フォルダの中のデータをまとめて処理
%動画ファイル・トラッキングファイルの名前はYYYYMMDD_N1_N2.mp4(.csv)とすること（N1:その日の何番目の撮影か、N2:サンプルナンバー）
%情報ファイルの名前はYYYYMMDD_N2.csvとすること

cd("C:\Users\no5ri\OneDrive - The University of Tokyo\フォルダ\大学\授業課題等\卒業研究\実験記録\フェロモン\UMAtracker\撮影2\20240118_1")

MovieNum = string("20240118_1");

%情報ファイルの読み取り

Info = readtable(append(MovieNum, "-info.csv"));
    Info(Info.Error==1,:)=[];
SampleName = append(MovieNum, "_", string(Info.SampleNumber));
Pheromone = string(Info.Pheromone);
    Pheromone(ismissing(Pheromone)) = "なし";
Walker = string(Info.Walker);
PheroPlace = string(Info.PheroPlace);
    PheroPlace(ismissing(PheroPlace))="なし";
N = height(Info);

%%それぞれのサンプルごとに回すプログラム

for i = 1: N
        %動画から最後のフレームを抽出
        Movie = VideoReader(append(SampleName(i), ".mp4"));
        % 動画のフレーム数を取得
        num_frames = Movie.NumFrames;
        % 最後のフレームを読み込む
        last_frame = read(Movie, num_frames);
        % 最後のフレームを保存
        imwrite(last_frame, append(SampleName(i), "_LastFlame.png"));
    
    
        if Pheromone(i)==Walker(i)
            SorD="(同巣)";
        elseif Pheromone(i)=="なし"
            SorD="";
        else
            SorD="(異巣)";
        end
        Position = append(SampleName(i), "-position.csv");    
        position = readmatrix(string(Position));
        %info = "a";
        
        F=figure(i);
        imshow(last_frame);
        hold on
        p=plot(position(:,2),position(:,3),'r-','LineWidth',1);
        txt = append(SampleName(i), "  ",SorD );
        txtcell = {txt, append("Pheromone: ", Pheromone(i), ", ", PheroPlace(i)), append("Walker: ", Walker(i)),};
        t=text(10,100,txtcell,'interpreter','none');
        t.FontSize = 20;
        t.Color = [0.9,0.9,0.9];
        
        
        PhotoFile = append(SampleName(i), "_Trajectory.png");
        FigFile = append(SampleName(i), "_Trajectory.fig");
        %exportgraphics(gcf,PhotoFile) 
        saveas(F, PhotoFile)
        saveas(F, FigFile) 
        % pngで保存したものは画素数が変わってしまうため別プログラムで使用する際はfigファイルを利用すること。
        % ※MATLABの画像上の座標はピクセル基準であるため、画素数が変わると座標もずれる
        % 1280*720で保存！
        
        hold off
end
close all
clear all
cd ..